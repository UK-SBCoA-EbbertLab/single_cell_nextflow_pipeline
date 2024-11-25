process DEMULTIPLEX {

        publishDir "results/${params.out_dir}/pre_processing/demultiplexed/${sampName}/", mode: "copy"

	label 'demultiplexing'
	//label 'barcoding'

	input:
		tuple val(sampName), path(barcoded_fastq_R1), path(barcoded_fastq_R2), path(barcodes_to_keep)
	output:
		path("*"), emit: all
		tuple val(sampName), path("*.fastq"), emit: demult_fastq
	script:
	"""
		echo ${sampName}
		echo ${barcoded_fastq_R1}
		echo ${barcoded_fastq_R2}
		java \
    		-Xms100g \
	   	-Xmx140g \
	   	-cp /pscratch/mteb223_uksr/BRENDAN_SINGLE_CELL/single_cell_nextflow_pipeline/workflow/bin/PIPSeqDemultiplexer-Java/ \
	   	PIPSeqDemultiplexer \
		${barcodes_to_keep} \
	   	${sampName} \
		"." \
		${params.barcode_thresh} 

#		find ${sampName}_*.fastq -type f -exec awk -v lines=\$((${params.barcode_thresh} * 4)) 'NR>lines{f=1; exit} END{exit f}' {} \\; -exec rm {} \\;
	"""
}

process COMBINE_DEMULTIPLEX {
	
        publishDir "results/${params.out_dir}/pre_processing/combined_demultiplex/", mode: "copy"

	label 'combine_demultiplex'
	//label 'huge'

	input:
		path(concat_files)
		//tuple val(sampName), val(barcodes), path(concat_files)
	output:
		path("**/*_combined.fastq.gz"), emit: combined_demultiplex
	script:
	"""
		ls
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
