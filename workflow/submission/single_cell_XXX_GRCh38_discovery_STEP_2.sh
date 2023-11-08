#!/usr/bin/env bash

#
    # --ont_reads_txt "/scratch/bag222/data/ont_data/R10_V14_cDNA_Test_202310/final_data/*.txt" \
    # --contamination_ref "../../references/master_contaminant_reference.fasta" \
    # --housekeeping "../../references/hg38.HouseKeepingGenes.bed" \

nextflow ../main.nf --ont_reads_fq "/scratch/mteb223/PIPSeq/mouseBrain/test_corrected/*.fastq" \
    --ref "/project/mteb223_uksr/sequencing_resources/references/Ensembl/mouse_m39_soft_mask/Mus_musculus.GRCm39.dna_sm.primary_assembly.fa" \
    --annotation "/project/mteb223_uksr/sequencing_resources/annotations/Ensembl/mouse_m39_release_110/Mus_musculus.GRCm39.110.gtf" \
    --cdna_kit "PCS111" \
    --out_dir "./44B_Cerebellum_test_results/" \
    --is_discovery "False" \
    --bambu_track_reads "True" \
    --mapq "10" \
    --step "2" \
    --is_chm13 "False" -resume
