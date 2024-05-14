import java.io.*;
import java.nio.file.*;
import java.util.*;
import java.util.regex.*;
import java.util.zip.GZIPInputStream;
import java.util.zip.GZIPOutputStream;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.TimeUnit;

public class NanoporeConverter {

    private static final int BUFFER_SIZE = 100000;
    private static final String REVERSE_MAP = "ACGTacgt";
    private static final String REVERSE_COMPLEMENT_MAP = "TGCATGCA";
    
    private static final List<String> PATTERNS = Arrays.asList(

            ".{8}ATG.{6}GAG.{6}TCGAG.{8}",

            // Barcode indels
            ".{8}ATG.{5}GAG.{6}TCGAG.{8}", ".{8}ATG.{7}GAG.{6}TCGAG.{8}",
            ".{8}ATG.{6}GAG.{5}TCGAG.{8}", ".{8}ATG.{6}GAG.{7}TCGAG.{8}",

            // Linker mismatches
            ".{9}TG.{6}GAG.{6}TCGAG.{8}", ".{8}A.G.{6}GAG.{6}TCGAG.{8}", ".{8}AT.{7}GAG.{6}TCGAG.{8}",
            ".{8}ATG.{7}AG.{6}TCGAG.{8}", ".{8}ATG.{6}G.G.{6}TCGAG.{8}", ".{8}ATG.{6}GA.{7}TCGAG.{8}",
            ".{8}ATG.{6}GAG.{7}CGAG.{8}", ".{8}ATG.{6}GAG.{6}T.GAG.{8}", ".{8}ATG.{6}GAG.{6}TC.AG.{8}",
            ".{8}ATG.{6}GAG.{6}TCG.G.{8}", ".{8}ATG.{6}GAG.{6}TCGA.{9}",

            // Linker insertions
            ".{8}A.TG.{6}GAG.{6}TCGAG.{8}", ".{8}AT.G.{6}GAG.{6}TCGAG.{8}", ".{8}ATG.{6}G.AG.{6}TCGAG.{8}",
            ".{8}ATG.{6}GA.G.{6}TCGAG.{8}", ".{8}ATG.{6}GAG.{6}T.CGAG.{8}", ".{8}ATG.{6}GAG.{6}TC.GAG.{8}",
            ".{8}ATG.{6}GAG.{6}TCG.AG.{8}", ".{8}ATG.{6}GAG.{6}TCGA.G.{8}" 
        );

    public static void main(String[] args) {
        // Check if correct number of arguments provided
        if (args.length != 2) {
            System.err.println("Usage: NanoporeConverter <sourceDir> <outputDir>");
            System.exit(1);
        }

        String sourceDir = Paths.get(args[0]).toAbsolutePath().toString();
        String outputDir = Paths.get(args[1]).toAbsolutePath().toString();

        ExecutorService executor = Executors.newFixedThreadPool(Runtime.getRuntime().availableProcessors());
        List<Future<?>> futures = new ArrayList<>();

        File[] fastqFiles = new File(sourceDir).listFiles((dir, name) -> name.endsWith(".fastq"));

        if (fastqFiles == null || fastqFiles.length == 0) {
            System.err.println("No .fastq.gz files found in the source directory.");
            return;
        }

        // Prepare output files for writing
        String r1Out = outputDir + File.separator + "standard_R1.fastq.gz";
        String r2Out = outputDir + File.separator + "standard_R2.fastq.gz";

        // Clear or initialize output files
 	try {
    		clearFile(r1Out);
	} catch (IOException e) {
    		System.err.println("An error occurred while clearing the file: " + r1Out);
    		e.printStackTrace();
	}

	try {
    		clearFile(r2Out);
	} catch (IOException e) {
    		System.err.println("An error occurred while clearing the file: " + r2Out);
    		e.printStackTrace();
	}

        for (File fastqFile : fastqFiles) {
            // Submit each file processing as a separate task
            Future<?> future = executor.submit(() -> {
                try {
                    convertNanopore(fastqFile, r1Out, r2Out);
                } catch (IOException e) {
                    System.err.println("Error processing file: " + fastqFile.getName() + ". Error: " + e.getMessage());
                }
            });
            futures.add(future);
        }

        // Wait for all tasks to complete
        for (Future<?> future : futures) {
            try {
                future.get();
            } catch (InterruptedException | ExecutionException e) {
                System.err.println("Error in processing: " + e.getMessage());
            }
        }

        // Shutdown executor
        executor.shutdown();
        try {
            if (!executor.awaitTermination(60, TimeUnit.SECONDS)) {
                executor.shutdownNow();
            }
        } catch (InterruptedException e) {
            executor.shutdownNow();
        }
	
    }

