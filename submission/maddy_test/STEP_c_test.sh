#!/bin/bash
#SBATCH --time=3-0:00:00
#SBATCH --job-name=SCP_Sc_test
#SBATCH --ntasks=1
#SBATCH --cpus-per-task 1
#SBATCH --mem-per-cpu 400G
#SBATCH --partition=normal
#SBATCH -e slurm-%j.err
#SBATCH -o slurm-%j.out
#SBATCH -A coa_mteb223_uksr

nextflow ../../workflow/main.nf \
	--out_dir "Tcell_test" \
	--ont_fq_to_merge "/pscratch/mteb223_uksr/BRENDAN_SINGLE_CELL/single_cell_nextflow_pipeline/datasets/test_data/TCell_test/" \
        --sample_id_table "/pscratch/mteb223_uksr/BRENDAN_SINGLE_CELL/single_cell_nextflow_pipeline/datasets/test_data/TCell_test/test_sample_id_to_folder.tsv" \
        --step c
