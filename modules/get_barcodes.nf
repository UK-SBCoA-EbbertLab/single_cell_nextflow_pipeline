process CONVERT_NANOPORE {
	label 'huge'

	input:
		path input_fastq

	output:
		path("converted/"),emit: dir

	script:
	"""
		mkdir converted		
		java \
		    -Xms300g \
		    -Xmx400g \
		    -cp /scratch/bjwh228/working_single_cell_pipeline/workflow/bin/NanoporeConverter-Java/ \
		    NanoporeConverter \
		    ${input_fastq} \
		    "converted/"	
	"""
}

process PIPSEEKER {
	
	publishDir "results/${params.out_dir}/barcoding", mode: "copy", overwrite: true

	label 'huge'

	input:
		path(fastq)
		path(dir)

	output:
		path("./barcodes/barcode_whitelist.txt"),emit: barcode_list
		path("./barcodes/generated_barcode_read_info_table.csv")
		path("./barcoded_fastqs"), emit:barcoded_fastqs

	script:
	"""
		converted_dir=${dir}
		pipseeker barcode --verbosity 2 --skip-version-check --chemistry v4 --fastq \$converted_dir/. --output-path . 
	"""
}	
