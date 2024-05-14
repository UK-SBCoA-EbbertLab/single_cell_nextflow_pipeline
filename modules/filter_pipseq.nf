process FILTER_PIP {
	
        publishDir "results/${params.out_dir}/", mode: "copy", overwrite: true

	label 'barcoding'

	input:
		path(dir)
		val(name)
	output:
		path("${name}-demultiplexed")
	script:
	"""
		java \
    		-Xms100g \
	   	-Xmx140g \
	   	-cp /scratch/bjwh228/working_single_cell_pipeline/workflow/bin/PIPSeqDemultiplexer-Java/ \
	   	PIPSeqDemultiplexer \
	   	${dir} \
	   	"${name}-demultiplexed" \
	   	${name} \
		8 \
		500
	"""
}
