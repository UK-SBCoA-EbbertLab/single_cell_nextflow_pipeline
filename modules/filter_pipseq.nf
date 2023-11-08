process FILTER_PIP {
	
        publishDir "results/${params.out_dir}/", mode: "copy", overwrite: true

	label 'filter'

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
	   	-cp /scratch/bjwh228/nextflow/RNA_seq_single_cell_nextflow-pipeline/workflow/bin/PIPSeqDemultiplexer-Java/ \
	   	PIPSeqDemultiplexer \
	   	${dir} \
	   	"${name}-demultiplexed" \
	   	${name} \
		8
	"""
}
