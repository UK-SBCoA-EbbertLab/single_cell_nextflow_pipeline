#!/bin/bash


#SBATCH --time=3-0:00:00
#SBATCH --job-name=PBMC_bulk
#SBATCH --ntasks=1
#SBATCH --cpus-per-task 1
#SBATCH --mem-per-cpu 400G
#SBATCH --partition=normal
#SBATCH -e slurm-%j.err
#SBATCH -o slurm-%j.out
#SBATCH -A coa_mteb223_uksr

nextflow ../../workflow/main.nf \
	--ont_reads_fq "/pscratch/mteb223_uksr/BRENDAN_SINGLE_CELL/single_cell_nextflow_pipeline/submission/PBMC_patient0/STEP_c/results/PBMC_patient0/pre_processing/merged_fastq/*.fastq" \
	--ref "/project/mteb223_uksr/sequencing_resources/references/Ensembl/hg38_release_112/dna/Homo_sapiens.GRCh38.dna.primary_assembly.fa" \
	--annotation "/project/mteb223_uksr/sequencing_resources/annotations/Ensembl/hg38_release_112/Homo_sapiens.GRCh38.112.chr.gtf" \
	--cdna_kit "PCS114" \
	--out_dir "PBMC_patient0_Aug_22_2024" \
	--is_discovery "True" \
	--track_reads "True" \
	--mapq "10" \
	--step "2" \
	--is_chm13 "False" #\
#	-resume
	

#
    # --ont_reads_txt "/scratch/bag222/data/ont_data/R10_V14_cDNA_Test_202310/final_data/*.txt" \
    # --contamination_ref "../../references/master_contaminant_reference.fasta" \
    # --housekeeping "../../references/hg38.HouseKeepingGenes.bed" \
