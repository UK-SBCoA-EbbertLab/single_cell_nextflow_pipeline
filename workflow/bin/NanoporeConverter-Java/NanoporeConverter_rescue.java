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

public class NanoporeConverter_rescue {

	private static final String REVERSE_MAP = "ACGTacgt";
	private static final String REVERSE_COMPLEMENT_MAP = "TGCATGCA";

	private static final List<Pattern> COMPILED_PATTERNS = Arrays.asList(
	// We don't modify the 8 at the beginning or end because there are extra
	// characters that we just take
//            ".{8}ATG.{6}GAG.{6}TCGAG.{8}",
//            ".{8}ATG.{5}GAG.{6}TCGAG.{8}", ".{8}ATG.{7}GAG.{6}TCGAG.{8}",
//            ".{8}ATG.{6}GAG.{5}TCGAG.{8}", ".{8}ATG.{6}GAG.{7}TCGAG.{8}",
//            ".{9}TG.{6}GAG.{6}TCGAG.{8}", ".{8}A.G.{6}GAG.{6}TCGAG.{8}", ".{8}AT.{7}GAG.{6}TCGAG.{8}",
//            ".{8}ATG.{7}AG.{6}TCGAG.{8}", ".{8}ATG.{6}G.G.{6}TCGAG.{8}", ".{8}ATG.{6}GA.{7}TCGAG.{8}",
//            ".{8}ATG.{6}GAG.{7}CGAG.{8}", ".{8}ATG.{6}GAG.{6}T.GAG.{8}", ".{8}ATG.{6}GAG.{6}TC.AG.{8}",
//            ".{8}ATG.{6}GAG.{6}TCG.G.{8}", ".{8}ATG.{6}GAG.{6}TCGA.{9}",
//            ".{8}A.TG.{6}GAG.{6}TCGAG.{8}", ".{8}AT.G.{6}GAG.{6}TCGAG.{8}", ".{8}ATG.{6}G.AG.{6}TCGAG.{8}",
//            ".{8}ATG.{6}GA.G.{6}TCGAG.{8}", ".{8}ATG.{6}GAG.{6}T.CGAG.{8}", ".{8}ATG.{6}GAG.{6}TC.GAG.{8}",
//            ".{8}ATG.{6}GAG.{6}TCG.AG.{8}", ".{8}ATG.{6}GAG.{6}TCGA.G.{8}" 

		// Perfect Pattern Match
		Pattern.compile("(.{8})(ATG)(.{6})(GAG)(.{6})(TCGAG)(.{8})"),

		// Barcode indels
		Pattern.compile("(.{8})(ATG)(.{5})(GAG)(.{6})(TCGAG)(.{8})"), 
		Pattern.compile("(.{8})(ATG)(.{7})(GAG)(.{6})(TCGAG)(.{8})"),
		Pattern.compile("(.{8})(ATG)(.{6})(GAG)(.{5})(TCGAG)(.{8})"), 
		Pattern.compile("(.{8})(ATG)(.{6})(GAG)(.{7})(TCGAG)(.{8})"),

		// Linker mismatches
		Pattern.compile("(.{8})(.TG)(.{6})(GAG)(.{6})(TCGAG)(.{8})"), 
		Pattern.compile("(.{8})(A.G)(.{6})(GAG)(.{6})(TCGAG)(.{8})"),
		Pattern.compile("(.{8})(AT.)(.{6})(GAG)(.{6})(TCGAG)(.{8})"), 
		Pattern.compile("(.{8})(ATG)(.{6})(.AG)(.{6})(TCGAG)(.{8})"),
		Pattern.compile("(.{8})(ATG)(.{6})(G.G)(.{6})(TCGAG)(.{8})"), 
		Pattern.compile("(.{8})(ATG)(.{6})(GA.)(.{6})(TCGAG)(.{8})"),
		Pattern.compile("(.{8})(ATG)(.{6})(GAG)(.{6})(.CGAG)(.{8})"), 
		Pattern.compile("(.{8})(ATG)(.{6})(GAG)(.{6})(T.GAG)(.{8})"),
		Pattern.compile("(.{8})(ATG)(.{6})(GAG)(.{6})(TC.AG)(.{8})"), 
		Pattern.compile("(.{8})(ATG)(.{6})(GAG)(.{6})(TCG.G)(.{8})"),
		Pattern.compile("(.{8})(ATG)(.{6})(GAG)(.{6})(TCGA.)(.{8})"),

		// Linker insertions
		Pattern.compile("(.{8})(A.TG)(.{6})(GAG)(.{6})(TCGAG)(.{8})"), 
		Pattern.compile("(.{8})(AT.G)(.{6})(GAG)(.{6})(TCGAG)(.{8})"),
		Pattern.compile("(.{8})(ATG)(.{6})(G.AG)(.{6})(TCGAG)(.{8})"), 
		Pattern.compile("(.{8})(ATG)(.{6})(GA.G)(.{6})(TCGAG)(.{8})"),
		Pattern.compile("(.{8})(ATG)(.{6})(GAG)(.{6})(T.CGAG)(.{8})"), 
		Pattern.compile("(.{8})(ATG)(.{6})(GAG)(.{6})(TC.GAG)(.{8})"),
		Pattern.compile("(.{8})(ATG)(.{6})(GAG)(.{6})(TCG.AG)(.{8})"), 
		Pattern.compile("(.{8})(ATG)(.{6})(GAG)(.{6})(TCGA.G)(.{8})"));

