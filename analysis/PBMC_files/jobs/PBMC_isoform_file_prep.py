import os
import tempfile

from anndata import AnnData
#import anndata as ad
import muon
import numpy as np
import requests
import io
import scanpy as sc
import scvi
import seaborn as sns
import torch
import pandas as pd
#from biomart import BiomartServer
#from bioservices import BioMart
import rdata
import matplotlib.pyplot as plt
from adjustText import adjust_text
from scipy.stats import beta

sc.set_figure_params(figsize=(6, 6), frameon=False)
sns.set_theme()
torch.set_float32_matmul_precision("high")
save_dir = tempfile.TemporaryDirectory()

# Define the output directory relative to the current working directory
output_dir = './SCVI_python_files/'

os.makedirs(output_dir, exist_ok=True)

# You can now use output_dir to save your file s
print(f"Output directory is set to: {output_dir}")

## Load isoform data
## Define the path to your count matrix file
PBMC1_iso_path = 'Raw_Data/PBMC1_combined_counts_transcript.txt'
PBMC2_iso_path = 'Raw_Data/PBMC2_combined_counts_transcript.txt'

PBMC1_iso_data = pd.read_csv(PBMC1_iso_path, sep="\t")
PBMC1_iso_IDs = PBMC1_iso_data[['TXNAME', 'GENEID']]

PBMC2_iso_data = pd.read_csv(PBMC2_iso_path, sep="\t")
PBMC2_iso_IDs = PBMC2_iso_data[['TXNAME', 'GENEID']]

# Save the raw data first for backup
PBMC1_iso_data.to_pickle("PBMC1_isoform_data.raw.pkl")
PBMC1_iso_IDs.to_pickle("PBMC1_isoform_IDs.raw.pkl")
PBMC2_iso_data.to_pickle("PBMC2_isoform_data.raw.pkl")
PBMC2_iso_IDs.to_pickle("PBMC2_isoform_IDs.raw.pkl")

# Subset the isoform data with only Ensembl IDs starting with "ENST"
iso_valid_indices_1 = PBMC1_iso_IDs['TXNAME'].str.startswith("ENST")
iso_valid_gene_ids_1 = PBMC1_iso_IDs['GENEID'][iso_valid_indices_1]
iso_valid_indices_2 = PBMC2_iso_IDs['TXNAME'].str.startswith("ENST")
iso_valid_gene_ids_2 = PBMC2_iso_IDs['GENEID'][iso_valid_indices_2]

# Subset the isoform data based on valid indices
PBMC1_iso_data_ENST = PBMC1_iso_data[iso_valid_indices_1]
PBMC2_iso_data_ENST = PBMC2_iso_data[iso_valid_indices_2]

# Sort the subsetted isoform data by "TXNAME"
PBMC1_iso_data_ENST = PBMC1_iso_data_ENST.sort_values(by='TXNAME')
PBMC2_iso_data_ENST = PBMC2_iso_data_ENST.sort_values(by='TXNAME')

# Select only "TXNAME" and "GENEID" columns
PBMC1_iso_IDs_ENST = PBMC1_iso_data_ENST[['TXNAME', 'GENEID']]
PBMC2_iso_IDs_ENST = PBMC2_iso_data_ENST[['TXNAME', 'GENEID']]

# Save the subsetted and sorted data
PBMC1_iso_data_ENST.to_pickle("PBMC1_iso_data.ENST.pkl")
PBMC1_iso_IDs_ENST.to_pickle("PBMC1_iso_IDs.ENST.pkl")
PBMC2_iso_data_ENST.to_pickle("PBMC2_iso_data.ENST.pkl")
PBMC2_iso_IDs_ENST.to_pickle("PBMC2_iso_IDs.ENST.pkl")
