#!/usr/bin/env bash

#
    # --ont_reads_txt "/scratch/bag222/data/ont_data/R10_V14_cDNA_Test_202310/final_data/*.txt" \
    # --contamination_ref "../../references/master_contaminant_reference.fasta" \
    # --housekeeping "../../references/hg38.HouseKeepingGenes.bed" \

#SBATCH --time=10-0:00:00
#SBATCH --job-name=Human3_fresh_discovery
#SBATCH --ntasks=1
#SBATCH --cpus-per-task 1
#SBATCH --mem-per-cpu 50G
#SBATCH --partition=normal
#SBATCH -e slurm-%j.err
#SBATCH -o slurm-%j.out
#SBATCH -A coa_mteb223_uksr

nextflow ../../../workflow/main.nf \
	--step "3" \
	--bambu_rds "/pscratch/mteb223_uksr/BRENDAN_SINGLE_CELL/cDNA_pipeline/submission/Human3_fresh/Step_2/results/Human3_fresh_DEC_17_2024_with_contamination/bambu_prep/*.rds" \
	--ref "/project/mteb223_uksr/sequencing_resources/references/Ensembl/hg38_release_113/dna/Homo_sapiens.GRCh38.dna.primary_assembly.fa" \
	--annotation "/project/mteb223_uksr/sequencing_resources/annotations/Ensembl/hg38_release_113/Homo_sapiens.GRCh38.113.chr.gtf" \
	--is_chm13 "False" \
	--fai "/pscratch/mteb223_uksr/BRENDAN_SINGLE_CELL/cDNA_pipeline/submission/Human3_fresh/Step_2/results/Human3_fresh_DEC_17_2024_with_contamination/fai/Homo_sapiens.GRCh38.dna.primary_assembly.fa.fai" \
	--out_dir "Human3_fresh_DEC_17_2024_with_contamination" \
	--is_discovery "True" \
	--NDR "auto" \
	--track_reads "True" \
	--intermediate_qc "/pscratch/mteb223_uksr/BRENDAN_SINGLE_CELL/cDNA_pipeline/submission/Human3_fresh/Step_2/results/Human3_fresh_DEC_17_2024_with_contamination/intermediate_qc_reports/" \
	--multiqc_input "/pscratch/mteb223_uksr/BRENDAN_SINGLE_CELL/cDNA_pipeline/submission/Human3_fresh/Step_2/results/Human3_fresh_DEC_17_2024_with_contamination/multiQC_input/**" \
	--multiqc_config "/pscratch/mteb223_uksr/BRENDAN_SINGLE_CELL/cDNA_pipeline/workflow/bin/multiqc_config.yaml" \
	-with-trace \
	-resume