	public static String getBaseName(String fileName) {
		int firstDotIndex = fileName.indexOf('.');
		if (firstDotIndex == -1) {
			return fileName; // No extension found
		}
		return fileName.substring(0, firstDotIndex);
	}

	public static pBarcode check_forward_read(String f_read) {
		pBarcode f_barcode = new pBarcode();
		// Check to see if the line has the barcode pattern
		for (Pattern compiledPattern : COMPILED_PATTERNS) {
			Matcher matcher = compiledPattern.matcher(f_read);
			// If we find a barcode pattern match, create a barcode object and stop looking for a match
			if (matcher.find()) {
				f_barcode = new pBarcode(matcher, f_read);
				System.out.println("in forward match :" + f_barcode.getStartIndex() + "   " + f_barcode.getEndIndex());
				System.out.println("OGbarcode: " + f_barcode.ogBarcode + "  processedBarcode: " + f_barcode.pBarcode);
				break;
			}
		}
		return f_barcode; 
	}

	public static pBarcode check_reverse_complement_read(String f_read) {
		pBarcode rc_barcode = new pBarcode();
		String rc_read = getReverseComplement(f_read);

		// Check to see if the line has the barcode pattern
		for (Pattern compiledPattern : COMPILED_PATTERNS) {
			Matcher matcher = compiledPattern.matcher(rc_read);
			// If we find a barcode pattern match, create a barcode object and stop looking for a match
			if (matcher.find()) {
				rc_barcode = new pBarcode(matcher, rc_read);
				System.out.println("in reverse complement match :" + rc_barcode.getStartIndex() + "   " + rc_barcode.getEndIndex());
				System.out.println("OGbarcode: " + rc_barcode.ogBarcode + "  processedBarcode: " + rc_barcode.pBarcode);
				break;
			}
		}
		return rc_barcode;
	}

	public static void incrementValue(Map<String, Integer> map, String key) {
		map.put(key, map.getOrDefault(key, 0) + 1);
	}

