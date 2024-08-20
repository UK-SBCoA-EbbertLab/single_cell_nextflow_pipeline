process DEMULTIPLEX {
	
       // publishDir "results/${params.out_dir}/pre_processing/demultiplexed/${sampName}/${baseName}", mode: "copy", overwrite: true

	label 'barcoding'

	input:
		tuple val(sampName), val(baseName), path(barcoded_fastq_R1), path(barcoded_fastq_R2)
	output:
		tuple val(sampName), path("*.fastq.gz"), emit: demult_fastq
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
	   	${sampName} \
		${baseName} 
	"""
}

process COMBINE_DEMULTIPLEX {
	
        publishDir "results/${params.out_dir}/pre_processing/combined_demultiplex/${sampName}/", mode: "copy", overwrite: true

	label 'large'

	input:
		tuple val(sampName), val(barcode), path(concat_files)
	output:
		tuple val(sampName), path("*.fastq.gz"), emit: combined_demultiplex
	script:
	"""
		java -cp /pscratch/mteb223_uksr/BRENDAN_SINGLE_CELL/single_cell_nextflow_pipeline/workflow/bin/modified-UnzipAndConcat-Java/ modified_UnzipAndConcat ".fastq" "${sampName}_${barcode}"
		mv "${sampName}_${barcode}" "${sampName}_${barcode}.fastq"
		gzip -k "${sampName}_${barcode}.fastq"

	"""
}
