import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.HashSet;
import java.util.Set;

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
    public boolean isAmbiguous;
    public int length;
    public int ogLength;

    public String ogTier1;
    public String tier1;
    public String ogL1;
    public String ogTier2;
    public String tier2;
    public String ogL2;
    public String ogTier3;
    public String tier3;
    public String ogL3;
    public String ogTier4;
    public String tier4;

    private int start;
    private int end;

    private static final String[] tier1Array = {"AGAAACCA","CCTTTACA","TACCTCCC","ACCTTCCC","AAACTACA","ATTACCTT","GATTTCCC","CTCCTCCA","TCTAAACT","AAGTCCAA","TCCGACAC","GAGAAACC","ACCCTCAA","AGACCTCA","GATTACTT","CCACCTCT","TAACTTCT","TTCCCTAT","CTGTTTCC","TCCTATAT","CACTAACC","CCCTGTTT","TTGACCCA","TCTATTCC","GTGTCACC","AGGACACA","CTTTGGAC","CCTATTTA","TAGTCTCT","CTTTCACT","ATCCCACC","ATACTCTC","CAATTCTC","ATTTCCAT","CAAGGGTT","GTCTTCCT","CTGGGTAT","CAAACATT","CAGGTTGC","GTCCTTGC","GATTGGGA","TTGGGTCC","TACCCTGC","GAGGGTCA","AGAGGTGC","CTGTGACC","GTCCACTA","CTTAGTGT","GAGTGTAC","GTTGTCCG","TCTTTGAC","CCTTTGTC","GTGAACTC","AAGGGACC","AATACATC","AAACAAAC","ACTACCCG","GATGTGGC","ACCCATGC","ACCAACCC","AAAGAGGC","AAGTTGTC","GAATCCCA","CTTTATCC","GTAAACAA","CTTCTACG","CCATCCAC","CCTCATGA","CTAGACTA","ACCAGTTT","AGTTGAAC","AGTTTGTA","CCCTCTTG","GAGGAGTG","TCCCTGGA","AAATTCCG","GAAATACG","AGTCACAA","TACTGAAT","AGACGAGG","CCTACGCT","AAACCGCC","AATATGAC","GACACCTG","CTGTTGTG","CTAACGCC","TTCACTGG","GTCTAATC","TATGTGAA","GTGAGGCA","TATCTGTC","GTGGTGCT","ATACACCC","CCCTTGCA","TATCCACG","GCCTGGTA"};
    private static final String[] tier2Array = {"AGGAAA","AGGTAA","AGTGGA","ATGTTG","GGTTTC","GTAGAG","GTTAGT","GTTTGG","TAGCGA","TATTGG","TGGGTT","TTGGTA","AAGAGA","AAAGTG","TAAGGC","AAAGGC","AATAGC","TAAGCC","TATGCC","GTTGCT","CAGTTG","GAAAGG","CACAAG","TACAGA","GAAGAA","ACAAAG","AGAAGG","GCGTTT","TGAAAG","TGAGAA","GATGAA","CACGAA","ACGGTT","GATTTC","TAGTCT","TTTCTC","CGCAAA","CATCTA","GGTCTA","AAGGTG","AAAGAC","AGAAAC","TTAACG","TGAACC","AGTTAC","AAACCG","TAACCC","GCACTA","AGACGT","ACATGT","ATCAAC","TTCGAA","GACAAT","TGCTTT","TGCTAG","GTGATC","GATATG","GTAATC","GAAATC","GCTGTA","TGTATC","CTGAAG","ATGCAC","GTACAA","AAACAC","AAGCAC","GAACAG","GTTCAC","ACCTTT","AACTGA","CCGTAT","ATCTGA","TCAAAG","TCGATT","GCTAAG","GAGATA","CTGGTA","CTTGTT","CTTTAG","CTTCGA","CTAAAG","CTATGG","TCTGTG","CACATT","TCAGTC","CCAAAT","AATACC","ACTTCC","ACAACC","CCTAAT","ACAGCA","CTTGAC","CAATAC","GCTCTT","TTGGCA","TCTACC"};
    private static final String[] tier3Array = {"AAGGTG","AGGAAA","AGGTAA","AGTGGA","ATGCAC","ATGTTG","GGTTTC","GTAATC","GTACAA","GTAGAG","GTGATC","GTTAGT","GTTTGG","TAGAAC","TAGCGA","TATTGG","TGGGTT","TGTAAC","TGTATC","TTAACG","TTGGCA","TTGGTA","AAGAGA","AAAGTG","TAAGGC","AAACCG","AAACAC","AAAGAC","AAAGGC","AATAGC","AAGCAC","AGTTAC","TAAGCC","TATGCC","CTGAAG","CTGGTA","GTTGCT","GCTGTA","CAGTTG","CTTGAC","CTTGTT","CTTTAG","CTAAAG","CTATGG","GCTAAG","TAACCC","AATACC","ACAGCA","ACATGT","ACTTCC","TCAGTC","CAAACA","CAATAC","TGCTTT","TGCTAG","TCTGTG","CTTCCA","CCTAAT","AACTGA","GAAAGG","GAACAG","CACAAG","CACATT","TACAGA","ACCATA","TCCATA","GTTCAC","TCTACC","TTCCAG","GAAGAA","ACAAAG","ACAACC","CCAAAT","GACAAT","GCACTA","ATCAAC","GAAACC","GAAATC","GATATG","AGAAAC","AGAAGG","AGACGT","GATACC","TCAAAG","ACCTTT","AAGCTC","GCGTTT","CTTCGA","ATCTGA","TGAAAG","TGAACC","TGAGAA","ATCTTC","AAACTC","TACTCA","CACGAA"};
    private static final String[] tier4Array = {"CCTATTTA","CAGTTTAA","ATACACCC","ATCCCACC","TCCTATAT","TTAGCAAT","ACCAACCC","GCCAACAT","ACCAGTTT","AGTAGTTA","CCTTTACA","ACAAGTAG","ACACCAAG","ACCCATGC","GGCCCAAT","GGCTATAA","AGCATGCC","CACTAACC","ATGCATAT","TTGCATTC","AATAAGGA","TTCTAGGA","AGTAATGG","ACTAATTG","ATCAGGGA","CTCCCAAA","GACACAAA","CCATATGA","ATATGCAA","GCTAAGTT","TGCACCAG","CAAACATT","AAACTACA","ATCCTAGT","TACCTAAG","TGGCTAGT","CACAACCT","ATAACAGG","GGCAAGGT","GGTTAGGG","GTCAGGTT","CTCAAACA","AATATGAC","AACAGAAC","ACCACAGA","ACTAGAGC","GATGCAGA","GTCAAGAG","TCCAGAAG","GGTTACAC","AAACTGTG","TAAGGGCC","TAGTAGCC","ACAGGCCA","CAAGGAAT","CAAGGTAC","GCTATGGG","AACAAATG","CCTTTGTC","CCCTGTTT","TTTGCCAG","GCCTGGTA","GTCTGGAA","TCTGATTT","ACAAAGAT","AACTGCCT","CTCACATC","GTCTAATC","AAATAGCA","AATGTATG","CGTGTACA","GATGTGGC","TATGTGAA","CGTGGGAT","GATGGTTA","AAAGAGGC","ACAGATAA","ATAGATGT","CCAGACAG","GAAGATAT","TGGGAATT","AGTTTGTA","GGAGGTTT","GGAGTAAG","ACCTGAAG","TACTGAAT","CAAGGGTT","CTGTTAAA","CTGTTTCC","GAGTGTAC","TAATGTGG","CTGGGTAT","TTGGGTCC","ACATGGAC","ATATGGGT","GAAAGACA"};

    // Constructor for an empty pBarcode
    public pBarcode() {
        this.pBarcode = "";
        this.ogBarcode = "";
        this.isAmbiguous = false;
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
        this.start = 0;
        this.end = 0;
    }

    public pBarcode(Matcher matcher, String input) {
        // Extract ogBarcode using matcher start and end
        this.ogBarcode = input.substring(matcher.start(), matcher.end());
        this.isAmbiguous = false;
	this.start = matcher.start();
	this.end = matcher.end();

        // Extract tiers using capture groups from matcher
        this.ogTier1 = matcher.group(1);
	this.ogL1 = matcher.group(2);
        this.ogTier2 = matcher.group(3);
	this.ogL2 = matcher.group(4);
        this.ogTier3 = matcher.group(5);
	this.ogL3 = matcher.group(6);
        this.ogTier4 = matcher.group(7);

        // Compare each tier to the respective array and find the lowest Levenshtein distance
        this.tier1 = processTier(this.ogTier1, tier1Array, 2);
        this.tier2 = processTier(this.ogTier2, tier2Array, 2);
        this.tier3 = processTier(this.ogTier3, tier3Array, 2);
        this.tier4 = processTier(this.ogTier4, tier4Array, 2);

        // Reconstruct the pBarcode from the processed tiers
        this.pBarcode = this.tier1 + "ATG" + this.tier2 + "GAG" + this.tier3 + "TCGAG" + this.tier4;

        // Set the length of the final pBarcode
        this.length = this.pBarcode.length();
    }

    private String processTier(String tier, String[] tierArray, int minDist) {
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
            this.isAmbiguous = true;
        }

        // Replace tier if the lowest Levenshtein distance is not zero
        if (minDistance != 0) {
            tier = closestElement;
        }

        return tier;
    }

    public String getBarcodeQualFromString(String qual) {
	if (qual.length() < end + 15) {
	    return "ERROR";
	} else {
	    return "~".repeat(39) + qual.substring(end, end + 15);
//	    //TODO: THIS NEEDS TO HANDLE WHEN WE CHANGE THE TIERS!!!
//	    if ((end + 15) - start != 54) {
//		return "~".repeat(54);
//	    } else {
//		return qual.substring(start, start + 54);
//	        //return qual.substring(start - 3, end + 12);
//	    }
	}
    }

    public void rescueBarcode(Set<String> barcodeWhitelist) {
	System.out.println("START RESCUING");
	String unAmbiguousBarcode = processTier(this.pBarcode, barcodeWhitelist.toArray(new String[0]), 11);
	if (unAmbiguousBarcode != this.pBarcode) {
	   this.pBarcode = unAmbiguousBarcode;
	}
	System.out.println("RESCUING OVER");
    }	
	
	
	    
}

