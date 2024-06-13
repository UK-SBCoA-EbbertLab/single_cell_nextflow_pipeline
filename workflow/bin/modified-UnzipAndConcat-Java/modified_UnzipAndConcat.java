import java.io.*;
import java.nio.file.*;
import java.util.*;
import java.util.zip.*;

public class modified_UnzipAndConcat {
    public static void main(String[] args) {
        // Check if the TSV file is provided
        if (args.length != 1) {
            System.out.println("Usage: java UnzipAndConcat <output filename>");
            System.exit(1);
        }

	String directory = System.getProperty("user.dir");
        System.out.println("Current working directory: " + directory);

	String fileName = args[0];
        try {
            String currentDirectory = directory;
            // Extract .gz files
            extractGzFiles(currentDirectory);
            // Concatenate .fastq files for this sample
            concatenateFastqFiles(currentDirectory, fileName);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private static void extractGzFiles(String directory) throws IOException {
        Files.walk(Paths.get(directory))
                .filter(Files::isRegularFile)
                .filter(path -> path.toString().endsWith(".fastq.gz"))
                .forEach(path -> {
                    try {
			System.out.println(path);
                        GunzipFile(path);
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                });
    }

    private static void concatenateFastqFiles(String directory, String fileName) throws IOException {
        String outputFile = fileName;
        try (BufferedWriter writer = new BufferedWriter(new FileWriter(outputFile, true))) {
            Files.walk(Paths.get(directory))
                    .filter(Files::isRegularFile)
                    .filter(path -> path.toString().endsWith(".fastq"))
		    .sorted(Comparator.comparing(Path::toString))
                    .forEach(path -> {
			System.out.println(path);
                        try (BufferedReader reader = new BufferedReader(new FileReader(path.toFile()))) {
                            String line;
                            while ((line = reader.readLine()) != null) {
			        System.out.println(line);
                                writer.write(line);
                                writer.newLine();
                            }
                        } catch (IOException e) {
                            e.printStackTrace();
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

