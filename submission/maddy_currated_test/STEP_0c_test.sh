#!/bin/bash
#SBATCH --time=3-0:00:00
#SBATCH --job-name=TEST_SCP_S0_demux
#SBATCH --ntasks=1
#SBATCH --cpus-per-task 1
#SBATCH --mem-per-cpu 400G
#SBATCH --partition=normal
#SBATCH -e slurm-%j.err
#SBATCH -o slurm-%j.out
#SBATCH -A cca_mteb223_uksr

nextflow ../../workflow/main.nf \
	--demulti_fastqs "results/maddy_testing_sc_st0/pre_processing/demultiplexed/*/*" \
        --out_dir "maddy_testing_sc_st0" \
        --demultiplex_name "maddy_testing_sc_st0" \
        --step "0c" \
	-resume #\
	#--ont_reads_fq_dir "/pscratch/mteb223_uksr/BRENDAN_SINGLE_CELL/single_cell_nextflow_pipeline/datasets/test_data/TCell_test/" \
