#!/usr/bin/env python
import pandas as pd
import sys
import csv

input_file_path = sys.argv[1]
pattern = sys.argv[2]
output_file_path = sys.argv[3]

ref_novel = pd.read_csv(input_file_path, header=None, delimiter="\t", low_memory=False, comment="#", names=["chr", "source", "type", "start", "end", "dot_1", "strand", "dot_2", "other"])

#keep only novel transcripts
ref_novel = ref_novel.loc[ref_novel["other"].str.contains(f"transcript_id \"{pattern}")].copy()

ref_novel.to_csv(output_file_path, index=False, header=False, sep="\t", quoting=csv.QUOTE_NONE)
