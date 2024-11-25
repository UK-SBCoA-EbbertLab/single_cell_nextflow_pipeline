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

    private static final String REVERSE_MAP = "ACGTacgt";
    private static final String REVERSE_COMPLEMENT_MAP = "TGCATGCA";
    
    private static final List<String> PATTERNS = Arrays.asList(
            // We don't midify the 8 at the beginning or end because there are extra characters that we just take
//            ".{8}ATG.{6}GAG.{6}TCGAG.{8}",
            "(.{8})(ATG)(.{6})(GAG)(.{6})(TCGAG)(.{8})",

            // Barcode indels
            "(.{8})(ATG)(.{5})(GAG)(.{6})(TCGAG)(.{8})", "(.{8})(ATG)(.{7})(GAG)(.{6})(TCGAG)(.{8})",
            "(.{8})(ATG)(.{6})(GAG)(.{5})(TCGAG)(.{8})", "(.{8})(ATG)(.{6})(GAG)(.{7})(TCGAG)(.{8})",
//            ".{8}ATG.{5}GAG.{6}TCGAG.{8}", ".{8}ATG.{7}GAG.{6}TCGAG.{8}",
//            ".{8}ATG.{6}GAG.{5}TCGAG.{8}", ".{8}ATG.{6}GAG.{7}TCGAG.{8}",

            // Linker mismatches
            "(.{8})(.TG)(.{6})(GAG)(.{6})(TCGAG)(.{8})", "(.{8})(A.G)(.{6})(GAG)(.{6})(TCGAG)(.{8})", "(.{8})(AT.)(.{6})(GAG)(.{6})(TCGAG)(.{8})",
            "(.{8})(ATG)(.{6})(.AG)(.{6})(TCGAG)(.{8})", "(.{8})(ATG)(.{6})(G.G)(.{6})(TCGAG)(.{8})", "(.{8})(ATG)(.{6})(GA.)(.{6})(TCGAG)(.{8})",
            "(.{8})(ATG)(.{6})(GAG)(.{6})(.CGAG)(.{8})", "(.{8})(ATG)(.{6})(GAG)(.{6})(T.GAG)(.{8})", "(.{8})(ATG)(.{6})(GAG)(.{6})(TC.AG)(.{8})",
            "(.{8})(ATG)(.{6})(GAG)(.{6})(TCG.G)(.{8})", "(.{8})(ATG)(.{6})(GAG)(.{6})(TCGA.)(.{8})",
//            ".{9}TG.{6}GAG.{6}TCGAG.{8}", ".{8}A.G.{6}GAG.{6}TCGAG.{8}", ".{8}AT.{7}GAG.{6}TCGAG.{8}",
//            ".{8}ATG.{7}AG.{6}TCGAG.{8}", ".{8}ATG.{6}G.G.{6}TCGAG.{8}", ".{8}ATG.{6}GA.{7}TCGAG.{8}",
//            ".{8}ATG.{6}GAG.{7}CGAG.{8}", ".{8}ATG.{6}GAG.{6}T.GAG.{8}", ".{8}ATG.{6}GAG.{6}TC.AG.{8}",
//            ".{8}ATG.{6}GAG.{6}TCG.G.{8}", ".{8}ATG.{6}GAG.{6}TCGA.{9}",

            // Linker insertions
            "(.{8})(A.TG)(.{6})(GAG)(.{6})(TCGAG)(.{8})", "(.{8})(AT.G)(.{6})(GAG)(.{6})(TCGAG)(.{8})", "(.{8})(ATG)(.{6})(G.AG)(.{6})(TCGAG)(.{8})",
            "(.{8})(ATG)(.{6})(GA.G)(.{6})(TCGAG)(.{8})", "(.{8})(ATG)(.{6})(GAG)(.{6})(T.CGAG)(.{8})", "(.{8})(ATG)(.{6})(GAG)(.{6})(TC.GAG)(.{8})",
            "(.{8})(ATG)(.{6})(GAG)(.{6})(TCG.AG)(.{8})", "(.{8})(ATG)(.{6})(GAG)(.{6})(TCGA.G)(.{8})" 
//            ".{8}A.TG.{6}GAG.{6}TCGAG.{8}", ".{8}AT.G.{6}GAG.{6}TCGAG.{8}", ".{8}ATG.{6}G.AG.{6}TCGAG.{8}",
//            ".{8}ATG.{6}GA.G.{6}TCGAG.{8}", ".{8}ATG.{6}GAG.{6}T.CGAG.{8}", ".{8}ATG.{6}GAG.{6}TC.GAG.{8}",
//            ".{8}ATG.{6}GAG.{6}TCG.AG.{8}", ".{8}ATG.{6}GAG.{6}TCGA.G.{8}" 
        );

    public static String getBaseName(String fileName) {
        int firstDotIndex = fileName.indexOf('.');
        if (firstDotIndex == -1) {
            return fileName; // No extension found
        }
        return fileName.substring(0, firstDotIndex);
    }

    public static void main(String[] args) {
        // Check if correct number of arguments provided
        if (args.length != 1) {
            System.err.println("Usage: NanoporeConverter <inputFastq>");
            System.exit(1);
        }

        File fastqFile = new File(Paths.get(args[0]).toAbsolutePath().toString());

        ExecutorService executor = Executors.newFixedThreadPool(Runtime.getRuntime().availableProcessors());
        List<Future<?>> futures = new ArrayList<>();
//
//        File[] fastqFiles = new File(sourceDir).listFiles((dir, name) -> name.endsWith(".fastq.gz"));

//        if (fastqFiles == null || fastqFiles.length == 0) {
//            System.err.println("No .fastq.gz files found in the source directory.");
//            System.exit(1);
//        }

//	System.out.println("fastq files" + Arrays.toString(fastqFiles));

  //      for (File fastqFile : fastqFiles) {
            // Submit each file processing as a separate task
            Future<?> future = executor.submit(() -> {
                try {
//			System.out.println(fastqFile);
			String fileName = fastqFile.getName();
			String baseFileName = getBaseName(fileName);

        		// Prepare output files for writing
		        String r1Out = baseFileName + "_standard_R1.fastq.gz";
		        String r2Out = baseFileName + "_standard_R2.fastq.gz";
//			System.out.println(r1Out);
//			System.out.println(r2Out);

			try {
				File r1 = new File(r1Out);
				r1.createNewFile();
//				System.out.println(r1);
			} catch ( Exception e ) {
		    		System.err.println("An error occurred while creating the file: " + r1Out);
				e.printStackTrace();
            			System.exit(1);
			}
			try {
				File r2 = new File(r2Out);
				r2.createNewFile();
			} catch (Exception e) {
		    		System.err.println("An error occurred while creating the file: " + r2Out);
				e.printStackTrace();
            			System.exit(1);
			}

//			System.out.println(fastqFile);

		        // Clear or initialize output files
		 	try {
		    		clearFile(r1Out);
			} catch (IOException e) {
		    		System.err.println("An error occurred while clearing the file: " + r1Out);
		    		e.printStackTrace();
            			System.exit(1);
			}

			try {
		    		clearFile(r2Out);
			} catch (IOException e) {
		    		System.err.println("An error occurred while clearing the file: " + r2Out);
		    		e.printStackTrace();
            			System.exit(1);
			}

                    convertNanopore(fastqFile, r1Out, r2Out, baseFileName);
                } catch (IOException e) {
                    System.err.println("Error processing file: " + fastqFile.getName() + ". Error: " + e.getMessage());
		    e.printStackTrace();
            	    System.exit(1);
                }
            });
            futures.add(future);
    //    }

        // Wait for all tasks to complete
        for (Future<?> future1 : futures) {
            try {
                future1.get();
            } catch (InterruptedException | ExecutionException e) {
                System.err.println("Error in processing: " + e.getMessage());
                System.exit(1);
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
     * @param inputFastq - The FASTQ file to convert.
     * @throws IOException if an error occurs during file operations.
     */
    public static void convertNanopore(File fastqFile, String r1Out, String r2Out, String fileBaseName) throws IOException {
            List<String> r1Buffer = new ArrayList<>();
            List<String> r2Buffer = new ArrayList<>();
            List<String> skippedBuffer = new ArrayList<>();
            List<String> skippedStatsBuffer = new ArrayList<>();
            List<String> barcodeWhitelist = new ArrayList<>();
//	    System.out.println(fastqFile);

            try (BufferedReader reader = new BufferedReader(new InputStreamReader(new GZIPInputStream(new FileInputStream(fastqFile))))) {
                String line;
		// TODO: double check what the pattern needs to be for this
	//	int i = Integer.parseInt(fastqFile.getName().replaceAll("[^\\d]", ""));
		//int i = Integer.parseInt(fastqFile.getName().split("_")[1].replaceAll("[^\\d]", ""));
                int idx = 0;
                boolean skipRead = false;
                int r1StartPos = 0, r1EndPos = 0, r2StartPos = 0;
                String r1Sequence = "", r2Sequence = "", ogHeaderInfo = "";
                boolean reverse = false;
		boolean found = false;
		boolean firstTime = true;

		// keeping track of how many reads we are missing out on
		int n_total_reads = 0;
		int n_skipped_reads = 0;
		int n_ambiguous_barcode = 0;

		int inReadIndex = 0;
        	int outReadIndex = 1;

		pBarcode barcode = new pBarcode();

                // Processing each line of the file
                while ((line = reader.readLine()) != null) {
		    // idx == 0 is the header line
		    if (idx == 0) {
			ogHeaderInfo = line.substring(1);   
			n_total_reads += 1;
                	r1StartPos = 0;
			r1EndPos = 0; 
			r2StartPos = 0;
			found = false;
		    }

                    // idx == 1 is Sequence line
		    else if(idx == 1) {
                        reverse = false;
			r2Sequence = line.strip();
                        
			for (String pattern : PATTERNS) {
                            Pattern compiledPattern = Pattern.compile(pattern);
                            Matcher matcher = compiledPattern.matcher(line);
                            if (matcher.find()) {
				barcode = new pBarcode(matcher, line);
				r1StartPos = matcher.start();
				r1EndPos = matcher.end();
				System.out.println("in first match :" + r1StartPos + "   " + r1EndPos);
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
				    barcode = new pBarcode(matcher, line);
				    r1StartPos = matcher.start();
				    r1EndPos = matcher.end();
				    System.out.println("in second match :" + r1StartPos + "   " + r1EndPos);
				    found = true;
                                    break;
                                } else {
				    line = getReverseComplement(line);
				    reverse = false;
				}
                            }
                        }

                        if (found) {
		            if (!barcode.isAmbiguous) {
		    		r2StartPos = r1EndPos + 31;
				System.out.println("r1StartPos: " + r1StartPos + "\nr1EndPos: " + r1EndPos + "\nr2StartPos: " + r2StartPos + "\nline length: " +line.length());

			        if (line.length() > r2StartPos + 20) {
				    //TODO this needs to also grab the MI
                                    r1Sequence = barcode.pBarcode + line.substring(r1EndPos, r1EndPos + 15);

			            if (r1Sequence.length() < 54) {
				        System.out.println(" LENGTH OF THE SEQUENCE: " + r1Sequence.length());
				        System.out.println("ogTier 1: " + barcode.ogTier1 + "\nogTier 2: " + barcode.ogTier2 + "\nogTier 3: " + barcode.ogTier3 + "\nogTier 4: " + barcode.ogTier4);
				        System.out.println("Tier 1: " + barcode.tier1 + "\nTier 2: " + barcode.tier2 + "\nTier 3: " + barcode.tier3 + "\nTier 4: " + barcode.tier4);
				        System.out.println("l1: " + barcode.ogL1 + "\nl2: " + barcode.ogL2 + "\nl3: " + barcode.ogL3);
				        throw new Exception("ERROR: " + ogHeaderInfo + " barcode was not long enough. OG: " + line.substring(r1StartPos - 3, r1EndPos + 12) + " P: " + r1Sequence);
			            }
                                    //r1Sequence = line.substring(r1StartPos, r1EndPos);
			    
                                    r2Sequence = line.substring(r2StartPos).strip();
                                } else {
			            n_skipped_reads += 1;
                                    skipRead = true;
                                }
			    } else {
				n_skipped_reads += 1;
				n_ambiguous_barcode += 1;
				skipRead = true;
			    }
                        } else {
			    n_skipped_reads += 1;
                            skipRead = true;
                        }
                    }

		    // idx == 3 is the quality line
                    else if(idx == 3) {
                        if (!skipRead) {
                            if (reverse) {
                                line = new StringBuilder(line).reverse().toString();
                            }

                            String r1Qual = barcode.getBarcodeQualFromString(line);
                            String r2Qual = line.substring(r2StartPos).trim();

                            String readHeader = "@" + "file_" + fileBaseName + "_read_" + outReadIndex + " " + ogHeaderInfo;
				
                            r1Buffer.add(readHeader);
                            r1Buffer.add(r1Sequence);
                            r1Buffer.add("+");
                            r1Buffer.add(r1Qual);

                            r2Buffer.add(readHeader);
                            r2Buffer.add(getReverseComplement(r2Sequence));
                            r2Buffer.add("+");
                            r2Buffer.add(new StringBuilder(r2Qual).reverse().toString());
			    
			    barcodeWhitelist.add(barcode.pBarcode);

			    if (firstTime) {
				    System.out.println(readHeader);
				    System.out.println(r1Sequence);
				    System.out.println(r1Qual);
				    System.out.println(r2Sequence);
				    System.out.println(r2Qual);

				    firstTime = false;
			    }


                            outReadIndex += 1;
                        } else {
			    String readHeader = "@file_" + fileBaseName + ogHeaderInfo;
			    skippedBuffer.add(readHeader);
			    skippedBuffer.add(r2Sequence);
			    skippedBuffer.add("+");
			    skippedBuffer.add(line.strip());			    
			}
                        skipRead = false;
                        idx = -1;
                    }
                    idx = (idx + 1) % 4;
                }
	    
		skippedStatsBuffer.add("Filename\tTotalReads\tSkippedReads\tAmbiguousBarcodes");
    		skippedStatsBuffer.add(fileBaseName + "\t" + n_total_reads + "\t" + n_skipped_reads + "\t" + n_ambiguous_barcode);
		System.out.println(skippedStatsBuffer);
	    } catch (IOException e) {
                System.err.println("Error processing file: " + fastqFile.getName() + ". Error: " + e.getMessage());
                System.exit(1);
            } catch (Exception e) {
                System.err.println("Error processing file: " + fastqFile.getName() + ". Error: " + e.getMessage());
		System.exit(1);
	    }


            // Write buffers to output files
            synchronized (NanoporeConverter.class) {
            	appendToFile(r1Out, String.join("\n", r1Buffer) + "\n");
            	appendToFile(r2Out, String.join("\n", r2Buffer) + "\n");
		appendToFile(fileBaseName + "_skippedReads.fastq.dontuse.gz", String.join("\n", skippedBuffer) + "\n");
		appendToFile(fileBaseName + "_skippedReads.stats.gz", String.join("\n", skippedStatsBuffer) + "\n");
		appendToFile(fileBaseName + "_barcodeWhitelist.txt.gz", String.join("\n", barcodeWhitelist) + "\n");
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
            out.write(content.getBytes());
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
        return sb.reverse().toString().strip();
    }
}
