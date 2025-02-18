#!/usr/bin/env bash

#
    # --ont_reads_txt "/scratch/bag222/data/ont_data/R10_V14_cDNA_Test_202310/final_data/*.txt" \
    # --contamination_ref "../../references/master_contaminant_reference.fasta" \
    # --housekeeping "../../references/hg38.HouseKeepingGenes.bed" \

#SBATCH --time=6-0:00:00
#SBATCH --job-name=PBMC_bulk_test_s2
#SBATCH --ntasks=1
#SBATCH --cpus-per-task 1
#SBATCH --mem-per-cpu 100G
#SBATCH --partition=normal
#SBATCH -e slurm-%j.err
#SBATCH -o slurm-%j.out
#SBATCH -A coa_mteb223_uksr

nextflow ../../../workflow/main.nf \
	--step 2 \
	--ont_reads_fq "../../../../submission/PBMC_patient0/STEP_0/results/PBMC_rebasecalled_FEB_10_2025/pre_processing/concatenated_fastq_and_sequencing_summary_files/*.fastq" \
	--ont_reads_txt "../../../../submission/PBMC_patient0/STEP_0/results/PBMC_rebasecalled_FEB_10_2025/pre_processing/concatenated_fastq_and_sequencing_summary_files/*.txt" \
	--read_stats "../../../../submission/PBMC_patient0/STEP_0/results/PBMC_rebasecalled_FEB_10_2025/pre_processing/stats/**/*.combined_stats.json" \
	--ref "/project/mteb223_uksr/sequencing_resources/references/Ensembl/hg38_release_113/dna/Homo_sapiens.GRCh38.dna.primary_assembly.fa" \
	--annotation "/project/mteb223_uksr/sequencing_resources/annotations/Ensembl/hg38_release_113/Homo_sapiens.GRCh38.113.gtf" \
	--housekeeping "../../../references/hg38.HouseKeepingGenes.bed" \
	--out_dir "PBMC_rebasecalled_bulk_discovery_FEB_10_2025_with_contamination" \
	--cdna_kit "PCS114" \
	--is_chm13 "False" \
	--mapq 10 \
	--is_dRNA "False" \
	--contamination_ref "../../../contamination_reference_doc/master_contaminant_reference.fasta" \
	--qscore_thresh 9 \
	--tmpwritedir "/scratch/mlpa241/mpl_config/" \
	-with-trace \
	-with-timeline \
	-with-report #\
	#-resume
	#--ont_reads_txt "../../../../submission/PBMC_patient0/STEP_0/results/PBMC_rebasecalled_FEB_2025_update/pre_processing/concatenated_fastq_and_sequencing_summary_files/*.txt" \