	public static String compare_barcodes_and_determine_action(pBarcode f_barcode, pBarcode rc_barcode, String read, Map<String, Integer> theStats, 
			HashMap<String, Set<pBarcode>> tier1map, HashMap<String, Set<pBarcode>> tier2map, 
			HashMap<String, Set<pBarcode>> tier3map, HashMap<String, Set<pBarcode>> tier4map) {
		// this function will return strings for what action to take (f_barcode, rc_barcode, discard) 
		// as well as update the stats map
		// Both the barcodes are empty, this read didn't have a barcode
		if (f_barcode.isEmptyBarcode() && rc_barcode.isEmptyBarcode()) {
			incrementValue(theStats, "noPatternMatch");
			incrementValue(theStats, "nTotalDiscardedReads");
			return "discard";

		// if only the f_barcode was found
		} else if (rc_barcode.isEmptyBarcode()) {
			incrementValue(theStats, "fPatternMatch");
			// if the f_barcode is usable
			if (f_barcode.isUsableBarcode()) {
				incrementValue(theStats, "fUndecidedBarcode");
				// check first to see if the barcode is ambiguous
				if (f_barcode.isAmbiguous()) {
					// If the barcode is ambiguous, we want to try to rescue the barcode
					f_barcode.rescueBarcode(tier1map, tier2map, tier3map, tier4map);
					if (!f_barcode.isAmbiguous()) {
						if (read.length() > f_barcode.getEndIndex() + 51) {
							return "f_barcode";
						} else {
							incrementValue(theStats, "nTotalDiscardedReads");
							incrementValue(theStats, "nTotalTooShortReads");
							return "discard";
						}
					} else {
						incrementValue(theStats, "nTotalDiscardedReads");
						return "discard";
					}
				} else {
					if (read.length() > f_barcode.getEndIndex() + 51) {
						return "f_barcode";
					} else {
						incrementValue(theStats, "nTotalDiscardedReads");
						incrementValue(theStats, "nTotalTooShortReads");
						return "discard";
					}
				}
			} else {
				// the barcode is not usable, we need to throw this to the discarded file
				incrementValue(theStats, "nTotalDiscardedReads");
				return "discard";
			}

		// if only the rc_barcode was found
		} else if (f_barcode.isEmptyBarcode()) {
			incrementValue(theStats, "rcPatternMatch");
			// if the barcode is usable
			if (rc_barcode.isUsableBarcode()) {
				incrementValue(theStats, "rcUndecidedBarcode");
				// check first to see if the barcode is ambiguous
				if (rc_barcode.isAmbiguous()) {
					// If the barcode is ambiguous, we want to try to rescue the barcode
					rc_barcode.rescueBarcode(tier1map, tier2map, tier3map, tier4map);
					if (!rc_barcode.isAmbiguous()) {
						if (read.length() > rc_barcode.getEndIndex() + 51) {
							return "rc_barcode";
						} else {
							incrementValue(theStats, "nTotalDiscardedReads");
							incrementValue(theStats, "nTotalTooShortReads");
							return "discard";
						}

					} else {
						incrementValue(theStats, "nTotalDiscardedReads");
						return "discard";
					}
				} else {
					if (read.length() > rc_barcode.getEndIndex() + 51) {
						return "rc_barcode";
					} else {
						incrementValue(theStats, "nTotalDiscardedReads");
						incrementValue(theStats, "nTotalTooShortReads");
						return "discard";
					}
				}
			} else {
				// the barcode is not usable, we need to throw this to the discarded file
				incrementValue(theStats, "nTotalDiscardedReads");
				return "discard";
			}

		// if they are both NOT empty
		} else {
			incrementValue(theStats, "bothPatternMatch");
			if (!f_barcode.isUsableBarcode() && !rc_barcode.isUsableBarcode()) {
				incrementValue(theStats, "nTotalDiscardedReads");
				incrementValue(theStats, "bothBothDiscard");
				return "discard";
			} else if (f_barcode.isUsableBarcode() && rc_barcode.isUsableBarcode()) {
				incrementValue(theStats, "nTotalDiscardedReads");
				incrementValue(theStats, "bothBothUndecidedBarcode");
				return "discard";
			} else if (f_barcode.isUsableBarcode()) {
				incrementValue(theStats, "bothFUndecidedBarcode");
				if (f_barcode.isAmbiguous()) {
					// If the barcode is ambiguous, we want to try to rescue the barcode
					f_barcode.rescueBarcode(tier1map, tier2map, tier3map, tier4map);
					if (!f_barcode.isAmbiguous()) {
						if (read.length() > f_barcode.getEndIndex() + 51) {
							return "f_barcode";
						} else {
							incrementValue(theStats, "nTotalDiscardedReads");
							incrementValue(theStats, "nTotalTooShortReads");
							return "discard";
						}
					} else {
						incrementValue(theStats, "nTotalDiscardedReads");
						return "discard";
					}
				} else {
					if (read.length() > f_barcode.getEndIndex() + 51) {
						return "f_barcode";
					} else {
						incrementValue(theStats, "nTotalDiscardedReads");
						incrementValue(theStats, "nTotalTooShortReads");
						return "discard";
					}
				}
			} else if (rc_barcode.isUsableBarcode()) {
				incrementValue(theStats, "bothRcUndecidedBarcode");
				if (rc_barcode.isAmbiguous()) {
					// If the barcode is ambiguous, we want to try to rescue the barcode
					rc_barcode.rescueBarcode(tier1map, tier2map, tier3map, tier4map);
					if (!rc_barcode.isAmbiguous()) {
						if (read.length() > rc_barcode.getEndIndex() + 51) {
							return "rc_barcode";
						} else {
							incrementValue(theStats, "nTotalDiscardedReads");
							incrementValue(theStats, "nTotalTooShortReads");
							return "discard";
						}
					} else {
						incrementValue(theStats, "nTotalDiscardedReads");
						return "discard";
					}
				} else {
					if (read.length() > rc_barcode.getEndIndex() + 51) {
						return "rc_barcode";
					} else {
						incrementValue(theStats, "nTotalDiscardedReads");
						incrementValue(theStats, "nTotalTooShortReads");
						return "discard";
					}
				}
			} else {
				System.err.println("THIS SHOULD NEVER HAPPEN. LOOK IN COMPARE AND DETERMINE ACTION");
				System.exit(1);
			}

		} 
		return "ERROR";
	}

