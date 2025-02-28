#!/usr/bin/env python
import sys
import os
os.environ["POLARS_MAX_THREADS"] = "14"
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



parent_dir = sys.argv[1]

name = sys.argv[2]

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

merge_counts(parent_dir, gFilename, ["GENEID"], gene_name)
merge_counts(parent_dir, tFilename, ["TXNAME","GENEID"], transcript_name)
merge_counts(parent_dir, tcFilename, ["TXNAME","GENEID"], tc_name)
merge_counts(parent_dir, fltFilename, ["TXNAME","GENEID"], flt_name)
merge_counts(parent_dir, uctFilename, ["TXNAME","GENEID"], uct_name)

