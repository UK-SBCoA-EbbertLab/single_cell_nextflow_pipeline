#!/usr/bin/env bash

#
    # --ont_reads_txt "/scratch/bag222/data/ont_data/R10_V14_cDNA_Test_202310/final_data/*.txt" \
    # --contamination_ref "../../references/master_contaminant_reference.fasta" \
    # --housekeeping "../../references/hg38.HouseKeepingGenes.bed" \

#SBATCH --time=6-0:00:00
#SBATCH --job-name=Human3_fresh_unmapped
#SBATCH --ntasks=1
#SBATCH --cpus-per-task 1
#SBATCH --mem-per-cpu 100G
#SBATCH --partition=normal
#SBATCH -e slurm-%j.err
#SBATCH -o slurm-%j.out
#SBATCH -A coa_mteb223_uksr

nextflow ../../../workflow/main.nf \
	--step 2 \
	--path "/pscratch/mteb223_uksr/BRENDAN_SINGLE_CELL/single_cell_nextflow_pipeline/datasets/Human3_CortexChoroidPlexus_FreshFrozenSC/00_All_Fresh/" \
	--ref "/project/mteb223_uksr/sequencing_resources/references/Ensembl/hg38_release_113/dna/Homo_sapiens.GRCh38.dna.primary_assembly.fa" \
	--annotation "/project/mteb223_uksr/sequencing_resources/annotations/Ensembl/hg38_release_113/Homo_sapiens.GRCh38.113.chr.gtf" \
	--housekeeping "../../../references/hg38.HouseKeepingGenes.bed" \
	--out_dir "Human3_fresh_DEC_17_2024_with_contamination" \
	--cdna_kit "PCS114" \
	--is_chm13 "False" \
	--mapq 10 \
	--is_dRNA "False" \
	--contamination_ref "../../../contamination_reference_doc/master_contaminant_reference.fasta" \
	--qscore_thresh 9 \
	-with-trace \
	-with-dag \
	-preview \
	-resume

