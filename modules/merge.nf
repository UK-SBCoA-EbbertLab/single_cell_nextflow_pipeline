process MERGE_MATRICES {
	label 'huge'

	publishDir "results/${params.out_dir}/merged_bambu_matrices/", pattern: "*.txt", mode: "copy", overwrite: true

	input:
		path directory
		val name
	output:
		path("*.txt"), emit: out
	script:
	"""
		merge_matrices.py ${directory} ${name}
	"""
}
process MERGE_SUMMARY {
	label 'medium'

	publishDir "results/${params.out_dir}/summary_files/", pattern: "*.txt", mode: "copy", overwrite: true

	input:
		path sampleIDtable
		val ont_reads_fq_dir
	output:
		path("*.txt"), emit: out
	script:
	"""
		concat_summary.sh ${sampleIDtable} ${ont_reads_fq_dir}
	"""
}
process MERGE_FASTQ {
	label 'large'

	publishDir "results/${params.out_dir}/merged_fastq/", pattern: "*.fastq", mode: "copy", overwrite: true

	input:
		path sampleIDtable
		val ont_reads_fq_dir
	output:
		path("*.fastq"), emit: out
	script:
	"""
		java -cp /scratch/bjwh228/working_single_cell_pipeline/workflow/bin/UnzipAndConcat-Java/ UnzipAndConcat ${sampleIDtable} ${ont_reads_fq_dir}
	"""
}
