import java.nio.file.*;
import java.text.NumberFormat;
import java.util.*;
import java.util.stream.Collectors;
import java.util.zip.*;
import java.io.*;
import java.util.concurrent.*;

public class PIPSeqDemultiplexer {
	private static final Map<Path, StringBuffer> fileBuffers = new ConcurrentHashMap<>();
	private static final Map<Path, Integer> fileBufferCurrentReadCount = new ConcurrentHashMap<>();
	private static final Map<Path, Integer> fileBufferPrintedReadCount = new ConcurrentHashMap<>();

	private static final int MAX_BUFFER_SIZE_CHARS = 5 * 1024 * 1024; //Flush buffer if it exceeds 5MB

	public static void demultiplexPips(Path fastqR1, Path fastqR2, Set<String> barcodesToKeep, String sampleName) {

		System.out.println("Processing paired files:");
		System.out.println("Read 1: " + fastqR1);
		System.out.println("Read 2: " + fastqR2);

		if (Files.exists(fastqR1) && Files.exists(fastqR2)) {
			try {
				processFiles(fastqR1.toAbsolutePath().toString(), fastqR2.toAbsolutePath().toString(), barcodesToKeep, sampleName);
			} catch (IOException e) {
				System.out.println("I/O Exception occurred");
				e.printStackTrace();
				System.exit(1);
			} catch (Exception e) {
				System.out.println("Exception occurred");
				e.printStackTrace();
				System.exit(1);
			}

		} else {
			System.out.println("One or both files DNE");
			System.exit(1);
		}

	}

	public static Set<String> readBarcodes(String inputFilePath) {
		Set<String> barcodes = new HashSet<>();

		try (BufferedReader br = new BufferedReader(new FileReader(inputFilePath))) {
			String line;
			// Skip the header row
			br.readLine();

			while ((line = br.readLine()) != null) {
				String[] columns = line.split("\t");
				barcodes.add(columns[0]); //first column is the barcode
			}
		} catch (IOException e) {
			e.printStackTrace();
		}

		return barcodes;
	}


	public static void processFiles(String fastqR1, String fastqR2, Set<String> barcodesToKeep, String sampleName)
			throws IOException {

		try (BufferedReader file1Reader = new BufferedReader(new InputStreamReader(new GZIPInputStream(new FileInputStream(fastqR1))));
		     BufferedReader file2Reader = new BufferedReader(new InputStreamReader(new GZIPInputStream(new FileInputStream(fastqR2))))) {

			int readsProcessed = 0;
			int readsKept = 0;
			/*
			 * This String array should have four entries (one per line in a read)
			 */
			String[] f1Read, f2Read;

			while ((f1Read = getNextRead(file1Reader)) != null) {
				f2Read = getNextRead(file2Reader);
				
				/*
				 * file1 and file2 should match exactly in number of reads and in the order. If
				 * they are ever out of sync, then something is wrong.
				 */
				if (!f1Read[0].equals(f2Read[0])) {
					throw new IOException("ERROR: Expected a read but did not find one. Check"
							+ " the input files are complete (i.e., not truncated).");
				}

				String barcode = f1Read[1].substring(0,16);
				if (barcodesToKeep.contains(barcode)) {
					Path outputFile = Paths.get(sampleName + "_" + barcode + ".fastq");
					addToBuffer(outputFile, f2Read);
					readsKept++;
				}

				readsProcessed++;
				if (readsProcessed % 10000 == 0) {
					System.out.println("Processed " + NumberFormat.getNumberInstance(Locale.US).format(readsProcessed)
							+ " reads (" + NumberFormat.getNumberInstance(Locale.US).format(readsProcessed * 4)
							+ " lines) in " + fastqR1 + "...");
				}
			}

			System.out.println("Reads kept: " + readsKept);

		} catch (Exception e) {
			System.out.println(e.getMessage());
			System.exit(1);
		}
	}

	/**
	 * Get the next read given the file reader. Will return a String[] with four
	 * entries (one for each line of the read).
	 * 
	 * @param fileReader
	 * @return
	 * @throws IOException
	 */
	public static String[] getNextRead(BufferedReader fileReader) throws IOException {

		String[] linesForRead = new String[4];
		linesForRead[0] = fileReader.readLine();
		if (linesForRead[0] != null) {
			linesForRead[1] = fileReader.readLine();
			linesForRead[2] = fileReader.readLine();
			linesForRead[3] = fileReader.readLine();

			return linesForRead;
		}
		return null;
	}

	/**
	 * The method through which all processes add to the same buffer. This would be
	 * faster if we used a concurrent data structure rather than synchronizing the
	 * entire method, but this is working well enough.
	 * 
	 * @param path
	 * @param lines
	 */
	public static void addToBuffer(Path path, String[] lines) {
		fileBuffers.compute(path, (key, buffer) -> {
			if (buffer == null) buffer = new StringBuffer();
			synchronized (buffer) {
				for (String line: lines) {
					buffer.append(line).append("\n");
				}
		
				fileBufferCurrentReadCount.merge(path, 1, Integer::sum);

				// Check if buffer size exceeds the maximum size in bytes
				if (buffer.length() >= MAX_BUFFER_SIZE_CHARS) {
					flushBuffer(path, buffer);
				}
				return buffer;
			}
		});

	}

