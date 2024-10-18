import java.nio.file.*;
import java.text.NumberFormat;
import java.util.*;
import java.util.zip.*;
import java.io.*;
import java.util.concurrent.*;

public class PIPSeqDemultiplexer {
	private static final Map<Path, StringBuilder> fileBuffers = new HashMap<>();
	private static final Map<Path, Integer> fileBufferCurrentReadCount = new HashMap<>();
	private static final Map<Path, Integer> fileBufferPrintedReadCount = new HashMap<>();

	public static void demultiplexPips(String fastqR1, String fastqR2, String barToKeep, String sampleName, String baseName) {

		Path path1 = Paths.get(fastqR1);
		Path path2 = Paths.get(fastqR2);
		Path barcodes = Paths.get(barToKeep);

		System.out.println(path1);
		System.out.println(path2);
		System.out.println(barcodes);

		if (Files.exists(path1) && Files.exists(path2) && Files.exists(barcodes)) {
			try {
				// long size1 = Files.size(path1);
				// long size2 = Files.size(path2);

				// System.out.println("Size of " + fastqR1 + ": " + size1 + " bytes");
				// System.out.println("Size of " + fastqR2 + ": " + size2 + " bytes");
				

				Set<String> barcodesToKeep = readBarcodes(barToKeep);

				processFiles(fastqR1, fastqR2, barcodesToKeep, sampleName, baseName);
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

		/*
		 * Write all buffers (cells).
		 */
		System.out.println("About to flush some buffers");
		writeRemainingLineCountsHistogramToFile(sampleName, baseName);
		flushAllBuffers();
	}

	public static Set<String> readBarcodes(String inputFilePath) {
		Set<String> barcodes = new HashSet<>();

		try (BufferedReader br = new BufferedReader(new FileReader(inputFilePath))) {
			String line;
			// Skip the header row
			br.readLine();

			while ((line = br.readLine()) != null) {
				String[] columns = line.split("\t");
				String barcode = columns[0];  // First column is the barcode
				barcodes.add(barcode);
			}
		} catch (IOException e) {
			e.printStackTrace();
		}

		return barcodes;
	}


	public static void processFiles(String fastqR1, String fastqR2, Set<String> barcodesToKeep, String sampleName, String baseName)
			throws IOException {

		String f1ReadName, f1Seq, f2ReadName;

		/*
		 * This String array should have four entries (one per line in a read)
		 */
		String[] f1Read, f2Read;

		try {
			BufferedReader file1Reader = new BufferedReader(
					new InputStreamReader(new GZIPInputStream(new FileInputStream(fastqR1))));
			BufferedReader file2Reader = new BufferedReader(
					new InputStreamReader(new GZIPInputStream(new FileInputStream(fastqR2))));

			int readsProcessed = 0;

			while (true) {

				if (readsProcessed % 1000 == 0) {
					System.out.println("Processed " + NumberFormat.getNumberInstance(Locale.US).format(readsProcessed)
							+ " reads (" + NumberFormat.getNumberInstance(Locale.US).format(readsProcessed * 4)
							+ " lines) in " + fastqR1 + "...");
				}

				f1Read = getNextRead(file1Reader);

				/*
				 * getNextRead will return null if we've reached the end
				 */
				if (f1Read == null) {
					break;
				}

				f2Read = getNextRead(file2Reader);

				f1ReadName = f1Read[0];
				f1Seq = f1Read[1];

				f2ReadName = f2Read[0];

				/*
				 * file1 and file2 should match exactly in number of reads and in the order. If
				 * they are ever out of sync, then something is wrong.
				 */
				if (!f1ReadName.equals(f2ReadName)) {
					throw new IOException("ERROR: Expected a read but did not find one. Check"
							+ " the input files are complete (i.e., not truncated).");
				}

				if (barcodesToKeep.contains(f1Seq.substring(0, 16))) {
					Path outputFile = Paths.get(sampleName + "_" + f1Seq.substring(0, 16) + "/" + sampleName + "_" + baseName + "_" + f1Seq.substring(0, 16) + ".fastq.gz");
					// Extract the parent directory
					Path directory = outputFile.getParent();
	
					// Create the directory if it doesn't exist
					Files.createDirectories(directory);
	
					addToBuffer(outputFile, f2Read);
				}
				readsProcessed++;

			}

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
		String line;
		line = fileReader.readLine();
		if (line != null) {
			linesForRead[0] = line;
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
	public static synchronized void addToBuffer(Path path, String[] lines) {
		try {
			StringBuilder buffer = fileBuffers.getOrDefault(path, new StringBuilder());
			Integer currentBufferReadCount = fileBufferCurrentReadCount.getOrDefault(path, 0);
			
			for (String line : lines) {
				buffer.append(line).append("\n");
			}

			/*
			 * Increment the number of reads in the buffer by one and store in HashMap.
			 */
			currentBufferReadCount++;
			fileBufferCurrentReadCount.put(path, currentBufferReadCount);

			fileBuffers.put(path, buffer);
		} catch (Exception e) {
			System.out.println(e.getMessage());
			System.exit(1);
		}
	}

	public static synchronized void flushBuffer(Path path, StringBuilder buffer) {
		// Ensure the file extension is .gz
		// if (!path.toString().endsWith(".gz")) {
		// path = Paths.get(path.toString() + ".gz");
		// }

		try (GZIPOutputStream gzipOutputStream = new GZIPOutputStream(new FileOutputStream(path.toFile()))) {
			// try (FileOutputStream outputStream = new FileOutputStream(path.toFile(),
			// true)) {
			// gzipOutputStream.write(buffer.toString().getBytes());
			gzipOutputStream.write(buffer.toString().getBytes());
			buffer.setLength(0);
			/*
			 * Track how many reads have been written to/from this buffer so far. Also reset
			 * the number of reads left in the buffer to zero.
			 */
			Integer bufferPrintedReadsSoFar = fileBufferPrintedReadCount.getOrDefault(path, Integer.valueOf(0)); // Get
																													// how
																													// many
																													// have
																													// already
																													// been
																													// printed
																													// to
																													// file
			Integer currentBufferReadCount = fileBufferCurrentReadCount.getOrDefault(path, Integer.valueOf(0)); // Get
																												// how
																												// many
																												// reads
																												// were
																												// in
																												// the
																												// buffer
																												// before
																												// printing
			fileBufferPrintedReadCount.put(path, bufferPrintedReadsSoFar + currentBufferReadCount); // Set the number of
																									// reads printed to
																									// be what was
																									// previously
																									// printed plus what
																									// was just printed
			fileBufferCurrentReadCount.put(path, 0); // Set the number of reads left in the buffer to zero.

		} catch (IOException e) {
			e.printStackTrace();
			System.exit(1);
		}
	}

	/**
	 * Flush remaining buffers where the total number of reads (including those
	 * previously printed) meet our inclusion criteria. This ensures we don't throw
	 * out any reads that remain if the given buffer has already been printed out.
	 */
	public static synchronized void flushAllBuffers() {

		int bufferPrintedReadsSoFar, currentBufferReadCount;
		System.out.println("In the flush buffer function");
		for (Map.Entry<Path, StringBuilder> entry : fileBuffers.entrySet()) {

			/*
			 * Get how many have already been printed to file. Must allow default of zero
			 * here because only those that have already printed to a file will be in this
			 * map.
			 */
			bufferPrintedReadsSoFar = fileBufferPrintedReadCount.getOrDefault(entry.getKey(), Integer.valueOf(0));
			/*
			 * Get how many reads are in the buffer. Do not allow a default here, because if
			 * if the current buffer doesn't already exist in the map, something has gone
			 * wrong elsewhere.
			 */
			currentBufferReadCount = fileBufferCurrentReadCount.get(entry.getKey());

			flushBuffer(entry.getKey(), entry.getValue());
		}
	}

	public static void writeRemainingLineCountsHistogramToFile(String sampleName, String baseName) {
		StringBuilder outputBuffer = new StringBuilder();

		// Add table header to output buffer
		outputBuffer.append("Buffer Name\tRead Count\n");

		try {

			System.out.println("\nNumber of buffers (cells) left: " + fileBuffers.size());

			FileWriter writer = new FileWriter(sampleName + "_" + baseName + "_counts_histogram.txt");
			writer.write("Num reads: Counts\n");

			// Map to store the histogram data
			Map<Integer, Integer> histogramData = new TreeMap<>();

			// Calculate line counts for each buffer and add to output buffer
			for (Map.Entry<Path, StringBuilder> entry : fileBuffers.entrySet()) {

				String bufferContent = entry.getValue().toString();
				int readCount = countLines(bufferContent) / 4;
				histogramData.put(readCount, histogramData.getOrDefault(readCount, 0) + 1);
			}

			for (Map.Entry<Integer, Integer> entry : histogramData.entrySet()) {
				writer.write(entry.getKey() + ": " + entry.getValue() + "\n");
			}

			writer.close();
		} catch (IOException e) {
			System.err.println("Error writing to file: " + e.getMessage());
			System.exit(1);
		}
	}

	public static int countLines(String buffer) {
		int lines = 0;
		int length = buffer.length();
		for (int i = 0; i < length; i++) {
			if (buffer.charAt(i) == '\n') {
				lines++;
			}
		}
		return lines;
	}

	public static void main(String[] args) {

		if (args.length != 5) {
			System.out.println("Usage: FastqFilter <fastqR1> <fastqR2> <barcodesToKeep> <sampleName> <baseName>");
			return;
		}

		String fastqR1 = Paths.get(args[0]).toAbsolutePath().toString();
		String fastqR2 = Paths.get(args[1]).toAbsolutePath().toString();
		System.out.println(fastqR1);
		System.out.println(fastqR2);
		String barToKeep = Paths.get(args[2]).toAbsolutePath().toString();
		String sampleName = args[3];
		String baseName = args[4];

		demultiplexPips(fastqR1, fastqR2, barToKeep, sampleName, baseName);
	}

}
