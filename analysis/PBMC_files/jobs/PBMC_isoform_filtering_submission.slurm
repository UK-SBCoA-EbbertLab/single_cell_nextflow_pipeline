#!/bin/bash

#SBATCH --time=48:15:00             # Time limit for the job (REQUIRED).
#SBATCH --job-name=PBMC_isoform      # Job name
#SBATCH --ntasks=1                  # Number of cores for the job. Same as SBATCH -n 1
#SBATCH --mem=500G                  # Total memory requested
#SBATCH --partition=normal          # Partition/queue to run the job in. (REQUIRED)
#SBATCH -e slurm-%j.err             # Error file for this job.
#SBATCH -o slurm-%j.out             # Output file for this job.
#SBATCH -A coa_mteb223_uksr         # Project allocation account name (REQUIRED)



singularity exec /project/mteb223_uksr/singularity_files/jupyterR_and_py.sif python3 PBMC_isoform_filtering_file_prep.py