	public static void flushBuffer(Path path, StringBuffer buffer) {
		synchronized (buffer) {
			/*
			 * Write all buffers (cells).
			 */
			System.out.println("About to flush some buffers");
			try (FileOutputStream outputStream = new FileOutputStream(path.toFile(), true)) {
				// write buffer contents to file
				outputStream.write(buffer.toString().getBytes());
		
				// update read counts
				int currentBufferReadCount = fileBufferCurrentReadCount.getOrDefault(path, 0); 
				fileBufferPrintedReadCount.merge(path, currentBufferReadCount, Integer::sum); 

				// Set the number of reads left in the buffer to zero.
				fileBufferCurrentReadCount.put(path, 0); 
				buffer.setLength(0);
			} catch (IOException e) {
				e.printStackTrace();
				System.exit(1);
			}
		}
	}

	/**
	 * Flush remaining buffers where the total number of reads (including those
	 * previously printed) meet our inclusion criteria. This ensures we don't throw
	 * out any reads that remain if the given buffer has already been printed out.
	 */
	public static void flushAllBuffers() {
		System.out.println("Flushing all buffers...");
		fileBuffers.forEach((path, buffer) -> flushBuffer(path, buffer));
	}

	public static void writeBarcodesCountsToFile(String sampleName) {
		System.out.println("Writing barcode counts...");
		try(FileWriter writer = new FileWriter(sampleName  + "_barcode_counts.txt")) {
			writer.write("Barcode\tReads\n");
			fileBufferPrintedReadCount.forEach((path, count) -> {
				try {
					writer.write(path + "\t" + count + "\n");
				} catch (IOException e) {
					System.err.println("Error writing to file: " + e.getMessage());
					System.exit(1);
				}
			});
		} catch (IOException e) {
			System.err.println("Error writing barcode counts: " + e.getMessage());
			System.exit(1);
		}
	}

	public static void main(String[] args) {

		if (args.length != 4) {
			System.out.println("Usage: PIPSeqDemultiplexer <barcodesToKeep> <sampleName> <dir_to_fastqs> <numThreads>");
			return;
		}
		
		// Initialize passed parameters:
		// barToKeep --> the barcodes that we will be keeping
		// sampleName --> name of the sample we are demultiplexing for
		// fastqsDir --> the directory where the paired fastqs we will be demultiplexing are located
		// numThreads --> the number of threads we will be working with
		String barToKeep = Paths.get(args[0]).toAbsolutePath().toString();
		String sampleName = args[1];
		Path fastqsDir = Paths.get(args[2]);
		int numThreads = Integer.parseInt(args[3]);

		// Instantiate the executor
		ExecutorService executor = Executors.newFixedThreadPool(numThreads);

		try {
			Set<String> barcodesToKeep = readBarcodes(barToKeep);

			// Collect all files with .fastq or .fq extension
			Map<String, List<Path>> pairedFiles = Files.list(fastqsDir)
				.filter(file -> Files.isRegularFile(file) && (file.toString().endsWith("_R1.fastq.gz") || file.toString().endsWith("_R2.fastq.gz")))
				.collect(Collectors.groupingBy(file -> file.getFileName().toString().replaceAll("_R[12]\\.fastq\\.gz$", "")));

			List<Future<Void>> futures = new ArrayList<>();

			// Loop through each pair
			for (Map.Entry<String, List<Path>> entry : pairedFiles.entrySet()) {
				List<Path> pair = entry.getValue();
				if (pair.size() == 2) {
					final Path r1 = pair.get(0).getFileName().toString().contains("_R1") ? pair.get(0) : pair.get(1);
					final Path r2 = pair.get(0).getFileName().toString().contains("_R1") ? pair.get(1) : pair.get(0);
	
					// Perform your processing on r1 and r2 here
					futures.add(executor.submit(() -> {
						demultiplexPips(r1, r2, barcodesToKeep, sampleName);
						return null;
					}));
	
				} else {
					System.out.println("Unpaired file detected: " + entry.getKey());
				}
			}

			for (Future<Void> future : futures) {
				try {
					future.get();
				} catch (Exception e) {
					e.printStackTrace();
					System.out.println("FUTURE FAILED");
					System.exit(1);
				}
			}
			flushAllBuffers();
			writeBarcodesCountsToFile(sampleName);

			executor.shutdown();
			try {
				if (!executor.awaitTermination(60, TimeUnit.SECONDS)) {
					executor.shutdownNow();
				}
			} catch (InterruptedException e) {
				executor.shutdownNow();
			}

		} catch (IOException e) {
			e.printStackTrace();
			System.exit(1);
			
		} catch (Exception e) {
			e.printStackTrace();
			System.exit(1);
		}
	}
}
