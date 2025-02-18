#!/usr/bin/env bash
#SBATCH --time=3-0:00:00
#SBATCH --job-name=PBMC_3_SC
#SBATCH --ntasks=1
#SBATCH --cpus-per-task 1
#SBATCH --mem-per-cpu 400G
#SBATCH --partition=normal
#SBATCH -e slurm-%j.err
#SBATCH -o slurm-%j.out
#SBATCH -A coa_mteb223_uksr

nextflow ../../../workflow/main.nf \
	--bambu_rds "/pscratch/mteb223_uksr/BRENDAN_SINGLE_CELL/single_cell_nextflow_pipeline/submission/PBMC_patient0/STEP_2/results/PBMC_patient0_FEB_11_2025_bambu_quant/bambu_prep/*.rds" \
	--ref "/project/mteb223_uksr/sequencing_resources/references/Ensembl/hg38_release_113/dna/Homo_sapiens.GRCh38.dna.primary_assembly.fa" \
	--fai "/project/mteb223_uksr/sequencing_resources/references/Ensembl/hg38_release_113/dna/Homo_sapiens.GRCh38.dna.primary_assembly.fa.fai" \
	--annotation "/pscratch/mteb223_uksr/BRENDAN_SINGLE_CELL/single_cell_nextflow_pipeline/cDNA_pipeline/submission/PBMC_patien0/STEP_3/results/PBMC_rebasecalled_bulk_discovery_FEB_11_2025_with_contamination/bambu_discovery/extended_annotations.gtf" \
	--is_discovery "False" \
	--track_reads "False" \
	--out_dir "PBMC_patient0_FEB_11_2025_bambu_quant" \
	--step "3" \
	--is_chm13 "False" \
	-with-trace \
	-with-timeline \
	-with-report \
	-resume

