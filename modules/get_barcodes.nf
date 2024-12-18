process CONVERT_NANOPORE {
	
	publishDir "results/${params.out_dir}/pre_processing/paired_end_fastqs", mode: "copy"
	//publishDir "results/${params.out_dir}/pre_processing/paired_end_fastqs", mode: "copy", overwrite: true

	label 'convert_nanopore'
	//label 'huge'

	input:
		tuple val(sampName), val(baseName), path (input_fastqs)


	output:
		tuple val(sampName), val(baseName), path("${sampName}*.fastq.gz"), emit: good
		tuple val(sampName), path("*.stats.gz"),  emit: bad_stats
		tuple val(sampName), val(baseName), path("*dontuse.gz"),  emit: to_rescue
		tuple val(sampName), path("*.ser.gz"),  emit: barcodes

	script:
	"""

		# Loop through each line in the input file
		while IFS= read -r file_path; do
		    # Create a symbolic link in the current directory with the base name
		    ln -s "\$file_path" .
		done < "${input_fastqs}"
		
		java \
		    -Xms10g \
		    -Xmx45g \
		    -cp /pscratch/mteb223_uksr/BRENDAN_SINGLE_CELL/single_cell_nextflow_pipeline/workflow/bin/NanoporeConverter-Java/ \
		    NanoporeConverter \
		    ${sampName} \
		    ${baseName}
	"""
}

process CAT_BARCODE_WHITELIST {

	publishDir "results/${params.out_dir}/pre_processing/concat_barcode_lists", mode: "copy"
	//publishDir "results/${params.out_dir}/pre_processing/concat_barcode_lists", mode: "copy", overwrite: true

	label 'cat_barcode_whitelist'
	//label 'large'

	input:
		tuple val(sampName), path(files)
	output:
		tuple val(sampName), path("${sampName}_tier1map_barcodes.ser.gz"), path("${sampName}_tier2map_barcodes.ser.gz"), path("${sampName}_tier3map_barcodes.ser.gz"), path("${sampName}_tier4map_barcodes.ser.gz")
	
	script:
	"""
		java -cp /pscratch/mteb223_uksr/BRENDAN_SINGLE_CELL/single_cell_nextflow_pipeline/workflow/bin/NanoporeConverter-Java/ combinedBarcodeWhitelists
		mv tier1map_barcodes.ser.gz ${sampName}_tier1map_barcodes.ser.gz
		mv tier2map_barcodes.ser.gz ${sampName}_tier2map_barcodes.ser.gz
		mv tier3map_barcodes.ser.gz ${sampName}_tier3map_barcodes.ser.gz
		mv tier4map_barcodes.ser.gz ${sampName}_tier4map_barcodes.ser.gz

	"""

}

process CAT_STATS {
	
	publishDir "results/${params.out_dir}/pre_processing/concat_stats", mode: "copy"
	//publishDir "results/${params.out_dir}/pre_processing/concat_stats", mode: "copy", overwrite: true

	label 'cat_stats'
	//label 'large'

	input:
		tuple val(sampName), path(files)
	output:
		tuple val(sampName), path("*_stats_sorted.txt")
	
	script:
	"""
		java -cp /pscratch/mteb223_uksr/BRENDAN_SINGLE_CELL/single_cell_nextflow_pipeline/workflow/bin/modified-UnzipAndConcat-Java/ modified_UnzipAndConcat ".stats" "${sampName}_stats.txt"
		# this is to get rid of any duplicates
		awk -i inplace '!seen[\$0]++' "${sampName}_stats.txt"
		{ head -n 1 "${sampName}_stats.txt"; tail -n +2 "${sampName}_stats.txt" | sort; } > "${sampName}_stats_sorted.txt"
		rm "${sampName}_stats.txt"
	"""
}

