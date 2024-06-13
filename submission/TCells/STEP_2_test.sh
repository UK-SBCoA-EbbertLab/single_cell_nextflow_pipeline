#!/bin/bash

nextflow ../../workflow/main.nf \
    --step "2" \
    --is_dRNA "False" \
    --ont_reads_fq "./results/Tcell_test/pre_processing/demultiplexed/**/*.fastq" \
    --ref "/project/mteb223_uksr/sequencing_resources/references/Ensembl/hg38_release_112/dna/Homo_sapiens.GRCh38.dna.primary_assembly.fa" \
    --annotation "/project/mteb223_uksr/sequencing_resources/annotations/Ensembl/hg38_release_112/Homo_sapiens.GRCh38.112.chr.gtf" \
    --out_dir "Tcell_test" \
    --cdna_kit "PCS114" \
    --housekeeping "../../references/hg38.HouseKeepingGenes.bed" \
    --mapq "10" \
    --contamination_ref "../../references/master_contaminant_reference.fasta" \
    --track_reads "True" \
    --is_chm13 "False" \
    --mapped_reads_thresh 1 \
    -resume
