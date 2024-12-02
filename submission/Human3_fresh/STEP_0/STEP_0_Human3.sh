#!/bin/bash
#SBATCH --time=14-0:00:00
#SBATCH --job-name=SCPS0_demux_Human3
#SBATCH --ntasks=1
#SBATCH --cpus-per-task 1
#SBATCH --mem-per-cpu 10G
#SBATCH --partition=normal
#SBATCH -e slurm-%j.err
#SBATCH -o slurm-%j.out
#SBATCH -A coa_mteb223_uksr

time nextflow ../../../workflow/main.nf \
	--sample_id_table "/pscratch/mteb223_uksr/BRENDAN_SINGLE_CELL/single_cell_nextflow_pipeline/datasets/Human3_CortexChoroidPlexus_FreshFrozenSC/sample_id_to_folder.tsv" \
	--ont_reads_fq_dir "/pscratch/mteb223_uksr/BRENDAN_SINGLE_CELL/single_cell_nextflow_pipeline/datasets/Human3_CortexChoroidPlexus_FreshFrozenSC/" \
	--out_dir "Human3_fresh_NOV_2024" \
        --demultiplex_name "Human3_fresh_NOV_2024" \
	--n_threads 10 \
	--barcode_thresh 100 \
        --step 0 \
	-with-report \
	-with-timeline \
	-with-trace \
	-resume
	#--ont_reads_fq_dir "/pscratch/mteb223_uksr/BRENDAN_SINGLE_CELL/single_cell_nextflow_pipeline/submission/PBMC_patient0/results/PBMC_patient0/pre_processing/merged_fastq/" \
	#-with-dag \
