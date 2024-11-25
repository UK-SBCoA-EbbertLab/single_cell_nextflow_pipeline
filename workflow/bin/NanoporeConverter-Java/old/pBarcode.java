import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.HashSet;
import java.util.Set;
import java.io.*;
import java.util.Objects;
import java.util.zip.GZIPOutputStream;
import java.util.zip.GZIPInputStream;


/**
 * 
 *
 *
 *
 *
 */
public class pBarcode {

	public String pBarcode;
	public String ogBarcode;
	public int length;
	public int ogLength;

	private List<String> ogTiersAndLinkers;

	public String tier1;
	public String tier2;
	public String tier3;
	public String tier4;

	public boolean tier1isAmb;
	public boolean tier2isAmb;
	public boolean tier3isAmb;
	public boolean tier4isAmb;


	private int start;
	private int end;

	private static final String[] tier1Array = { "AGAAACCA", "CCTTTACA", "TACCTCCC", "ACCTTCCC", "AAACTACA", "ATTACCTT",
			"GATTTCCC", "CTCCTCCA", "TCTAAACT", "AAGTCCAA", "TCCGACAC", "GAGAAACC", "ACCCTCAA", "AGACCTCA", "GATTACTT",
			"CCACCTCT", "TAACTTCT", "TTCCCTAT", "CTGTTTCC", "TCCTATAT", "CACTAACC", "CCCTGTTT", "TTGACCCA", "TCTATTCC",
			"GTGTCACC", "AGGACACA", "CTTTGGAC", "CCTATTTA", "TAGTCTCT", "CTTTCACT", "ATCCCACC", "ATACTCTC", "CAATTCTC",
			"ATTTCCAT", "CAAGGGTT", "GTCTTCCT", "CTGGGTAT", "CAAACATT", "CAGGTTGC", "GTCCTTGC", "GATTGGGA", "TTGGGTCC",
			"TACCCTGC", "GAGGGTCA", "AGAGGTGC", "CTGTGACC", "GTCCACTA", "CTTAGTGT", "GAGTGTAC", "GTTGTCCG", "TCTTTGAC",
			"CCTTTGTC", "GTGAACTC", "AAGGGACC", "AATACATC", "AAACAAAC", "ACTACCCG", "GATGTGGC", "ACCCATGC", "ACCAACCC",
			"AAAGAGGC", "AAGTTGTC", "GAATCCCA", "CTTTATCC", "GTAAACAA", "CTTCTACG", "CCATCCAC", "CCTCATGA", "CTAGACTA",
			"ACCAGTTT", "AGTTGAAC", "AGTTTGTA", "CCCTCTTG", "GAGGAGTG", "TCCCTGGA", "AAATTCCG", "GAAATACG", "AGTCACAA",
			"TACTGAAT", "AGACGAGG", "CCTACGCT", "AAACCGCC", "AATATGAC", "GACACCTG", "CTGTTGTG", "CTAACGCC", "TTCACTGG",
			"GTCTAATC", "TATGTGAA", "GTGAGGCA", "TATCTGTC", "GTGGTGCT", "ATACACCC", "CCCTTGCA", "TATCCACG",
			"GCCTGGTA" };
	private static final String[] tier2Array = { "AGGAAA", "AGGTAA", "AGTGGA", "ATGTTG", "GGTTTC", "GTAGAG", "GTTAGT",
			"GTTTGG", "TAGCGA", "TATTGG", "TGGGTT", "TTGGTA", "AAGAGA", "AAAGTG", "TAAGGC", "AAAGGC", "AATAGC",
			"TAAGCC", "TATGCC", "GTTGCT", "CAGTTG", "GAAAGG", "CACAAG", "TACAGA", "GAAGAA", "ACAAAG", "AGAAGG",
			"GCGTTT", "TGAAAG", "TGAGAA", "GATGAA", "CACGAA", "ACGGTT", "GATTTC", "TAGTCT", "TTTCTC", "CGCAAA",
			"CATCTA", "GGTCTA", "AAGGTG", "AAAGAC", "AGAAAC", "TTAACG", "TGAACC", "AGTTAC", "AAACCG", "TAACCC",
			"GCACTA", "AGACGT", "ACATGT", "ATCAAC", "TTCGAA", "GACAAT", "TGCTTT", "TGCTAG", "GTGATC", "GATATG",
			"GTAATC", "GAAATC", "GCTGTA", "TGTATC", "CTGAAG", "ATGCAC", "GTACAA", "AAACAC", "AAGCAC", "GAACAG",
			"GTTCAC", "ACCTTT", "AACTGA", "CCGTAT", "ATCTGA", "TCAAAG", "TCGATT", "GCTAAG", "GAGATA", "CTGGTA",
			"CTTGTT", "CTTTAG", "CTTCGA", "CTAAAG", "CTATGG", "TCTGTG", "CACATT", "TCAGTC", "CCAAAT", "AATACC",
			"ACTTCC", "ACAACC", "CCTAAT", "ACAGCA", "CTTGAC", "CAATAC", "GCTCTT", "TTGGCA", "TCTACC" };
	private static final String[] tier3Array = { "AAGGTG", "AGGAAA", "AGGTAA", "AGTGGA", "ATGCAC", "ATGTTG", "GGTTTC",
			"GTAATC", "GTACAA", "GTAGAG", "GTGATC", "GTTAGT", "GTTTGG", "TAGAAC", "TAGCGA", "TATTGG", "TGGGTT",
			"TGTAAC", "TGTATC", "TTAACG", "TTGGCA", "TTGGTA", "AAGAGA", "AAAGTG", "TAAGGC", "AAACCG", "AAACAC",
			"AAAGAC", "AAAGGC", "AATAGC", "AAGCAC", "AGTTAC", "TAAGCC", "TATGCC", "CTGAAG", "CTGGTA", "GTTGCT",
			"GCTGTA", "CAGTTG", "CTTGAC", "CTTGTT", "CTTTAG", "CTAAAG", "CTATGG", "GCTAAG", "TAACCC", "AATACC",
			"ACAGCA", "ACATGT", "ACTTCC", "TCAGTC", "CAAACA", "CAATAC", "TGCTTT", "TGCTAG", "TCTGTG", "CTTCCA",
			"CCTAAT", "AACTGA", "GAAAGG", "GAACAG", "CACAAG", "CACATT", "TACAGA", "ACCATA", "TCCATA", "GTTCAC",
			"TCTACC", "TTCCAG", "GAAGAA", "ACAAAG", "ACAACC", "CCAAAT", "GACAAT", "GCACTA", "ATCAAC", "GAAACC",
			"GAAATC", "GATATG", "AGAAAC", "AGAAGG", "AGACGT", "GATACC", "TCAAAG", "ACCTTT", "AAGCTC", "GCGTTT",
			"GCTGTA", "CAGTTG", "CTTGAC", "CTTGTT", "CTTTAG", "CTAAAG", "CTATGG", "GCTAAG", "TAACCC", "AATACC",
			"ACAGCA", "ACATGT", "ACTTCC", "TCAGTC", "CAAACA", "CAATAC", "TGCTTT", "TGCTAG", "TCTGTG", "CTTCCA",
			"CCTAAT", "AACTGA", "GAAAGG", "GAACAG", "CACAAG", "CACATT", "TACAGA", "ACCATA", "TCCATA", "GTTCAC",
			"TCTACC", "TTCCAG", "GAAGAA", "ACAAAG", "ACAACC", "CCAAAT", "GACAAT", "GCACTA", "ATCAAC", "GAAACC",
			"GAAATC", "GATATG", "AGAAAC", "AGAAGG", "AGACGT", "GATACC", "TCAAAG", "ACCTTT", "AAGCTC", "GCGTTT",
			"CTTCGA", "ATCTGA", "TGAAAG", "TGAACC", "TGAGAA", "ATCTTC", "AAACTC", "TACTCA", "CACGAA" };
	private static final String[] tier4Array = { "CCTATTTA", "CAGTTTAA", "ATACACCC", "ATCCCACC", "TCCTATAT", "TTAGCAAT",
			"ACCAACCC", "GCCAACAT", "ACCAGTTT", "AGTAGTTA", "CCTTTACA", "ACAAGTAG", "ACACCAAG", "ACCCATGC", "GGCCCAAT",
			"GGCTATAA", "AGCATGCC", "CACTAACC", "ATGCATAT", "TTGCATTC", "AATAAGGA", "TTCTAGGA", "AGTAATGG", "ACTAATTG",
			"ATCAGGGA", "CTCCCAAA", "GACACAAA", "CCATATGA", "ATATGCAA", "GCTAAGTT", "TGCACCAG", "CAAACATT", "AAACTACA",
			"ATCCTAGT", "TACCTAAG", "TGGCTAGT", "CACAACCT", "ATAACAGG", "GGCAAGGT", "GGTTAGGG", "GTCAGGTT", "CTCAAACA",
			"AATATGAC", "AACAGAAC", "ACCACAGA", "ACTAGAGC", "GATGCAGA", "GTCAAGAG", "TCCAGAAG", "GGTTACAC", "AAACTGTG",
			"TAAGGGCC", "TAGTAGCC", "ACAGGCCA", "CAAGGAAT", "CAAGGTAC", "GCTATGGG", "AACAAATG", "CCTTTGTC", "CCCTGTTT",
			"TTTGCCAG", "GCCTGGTA", "GTCTGGAA", "TCTGATTT", "ACAAAGAT", "AACTGCCT", "CTCACATC", "GTCTAATC", "AAATAGCA",
			"AATGTATG", "CGTGTACA", "GATGTGGC", "TATGTGAA", "CGTGGGAT", "GATGGTTA", "AAAGAGGC", "ACAGATAA", "ATAGATGT",
			"CCAGACAG", "GAAGATAT", "TGGGAATT", "AGTTTGTA", "GGAGGTTT", "GGAGTAAG", "ACCTGAAG", "TACTGAAT", "CAAGGGTT",
			"CTGTTAAA", "CTGTTTCC", "GAGTGTAC", "TAATGTGG", "CTGGGTAT", "TTGGGTCC", "ACATGGAC", "ATATGGGT",
			"GAAAGACA" };

