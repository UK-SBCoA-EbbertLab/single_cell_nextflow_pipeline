# Single-Cell Nextflow Pipeline (Pipseeker)

This pipeline was used to prepare single-cell data, sequenced using a protocol designed in our lab, for analysis. The protocol combined ONT long-reads with PIP-seq single-cell. This pipeline was based on a pipeline developed by Bernardo Aguzzoli-Heberle and then heavily modified to fit our needs here. 

Read our paper for more information about this pipeline: TODO: place paper URL here

## Steps Overview

This pipeline that we ran has 5 steps. A brief explanation of each is found below.

The first step is the pre-processing step, called Step 0, that takes fastqs outputted after basecalling ONT long-reads. Briefly, this step takes those fastqs and demultiplexes them into fastqs that contain reads for only a single barcode, ie. each fastq contains the reads for a single cell. 

The second step is what we call Step 2 - Bulk. Here we run the data not on a single cell level, but as 'bulk' in order for us to determine the QC reports and to prepare the bulk data to be run through Bambu Discovery to identify novel isoforms.

The third step, Step 3 - Bulk, runs the prepared .rds files through Bambu Discovery. This step generates the extended annotation file used in later steps, the multiqc report, and outputs from gffcompare comparing other paper's annotations to ours to be analysed later. 

The fourth step is Step 2 - Single Cell. This step takes the cell fastq files through alignment, filtering, and bambu preparation to be run through Bambu quantification using the extended annotation from the previous step.

The fifth step is Step 3 - Single Cell, which runs the data through Bambu quantification and generates the final counts matrices to be analysed downstream.

## Examples of the submissions

### Example for Step 0: Single-cell preprocessing

	nextflow ../../../workflow/main.nf \
		--sample_id_table "../../../datasets/PBMC/PBMC_patient0_rebasecalled/sample_id_to_folder.tsv" \
		--ont_reads_fq_dir "../../../datasets/PBMC/PBMC_patient0_rebasecalled/" \
		--out_dir "PBMC_rebasecalled_FEB_10_2025" \
	        --demultiplex_name "PBMC_rebasecalled_FEB_10_2025" \
		--cdna_kit "PCS114" \
		--qscore_thresh "9" \
		--barcode_thresh 100 \
		--mpldir "/tmp/dir/mpl_config" \
		--n_threads 8 \
	        --step 0 \
		-with-report \
		-with-timeline \
		-with-trace

### Example for Step 2 - Bulk

	nextflow ../../../workflow/main.nf \
		--step 2 \
		--ont_reads_fq "../../../../submission/PBMC_patient0/STEP_0/results/PBMC_rebasecalled_FEB_10_2025/pre_processing/concatenated_fastq_and_sequencing_summary_files/*.fastq" \
		--ont_reads_txt "../../../../submission/PBMC_patient0/STEP_0/results/PBMC_rebasecalled_FEB_10_2025/pre_processing/concatenated_fastq_and_sequencing_summary_files/*.txt" \
		--read_stats "../../../../submission/PBMC_patient0/STEP_0/results/PBMC_rebasecalled_FEB_10_2025/pre_processing/stats/**/*.combined_stats.json" \
		--ref "/path/to/sequencing_resources/references/Ensembl/hg38_release_113/dna/Homo_sapiens.GRCh38.dna.primary_assembly.fa" \
		--annotation "/path/to/sequencing_resources/annotations/Ensembl/hg38_release_113/Homo_sapiens.GRCh38.113.gtf" \
		--housekeeping "../../../references/hg38.HouseKeepingGenes.bed" \
		--out_dir "PBMC_rebasecalled_bulk_discovery_FEB_10_2025_with_contamination" \
		--cdna_kit "PCS114" \
		--is_chm13 "False" \
		--mapq 10 \
		--is_dRNA "False" \
		--contamination_ref "../../../contamination_reference_doc/master_contaminant_reference.fasta" \
		--qscore_thresh 9 \
		--tmpwritedir "/tmp/dir/mpl_config/" \
		-with-trace \
		-with-timeline \
		-with-report 