process CONVERT_NANOPORE_RESCUE {
	
	publishDir "results/${params.out_dir}/pre_processing/rescued_paired_end_fastqs", mode: "copy"
	//publishDir "results/${params.out_dir}/pre_processing/rescued_paired_end_fastqs", mode: "copy", overwrite: true

	label 'convert_nanopore_rescue'
	//label 'huge'

	input:
		tuple val(sampName), val(baseName), path(fastq_to_rescue), path(barcodes_1), path(barcodes_2), path(barcodes_3), path(barcodes_4)

	output:
		tuple val(sampName), val(baseName_rescued), path("*.fastq.gz"), emit: good
		tuple val(sampName), path("*.stats.gz"), emit: stats
		tuple val(sampName), path("*dontuse.gz"), emit: bad

	script:
	baseName_rescued = baseName + "_rescued"
	"""
		echo "${sampName}"
		echo "${fastq_to_rescue}"
		java \
		    -Xms100g \
		    -Xmx225g \
		    -cp /pscratch/mteb223_uksr/BRENDAN_SINGLE_CELL/single_cell_nextflow_pipeline/workflow/bin/NanoporeConverter-Java/ \
		    NanoporeConverter_rescue \
		    ${fastq_to_rescue} ${barcodes_1} ${barcodes_2} ${barcodes_3} ${barcodes_4}
	"""
}

process CAT_CONVERTED_FASTQS {
	
	publishDir "results/${params.out_dir}/pre_processing/concat_merged_fastqs", mode: "copy"
	//publishDir "results/${params.out_dir}/pre_processing/concat_merged_fastqs", mode: "copy", overwrite: true

	label 'large'

	input:
		tuple val(sampName), val(R), path(files)
	output:
		tuple val(sampName), path("*_converted_merged_${R}.fastq.gz")
	
	script:
	"""
		java -cp /pscratch/mteb223_uksr/BRENDAN_SINGLE_CELL/single_cell_nextflow_pipeline/workflow/bin/modified-UnzipAndConcat-Java/ modified_UnzipAndConcat ".fastq" "${sampName}_converted_merged_${R}"
		mv "${sampName}_converted_merged_${R}" "${sampName}_converted_merged_${R}.fastq"
		gzip "${sampName}_converted_merged_${R}.fastq"

	"""

}

process PIPSEEKER {
	
	publishDir "results/${params.out_dir}/pre_processing/barcoding/${sampName}/${baseName}", mode: "copy"
	//publishDir "results/${params.out_dir}/pre_processing/barcoding/${sampName}/${baseName}", mode: "copy", overwrite: true

	label 'pipseeker'
	//label 'huge'

	input:
		tuple val(sampName), val(baseName), path(R)

	output:
		path("./barcodes/${sampName}_${baseName}_barcode_whitelist.txt"), emit: barcode_list
		tuple val(sampName), path("./barcodes/${sampName}_${baseName}_generated_barcode_read_info_table.csv"), emit:barcode_counts
		tuple val(sampName), path("./barcoded_fastqs/${sampName}_${baseName}_barcoded_1_R1.fastq.gz"), path("./barcoded_fastqs/${sampName}_${baseName}_barcoded_1_R2.fastq.gz"), emit:to_demultiplex

	script:
	"""
		pipseeker barcode --verbosity 2 --skip-version-check --chemistry v4 --fastq . --output-path . 
		mv ./barcoded_fastqs/barcoded_1_R1.fastq.gz "./barcoded_fastqs/${sampName}_${baseName}_barcoded_1_R1.fastq.gz"
		mv ./barcoded_fastqs/barcoded_1_R2.fastq.gz "./barcoded_fastqs/${sampName}_${baseName}_barcoded_1_R2.fastq.gz"
		mv ./barcodes/generated_barcode_read_info_table.csv "./barcodes/${sampName}_${baseName}_generated_barcode_read_info_table.csv"
		mv ./barcodes/barcode_whitelist.txt "./barcodes/${sampName}_${baseName}_barcode_whitelist.txt"
	"""
}	

process COUNT_AND_FILTER_BARCODES {
	publishDir "results/${params.out_dir}/pre_processing/barcoding/${sampName}", mode: "copy"

	label 'count_and_filter_barcodes'
	//label 'small'

	input:
		tuple val(sampName), path(barcode_counts)

	output:
		tuple val(sampName), path("${sampName}_barcodes_to_keep.txt"), emit:barcodes_to_keep
		path("${sampName}_all_barcodes.txt")

	script:
	"""
		count_barcodes.py --threshold ${params.barcode_thresh} --output "${sampName}_barcodes_to_keep.txt" --fulloutput "${sampName}_all_barcodes.txt"
	"""
}
