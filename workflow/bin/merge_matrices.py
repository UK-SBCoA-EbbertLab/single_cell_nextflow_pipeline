#!/usr/bin/env python
import sys
import os
import glob
import pandas as pd
import numpy as np
from matplotlib import pyplot as plt
import seaborn as sns

def merge_counts(parent_directory):
    dataframes = []

    gFilename = '*counts_gene.txt'
    tFilename = '*CPM_transcript.txt'
    tcFilename = '*counts_transcript.txt'
    fltFilename = '*fullLengthCounts_transcript.txt'
    uctFilename = '*uniqueCounts_transcript.txt'

    gPattern = os.path.join(parent_directory, gFilename)
    tPattern = os.path.join(parent_directory, tFilename)
    tcPattern = os.path.join(parent_directory, tcFilename)
    fltPattern = os.path.join(parent_directory, fltFilename)
    uctPattern = os.path.join(parent_directory, uctFilename)

    gBambu_matrices = glob.glob(gPattern)
    tBambu_matrices = glob.glob(tPattern)
    tcBambu_matrices = glob.glob(tcPattern)
    fltBambu_matrices = glob.glob(fltPattern)
    uctBambu_matrices = glob.glob(uctPattern)

    first = True

    df_merged_counts = pd.DataFrame()
    df_merged_tpm = pd.DataFrame()
    df_merged_tcm = pd.DataFrame()
    df_merged_fltm = pd.DataFrame()
    df_merged_uctm = pd.DataFrame()

    for m in gBambu_matrices:
        df_counts = pd.read_csv(m, sep='\t', low_memory=False, header=0)
        if first:
            df_merged_counts = df_counts.copy()
            first = False
        else:
            df_merged_counts = pd.concat([df_merged_counts, df_counts.iloc[:,1:]], axis=1)

    first = True
    for m in tBambu_matrices:
        df_tpm = pd.read_csv(m, sep='\t', low_memory=False, header=0)
        if first:
            df_merged_tpm = df_tpm.copy()
            first = False
        else:
            df_merged_tpm = pd.concat([df_merged_tpm,df_tpm.iloc[:,2:]], axis=1)
    first = True
    for m in tcBambu_matrices:
        df_tcm = pd.read_csv(m, sep='\t', low_memory=False, header=0)
        if first:
            df_merged_tcm = df_tcm.copy()
            first = False
        else:
            df_merged_tcm = pd.concat([df_merged_tcm, df_tcm.iloc[:,2:]], axis=1)
    first = True
    for m in fltBambu_matrices:
        df_flt = pd.read_csv(m, sep='\t', low_memory=False, header=0)
        if first:
            df_merged_fltm = df_flt.copy()
            first = False
        else:
            df_merged_fltm = pd.concat([df_merged_fltm, df_flt.iloc[:,2:]], axis=1)
    first = True
    for m in uctBambu_matrices:
        df_uctm = pd.read_csv(m, sep='\t', low_memory=False, header=0)
        if first:
            df_merged_uctm = df_uctm.copy()
            first = False
        else:
            df_merged_uctm = pd.concat([df_merged_uctm, df_uctm.iloc[:,2:]], axis=1)
    return df_merged_counts, df_merged_tpm, df_merged_tcm, df_merged_fltm, df_merged_uctm

parent_directory = sys.argv[1]

name = sys.argv[2]

gene_name = name + "_combined_counts_gene.txt"
transcript_name = name + "_combined_CPM_transcript.txt"
tc_name = name + "_combined_counts_transcript.txt"
flt_name = name + "_combined_fullLengthCounts_transcript.txt"
uct_name = name + "_combined_uniqueCounts_transcript.txt"

df1, df2, df3, df4, df5 = merge_counts(parent_directory)

df1.to_csv(gene_name, sep='\t', index=False)
df2.to_csv(transcript_name, sep='\t', index=False)
df3.to_csv(tc_name, sep='\t', index=False)
df4.to_csv(flt_name, sep='\t', index=False)
df5.to_csv(uct_name, sep='\t', index=False)

