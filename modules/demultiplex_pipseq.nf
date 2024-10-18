process DEMULTIPLEX {
	
        publishDir "results/${params.out_dir}/pre_processing/demultiplexed/${sampName}/", mode: "copy"

	label 'barcoding'

	input:
		tuple val(sampName), val(baseName), path(barcoded_fastq_R1), path(barcoded_fastq_R2), path(barcodes_to_keep)
	output:
		tuple val(sampName), path("**/*.fastq.gz"), emit: demult_fastq
		path("*.txt")
	script:
	"""
		echo ${barcoded_fastq_R1}
		echo ${barcoded_fastq_R2}
		java \
    		-Xms100g \
	   	-Xmx140g \
	   	-cp /pscratch/mteb223_uksr/BRENDAN_SINGLE_CELL/single_cell_nextflow_pipeline/workflow/bin/PIPSeqDemultiplexer-Java/ \
	   	PIPSeqDemultiplexer \
	   	${barcoded_fastq_R1} \
	   	${barcoded_fastq_R2} \
		${barcodes_to_keep} \
	   	${sampName} \
		${baseName} 
	"""
}

process COMBINE_DEMULTIPLEX {
	
        publishDir "results/${params.out_dir}/pre_processing/combined_demultiplex/", mode: "copy", overwrite: true

	label 'huge'

	input:
		path(concat_files)
		//tuple val(sampName), val(barcodes), path(concat_files)
	output:
		path("**/*_combined.fastq.gz"), emit: combined_demultiplex
	script:
	"""
		for barcode in \$(ls); do
			echo \${barcode}
			java -cp /pscratch/mteb223_uksr/BRENDAN_SINGLE_CELL/single_cell_nextflow_pipeline/workflow/bin/modified-UnzipAndConcat-Java/ modified_UnzipAndConcat ".fastq" "\${barcode}" "\${barcode}_combined"
			sampName="\${barcode:0:\${#barcode}-17}"
			mkdir -p \${sampName}
			mv "\${barcode}_combined" "\${sampName}/\${barcode}_combined.fastq"
			gzip "\${sampName}/\${barcode}_combined.fastq"
		done

	"""
}
