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
from anndata import read_h5ad

sc.set_figure_params(figsize=(6, 6), frameon=False)
sns.set_theme()
torch.set_float32_matmul_precision("high")
save_dir = tempfile.TemporaryDirectory()

# Define the output directory relative to the current working directory
output_dir = './SCVI_python_files'
os.makedirs(output_dir, exist_ok=True)

# You can now use output_dir to save your file s
print(f"Output directory is set to: {output_dir}")


# Define the folder path
folder_path = "SCVI_python_files"

# Load the AnnData objects
PBMC1_gene = read_h5ad(os.path.join(folder_path, "PBMC1_gene_AnnData.h5ad"))
PBMC2_gene = read_h5ad(os.path.join(folder_path, "PBMC2_gene_AnnData.h5ad"))
PBMC1_iso = read_h5ad(os.path.join(folder_path, "PBMC1_iso_AnnData.h5ad"))
PBMC2_iso = read_h5ad(os.path.join(folder_path, "PBMC2_iso_AnnData.h5ad"))

# Verify the structure
print(PBMC1_gene)
print(PBMC2_gene)
print(PBMC1_iso)
print(PBMC2_iso)

# Initial cell counts
init_cell_counts_1 = PBMC1_gene.n_obs
init_cell_counts_2 = PBMC2_gene.n_obs

init_cell_counts_df = pd.DataFrame({
    'Sample': ['PBMC1', 'PBMC2'],
    'Initial Cell #': [init_cell_counts_1, init_cell_counts_2]
})

print(init_cell_counts_df)

# Calculate percent mitochondrial reads
PBMC1_gene.var["mt"] =PBMC1_gene.var_names.str.startswith("MT-")
PBMC2_gene.var["mt"] = PBMC2_gene.var_names.str.startswith("MT-")
PBMC1_iso.var["mt"] =PBMC1_iso.var_names.str.startswith("MT-")
PBMC2_iso.var["mt"] = PBMC2_iso.var_names.str.startswith("MT-")

# hemoglobin genes
PBMC1_gene.var["hb"] = PBMC1_gene.var_names.str.contains("^HB[^(P)]")
PBMC2_gene.var["hb"] = PBMC2_gene.var_names.str.contains("^HB[^(P)]")
PBMC1_iso.var["hb"] = PBMC1_iso.var_names.str.contains("^HB[^(P)]")
PBMC2_iso.var["hb"] = PBMC2_iso.var_names.str.contains("^HB[^(P)]")

sc.pp.calculate_qc_metrics(
    PBMC1_gene, qc_vars=["mt", "hb"], inplace=True, log1p=True
)

sc.pp.calculate_qc_metrics(
    PBMC2_gene, qc_vars=["mt", "hb"], inplace=True, log1p=True
)

sc.pp.calculate_qc_metrics(
    PBMC1_iso, qc_vars=["mt", "hb"], inplace=True, log1p=True
)

sc.pp.calculate_qc_metrics(
    PBMC2_iso, qc_vars=["mt", "hb"], inplace=True, log1p=True
)

# Calculate the number of cells in which each gene is detected
PBMC1_gene_counts = np.sum(PBMC1_gene.X > 0, axis=0)

# If gene_counts is a sparse matrix, convert it to a dense array
if isinstance(PBMC1_gene_counts, np.matrix):
    gene_counts = np.array(gene_counts).flatten()

# Calculate the number of cells in which each gene is detected
PBMC2_gene_counts = np.sum(PBMC2_gene.X > 0, axis=0)

# If gene_counts is a sparse matrix, convert it to a dense array
if isinstance(PBMC2_gene_counts, np.matrix):
    gene_counts = np.array(gene_counts).flatten()

# Identify genes detected in fewer than the lower threshold of cells (e.g., 5 cells)
lower_threshold = 5
PBMC1_genes_to_remove = PBMC1_gene.var_names[PBMC1_gene_counts < lower_threshold]
PBMC2_genes_to_remove = PBMC2_gene.var_names[PBMC2_gene_counts < lower_threshold]

# Display the genes that will be removed
print("Genes to remove from PBMC1:", PBMC1_genes_to_remove)
print("Genes to remove from PBMC2:", PBMC2_genes_to_remove)

# Assuming PBMC1_gene is an AnnData object, extract the isoform IDs from var_names
P1_isoform_IDs = PBMC1_iso.var_names

# Convert to a list (if needed)
P1_isoform_ID_list = P1_isoform_IDs.tolist()

# Print the first few isoform IDs to verify
print(P1_isoform_ID_list[:10])  # Show the first 10 isoform IDs

# Assuming PBMC1_gene is an AnnData object, extract the isoform IDs from var_names
P2_isoform_IDs = PBMC2_iso.var_names

# Convert to a list (if needed)
P2_isoform_ID_list = P2_isoform_IDs.tolist()

# Print the first few isoform IDs to verify
print(P2_isoform_ID_list[:10])  # Show the first 10 isoform IDs

# Filter the isoform IDs based on both GENEID and ENSEMBLEID
# Filter the isoform IDs based on the GENEID:ENSEMBLEID combinations to remove
# Define a function to filter isoforms based on GENEID:ENSEMBLEID
def filter_isoform_data(adata, genes_to_remove):
    # Extract the isoform IDs (var_names) in the format GENEID:ENSEMBLEID:ISOFORMID
    isoform_ids = adata.var_names
    
    # Filter out isoforms where GENEID:ENSEMBLEID matches the ones to remove
    mask = ~isoform_ids.str.startswith(tuple(genes_to_remove))  # Create a mask for isoforms to keep
    
    # Filter the AnnData object
    adata_filtered = adata[:, mask].copy()  # Filter the columns (features/isoforms) based on the mask
    
    return adata_filtered

