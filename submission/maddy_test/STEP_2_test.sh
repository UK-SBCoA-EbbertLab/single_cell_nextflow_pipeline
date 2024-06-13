#!/bin/bash
#SBATCH --time=3-0:00:00
#SBATCH --job-name=SCP_S2_test
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
    --ont_reads_fq "./results/Tcell_test/pre_processing/demultiplexed/**/*.fastq" \
    --ref "/project/mteb223_uksr/sequencing_resources/references/Ensembl/hg38_release_112/dna/Homo_sapiens.GRCh38.dna.primary_assembly.fa" \
    --annotation "/pscratch/mteb223_uksr/BRENDAN_SINGLE_CELL/cDNA_pipeline/submission/maddy_test/results/maddy_tcell_test/bambu_discovery/extended_annotations.gtf" \
    --out_dir "Tcell_test" \
    --cdna_kit "PCS114" \
    --housekeeping "../../references/hg38.HouseKeepingGenes.bed" \
    --mapq "10" \
    --contamination_ref "../../references/master_contaminant_reference.fasta" \
    --track_reads "True" \
    --is_chm13 "False" \
    --mapped_reads_thresh 1
