#!/bin/bash
#SBATCH --time=05:15:00             # Time limit for the job (REQUIRED).
#SBATCH --job-name=prepare_annotations      # Job name
#SBATCH --ntasks=1                  # Number of cores for the job. Same as SBATCH -n 1
#SBATCH --mem=100G                  # Total memory requested
#SBATCH --partition=normal          # Partition/queue to run the job in. (REQUIRED)
#SBATCH -e slurm-%j.err             # Error file for this job.
#SBATCH -o slurm-%j.out             # Output file for this job.
#SBATCH -A coa_mteb223_uksr         # Project allocation account name (REQUIRED)

singularity exec library://ebbertlab-madeline/pip_single_cell/nanopore:sha256.a50552a9ec75d90397d8c278a03927a7ea683b7279344922b41cf695f994c8a9 python prepare_comparison_annotations.py 
