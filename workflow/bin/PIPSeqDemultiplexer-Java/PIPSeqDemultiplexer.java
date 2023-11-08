import java.nio.file.*;
import java.text.NumberFormat;
import java.util.*;
import java.util.zip.*;
import java.io.*;
import java.util.concurrent.*;


public class PIPSeqDemultiplexer {

//	public PIPSeqDemultiplexer() {
//		// TODO Auto-generated constructor stub
//	}
	

//	private static final int BUFFER_SIZE = 10 * 1024 * 1024 * 1024; // 10GB
//	private static final int BUFFER_SIZE = 10 * 1024 * 1024;
	private static final Map<Path, StringBuilder> fileBuffers = new HashMap<>();
	private static final Map<Path, Integer> fileBufferCurrentReadCount = new HashMap<>();
	private static final Map<Path, Integer> fileBufferPrintedReadCount = new HashMap<>();
	
	/* 
	 * All buffers with at least this many lines will be printed
	 * out.
	 */
	private static int MINIMUM_READ_COUNT = 500;


	public static void demultiplexPips(String fastqDir, String outputDir, String sampleName, int numThreads, int minimumReads) {
		int index = 1;
		
		MINIMUM_READ_COUNT = minimumReads;

		ExecutorService executor = Executors.newFixedThreadPool(numThreads);

		List<Future<Void>> futures = new ArrayList<>();

		while (true) {
			String r1Path = fastqDir + "/barcoded_" + index + "_R1.fastq.gz";
			String r2Path = fastqDir + "/barcoded_" + index + "_R2.fastq.gz";

			if (Files.exists(Paths.get(r1Path)) && Files.exists(Paths.get(r2Path))) {
				final int idx = index;
				futures.add(executor.submit(() -> {
					processFiles(idx, fastqDir, outputDir, sampleName);
					return null;
				}));
				index++;
			} else {
				break;
			}
		}

		for (Future<Void> future : futures) {
			try {
				future.get();
			} catch (Exception e) {
				e.printStackTrace();
			}
		}

		/*
		 * Write all buffers (cells) with at least the MINIMUM_READ_COUNT.
		 * This 
		 */
		writeRemainingLineCountsHistogramToFile(sampleName);
		flushAllBuffersAboveMinimumReadCount();

		executor.shutdown();
	}

