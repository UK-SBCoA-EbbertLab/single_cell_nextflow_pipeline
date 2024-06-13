process CONVERT_NANOPORE {
	
	publishDir "results/${params.out_dir}/pre_processing/paired_end_fastqs", mode: "copy", overwrite: true

	label 'huge'

	input:
		tuple val (sampName), path (input_fastq)


	output:
		tuple val(sampName), path("*.fastq.gz")

	script:
//	sampName = input_fastq.name.replaceAll(/\..*$/, "")
	"""
		echo "${sampName}"
		echo "${input_fastq}"
		java \
		    -Xms300g \
		    -Xmx400g \
		    -cp /pscratch/mteb223_uksr/BRENDAN_SINGLE_CELL/single_cell_nextflow_pipeline/workflow/bin/NanoporeConverter-Java/ \
		    NanoporeConverter \
		    ${input_fastq}
	"""
}

process CAT_CONVERTED_FASTQS {
	
	publishDir "results/${params.out_dir}/pre_processing/concat_merged_fastqs", mode: "copy", overwrite: true

	label 'large'

	input:
		tuple val(sampName), val(R), path(files)
	output:
		tuple val(sampName), path("*_converted_merged_${R}.fastq.gz")
	
	script:
	"""
		java -cp /pscratch/mteb223_uksr/BRENDAN_SINGLE_CELL/single_cell_nextflow_pipeline/workflow/bin/modified-UnzipAndConcat-Java/ modified_UnzipAndConcat "${sampName}_converted_merged_${R}"
		mv "${sampName}_converted_merged_${R}" "${sampName}_converted_merged_${R}.fastq"
		gzip -k "${sampName}_converted_merged_${R}.fastq"

	"""

}

process PIPSEEKER {
	
	publishDir "results/${params.out_dir}/pre_processing/barcoding/${sampName}", mode: "copy", overwrite: true

	label 'huge'

	input:
		tuple val(sampName), path(R)

	output:
		path("./barcodes/barcode_whitelist.txt"),emit: barcode_list
		path("./barcodes/generated_barcode_read_info_table.csv")
		path("./barcoded_fastqs/barcoded_1_R1.fastq.gz"), emit:barcoded_fastq_R1
		path("./barcoded_fastqs/barcoded_1_R2.fastq.gz"), emit:barcoded_fastq_R2
		val(sampName), emit:sampName

	script:
	"""
		pipseeker barcode --verbosity 2 --skip-version-check --chemistry v4 --fastq . --output-path . 
	"""
}	
