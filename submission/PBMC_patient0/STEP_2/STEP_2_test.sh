#!/bin/bash
#SBATCH --time=3-0:00:00
#SBATCH --job-name=SCP_S2_bambu_prep_PBMC
#SBATCH --ntasks=1
#SBATCH --cpus-per-task 1
#SBATCH --mem-per-cpu 400G
#SBATCH --partition=normal
#SBATCH -e slurm-%j.err
#SBATCH -o slurm-%j.out
#SBATCH -A coa_mteb223_uksr

nextflow ../../workflow/main.nf \
    --step "2" \
    --is_dRNA "False" \
    --ont_reads_fq "results/PBMC_patient0/pre_processing/demultiplexed/**/*.fastq" \
    --ref "/project/mteb223_uksr/sequencing_resources/references/Ensembl/hg38_release_112/dna/Homo_sapiens.GRCh38.dna.primary_assembly.fa" \
    --annotation "/project/mteb223_uksr/sequencing_resources/annotations/Ensembl/hg38_release_112/Homo_sapiens.GRCh38.112.chr.gtf" \
    --out_dir "PBMC_patient0_no_discovery" \
    --cdna_kit "PCS114" \
    --housekeeping "../../references/hg38.HouseKeepingGenes.bed" \
    --mapq "10" \
    --contamination_ref "../../references/master_contaminant_reference.fasta" \
    --track_reads "True" \
    --is_chm13 "False" \
    --mapped_reads_thresh 100 \
    -resume
