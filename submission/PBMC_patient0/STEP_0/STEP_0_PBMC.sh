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
	--sample_id_table "/pscratch/mteb223_uksr/BRENDAN_SINGLE_CELL/single_cell_nextflow_pipeline/datasets/PBMC/PBMC_patient0_rebasecalled/sample_id_to_folder.tsv" \
	--ont_reads_fq_dir "/pscratch/mteb223_uksr/BRENDAN_SINGLE_CELL/single_cell_nextflow_pipeline/datasets/PBMC/PBMC_patient0_rebasecalled/" \
	--out_dir "PBMC_rebasecalled_FEB_2025_update" \
        --demultiplex_name "PBMC_rebasecalled_FEB_2025_update" \
	--cdna_kit "PCS114" \
	--qscore_thresh "9" \
	--barcode_thresh 100 \
	--mpldir "/scratch/mlpa241/mpl_config" \
        --step 0 \
	-with-report \
	-with-timeline \
	-with-trace #\
#	-resume
#	-with-dag \
#	--sample_id_table "/pscratch/mteb223_uksr/BRENDAN_SINGLE_CELL/single_cell_nextflow_pipeline/datasets/PBMC/PBMC_patient0/sample_id_to_folder.tsv" \
#	--ont_reads_fq_dir "/pscratch/mteb223_uksr/BRENDAN_SINGLE_CELL/single_cell_nextflow_pipeline/datasets/PBMC/PBMC_patient0/" \
#	--out_dir "PBMC_patient0_JAN_16_2024" \
#        --demultiplex_name "PBMC_patient0_JAN_16_2024" \

#	--sample_id_table "/pscratch/mteb223_uksr/BRENDAN_SINGLE_CELL/single_cell_nextflow_pipeline/datasets/PBMC/PBMC_small_test/sample_id_to_folder.tsv" \
#	--ont_reads_fq_dir "/pscratch/mteb223_uksr/BRENDAN_SINGLE_CELL/single_cell_nextflow_pipeline/datasets/PBMC/PBMC_small_test/" \
#        --demultiplex_name "PBMC_patient0_small_test_JAN_2024" \