	// Constructor for an empty pBarcode
	public pBarcode() {
		this.pBarcode = "";
		this.ogBarcode = "";
		this.length = 0;
		this.ogTiersAndLinkers = new ArrayList<>();
		this.tier1 = "";
		this.tier2 = "";
		this.tier3 = "";
		this.tier4 = "";
		this.tier1isAmb = false;
		this.tier2isAmb = false;
		this.tier3isAmb = false;
		this.tier4isAmb = false;
		this.start = 0;
		this.end = 0;
	}

	public pBarcode(Matcher matcher, String input) {
		// Extract ogBarcode using matcher start and end
		this.ogBarcode = input.substring(matcher.start(), matcher.end());
		this.start = matcher.start();
		this.end = matcher.end();

		// Extract ogTiers and ogLinkers using capture groups from matcher
		this.ogTiersAndLinkers.add(matcher.group(1));
		this.ogTiersAndLinkers.add(matcher.group(2));
		this.ogTiersAndLinkers.add(matcher.group(3));
		this.ogTiersAndLinkers.add(matcher.group(4));
		this.ogTiersAndLinkers.add(matcher.group(5));
		this.ogTiersAndLinkers.add(matcher.group(6));
		this.ogTiersAndLinkers.add(matcher.group(7));

		// Compare each tier to the respective array and find the lowest Levenshtein
		// distance
		this.tier1 = processTier(matcher.group(1), tier1Array, 2, 1);
		this.tier2 = processTier(matcher.group(3), tier2Array, 2, 2);
		this.tier3 = processTier(matcher.group(5), tier3Array, 2, 3);
		this.tier4 = processTier(matcher.group(7), tier4Array, 2, 4);

		// Reconstruct the pBarcode from the processed tiers
		this.pBarcode = this.tier1 + "ATG" + this.tier2 + "GAG" + this.tier3 + "TCGAG" + this.tier4;

		// Set the length of the final pBarcode
		this.length = this.pBarcode.length();
	}

