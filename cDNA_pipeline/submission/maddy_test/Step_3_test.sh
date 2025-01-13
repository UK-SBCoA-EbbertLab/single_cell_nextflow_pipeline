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

nextflow ../../workflow/main.nf \
	--bambu_rds "/pscratch/mteb223_uksr/BRENDAN_SINGLE_CELL/cDNA_pipeline/submission/maddy_test/results/maddy_tcell_test/bambu_prep/*.rds" \
	--ref "/project/mteb223_uksr/sequencing_resources/references/Ensembl/hg38_release_112/dna/Homo_sapiens.GRCh38.dna.primary_assembly.fa" \
	--fai "/pscratch/mteb223_uksr/BRENDAN_SINGLE_CELL/cDNA_pipeline/submission/maddy_test/results/maddy_tcell_test/fai/Homo_sapiens.GRCh38.dna.primary_assembly.fa.fai" \
	--annotation "/project/mteb223_uksr/sequencing_resources/annotations/Ensembl/hg38_release_112/Homo_sapiens.GRCh38.112.chr.gtf" \
	--is_discovery "True" \
	--track_reads "True" \
	--multiqc_input "/pscratch/mteb223_uksr/BRENDAN_SINGLE_CELL/cDNA_pipeline/submission/maddy_test/results/maddy_tcell_test/multiQC_input/**" \
	--multiqc_config "/pscratch/mteb223_uksr/BRENDAN_SINGLE_CELL/cDNA_pipeline/workflow/bin/multiqc_config.yaml" \
	--out_dir "maddy_tcell_test" \
	--step "3" \
	--is_chm13 "False" #\
	#-resume

