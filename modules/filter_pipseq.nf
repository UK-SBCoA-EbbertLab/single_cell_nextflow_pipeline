process FILTER_PIP {
	
        publishDir "results/${params.out_dir}/pre_processing/demultiplexed/${sampName}", mode: "copy", overwrite: true

	label 'barcoding'

	input:
		path(barcoded_fastq_R1)
		path(barcoded_fastq_R2)
		val(sampName)
	output:
		path("*.fastq")
		path("*.txt")
	script:
	"""
		java \
    		-Xms100g \
	   	-Xmx140g \
	   	-cp /pscratch/mteb223_uksr/BRENDAN_SINGLE_CELL/single_cell_nextflow_pipeline/workflow/bin/PIPSeqDemultiplexer-Java/ \
	   	PIPSeqDemultiplexer \
	   	${barcoded_fastq_R1} \
	   	${barcoded_fastq_R2} \
	   	${sampName} \
		8 \
		5
	"""
}