# Filter PBMC1 and PBMC2 isoform data based on the combined genes to remove
filtered_PBMC1_iso = filter_isoform_data(PBMC1_iso, PBMC1_genes_to_remove)
filtered_PBMC2_iso = filter_isoform_data(PBMC2_iso, PBMC2_genes_to_remove)
filtered_PBMC1_gene = filter_isoform_data(PBMC1_iso, PBMC1_genes_to_remove)
filtered_PBMC2_gene = filter_isoform_data(PBMC2_iso, PBMC2_genes_to_remove)

# Display the filtered isoform data shapes
print("Filtered PBMC1 isoform data shape:", filtered_PBMC1_iso.shape)
print("Filtered PBMC2 isoform data shape:", filtered_PBMC2_iso.shape)

# Define quality control thresholds per cell
mt_upper_threshold = 15
hb_lower_threshold = 5
hb_upper_threshold = 94
total_counts_lower_threshold = 200
total_counts_upper_threshold = 15000
n_genes_lower_threshold = 250
n_genes_upper_threshold = 2500

PBMC1_gene = filtered_PBMC1_gene[
    (filtered_PBMC1_gene.obs['total_counts'].between(total_counts_lower_threshold, total_counts_upper_threshold)) &
    (filtered_PBMC1_gene.obs['n_genes_by_counts'].between(n_genes_lower_threshold, n_genes_upper_threshold)) &
    (filtered_PBMC1_gene.obs['pct_counts_mt'] < mt_upper_threshold) &
    (filtered_PBMC1_gene.obs['pct_counts_hb'] < hb_lower_threshold) |
    (filtered_PBMC1_gene.obs['pct_counts_hb'] > hb_upper_threshold), :
]

print("PBMC1 gene data shape after filtering:", PBMC1_gene.shape)

PBMC2_gene = filtered_PBMC2_gene[
    (filtered_PBMC2_gene.obs['total_counts'].between(total_counts_lower_threshold, total_counts_upper_threshold)) &
    (filtered_PBMC2_gene.obs['n_genes_by_counts'].between(n_genes_lower_threshold, n_genes_upper_threshold)) &
    (filtered_PBMC2_gene.obs['pct_counts_mt'] < mt_upper_threshold) &
    (filtered_PBMC2_gene.obs['pct_counts_hb'] < hb_lower_threshold) |
    (filtered_PBMC2_gene.obs['pct_counts_hb'] > hb_upper_threshold), :
]

print("PBMC2 gene data shape after filtering:", PBMC2_gene.shape)

PBMC1_iso = filtered_PBMC1_iso[
    (filtered_PBMC1_iso.obs['total_counts'].between(total_counts_lower_threshold, total_counts_upper_threshold)) & 
    (filtered_PBMC1_iso.obs['n_genes_by_counts'].between(n_genes_lower_threshold, n_genes_upper_threshold)) & 
    (filtered_PBMC1_iso.obs['pct_counts_mt'] < mt_upper_threshold) & 
    (filtered_PBMC1_iso.obs['pct_counts_hb'] < hb_lower_threshold) |
    (filtered_PBMC1_iso.obs['pct_counts_hb'] > hb_upper_threshold), :
]

print("PBMC1 iso data shape after filtering:", PBMC1_iso.shape)

PBMC2_iso = filtered_PBMC2_iso[
    (filtered_PBMC2_iso.obs['total_counts'].between(total_counts_lower_threshold, total_counts_upper_threshold)) & 
    (filtered_PBMC2_iso.obs['n_genes_by_counts'].between(n_genes_lower_threshold, n_genes_upper_threshold)) & 
    (filtered_PBMC2_iso.obs['pct_counts_mt'] < mt_upper_threshold) & 
    (filtered_PBMC2_iso.obs['pct_counts_hb'] < hb_lower_threshold) |
    (filtered_PBMC2_iso.obs['pct_counts_hb'] > hb_upper_threshold), :
]

print("PBMC2 iso data shape after filtering:", PBMC2_iso.shape)

# Post QC cell counts
post_qc_cell_counts_1 = PBMC1_gene.n_obs
post_qc_cell_counts_2 = PBMC2_gene.n_obs

post_qc_cell_counts_df = pd.DataFrame({
    'Sample': ['PBMC1', 'PBMC2'],
    'Initial Counts': [PBMC1_gene.n_obs, PBMC2_gene.n_obs],
    'Post QC Counts': [post_qc_cell_counts_1, post_qc_cell_counts_2],
    'Percent Remaining': [post_qc_cell_counts_1 / PBMC1_gene.n_obs * 100, post_qc_cell_counts_2 / PBMC2_gene.n_obs * 100]
})

print(post_qc_cell_counts_df)

# Save the AnnData objects
PBMC1_gene.write("PBMC1_gene_filtered_standard.h5ad")
PBMC2_gene.write("PBMC2_gene_filtered_standard.h5ad")

PBMC1_iso.write("PBMC1_iso_filtered_standard.h5ad")
PBMC2_iso.write("PBMC2_iso_filtered_standard.h5ad")