	public pBarcode(String t1, String t2, String t3, String t4) {
		this.pBarcode = t1 + "ATG" + t2 + "GAG" + t3 + "TCGAG" + t4;
                this.ogBarcode = t1 + "ATG" + t2 + "GAG" + t3 + "TCGAG" + t4;
                this.length = 39;
                this.tier1 = t1;
                this.tier2 = t2;
                this.tier3 = t3;
                this.tier4 = t4;
		this.ogTiersAndLinkers = new ArrayList<>();
		this.tier1isAmb = false;
		this.tier2isAmb = false;
		this.tier3isAmb = false;
		this.tier4isAmb = false;
		this.start = Integer.MAX_VALUE;
		this.end = Integer.MAX_VALUE;
	}

	private String processTier(String tier, String[] tierArray, int minDist, int tierVal) {
		int minDistance = Integer.MAX_VALUE;
		String closestElement = tier;
		List<String> ties = new ArrayList<>();

		// Calculate the Levenshtein distance to each element in the array
		for (String element : tierArray) {
			int distance = LevenshteinDistance.computeLevenshteinDistance(tier, element);
			if (distance < minDistance) {
				minDistance = distance;
				closestElement = element;
				ties.clear();
				ties.add(element);
			} else if (distance == minDistance) {
				ties.add(element);
			}
		}

		System.out.println(minDistance);
		System.out.println(ties.size());

		// Handle ambiguity
		if (ties.size() > 1 || minDistance > minDist) {
			if (tierVal == 1) {
				this.tier1isAmb = true;
			} else if (tierVal == 2) {
				this.tier2isAmb = true;
			} else if (tierVal == 3) {
				this.tier3isAmb = true;
			} else if (tierVal == 4) {
				this.tier4isAmb = true;
			} else {
				System.out.println("THIS SHOULD NOT BE HAPPENING!!");
			}
		}

		// Replace tier if the lowest Levenshtein distance is not zero
		if (minDistance != 0) {
			tier = closestElement;
		}

		return tier;
	}

