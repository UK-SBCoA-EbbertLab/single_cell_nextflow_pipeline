import java.util.*;
import java.io.IOException;
import java.nio.file.*;
import java.util.stream.Collectors;
import java.util.stream.Stream;

public class combinedBarcodeWhitelists {
	
	private static HashMap<String, Set<pBarcode>> tier1map = new HashMap<>();
	private static HashMap<String, Set<pBarcode>> tier2map = new HashMap<>();
	private static HashMap<String, Set<pBarcode>> tier3map = new HashMap<>();
	private static HashMap<String, Set<pBarcode>> tier4map = new HashMap<>();
	
	public static void main(String[] args) {
		Path currentDir = Paths.get(".");
		try (Stream<Path> files = Files.list(currentDir)) {
			List<String> serGzFiles = files
				.filter(file -> file.toString().endsWith("barcodeWhitelist.ser.gz"))
				.map(Path::toString)
				.collect(Collectors.toList());

			if(serGzFiles.isEmpty()) {
				System.err.println("No barcodeWhitelist.ser.gz files found in the current directory.");
				System.exit(1);
			}

			for (String filePath : serGzFiles) {
				List<pBarcode> deserializedPBarcodes = pBarcode.deserializeList(filePath);
				if (deserializedPBarcodes != null) {
					pBarcode.cleanBarcodes(deserializedPBarcodes);
					addBarcodesToMaps(deserializedPBarcodes);
		    		} else {
					System.err.println("Failed to deserialize file: " + filePath);
					System.exit(1);
				}	
			}

			// Save hashMaps to files to load later
			pBarcode.saveMapToFile(tier1map, "tier1map_barcodes.ser.gz");
			pBarcode.saveMapToFile(tier2map, "tier2map_barcodes.ser.gz");
			pBarcode.saveMapToFile(tier3map, "tier3map_barcodes.ser.gz");
			pBarcode.saveMapToFile(tier4map, "tier4map_barcodes.ser.gz");
		} catch (IOException e) {
			 System.err.println("Error reading files in the directory: " + e.getMessage());
	     		 System.exit(1);
		}
	}
	
	private static void addBarcodesToMaps(List<pBarcode> barcodes) {
		for (pBarcode barcode : barcodes) {
			addToMap(tier1map, barcode.tier1, barcode);
			addToMap(tier2map, barcode.tier2, barcode);
			addToMap(tier3map, barcode.tier3, barcode);
			addToMap(tier4map, barcode.tier4, barcode);
		}
	}
	
	private static void addToMap(HashMap<String, Set<pBarcode>> map, String key, pBarcode barcode) {
		map.computeIfAbsent(key, k -> new HashSet<>()).add(barcode);
	}

}
