import java.io.*;
import java.nio.file.*;
import java.util.*;
import java.util.zip.*;

public class UnzipAndConcat {
    public static void main(String[] args) {
        // Check if the TSV file is provided
        if (args.length != 2) {
            System.out.println("Usage: java UnzipAndConcat <tsv_file> <directory>");
            System.exit(1);
        }

        String tsvFilename = args[0];
	String directory = args[1];
        
        // Parse TSV to get sample to folder mapping
        Map<String, String> sampleToFolderMap = parseTsv(tsvFilename);
	sampleToFolderMap.forEach((folder, sampleId) -> System.out.println("SampleID: " + sampleId + "   folder: " + folder));
        // Process each sample and concatenate files in its corresponding folder
        sampleToFolderMap.forEach((folder, sampleId) -> {
            try {
                String currentDirectory = directory + folder;
                System.out.println("Processing directory for sample " + sampleId + ": " + currentDirectory);

                // Extract .gz files
                extractGzFiles(currentDirectory);

                // Concatenate .fastq files for this sample
                concatenateFastqFiles(currentDirectory, sampleId);
            } catch (IOException e) {
                e.printStackTrace();
		System.exit(1);
            }
        });
    }

    private static Map<String, String> parseTsv(String tsvFilename) {
        Map<String, String> sampleToFolderMap = new HashMap<>();
        try (BufferedReader reader = new BufferedReader(new FileReader(tsvFilename))) {
            String line;
            while ((line = reader.readLine()) != null) {
                String[] parts = line.split("\\s+");
                if (parts.length >= 2) {
		    System.out.println("Folder id: " + parts[0] + "  Sample id: " + parts[1]);
                    sampleToFolderMap.put(parts[0], parts[1]);
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
	    System.exit(1);
        }
        return sampleToFolderMap;
    }

    private static void extractGzFiles(String directory) throws IOException {
        Files.walk(Paths.get(directory))
                .filter(Files::isRegularFile)
                .filter(path -> path.toString().endsWith(".fastq.gz"))
                .forEach(path -> {
                    try {
                        GunzipFile(path);
                    } catch (IOException e) {
                        e.printStackTrace();
			System.exit(1);
                    }
                });
    }

    private static void concatenateFastqFiles(String directory, String sampleId) throws IOException {
        String outputFile = sampleId + ".fastq";
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(outputFile, true))) {
            Files.walk(Paths.get(directory))
                    .filter(Files::isRegularFile)
                    .filter(path -> path.toString().endsWith(".fastq"))
                    .forEach(path -> {
                        try (BufferedReader reader = new BufferedReader(new FileReader(path.toFile()))) {
                            String line;
                            while ((line = reader.readLine()) != null) {
                                writer.write(line);
                                writer.newLine();
                            }
                        } catch (IOException e) {
                            e.printStackTrace();
			    System.exit(1);
                        }
                    });
        }
    }

    private static void GunzipFile(Path path) throws IOException {
        try (GZIPInputStream gis = new GZIPInputStream(new FileInputStream(path.toFile()))) {
            String outputPath = path.toString().replace(".gz", "");
            try (FileOutputStream fos = new FileOutputStream(outputPath)) {
                byte[] buffer = new byte[1024];
                int len;
                while ((len = gis.read(buffer)) > 0) {
                    fos.write(buffer, 0, len);
                }
            }
        }
    }
}

