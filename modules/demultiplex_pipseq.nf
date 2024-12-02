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
	   	-Xmx240g \
	   	-cp /pscratch/mteb223_uksr/BRENDAN_SINGLE_CELL/single_cell_nextflow_pipeline/workflow/bin/PIPSeqDemultiplexer-Java/ \
	   	PIPSeqDemultiplexer \
		${barcodes_to_keep} \
	   	${sampName} \
		"." \
		${params.n_threads}


		# filter the files by barcode count again
		while read -r line; do
			# skip the header row
			if [[ "\$line" == "Barcode"* ]]; then
				echo "\$line" >> "${sampName}_passing_barcodes.txt"
				continue
			fi

			# Parse the barcode and read count from the line
			barcode=\$(echo "\$line" | awk '{print \$1}')
			reads=\$(echo "\$line" | awk '{print \$2}')

			# Check if the read count meets the threshold
			if (( reads >= ${params.barcode_thresh} )); then
				# If the file exists, retain it and add the barcode to the output file
				if [[ -f "\$barcode" ]]; then
					echo "\$line" >> "${sampName}_passing_barcodes.txt"
				fi
			else
				# If the file exists, delete it
				if [[ -f "\$barcode" ]]; then
					echo "Removing file: \$barcode"
					rm "\$barcode"
				fi
			fi
		done < "${sampName}_barcode_counts.txt"

		echo "Processing complete. Passing barcodes saved to ${sampName}_passing_barcodes.txt. Now sorting ..."

		sort -n -k 2 ${sampName}_passing_barcodes.txt > ${sampName}_passing_barcodes_sorted.txt

		echo "Barcodes sorted and saved to ${sampName}_passing_barcodes_sorted.txt."
		
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
