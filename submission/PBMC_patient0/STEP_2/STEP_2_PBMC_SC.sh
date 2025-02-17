#!/bin/bash
#SBATCH --time=7-0:00:00
#SBATCH --job-name=SCP_S2_bambu_prep_PBMC
#SBATCH --ntasks=1
#SBATCH --cpus-per-task 1
#SBATCH --mem-per-cpu 400G
#SBATCH --partition=normal
#SBATCH -e slurm-%j.err
#SBATCH -o slurm-%j.out
#SBATCH -A coa_mteb223_uksr

nextflow ../../../workflow/main.nf \
    --step "2" \
    --ont_reads_fq "../STEP_0/results/PBMC_rebasecalled_FEB_10_2025/pre_processing/06_demultiplexed/**/*.fastq" \
    --ref "/project/mteb223_uksr/sequencing_resources/references/Ensembl/hg38_release_113/dna/Homo_sapiens.GRCh38.dna.primary_assembly.fa" \
    --annotation "../../../cDNA_pipeline/submission/PBMC_patien0/STEP_3/results/PBMC_rebasecalled_bulk_discovery_FEB_11_2025_with_contamination/bambu_discovery/extended_annotations.gtf" \
    --out_dir "PBMC_patient0_FEB_11_2025_bambu_quant" \
    --mapq "10" \
    --track_reads "True" \
    --mapped_reads_thresh 100 \
    -with-trace \
    -with-timeline \
    -with-report \
    -resume
