process MERGE_MATRICES {
	label 'huge'

	publishDir "results/${params.out_dir}/merged_bambu_matrices/", pattern: "*.txt", mode: "copy", overwrite: true

	input:
		tuple val(sample), path(files)
		val name
	output:
		path("*.txt"), emit: out
	script:
	"""
		#merge_matrices.py . ${name}
		merge_matrices.py . ${name}_${sample} "low_memory"
	"""
}

process SEP_DIR_BY_SAMP {
	label 'local'

	input:
		path sample_id_table
	output:
		path("*.txt"), emit: dir_by_samp
	script:
	"""
		awk '{ print \$1 > \$2 "_samp_to_dir.txt" }' ${sample_id_table}
	"""

}

process SEP_DIR_BY_SAMP_KEEP_SAMP {
	label 'local'

	input:
		path sample_id_table
	output:
		path("*.txt"), emit: dir_by_samp
	script:
	"""
		awk '{ print > \$2 "_samp_to_dir.txt" }' ${sample_id_table}
	"""

}

process GET_ALL_FASTQ_GZ {

	publishDir "results/${params.out_dir}/pre_processing/00_sample_files_chunked", mode: "copy"

	label 'local'

	input:
		path sample_id_table
		val base_path
	output:
		path("*_samp_to_dir.txt"), emit: all_files
		path("*_samp_to_dir_chunk_*"), emit: split_files
		path("*_seq_summary_file.txt"), emit: seq_sum_files

	script:
	"""
		# Process each line of the input file
		while IFS=\$'\\t' read -r dir sample_id flowcell_id; do
		    # Combine base path with the directory path
		    full_dir_path="${base_path}/\${dir}"

		    seq_sum=\$(ls \${full_dir_path}/*equencing_summary*)
		    echo -e "\${seq_sum}" >> "\${sample_id}_\${flowcell_id}_seq_summary_file.txt"
		    
		    # Use find to get all .fastq.gz files in the directory
		    find "\${full_dir_path}" -name "*pass*.fastq.gz" | while read -r file_path; do
		        # Check if the file is not empty
		        if [ -s "\${file_path}" ]; then
		            echo -e "\${file_path}\t\${sample_id}\t\${flowcell_id}" >> all_sample_files_to_samp_id.txt
		        fi
		    done

		done < "${sample_id_table}"
		
		awk '{ print \$1 > \$2 "_" \$3 "_samp_to_dir.txt" }' all_sample_files_to_samp_id.txt

		for file in *_samp_to_dir.txt; do
			split -l 500 -d "\${file}" "\${file%.*}_chunk_"
		done

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
		path("*.fastq")
	script:
	"""
		java -cp /pscratch/mteb223_uksr/BRENDAN_SINGLE_CELL/single_cell_nextflow_pipeline/workflow/bin/UnzipAndConcat-Java/ UnzipAndConcat ${dir_by_samp} ${ont_fq_to_merge}
	"""
}