	public static void main(String[] args) {
		// Check if correct number of arguments provided
		if (args.length != 5) {
			System.err.println("Usage: NanoporeConverter_rescue <inputFastq> <tier1Map> <tier2Map> <tier3Map> <tier4Map>");
			System.exit(1);
		}

		File fastqFile = new File(Paths.get(args[0]).toAbsolutePath().toString());
		
		//Instantiate whitelist barcodes
		final HashMap<String, Set<pBarcode>> tier1map = pBarcode.loadMapFromFile(args[1]);
		final HashMap<String, Set<pBarcode>> tier2map = pBarcode.loadMapFromFile(args[2]);
		final HashMap<String, Set<pBarcode>> tier3map = pBarcode.loadMapFromFile(args[3]);
		final HashMap<String, Set<pBarcode>> tier4map = pBarcode.loadMapFromFile(args[4]);
		

		ExecutorService executor = Executors.newFixedThreadPool(Runtime.getRuntime().availableProcessors());
		List<Future<?>> futures = new ArrayList<>();
//
//        File[] fastqFiles = new File(sourceDir).listFiles((dir, name) -> name.endsWith(".fastq.gz"));

		// for (File fastqFile : fastqFiles) {
		// Submit each file processing as a separate task
		Future<?> future = executor.submit(() -> {
			try {
//			System.out.println(fastqFile);
				String fileName = fastqFile.getName();
				String baseFileName = getBaseName(fileName);

				// Prepare output files for writing
				String r1Out = baseFileName + "_standard_R1_rescued.fastq.gz";
				String r2Out = baseFileName + "_standard_R2_rescued.fastq.gz";

				try {
					File r1 = new File(r1Out);
					r1.createNewFile();
//				System.out.println(r1);
				} catch (Exception e) {
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

				convertNanopore(fastqFile, r1Out, r2Out, baseFileName, tier1map, tier2map, tier3map, tier4map);
			} catch (IOException e) {
				System.err.println("Error processing file: " + fastqFile.getName() + ". Error: " + e.getMessage());
				e.printStackTrace();
				System.exit(1);
			}
		});
		futures.add(future);
		// }

		// Wait for all tasks to complete
		for (Future<?> future1 : futures) {
			try {
				future1.get();
			} catch (InterruptedException | ExecutionException e) {
				System.err.println("Error in processing: " + e.getMessage());
				e.printStackTrace();
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
	 * 
	 * @param inputFastq - The FASTQ file to convert.
	 * @throws IOException if an error occurs during file operations.
	 */
	public static void convertNanopore(File fastqFile, String r1Out, String r2Out,
			String fileBaseName, HashMap<String, Set<pBarcode>> tier1map,
			HashMap<String, Set<pBarcode>> tier2map, HashMap<String, Set<pBarcode>> tier3map,
			HashMap<String, Set<pBarcode>> tier4map) throws IOException {
		/**
		 * Instantiate the buffers for the reads, barcode whitelist, and skipped reads
		 */
		List<String> r1Buffer = new ArrayList<>();
		List<String> r2Buffer = new ArrayList<>();
		List<String> discardedBuffer = new ArrayList<>();
		List<String> statsBuffer = new ArrayList<>();
//	    System.out.println(fastqFile);
			
		// STATS
		Map<String, Integer> stats = new HashMap<>();
		stats.put("noPatternMatch", 0);
		stats.put("rcPatternMatch", 0);
		stats.put("rcUndecidedBarcode", 0);
		stats.put("fPatternMatch", 0);
		stats.put("fUndecidedBarcode", 0);
		stats.put("bothPatternMatch", 0);
		stats.put("bothRcUndecidedBarcode", 0);
		stats.put("bothFUndecidedBarcode", 0);
		stats.put("bothBothUndecidedBarcode", 0);
		stats.put("bothBothDiscard", 0);
		stats.put("nTotalReads", 0);
		stats.put("nTotalSkippedReads", 0);
		stats.put("nTotalDiscardedReads", 0);
		stats.put("nTotalTooShortReads", 0);
		stats.put("nTotalKeptReads", 0);

		try (BufferedReader reader = new BufferedReader(
				new InputStreamReader(new GZIPInputStream(new FileInputStream(fastqFile))))) {
			String line;
			// keep track of which 'line' of the read we are on 
			// (each read in the fastq is made up of 4 lines)
			int idx = 0;
			String action = "";
			
			// Instantiate the barcode class
			pBarcode barcode = new pBarcode();

			String r1Sequence = "", r2Sequence = "", ogHeaderInfo = "";
//			boolean firstTime = true;

			// Keep track of how many reads we output from this fastq and add that number to the read header
			int outReadIndex = 1;

			// Processing each line of the file
			while ((line = reader.readLine()) != null) {
				// Check if the line is empty or only contains whitespace
				if (line.trim().isEmpty()) {
					System.out.println("empty line??");
					continue; // Skip further processing for this line
				}


				// idx == 0 is the header line
				if (idx == 0) {
					// We want to grab the header to save it for when we write the line to a file so that we can continue to track reads
					ogHeaderInfo = line.strip();
					System.out.println(ogHeaderInfo);
					incrementValue(stats, "nTotalReads");
					action = "";
					barcode = new pBarcode();
				}

				// idx == 1 is Sequence line
				else if (idx == 1) {
					// grab the whole line here in case we skip this read. We will want to put it in the skipped fastq
					r2Sequence = line.strip();

					pBarcode f_barcode = check_forward_read(line);
					pBarcode rc_barcode = check_reverse_complement_read(line);

					action = compare_barcodes_and_determine_action(f_barcode, rc_barcode, line, stats, tier1map, tier2map, tier3map, tier4map);
					
					if (action != "discard") {
						if (action == "f_barcode") {
							barcode = f_barcode;
						} else if (action == "rc_barcode") {
							barcode = rc_barcode;
							line = getReverseComplement(line);
						} else {
							System.out.println("Should I even be here....");
							throw new Exception("Action is something other than our 4 options");
						}

						// process the read
						r1Sequence = barcode.pBarcode + line.substring(barcode.getEndIndex(), barcode.getEndIndex() + 15);
								
						if (r1Sequence.length() < 54) {
							System.out.println(" LENGTH OF THE SEQUENCE: " + r1Sequence.length());
							System.out.println(barcode.toString());
							throw new Exception("ERROR: " + ogHeaderInfo + " barcode was not long enough. OG: "
									+ line.substring(barcode.getStartIndex() - 3, barcode.getEndIndex() + 12) + " P: " + r1Sequence);
						}

						// Get the R2 sequence 
						//r2Sequence = line.substring(0, barcode.getStartIndex()) + line.substring(barcode.getEndIndex() + 31).strip();	
						r2Sequence = line.substring(barcode.getEndIndex() + 31).strip();
					}
				}

				// idx == 3 is the quality line
				else if (idx == 3) {
					// add to the line header the file name the read is from and the number of the read that we are printing to the file
					String readHeader = ogHeaderInfo + " ConvertNanoporeInfo=file_" + fileBaseName + "_read_" + outReadIndex;

					if (action == "discard") {
						// if the read is discarded for whatever reason, add the read to the discardedBuffer
						discardedBuffer.add(readHeader);
						discardedBuffer.add(r2Sequence);
						discardedBuffer.add("+");
						discardedBuffer.add(line.strip());
						
					} else {
						// if the barcode was found on the reverse read, reverse the quality string
						if (action == "rc_barcode") {
							line = new StringBuilder(line).reverse().toString();
						}

						// grab the barcode quality and the rest of the line quality
						String r1Qual = barcode.getBarcodeQualFromString(line);
						//String r2Qual = line.substring(0, barcode.getStartIndex()) + line.substring(barcode.getEndIndex() + 31).trim();
						String r2Qual = line.substring(barcode.getEndIndex() + 31).trim();
						// Add r1 to buffer
						r1Buffer.add(readHeader);
						r1Buffer.add(r1Sequence);
						r1Buffer.add("+");
						r1Buffer.add(r1Qual);

						// Add r2 to buffer
						// the reversing here each time is intentional.
						r2Buffer.add(readHeader);
						r2Buffer.add(getReverseComplement(r2Sequence));
						r2Buffer.add("+");
						r2Buffer.add(new StringBuilder(r2Qual).reverse().toString());

//						if (firstTime) {
//							System.out.println(readHeader);
//							System.out.println(r1Sequence);
//							System.out.println(r1Qual);
//							System.out.println(r2Sequence);
//							System.out.println(r2Qual);
//
//							firstTime = false;
//						}

						outReadIndex += 1;
						incrementValue(stats, "nTotalKeptReads");
					}
					idx = -1;
				}
				idx = (idx + 1) % 4;
				if (!discardedBuffer.isEmpty() && stats.get("nTotalDiscardedReads") % 5000 == 0) {
					appendToFile(fileBaseName + "_discardedReads.fastq.dontuse.gz", String.join("\n", discardedBuffer) + "\n");
					discardedBuffer.clear();
				}
			}
			// after we are done going through all the reads, we want to add the skipped stats to their buffer 
			statsBuffer.add("Filename\tTotalReads\tTotalKeptReads\tTotalSkippedReads\tTotalDiscardedReads\tTotalTooShortReads\tnoPatternMatch\tfPatternMatch\tfUndecidedBarcode\trcPatternMatch\trcUndecidedBarcode\tbothPatternMatch\tbothBothDiscard\tbothFUndecidedBarcode\tbothRcUndecidedBarcode\tbothBothUndecidedBarcode");
			statsBuffer.add(fileBaseName + "\t" + stats.get("nTotalReads") + "\t" + stats.get("nTotalKeptReads") + "\t" + 
					stats.get("nTotalSkippedReads") + "\t" + stats.get("nTotalDiscardedReads") + "\t" + 
					stats.get("nTotalTooShortReads") + "\t" + stats.get("noPatternMatch") + "\t" + 
					stats.get("fPatternMatch") + "\t" + stats.get("fUndecidedBarcode") + "\t" + 
					stats.get("rcPatternMatch") + "\t" + stats.get("rcUndecidedBarcode") + "\t" + 
					stats.get("bothPatternMatch") + "\t" + stats.get("bothBothDiscard") + "\t" + 
					stats.get("bothFUndecidedBarcode") + "\t" + stats.get("bothRcUndecidedBarcode") + "\t" + 
					stats.get("bothBothUndecidedBarcode"));
			System.out.println(statsBuffer);
		} catch (IOException e) {
			System.err.println("Error processing file: " + fastqFile.getName() + ". Error: " + e.getMessage());
			e.printStackTrace();
			System.exit(1);
		} catch (Exception e) {
			System.err.println("Error processing file: " + fastqFile.getName() + ". Error: " + e.getMessage());
			e.printStackTrace();
			System.exit(1);
		}

		// Write buffers to output files
		synchronized (NanoporeConverter.class) {
			appendToFile(r1Out, String.join("\n", r1Buffer) + "\n");
			appendToFile(r2Out, String.join("\n", r2Buffer) + "\n");
			appendToFile(fileBaseName + "_discardedReads.fastq.dontuse.gz", String.join("\n", discardedBuffer) + "\n");
			appendToFile(fileBaseName + ".stats.gz", String.join("\n", statsBuffer) + "\n");
		}
	}

	/**
	 * Clears the content of a file.
	 * 
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
	 * 
	 * @param path    - The path to the file.
	 * @param content - The content to be appended.
	 * @throws IOException if an error occurs during the file operation.
	 */
	private static void appendToFile(String path, String content) throws IOException {
		try (GZIPOutputStream out = new GZIPOutputStream(new FileOutputStream(path, true))) {
			out.write(content.getBytes());
		}
	}

	/**
	 * Computes the reverse complement of a DNA sequence.
	 * 
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