    /**
     * Converts Nanopore FASTQ files to standard paired-end Illumina format.
     * @param sourceDir - The directory containing the input FASTQ files.
     * @param outputDir - The directory where the output files will be saved.
     * @throws IOException if an error occurs during file operations.
     */
    public static void convertNanopore(File fastqFile, String r1Out, String r2Out) throws IOException {
            List<String> r1Buffer = new ArrayList<>();
            List<String> r2Buffer = new ArrayList<>();
	    int bufferCount = 0;

            try (BufferedReader reader = new BufferedReader(new InputStreamReader(new FileInputStream(fastqFile)))) {
                String line;
		int i = Integer.parseInt(fastqFile.getName().split("_")[1].replaceAll("[^\\d]", ""));
                int idx = 0;
                boolean skipRead = false;
                int r1StartPos = 0, r1EndPos = 0, r2StartPos = 0;
                String r1Sequence = "", r2Sequence = "";
                boolean reverse = false;
		boolean found = false;

		int inReadIndex = 0;
        	int outReadIndex = 1;

                // Processing each line of the file
                while ((line = reader.readLine()) != null) {
                    // idx == 1 is Sequence line
		    if(bufferCount % 10000 == 0 && idx == 1){ 
		    	System.out.println("bufferCount: " + bufferCount);
		    }
                    if(idx == 1) {
			if (++bufferCount >= BUFFER_SIZE) {
				System.out.println("WRITING");
                        	appendToFile(r1Out, String.join("\n", r1Buffer) + "\n");
                        	appendToFile(r2Out, String.join("\n", r2Buffer) + "\n");
                    		r1Buffer.clear();
                    		r2Buffer.clear();
                    		bufferCount = 0; // Reset buffer count
                	}
                        reverse = false;
                        //Matcher matchr = null;
                        for (String pattern : PATTERNS) {
                            Pattern compiledPattern = Pattern.compile(pattern);
                            Matcher matcher = compiledPattern.matcher(line);
                            if (matcher.find()) {
				r1StartPos = matcher.start();
				found = true;
                                break;
                            }
                        }
			
                        if (!found) {
                            line = getReverseComplement(line);
                            reverse = true;
                            for (String pattern : PATTERNS) {
                                Pattern compiledPattern = Pattern.compile(pattern);
                                Matcher matcher = compiledPattern.matcher(line);

                                if (matcher.find()) {
				    r1StartPos = matcher.start();
				    found = true;
                                    break;
                                }
                            }
                        }

                        if (found) {
                            r1EndPos = r1StartPos + 54;
                            r2StartPos = r1EndPos + 31;
			    if(r1StartPos < 0){
				    skipRead = true;
			    }
                            if (line.length() > r1EndPos) {
                                r1Sequence = line.substring(r1StartPos, r1EndPos);
                            } else {
                                skipRead = true;
                            }	
                            if (line.length() > r2StartPos + 20) {
                                r2Sequence = line.substring(r2StartPos).strip();
                            } else {
                                skipRead = true;
                            }
                        } else {
                            skipRead = true;
                        }
                    }

                    else if(idx == 3) {
                        if (!skipRead) {
                            if (reverse) {
                                line = new StringBuilder(line).reverse().toString();
                            }

                            String r1Qual = line.substring(r1StartPos, r1EndPos).trim();
                            String r2Qual = line.substring(r2StartPos).trim();

                            String readHeader = "@" + "file_" + i + "_read_" + outReadIndex;
				
                            r1Buffer.add(readHeader);
                            r1Buffer.add(r1Sequence);
                            r1Buffer.add("+");
                            r1Buffer.add(r1Qual);

                            r2Buffer.add(readHeader);
                            r2Buffer.add(getReverseComplement(r2Sequence));
                            r2Buffer.add("+");
                            r2Buffer.add(new StringBuilder(r2Qual).reverse().toString());

                            outReadIndex += 1;
                        }
                        skipRead = false;
                        idx = -1;
                    }
                    idx = (idx + 1) % 4;
                }
	    } catch (IOException e) {
                System.err.println("Error processing file: " + fastqFile.getName() + ". Error: " + e.getMessage());
            }

            // Write buffers to output files
            synchronized (NanoporeConverter.class) {
            	appendToFile(r1Out, String.join("\n", r1Buffer) + "\n");
            	appendToFile(r2Out, String.join("\n", r2Buffer) + "\n");
            }
    }

    /**
     * Clears the content of a file.
     * @param path - The path to the file to be cleared.
     * @throws IOException if an error occurs during the file operation.
     */
    private static void clearFile(String path) throws IOException {
        try (FileOutputStream clear = new FileOutputStream(path)) {
            clear.write("".getBytes());
        }
    }

    /**
     * Appends content to a file.
     * @param path - The path to the file.
     * @param content - The content to be appended.
     * @throws IOException if an error occurs during the file operation.
     */
    private static void appendToFile(String path, String content) throws IOException {
        try (GZIPOutputStream out = new GZIPOutputStream(new FileOutputStream(path, true))){
	    System.out.println("WRITING");
            out.write(content.getBytes());
	    out.flush();
        }
    }

    /**
     * Computes the reverse complement of a DNA sequence.
     * @param seq - The input DNA sequence.
     * @return The reverse complement of the input sequence.
     */
    private static String getReverseComplement(String seq) {
        StringBuilder sb = new StringBuilder();
        for (char c : seq.toCharArray()) {
            int idx = REVERSE_MAP.indexOf(c);
            sb.append(idx >= 0 ? REVERSE_COMPLEMENT_MAP.charAt(idx) : c);
        }
        return sb.reverse().toString();
    }
}
