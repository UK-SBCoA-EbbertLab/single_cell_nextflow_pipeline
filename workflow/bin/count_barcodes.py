#!/usr/bin/env python
import os
import csv
import argparse
from collections import defaultdict

def sum_barcodes_in_directory(input_dir, threshold, output_tsv, full_output):
    barcode_counts = defaultdict(int)

    # Loop through all files in the input directory
    for filename in os.listdir(input_dir):
        if filename.endswith('generated_barcode_read_info_table.csv'):
            file_path = os.path.join(input_dir, filename)

            # Open and read the CSV file
            with open(file_path, 'r') as csvfile:
                reader = csv.DictReader(csvfile)

                for row in reader:
                    barcode = row['GENERATED_BARCODE']
                    num_reads = int(row['NUM_READS'])

                    # Sum reads by barcode
                    barcode_counts[barcode] += num_reads

    with open(full_output, 'w') as fullTsv:
        tsv_writer = csv.writer(fullTsv, delimiter='\t')
        tsv_writer.writerow(['BARCODE', 'TOTAL_READS']) #header row

        for barcode, total_reads in barcode_counts.items():
            tsv_writer.writerow([barcode, total_reads])

    # Filter barcodes with reads > threshold
    filtered_barcodes = {barcode: reads for barcode, reads in barcode_counts.items() if reads > threshold}

    # Write the filtered result to a TSV file
    with open(output_tsv, 'w') as tsvfile:
        tsv_writer = csv.writer(tsvfile, delimiter='\t')
        tsv_writer.writerow(['BARCODE', 'TOTAL_READS'])  # Header row

        for barcode, total_reads in filtered_barcodes.items():
            tsv_writer.writerow([barcode, total_reads])

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Sum barcode reads from CSV files and output filtered TSV.")

    # Optional input directory argument, defaulting to current directory
    parser.add_argument('--input', '-i', default='.', help="Input directory containing CSV files (default: current directory)")

    # Output file is still required
    parser.add_argument('--output', '-o', required=True, help="Output TSV file path")
    parser.add_argument('--fulloutput', '-f', required=True, help="Output TSV file path - full barcodes")
    parser.add_argument('--threshold', '-t', required=True, help="Threshold (n reads) for filtering barcodes")

    args = parser.parse_args()

    # Use the provided input directory or default to current directory
    input_directory = args.input
    output_file = args.output
    full_output = args.fulloutput
    try:
        threshold = int(args.threshold)
    except ValueError:
        print("Error: Threshold value must be an integer.")
        sys.exit(1)  # Exits the program with a non-zero status to indicate an error

    # Call the function
    sum_barcodes_in_directory(input_directory, threshold, output_file, full_output)

