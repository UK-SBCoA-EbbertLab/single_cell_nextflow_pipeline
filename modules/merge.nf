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

process SEP_DIR_BY_SAMP {
	label 'small'
	
	input:
		path sample_id_table
	output:
		path("*.txt"), emit: dir_by_samp
	script:
	"""
		awk '{ print > \$2 "_samp_to_dir.txt" }' ${sample_id_table}
	"""

}

process MERGE_SUMMARY {
	label 'medium'

	publishDir "results/${params.out_dir}/pre_processing/summary_files/", pattern: "*.txt", mode: "copy", overwrite: true

	input:
		path dir_by_samp
		val ont_fq_to_merge
	output:
		path("*.txt"), emit: out
	script:
	"""
		concat_summary.sh ${dir_by_samp} ${ont_fq_to_merge}
	"""
}
process MERGE_FASTQ {
	label 'large'

	publishDir "results/${params.out_dir}/pre_processing/merged_fastq/", mode: "copy", overwrite: true

	input:
		path dir_by_samp
		val ont_fq_to_merge
	output:
//		path("*.fastq.gz"), emit: out
		path("*.fastq"), emit: fastq
	script:
	"""
		java -cp /pscratch/mteb223_uksr/BRENDAN_SINGLE_CELL/single_cell_nextflow_pipeline/workflow/bin/UnzipAndConcat-Java/ UnzipAndConcat ${dir_by_samp} ${ont_fq_to_merge}
		gzip -k *.fastq
	"""
}
