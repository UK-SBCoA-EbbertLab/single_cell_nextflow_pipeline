process CONVERT_NANOPORE {
	label 'medium'

	input:
		path input_fastq

	output:
		path("converted/"),emit: dir

	script:
	"""
		
		java \
		    -Xms100g \
		    -Xmx140g \
		    -cp /scratch/bjwh228/nextflow/RNA_seq_single_cell_nextflow-pipeline/workflow/bin/NanoporeConverter-Java/ \
		    NanoporeConverter \
		    ${input_fastq} \
		    "converted/"	
	"""
}

process PIPSEEKER {
	
	publishDir "results/${params.out_dir}/barcoding", mode: "copy", overwrite: true

	label 'medium_large'

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
		pipseeker barcode --skip-version-check --chemistry v3 --fastq \$converted_dir/. --output-path . 
	"""
}	