	public boolean isAmbiguous() {
		return this.tier1isAmb || this.tier2isAmb || this.tier3isAmb || this.tier4isAmb;
	}

	public String getBarcodeQualFromString(String qual) {
		// for simplicity's sake, we will set the barcode quality to 'perfect' and then grab the quality of the molecular identifier
		if (qual.length() < end + 15) {
			return "ERROR";
		} else {
			return "~".repeat(39) + qual.substring(end, end + 15);
		}
	}

	public void rescueBarcode(Set<String> barcodeWhitelist) {
		// To try and rescue barcodes, we compare them to a whitelist for the sample and calculate the 
		// Levenshtein distance.  
		System.out.println("START RESCUING");
		String unAmbiguousBarcode = processTier(this.pBarcode, barcodeWhitelist.toArray(new String[0]), 11, 0);
		if (unAmbiguousBarcode != this.pBarcode) {
			this.pBarcode = unAmbiguousBarcode;
		}
		System.out.println("RESCUING OVER");
	}

	@Override
	public String toString() {
		return "pBarcode{" +
			"pBarcode='" + pBarcode + '\'' +
                        ", ogBarcode='" + ogBarcode + '\'' +
                        ", length=" + length +
                        ", ogLength=" + ogLength +
                        ", ogTiersAndLinkers='" + ogTiersAndLinkers + '\'' +
                        ", tier1='" + tier1 + '\'' +
                        ", tier2='" + tier2 + '\'' +
                        ", tier3='" + tier3 + '\'' +
                        ", tier4='" + tier4 + '\'' +
			", tier1isAmb='" + tier1isAmb + '\'' +
			", tier2isAmb='" + tier2isAmb + '\'' +
			", tier3isAmb='" + tier3isAmb + '\'' +
			", tier4isAmb='" + tier4isAmb + '\'' +
                        ", start=" + start +
                        ", end=" + end +
                        '}';

	}

	@Override
	public boolean equals(Object o) {
		if (this == o) return true;
		if (o == null || getClass() != o.getClass()) return false;
		pBarcode pBarcode1 = (pBarcode) o;
		return length == pBarcode1.length &&
			ogLength == pBarcode1.ogLength &&
			start == pBarcode1.start &&
			end == pBarcode1.end &&
			Objects.equals(pBarcode, pBarcode1.pBarcode) &&
			Objects.equals(ogBarcode, pBarcode1.ogBarcode) &&
			Objects.equals(tier1, pBarcode1.tier1) &&
			Objects.equals(tier2, pBarcode1.tier2) &&
			Objects.equals(tier3, pBarcode1.tier3) &&
			Objects.equals(tier4, pBarcode1.tier4) &&
			tier1isAmb == pBarcode1.tier1isAmb &&
			tier2isAmb == pBarcode1.tier2isAmb &&
			tier3isAmb == pBarcode1.tier3isAmb &&
			tier4isAmb == pBarcode1.tier4isAmb && 
			Objects.equals(ogTiersAndLinkers, pBarcode1.ogTiersAndLinkers);
	}

	@Override
	public int hashCode() {
		return Objects.hash(pBarcode, ogBarcode, length, ogLength, tier1, tier1isAmb, tier2, tier2isAmb, tier3, tier3isAmb, tier4, tier4isAmb, start, end, ogTiersAndLinkers);

	}

	// Serialization method for a list of pBarcode objects
	public static void serializeList(List<pBarcode> objList, String filename) {
		try (ObjectOutputStream out = new ObjectOutputStream(new GZIPOutputStream(new FileOutputStream(filename)))) {
			out.writeObject(objList);
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	// Deserialization method for a list of pBarcode objects
	@SuppressWarnings("unchecked")
	public static List<pBarcode> deserializeList(String filename) {
		try (ObjectInputStream in = new ObjectInputStream(new GZIPInputStream(new FileInputStream(filename)))) {
			return (List<pBarcode>) in.readObject();
		} catch (IOException | ClassNotFoundException e) {
			e.printStackTrace();
			return null;
		}
	}


}
