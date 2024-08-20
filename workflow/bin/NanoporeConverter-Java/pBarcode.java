import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Set;
import java.io.*;
import java.util.Objects;
import java.util.zip.GZIPOutputStream;
import java.util.zip.GZIPInputStream;


/**
 *
 */
public class pBarcode implements Serializable {
	
    private static final long serialVersionUID = 1L;
	public String pBarcode;
	public String ogBarcode;
	public int length;
	public int ogLength;

	public String tier1;
	public String tier2;
	public String tier3;
	public String tier4;

	public boolean tier1isAmb;
	public boolean tier2isAmb;
	public boolean tier3isAmb;
	public boolean tier4isAmb;
	
	private String ogTier1;
	private String ogTier2;
	private String ogTier3;
	private String ogTier4;
	
	private String ogL1;
	private String ogL2;
	private String ogL3;

	public int totalLD;
	
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
		this.tier1 = "";
		this.tier2 = "";
		this.tier3 = "";
		this.tier4 = "";
		this.ogTier1 = "";
		this.ogTier2 = "";
		this.ogTier3 = "";
		this.ogTier4 = "";
		this.ogL1 = "";
		this.ogL2 = "";
		this.ogL3 = "";
		this.tier1isAmb = false;
		this.tier2isAmb = false;
		this.tier3isAmb = false;
		this.tier4isAmb = false;
		this.start = 0;
		this.end = 0;
		this.totalLD = 0;
	}

	public pBarcode(Matcher matcher, String input) {
		// Extract ogBarcode using matcher start and end
		this.ogBarcode = input.substring(matcher.start(), matcher.end());
		this.start = matcher.start();
		this.end = matcher.end();

		// Extract ogTiers and ogLinkers using capture groups from matcher
		this.ogTier1 = matcher.group(1);
		this.ogL1 = matcher.group(2);
		this.ogTier2 = matcher.group(3);
		this.ogL2 = matcher.group(4);
		this.ogTier3 = matcher.group(5);
		this.ogL3 = matcher.group(6);
		this.ogTier4 = matcher.group(7);

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
		
		this.totalLD = 0;
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
				return tier;
			} else if (tierVal == 2) {
				this.tier2isAmb = true;
				return tier;
			} else if (tierVal == 3) {
				this.tier3isAmb = true;
				return tier;
			} else if (tierVal == 4) {
				this.tier4isAmb = true;
				return tier;
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

	public void rescueBarcode(HashMap<String, Set<pBarcode>> tier1map,
			HashMap<String, Set<pBarcode>> tier2map, HashMap<String, Set<pBarcode>> tier3map,
			HashMap<String, Set<pBarcode>> tier4map) {

		System.out.println("START RESCUING");
		Set<pBarcode> potentialBarcodes = new HashSet<pBarcode>();
		int nTierAmb = 0;
		
		if(!this.tier1isAmb) {
			System.out.println(this.tier1);
			System.out.println(tier1map.size());
			potentialBarcodes = new HashSet<>(grabBarcodes(this.tier1, tier1map));		
		} else { 
			nTierAmb += 1; 
		} 		
		
		if(!this.tier2isAmb) {
			Set<pBarcode> t2 = new HashSet<>(grabBarcodes(this.tier2, tier2map));
			if (potentialBarcodes.isEmpty() && nTierAmb != 0) {
				potentialBarcodes = t2;
			} else {
				potentialBarcodes.retainAll(t2);
			}
		} else { 
			nTierAmb += 1; 
		}
		
		if(!this.tier3isAmb) {
			Set<pBarcode> t3 = new HashSet<>(grabBarcodes(this.tier3, tier3map));
			if (potentialBarcodes.isEmpty() && nTierAmb != 0) {
				potentialBarcodes = t3;
			} else {
				potentialBarcodes.retainAll(t3);
			}
		} else { 
			nTierAmb += 1; 
		}
		
		if(!this.tier4isAmb) {
			Set<pBarcode> t4 = new HashSet<>(grabBarcodes(this.tier4, tier4map));
			if (potentialBarcodes.isEmpty() && nTierAmb != 0) {
				potentialBarcodes = t4;
			} else {
				potentialBarcodes.retainAll(t4);
			}
		} else { 
			nTierAmb += 1; 
		}
		
		System.out.println(potentialBarcodes);
		
		
		int minLDist = Integer.MAX_VALUE;
		List<pBarcode> ties = new ArrayList<>();
		pBarcode closest = new pBarcode();
		
		for (pBarcode barc : potentialBarcodes) {
			if(this.tier1isAmb) {
				barc.totalLD += LevenshteinDistance.computeLevenshteinDistance(this.tier1, barc.tier1);
			}
			if(this.tier2isAmb) {
				barc.totalLD += LevenshteinDistance.computeLevenshteinDistance(this.tier2, barc.tier2);
			}
			if(this.tier3isAmb) {
				barc.totalLD += LevenshteinDistance.computeLevenshteinDistance(this.tier3, barc.tier3);
			}
			if(this.tier4isAmb) {
				barc.totalLD += LevenshteinDistance.computeLevenshteinDistance(this.tier4, barc.tier4);
			}
			
			if (barc.totalLD < minLDist) {
				minLDist = barc.totalLD;
				closest = barc;
				ties.clear();
				ties.add(barc);
			} else if (barc.totalLD == minLDist) {
				ties.add(barc);
			}
		}

		// Replace tier if the lowest Levenshtein distance is not zero
		if (minLDist < 2*nTierAmb && ties.size() == 1) {
			this.tier1 = closest.tier1;
			this.tier2 = closest.tier2;
			this.tier3 = closest.tier3;
			this.tier4 = closest.tier4;
			this.pBarcode = closest.pBarcode;
			this.tier1isAmb = false;
			this.tier2isAmb = false;
			this.tier3isAmb = false;
			this.tier4isAmb = false;
			System.out.println("RESCUE SUCCESSFUL");
		}
		
		System.out.println("RESCUING OVER");
	}
	
	private Set<pBarcode> grabBarcodes(String key, HashMap<String, Set<pBarcode>> tierMap) {
		if (tierMap.containsKey(key)) {
			return tierMap.get(key);
		} else {
			return new HashSet<pBarcode>();
		}
	}

	@Override
	public String toString() {
		return "pBarcode{" +
			"pBarcode='" + pBarcode + '\'' +
				", ogBarcode='" + ogBarcode + '\'' +
				", length=" + length +
				", ogLength=" + ogLength +
				", tier1='" + tier1 + '\'' +
				", tier2='" + tier2 + '\'' +
				", tier3='" + tier3 + '\'' +
				", tier4='" + tier4 + '\'' +
				", ogtier1='" + ogTier1 + '\'' +
				", ogL1='" + ogL1 + '\'' +
				", ogTier2='" + ogTier2 + '\'' +
				", ogL2='" + ogL2 + '\'' +
				", ogTier3='" + ogTier3 + '\'' +
				", ogL3='" + ogL3 + '\'' +
				", ogTier4='" + ogTier4 + '\'' +
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
			Objects.equals(ogTier1, pBarcode1.ogTier1) &&
			Objects.equals(ogL1, pBarcode1.ogL1) &&
			Objects.equals(ogTier2, pBarcode1.ogTier2) &&
			Objects.equals(ogL2, pBarcode1.ogL2) &&
			Objects.equals(ogTier3, pBarcode1.ogTier3) &&
			Objects.equals(ogL3, pBarcode1.ogL3) &&
			Objects.equals(ogTier4, pBarcode1.ogTier4) &&
			tier1isAmb == pBarcode1.tier1isAmb &&
			tier2isAmb == pBarcode1.tier2isAmb &&
			tier3isAmb == pBarcode1.tier3isAmb &&
			tier4isAmb == pBarcode1.tier4isAmb;
	}

	@Override
	public int hashCode() {
		return Objects.hash(pBarcode, ogBarcode, length, ogLength, tier1, tier1isAmb, ogTier1, ogL1, tier2, tier2isAmb, ogTier2, ogL2, tier3, tier3isAmb, ogTier3, ogL3, tier4, tier4isAmb, ogTier4, start, end);
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
	
	public static void saveMapToFile(HashMap<String, Set<pBarcode>> map, String filename) {
        try (ObjectOutputStream out = new ObjectOutputStream(new GZIPOutputStream(new FileOutputStream(filename)))) {
            out.writeObject(map);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    @SuppressWarnings("unchecked")
    public static HashMap<String, Set<pBarcode>> loadMapFromFile(String filename) {
        try (ObjectInputStream in = new ObjectInputStream(new GZIPInputStream(new FileInputStream(filename)))) {
            return (HashMap<String, Set<pBarcode>>) in.readObject();
        } catch (IOException | ClassNotFoundException e) {
            e.printStackTrace();
            return null;
        }
    }
	
	public static List<pBarcode> cleanBarcodes(List<pBarcode> barcodes) {
		for (pBarcode pb : barcodes) {
			pb.cleanBarcode();
		}
		return barcodes;
	}
	
	private void cleanBarcode() {
		this.ogBarcode = "";
		this.ogTier1 = "";
		this.ogTier2 = "";
		this.ogTier3 = "";
		this.ogTier4 = "";
		this.ogL1 = "";
		this.ogL2 = "";
		this.ogL3 = "";
		this.tier1isAmb = false;
		this.tier2isAmb = false;
		this.tier3isAmb = false;
		this.tier4isAmb = false;
		this.start = 0;
		this.end = 0;
	}


}
