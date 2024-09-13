import java.io.*;
import java.nio.file.*;
import java.util.*;
import java.util.zip.*;

public class modified_UnzipAndConcat {
	public static void main(String[] args) {
		// Check if the TSV file is provided
		if (args.length < 2 || args.length > 3) {
			System.out.println("Usage 1: java modified-UnzipAndConcat <file extension> <output filename>");
			System.out.println("Usage 2: java modified-UnzipAndConcat <file extension> <barcode> <output filename>");
			System.exit(1);
		}

		String directory = System.getProperty("user.dir");
		System.out.println("Current working directory: " + directory);

		if (args.length == 2) {
			String fileExtension = args[0];
			String fileName = args[1];
			try {
				String currentDirectory = directory;
				// Extract .gz files
				extractGzFiles(currentDirectory, fileExtension);
				// Concatenate .fastq files for this sample
				concatenateFiles(currentDirectory, fileExtension, fileName);
			} catch (IOException e) {
				e.printStackTrace();
			}
		} else if (args.length == 3) {
			String fileExtension = args[0];
			String barcode = args[1];
			String fileName = args[2];
			try {
				String currentDirectory = directory;
				// Extract .gz files
				extractGzFiles_barcoded(currentDirectory, fileExtension, barcode);
				// Concatenate .fastq files for this sample
				concatenateFastqFiles_barcoded(currentDirectory, fileExtension, barcode, fileName);
			} catch (IOException e) {
				e.printStackTrace();
			}
		}

	}

	private static void extractGzFiles(String directory, String extension) throws IOException {
		Files.walk(Paths.get(directory)).filter(Files::isRegularFile)
				.filter(path -> path.toString().endsWith(extension + ".gz"))
				.forEach(path -> {
					try {
						System.out.println(path);
						GunzipFile(path);
					} catch (IOException e) {
						e.printStackTrace();
					}
				});
	}

	private static void concatenateFiles(String directory, String extension, String fileName) throws IOException {
		String outputFile = fileName;
		try (BufferedWriter writer = new BufferedWriter(new FileWriter(outputFile, true))) {
			Files.walk(Paths.get(directory)).filter(Files::isRegularFile)
					.filter(path -> path.toString().endsWith(extension))
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
	
	private static void extractGzFiles_barcoded(String directory, String extension, String barcode) throws IOException {
		Files.walk(Paths.get(directory)).filter(Files::isRegularFile)
				.filter(path -> path.toString().contains(barcode) && path.toString().endsWith(extension + ".gz"))
				.forEach(path -> {
					try {
						System.out.println(path);
						GunzipFile(path);
					} catch (IOException e) {
						e.printStackTrace();
					}
				});
	}

	private static void concatenateFastqFiles_barcoded(String directory, String extension, String barcode, String fileName) throws IOException {
		String outputFile = fileName;
		try (BufferedWriter writer = new BufferedWriter(new FileWriter(outputFile, true))) {
			Files.walk(Paths.get(directory)).filter(Files::isRegularFile)
					.filter(path -> path.toString().contains(barcode) && path.toString().endsWith(extension))
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
