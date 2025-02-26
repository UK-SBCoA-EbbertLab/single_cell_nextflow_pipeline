#!/usr/bin/env bash

#
    # --ont_reads_txt "/scratch/bag222/data/ont_data/R10_V14_cDNA_Test_202310/final_data/*.txt" \
    # --contamination_ref "../../references/master_contaminant_reference.fasta" \
    # --housekeeping "../../references/hg38.HouseKeepingGenes.bed" \

#SBATCH --time=3-0:00:00
#SBATCH --job-name=TCell_discovery
#SBATCH --ntasks=1
#SBATCH --cpus-per-task 1
#SBATCH --mem-per-cpu 400G
#SBATCH --partition=normal
#SBATCH -e slurm-%j.err
#SBATCH -o slurm-%j.out
#SBATCH -A coa_mteb223_uksr

nextflow ../../../workflow/main.nf \
	--bambu_rds "/pscratch/mteb223_uksr/BRENDAN_SINGLE_CELL/single_cell_nextflow_pipeline/cDNA_pipeline/submission/PBMC_patien0/STEP_2/results/PBMC_rebasecalled_bulk_discovery_FEB_10_2025_with_contamination/bambu_prep/*.rds" \
	--ref "/project/mteb223_uksr/sequencing_resources/references/Ensembl/hg38_release_113/dna/Homo_sapiens.GRCh38.dna.primary_assembly.fa" \
	--fai "/project/mteb223_uksr/sequencing_resources/references/Ensembl/hg38_release_113/dna/Homo_sapiens.GRCh38.dna.primary_assembly.fa.fai" \
	--annotation "/project/mteb223_uksr/sequencing_resources/annotations/Ensembl/hg38_release_113/Homo_sapiens.GRCh38.113.gtf" \
	--is_discovery "True" \
	--track_reads "False" \
	--multiqc_input "/pscratch/mteb223_uksr/BRENDAN_SINGLE_CELL/single_cell_nextflow_pipeline/cDNA_pipeline/submission/PBMC_patien0/STEP_2/results/PBMC_rebasecalled_bulk_discovery_FEB_10_2025_with_contamination/multiQC_input/**" \
	--multiqc_config "/pscratch/mteb223_uksr/BRENDAN_SINGLE_CELL/single_cell_nextflow_pipeline/cDNA_pipeline/workflow/bin/multiqc_config.yaml" \
	--intermediate_qc "/pscratch/mteb223_uksr/BRENDAN_SINGLE_CELL/single_cell_nextflow_pipeline/cDNA_pipeline/submission/PBMC_patien0/STEP_2/results/PBMC_rebasecalled_bulk_discovery_FEB_10_2025_with_contamination/intermediate_qc_reports/" \
	--glinos_annotation "/pscratch/mteb223_uksr/BRENDAN_SINGLE_CELL/single_cell_nextflow_pipeline/cDNA_pipeline/annotations/glinos_annotation_clean.gtf" \
	--leung_annotation "/pscratch/mteb223_uksr/BRENDAN_SINGLE_CELL/single_cell_nextflow_pipeline/cDNA_pipeline/annotations/leung_annotation_clean.gtf" \
	--heberle_annotation "/pscratch/mteb223_uksr/BRENDAN_SINGLE_CELL/single_cell_nextflow_pipeline/cDNA_pipeline/annotations/heberle_annotation_clean.gtf" \
	--out_dir "PBMC_rebasecalled_bulk_discovery_FEB_26_2025_with_contamination" \
	--step "3" \
	--is_chm13 "False" \
	-with-trace \
	-with-timeline \
	-with-report #\
#	-resume

