#!/usr/bin/env python
import sys
import os
os.environ["POLARS_MAX_THREADS"] = "10"
import glob
import polars as pl
print(pl.thread_pool_size())


def merge_counts(parentDirectory, fileName, columns, outfileName):
    dataframes = []
    pattern = os.path.join(parentDirectory, fileName)
    print(pattern)
    bambu_matrices = glob.glob(pattern)
    df_merged = None
    for m in bambu_matrices:
        # Read the first row to determine column names
        with open(m, "r") as f:
            header = f.readline().strip().split("\t")

        # Define schema dynamically
        schema_overrides = {header[0]: pl.Utf8, header[1]: pl.Utf8}  # First two columns as strings

        for col in header[2:]:  # Rest as floats
            schema_overrides[col] = pl.Float64

        # Read CSV with specified schema
        df = pl.read_csv(m, separator='\t', schema_overrides=schema_overrides)
        if df_merged is None:
            df_merged = df
        else:
            df_merged = df_merged.join(df, on=columns, how='full', coalesce=True)
    print(df_merged)
    df_merged.write_csv(outfileName, separator='\t')


def low_memory_merge(parentDirectory, fileName, columns, outfileName):
    
    pattern = os.path.join(parentDirectory, fileName)
    print(pattern)
    bambu_matrices = glob.glob(pattern)

    # Open all files simultaneously (minimal memory usage since we stream line-by-line)
    file_handles = [open(f, 'r') for f in bambu_matrices]
    with open(outfileName, 'w') as fout:
        try:
            # Use zip to iterate over one line from each file at a time
            for lines in zip(*file_handles):
                # Strip newline characters and split each line by the delimiter
                row_lists = [line.rstrip('\n').split('\t') for line in lines]

                # The first column is assumed identical across files; we check it here:
                tx = row_lists[0][0]
                if any(row[0] != tx for row in row_lists):
                    sys.stderr.write("Error: First column mismatch among files.\n")
                    sys.exit(1)

                if columns == 2:
                    # Build the combined row: include the tx and geneid only once, then append the rest of each row.
                    combined = [tx] + [row_lists[0][1]] + [item for row in row_lists for item in row[2:]]
                    fout.write('\t'.join(combined) + '\n')
                else:
                    combined = [tx] + [item for row in row_lists for item in row[1:]]
                    fout.write('\t'.join(combined) + '\n')

        finally:
            # Make sure to close all file handles
            for f in file_handles:
                f.close()


parent_dir = sys.argv[1]
name = sys.argv[2]
merge_type = sys.argv[3]


gFilename = "*counts_gene.txt"
tFilename = "*CPM_transcript.txt"
tcFilename = "*counts_transcript.txt"
fltFilename = "*fullLengthCounts_transcript.txt"
uctFilename = "*uniqueCounts_transcript.txt"

gene_name = name + "_combined_counts_gene.txt"
transcript_name = name + "_combined_CPM_transcript.txt"
tc_name = name + "_combined_counts_transcript.txt"
flt_name = name + "_combined_fullLengthCounts_transcript.txt"
uct_name = name + "_combined_uniqueCounts_transcript.txt"


if merge_type == "low_memory":
    low_memory_merge(parent_dir, gFilename, 1, gene_name)
    low_memory_merge(parent_dir, tFilename, 2, transcript_name)
    low_memory_merge(parent_dir, tcFilename, 2, tc_name)
    low_memory_merge(parent_dir, fltFilename, 2, flt_name)
    low_memory_merge(parent_dir, uctFilename, 2, uct_name)

else:
    merge_counts(parent_dir, gFilename, ["GENEID"], gene_name)
    merge_counts(parent_dir, tFilename, ["TXNAME","GENEID"], transcript_name)
    merge_counts(parent_dir, tcFilename, ["TXNAME","GENEID"], tc_name)
    merge_counts(parent_dir, fltFilename, ["TXNAME","GENEID"], flt_name)
    merge_counts(parent_dir, uctFilename, ["TXNAME","GENEID"], uct_name)


