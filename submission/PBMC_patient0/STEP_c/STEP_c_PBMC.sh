#!/bin/bash
#SBATCH --time=3-0:00:00
#SBATCH --job-name=SCP_Sc_PBMC
#SBATCH --ntasks=1
#SBATCH --cpus-per-task 1
#SBATCH --mem-per-cpu 400G
#SBATCH --partition=normal
#SBATCH -e slurm-%j.err
#SBATCH -o slurm-%j.out
#SBATCH -A coa_mteb223_uksr

time nextflow ../../../workflow/main.nf \
	--out_dir "PBMC_patient0_OCT_2024" \
	--ont_fq_to_merge "/pscratch/mteb223_uksr/BRENDAN_SINGLE_CELL/single_cell_nextflow_pipeline/datasets/PBMC/PBMC_patient0/" \
        --sample_id_table "/pscratch/mteb223_uksr/BRENDAN_SINGLE_CELL/single_cell_nextflow_pipeline/datasets/PBMC/PBMC_patient0/sample_id_to_folder.tsv" \
        --step c #\
#	-resume