	public static void processFiles(int index, String fastqDir, String outputDir, String sampleName) throws IOException {

		Path outputPath = Paths.get(outputDir);
		Files.createDirectories(outputPath);

		String r1Path = fastqDir + "/barcoded_" + index + "_R1.fastq.gz";
		String r2Path = fastqDir + "/barcoded_" + index + "_R2.fastq.gz";
		String f1ReadName, f1Seq, f2ReadName, outputFileName;
		Path outputFile;

		/*
		 * This String array should have four entries (one per line in a read)
		 */
		String[] f1Read, f2Read; 

		BufferedReader file1Reader = new BufferedReader(new InputStreamReader(new GZIPInputStream(new FileInputStream(r1Path))));
		BufferedReader file2Reader = new BufferedReader(new InputStreamReader(new GZIPInputStream(new FileInputStream(r2Path))));
			
		int readsProcessed = 0;

		while(true){
			
			if(readsProcessed % 1000000 == 0) {
				System.out.println("(Process " + index + ") Processed " +
						NumberFormat.getNumberInstance(Locale.US).format(readsProcessed) +
						" reads (" + NumberFormat.getNumberInstance(Locale.US).format(readsProcessed * 4) +
						" lines) in " + r1Path + "...");
			}

			f1Read = getNextRead(file1Reader);
			
			
			/*
			 * getNextRead will return null if we've reached the end
			 */
			if(f1Read == null) {
				break;
			}

			f2Read = getNextRead(file2Reader);

			f1ReadName = f1Read[0];
			f1Seq = f1Read[1];
//					f1Sep = f1Read[2];
//					f1Quality = f1Read[3];
			
			f2ReadName = f2Read[0];
//					f2Seq = f2Read[1];
//					f2Sep = f2Read[2];
//					f2Quality = f2Read[3];
			

			/*
			 * file1 and file2 should match exactly in number of reads and
			 * in the order. If they are ever out of sync, then something
			 * is wrong.
			 */
			if (!f1ReadName.equals(f2ReadName)) {
				throw new IOException("ERROR: Expected a read but did not find one. Check"
						+ " the input files are complete (i.e., not truncated).");
			}

			outputFileName = sampleName + "_" + f1Seq.substring(0, 16) + ".fastq";
			outputFile = outputPath.resolve(outputFileName);

			addToBuffer(outputFile, f2Read);
			readsProcessed++;
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
		if((line = fileReader.readLine()) != null) {
			linesForRead[0] = line;
			linesForRead[1] = fileReader.readLine();
			linesForRead[2] = fileReader.readLine();
			linesForRead[3] = fileReader.readLine();
			
			return linesForRead;
		}
		
		return null;
	}

	/**
	 * The method through which all processes add to the same buffer. This would
	 * be faster if we used a concurrent data structure rather than synchronizing 
	 * the entire method, but this is working well enough.
	 * 
	 * @param path
	 * @param lines
	 */
	public static synchronized void addToBuffer(Path path, String[] lines) {
		StringBuilder buffer = fileBuffers.getOrDefault(path, new StringBuilder());
		Integer currentBufferReadCount = fileBufferCurrentReadCount.getOrDefault(path, Integer.valueOf(0));
		
		for (String line : lines) {
			buffer.append(line).append("\n");
		}
		
		/*
		 * Increment the number of reads in the buffer by one and store in
		 * HashMap.
		 */
		currentBufferReadCount++; 
		fileBufferCurrentReadCount.put(path, currentBufferReadCount);

//		if (buffer.length() >= BUFFER_SIZE) {
		
		/*
		 * If the buffer has reached the minimum read count to be used, go ahead
		 * and flush it.
		 */
		if (currentBufferReadCount >= MINIMUM_READ_COUNT) {
			flushBuffer(path, buffer);
		} else {
			fileBuffers.put(path, buffer);
		}
	}

	public static synchronized void flushBuffer(Path path, StringBuilder buffer) {
		try {
			
			// Ensure the file extension is .gz
	        // if (!path.toString().endsWith(".gz")) {
	        //     path = Paths.get(path.toString() + ".gz");
	        // }

	        //try (GZIPOutputStream gzipOutputStream = new GZIPOutputStream(new FileOutputStream(path.toFile(), true))) {
	        try (FileOutputStream outputStream = new FileOutputStream(path.toFile(), true)) {
	            //gzipOutputStream.write(buffer.toString().getBytes());
	            outputStream.write(buffer.toString().getBytes());
	            buffer.setLength(0);
	        }
	        
	        /*
	         * Track how many reads have been written to/from this buffer so
	         * far. Also reset the number of reads left in the buffer to zero.
	         */
			Integer bufferPrintedReadsSoFar = fileBufferPrintedReadCount.getOrDefault(path, Integer.valueOf(0)); // Get how many have already been printed to file
			Integer currentBufferReadCount = fileBufferCurrentReadCount.getOrDefault(path, Integer.valueOf(0));  // Get how many reads were in the buffer before printing
			fileBufferPrintedReadCount.put(path, bufferPrintedReadsSoFar + currentBufferReadCount);              // Set the number of reads printed to be what was previously printed plus what was just printed
			fileBufferCurrentReadCount.put(path, 0);															 // Set the number of reads left in the buffer to zero.

		} catch (IOException e) {
			e.printStackTrace();
		}
	}


	/**
	 * Flush remaining buffers where the total number of reads (including those
	 * previously printed) meet our inclusion criteria. This ensures we don't 
	 * throw out any reads that remain if the given buffer has already been
	 * printed out.
	 */
	public static synchronized void flushAllBuffersAboveMinimumReadCount() {
//		String bufferContent;
		int bufferPrintedReadsSoFar, currentBufferReadCount;
		for (Map.Entry<Path, StringBuilder> entry: fileBuffers.entrySet()) {

			/* 
			 * Get how many have already been printed to file. Must allow default
			 * of zero here because only those that have already printed to a file
			 * will be in this map.
			 */
			bufferPrintedReadsSoFar = fileBufferPrintedReadCount.getOrDefault(entry.getKey(), Integer.valueOf(0));

			/* 
			 * Get how many reads are in the buffer. Do not allow a default here,
			 * because if if the current buffer doesn't already exist in the map,
			 * something has gone wrong elsewhere.
			 */
			currentBufferReadCount = fileBufferCurrentReadCount.get(entry.getKey());  

			/*
			 * If the number of reads already printed plus the number of reads
			 * left in the buffer meet inclusion criteria, flush the buffer.
			 */
			if(bufferPrintedReadsSoFar + currentBufferReadCount >= MINIMUM_READ_COUNT) {
				flushBuffer(entry.getKey(), entry.getValue());
			}

//			bufferContent = entry.getValue().toString();
//			readCount = countLines(bufferContent) / 4;
//			
//			if(readCount >= MINIMUM_READ_COUNT) {
//				flushBuffer(entry.getKey(), entry.getValue());
//			}
		}
	}
	
	public static void writeRemainingLineCountsHistogramToFile(String sampleName) {
		StringBuilder outputBuffer = new StringBuilder();

		// Add table header to output buffer
		outputBuffer.append("Buffer Name\tRead Count\n");

		try {
			
			System.out.println("\nNumber of buffers (cells) left: " + fileBuffers.size());

			FileWriter writer = new FileWriter(sampleName + "_counts_histogram.txt");
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
		}
	}

	
	/**
	 * Write the total line count for all remaining buffers. This winds
	 * up being easily >800,000 files/buffers/cells and the file is unwieldy.
	 * Printing the histogram is much more feasible.
	 */
//	public static void writeRemainingLineCountsToFile() {
//		StringBuilder outputBuffer = new StringBuilder();
//
//		// Add table header to output buffer
//		outputBuffer.append("Buffer Name\tLine Count\n");
//		// outputBuffer.append("------------|-----------\n");
//
//		try {
//			
//			System.out.println("\nNumber of buffers (cells) left: " + fileBuffers.size());
//
//			FileWriter writer = new FileWriter("line_counts.txt");
//			
//			// Calculate line counts for each buffer and add to output buffer
//			for (Map.Entry<Path, StringBuilder> entry : fileBuffers.entrySet()) {
//				
//				String bufferName = entry.getKey().getFileName().toString();
//				String bufferContent = entry.getValue().toString();
//				int lineCount = countLines(bufferContent);
//
//				outputBuffer.append(String.format("%-12s\t%d%n", bufferName, lineCount));
//				
//				if(outputBuffer.length() >= BUFFER_SIZE) {
//					writer.write(outputBuffer.toString());
//				}
//			}
//			
//			// Write the entire buffer to a file
//			writer.write(outputBuffer.toString());
//			writer.close();
//		} catch (IOException e) {
//			System.err.println("Error writing to file: " + e.getMessage());
//		}
//	}
	
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
	        System.out.println("Usage: FastqFilter <fastqDir> <outputDir> <fileName> <numThreads> <minimumReadCount>");
	        return;
	    }

	    String fastqDir = Paths.get(args[0]).toAbsolutePath().toString();
	    String outputDir = Paths.get(args[1]).toAbsolutePath().toString();
	    String sampleName = args[2];
	    int numThreads, minimumReads;
	    
	    try {
	        numThreads = Integer.parseInt(args[3]);
	        minimumReads = Integer.parseInt(args[4]);
	    } catch (NumberFormatException e) {
	        System.out.println("Invalid number of threads specified. Please provide an integer.");
	        return;
	    }
	    
		demultiplexPips(fastqDir, outputDir, sampleName, numThreads, minimumReads);
	}


}
