#!/bin/bash
#SBATCH --time=3-0:00:00
#SBATCH --job-name=SCP_S0_demux_test
#SBATCH --ntasks=1
#SBATCH --cpus-per-task 1
#SBATCH --mem-per-cpu 400G
#SBATCH --partition=normal
#SBATCH -e slurm-%j.err
#SBATCH -o slurm-%j.out
#SBATCH -A coa_mteb223_uksr

time nextflow ../../workflow/main.nf \
        --sample_id_table "/pscratch/mteb223_uksr/BRENDAN_SINGLE_CELL/single_cell_nextflow_pipeline/datasets/test_data/TCell_test/test_sample_id_to_folder.tsv" \
	--ont_reads_fq_dir "/pscratch/mteb223_uksr/BRENDAN_SINGLE_CELL/single_cell_nextflow_pipeline/datasets/test_data/TCell_test/" \
	--use_split true \
        --out_dir "Tcell_test_barcode_test" \
        --demultiplex_name "Tcell_test_barcode_test" \
        --step 0 #\
#	-resume #\
# --ont_reads_fq_dir "results/Tcell_test/pre_processing/merged_fastq/" \
