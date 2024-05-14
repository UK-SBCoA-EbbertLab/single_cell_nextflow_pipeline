#!/bin/bash
#SBATCH --time=3-0:00:00
#SBATCH --job-name=CP3f_demux
#SBATCH --ntasks=1
#SBATCH --cpus-per-task 1
#SBATCH --mem-per-cpu 400G
#SBATCH --partition=normal
#SBATCH -e slurm-%j.err
#SBATCH -o slurm-%j.out
#SBATCH -A coa_mteb223_uksr

nextflow ../../workflow/main.nf --ont_reads_fq_dir "/scratch/bjwh228/PHD-3-01_Full4_CD4Positive_TCell/Mouse_Brain/44B_Cerebellum/20230919_1750_1B_PAS39165_db8b7c46/fastq_pass/" \
        --out_dir "44B_Cerebellum" \
        --demultiplex_name "44B_Cerebellum" \
        --step 0
