#!/bin/bash

#SBATCH --time=3-0:00:00
#SBATCH --job-name=43BHEK_unmapped
#SBATCH --ntasks=1
#SBATCH --cpus-per-task 1
#SBATCH --mem-per-cpu 400G
#SBATCH --partition=normal
#SBATCH -e slurm-%j.err
#SBATCH -o slurm-%j.out
#SBATCH -A coa_mteb223_uksr

nextflow ../../workflow/main.nf \
       	--bambu_rds "./results/Tcell_test/bambu_prep/*.rds" \
	--ref "/project/mteb223_uksr/sequencing_resources/references/Ensembl/hg38_release_112/dna/Homo_sapiens.GRCh38.dna.primary_assembly.fa" \
	--fai "./results/Tcell_test/fai/Homo_sapiens.GRCh38.dna.primary_assembly.fa.fai" \
	--annotation "/pscratch/mteb223_uksr/BRENDAN_SINGLE_CELL/cDNA_pipeline/submission/maddy_test/results/maddy_tcell_test/bambu_discovery/extended_annotations.gtf" \
	--multiqc_input "./results/Tcell_test/multiQC_input/**" \
	--multiqc_config "/pscratch/mteb223_uksr/BRENDAN_SINGLE_CELL/single_cell_nextflow_pipeline/workflow/bin/multiqc_config.yaml" \
	--out_dir "Tcell_test" \
	--is_discovery "False" \
	--track_reads "True" \
	--step "3" \
	--is_chm13 "False"
