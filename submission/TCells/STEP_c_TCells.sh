#!/bin/bash
#SBATCH --time=3-0:00:00
#SBATCH --job-name=SCP_Sc_TCells
#SBATCH --ntasks=1
#SBATCH --cpus-per-task 1
#SBATCH --mem-per-cpu 400G
#SBATCH --partition=normal
#SBATCH -e slurm-%j.err
#SBATCH -o slurm-%j.out
#SBATCH -A coa_mteb223_uksr

nextflow ../../workflow/main.nf \
	--out_dir "TCells" \
	--ont_fq_to_merge "/pscratch/mteb223_uksr/BRENDAN_SINGLE_CELL/single_cell_nextflow_pipeline/datasets/TCell/TCell_CD4_Full4_08302023/PHD-3-01_Full4_CD4Positive_TCell/" \
        --sample_id_table "/pscratch/mteb223_uksr/BRENDAN_SINGLE_CELL/single_cell_nextflow_pipeline/datasets/TCell/TCell_CD4_Full4_08302023/PHD-3-01_Full4_CD4Positive_TCell/sample_id_to_folder_id.tsv" \
        --step c \
	-resume
