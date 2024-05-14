#!/usr/bin/env bash

#
    # --ont_reads_txt "/scratch/bag222/data/ont_data/R10_V14_cDNA_Test_202310/final_data/*.txt" \
    # --contamination_ref "../../references/master_contaminant_reference.fasta" \
    # --housekeeping "../../references/hg38.HouseKeepingGenes.bed" \

#SBATCH --time=3-0:00:00
#SBATCH --job-name=43BHEK_unmapped
#SBATCH --ntasks=1
#SBATCH --cpus-per-task 1
#SBATCH --mem-per-cpu 400G
#SBATCH --partition=normal
#SBATCH -e slurm-%j.err
#SBATCH -o slurm-%j.out
#SBATCH -A coa_mteb223_uksr

nextflow ../../workflow/main.nf --bambu_rds "./results/44B_Cerebellum_discovery/bambu_prep/*.rds" \
    --ref "/project/mteb223_uksr/sequencing_resources/references/Ensembl/mouse_m39_soft_mask/Mus_musculus.GRCm39.dna_sm.primary_assembly.fa" \
    --fai "./results/44B_Cerebellum_discovery/fai/*.fai" \
    --annotation "/scratch/bjwh228/cDNA_pipeline/submission/results/Mouse_Brain_discovery/bambu_discovery/extended_annotations.gtf" \
    --multiqc_input "./results/44B_Cerebellum_discovery/multiQC_input/**" \
    --multiqc_config "/pscratch/mteb223_uksr/single_cell_pipeline_test/cDNA_pipeline_single_cell/references/multiqc_config.yaml" \
    --out_dir "44B_Cerebellum_discovery" \
    --is_discovery "False" \
    --track_reads "True" \
    --step "3" \
    --is_chm13 "False"
