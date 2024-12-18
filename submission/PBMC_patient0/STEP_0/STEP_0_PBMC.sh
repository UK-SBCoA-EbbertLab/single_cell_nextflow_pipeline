#!/bin/bash
#SBATCH --time=14-0:00:00
#SBATCH --job-name=SCP_S0_demux_PBMC
#SBATCH --ntasks=1
#SBATCH --cpus-per-task 1
#SBATCH --mem-per-cpu 10G
#SBATCH --partition=normal
#SBATCH -e slurm-%j.err
#SBATCH -o slurm-%j.out
#SBATCH -A coa_mteb223_uksr

time nextflow ../../../workflow/main.nf \
	--sample_id_table "/pscratch/mteb223_uksr/BRENDAN_SINGLE_CELL/single_cell_nextflow_pipeline/datasets/PBMC/PBMC_patient0/sample_id_to_folder.tsv" \
	--ont_reads_fq_dir "/pscratch/mteb223_uksr/BRENDAN_SINGLE_CELL/single_cell_nextflow_pipeline/datasets/PBMC/PBMC_patient0/" \
	--out_dir "PBMC_patient0_OCT_31_2024" \
        --demultiplex_name "PBMC_patient0_OCT_31_2024" \
        --step 0 \
	-with-report \
	-with-timeline \
	-with-trace \
	-with-dag \
	-resume
	#--ont_reads_fq_dir "/pscratch/mteb223_uksr/BRENDAN_SINGLE_CELL/single_cell_nextflow_pipeline/submission/PBMC_patient0/results/PBMC_patient0/pre_processing/merged_fastq/" \