### Example for Step 3 - Bulk

	nextflow ../../../workflow/main.nf \
		--bambu_rds "../STEP_2/results/PBMC_rebasecalled_bulk_discovery_FEB_10_2025_with_contamination/bambu_prep/*.rds" \
		--ref "/path/to/sequencing_resources/references/Ensembl/hg38_release_113/dna/Homo_sapiens.GRCh38.dna.primary_assembly.fa" \
		--fai "/path/to/sequencing_resources/references/Ensembl/hg38_release_113/dna/Homo_sapiens.GRCh38.dna.primary_assembly.fa.fai" \
		--annotation "/path/to/sequencing_resources/annotations/Ensembl/hg38_release_113/Homo_sapiens.GRCh38.113.chr.gtf" \
		--is_discovery "True" \
		--track_reads "False" \
		--multiqc_input "../STEP_2/results/PBMC_rebasecalled_bulk_discovery_FEB_10_2025_with_contamination/multiQC_input/**" \
		--multiqc_config "../../../workflow/bin/multiqc_config.yaml" \
		--intermediate_qc "../STEP_2/results/PBMC_rebasecalled_bulk_discovery_FEB_10_2025_with_contamination/intermediate_qc_reports/" \
		--glinos_annotation "../../../annotations/glinos_annotation_clean.gtf" \
		--leung_annotation "../../../annotations/leung_annotation_clean.gtf" \
		--heberle_annotation "../../../annotations/heberle_annotation_clean.gtf" \
		--out_dir "PBMC_rebasecalled_bulk_discovery_FEB_11_2025_with_contamination" \
		--step "3" \
		--is_chm13 "False" \
		-with-trace \
		-with-timeline \
		-with-report 

### Example for Step 2 - Single-Cell
	nextflow ../../../workflow/main.nf \
		--step "2" \
		--ont_reads_fq "../STEP_0/results/PBMC_rebasecalled_FEB_10_2025/pre_processing/06_demultiplexed/**/*.fastq" \
		--ref "/path/to/sequencing_resources/references/Ensembl/hg38_release_113/dna/Homo_sapiens.GRCh38.dna.primary_assembly.fa" \
		--annotation "../../../cDNA_pipeline/submission/PBMC_patien0/STEP_3/results/PBMC_rebasecalled_bulk_discovery_FEB_11_2025_with_contamination/bambu_discovery/extended_annotations.gtf" \
		--out_dir "PBMC_patient0_FEB_11_2025_bambu_quant" \
		--mapq "10" \
		--track_reads "True" \
		--mapped_reads_thresh 100 \
		-with-trace \
		-with-timeline \
		-with-report

### Example for Step 3 - Single-Cell

	nextflow ../../../workflow/main.nf \
		--bambu_rds "../STEP_2/results/PBMC_patient0_FEB_11_2025_bambu_quant/bambu_prep/*.rds" \
		--ref "/path/to/sequencing_resources/references/Ensembl/hg38_release_113/dna/Homo_sapiens.GRCh38.dna.primary_assembly.fa" \
		--fai "/path/to/sequencing_resources/references/Ensembl/hg38_release_113/dna/Homo_sapiens.GRCh38.dna.primary_assembly.fa.fai" \
		--annotation "../../../cDNA_pipeline/submission/PBMC_patien0/STEP_3/results/PBMC_rebasecalled_bulk_discovery_FEB_11_2025_with_contamination/bambu_discovery/extended_annotations.gtf" \
		--is_discovery "False" \
		--track_reads "False" \
		--out_dir "PBMC_patient0_FEB_11_2025_bambu_quant" \
		--step "3" \
		--is_chm13 "False" \
		-with-trace \
		-with-timeline \
		-with-report



