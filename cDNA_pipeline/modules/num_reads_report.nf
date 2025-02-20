process MAKE_QC_REPORT_NO_TRIM {
    
    publishDir "results/${params.out_dir}/intermediate_qc_reports/number_of_reads/", pattern: "*num_reads.tsv", mode: "copy", overwrite: true
    publishDir "results/${params.out_dir}/intermediate_qc_reports/read_length/", pattern: "*length.tsv", mode: "copy", overwrite: true
    publishDir "results/${params.out_dir}/intermediate_qc_reports/quality_score_thresholds/", pattern: "*thresholds.tsv", mode: "copy", overwrite: true
    
    label 'small'

    input:
        tuple val(id), val(num_trimmed_fastq), val(mapq), path(json), path(flagstat_unfiltered), path(flagstat_filtered), val(num_pass_reads)
        val(qscore_thresh)

    output:
        path("${id}_num_reads.tsv"), emit: num_reads
        path("${id}_read_length.tsv"), emit: read_length
        path("${id}_quality_thresholds.tsv"), emit: qscore_thresh

    script:
        """
        reads_number_fastq_all=\$(jq '.["All Reads"].basecall.reads_number' "${json}")
 
        reads_number_aligned=\$(grep "primary mapped" "${flagstat_unfiltered}" | awk '{print \$1}')
       
        reads_number_aligned_filtered=\$(grep "primary mapped" "${flagstat_filtered}" | awk '{print \$1}')
       
        N50_fastq=\$(jq '.["All Reads"].basecall.N50' "${json}")

        median_read_length_fastq=\$(jq '.["All Reads"].basecall.len_percentiles[50]' "${json}")

        N50_alignment=\$(jq '.["All Reads"].alignment.N50' "${json}")
       
        median_read_length_alignment=\$(jq '.["All Reads"].alignment.len_percentiles[50]' "${json}")
       
        echo "${id}\t\${reads_number_fastq_all}\t${num_trimmed_fastq}\t\${reads_number_aligned}\t\${reads_number_aligned_filtered}" > "${id}_num_reads.tsv"
       
        echo "${id}\t\${N50_fastq}\t\${median_read_length_fastq}\t\${N50_alignment}\t\${median_read_length_alignment}" > "${id}_read_length.tsv"
       
        echo "${id}\t${qscore_thresh}\t${mapq}" > "${id}_quality_thresholds.tsv"
       
        """

}

process MAKE_QC_REPORT_TRIM {
    
    publishDir "results/${params.out_dir}/intermediate_qc_reports/number_of_reads/", pattern: "*num_reads.tsv", mode: "copy", overwrite: true
    publishDir "results/${params.out_dir}/intermediate_qc_reports/read_length/", pattern: "*length.tsv", mode: "copy", overwrite: true
    publishDir "results/${params.out_dir}/intermediate_qc_reports/quality_score_thresholds/", pattern: "*thresholds.tsv", mode: "copy", overwrite: true
    
    label 'small'

    input:
        tuple val(id), val(num_trimmed_fastq), path(json), path(flagstat_unfiltered), path(flagstat_filtered), val(read_stats)
        val(qscore_thresh)
	val(mapq)

    output:
        path("${id}_num_reads.tsv"), emit: num_reads
        path("${id}_read_length.tsv"), emit: read_length
        path("${id}_quality_thresholds.tsv"), emit: qscore_thresh

    script:
        """
        reads_number_fastq_all=\$(jq '.["All Reads"].basecall.reads_number' "${json}")

        reads_number_fastq_pass=\$(jq '.["0"].total_pass_reads' "${read_stats}")
	reads_after_pychop=\$(jq '.["0"].total_after_pychop' "${read_stats}")
	reads_after_NanoporeConvert=\$(jq '.["0"].total_after_NanoporeConvert' "${read_stats}")
	reads_after_pipseeker=\$(jq '.["0"].total_after_pipseeker' "${read_stats}")
 
        reads_number_aligned=\$(grep "primary mapped" "${flagstat_unfiltered}" | awk '{print \$1}')
       
        reads_number_aligned_filtered=\$(grep "primary mapped" "${flagstat_filtered}" | awk '{print \$1}')
       
        N50_fastq=\$(jq '.["All Reads"].basecall.N50' "${json}")

        median_read_length_fastq=\$(jq '.["All Reads"].basecall.len_percentiles[50]' "${json}")

        N50_alignment=\$(jq '.["All Reads"].alignment.N50' "${json}")
       
        median_read_length_alignment=\$(jq '.["All Reads"].alignment.len_percentiles[50]' "${json}")
       
        echo "${id}\t\${reads_number_fastq_all}\t\${reads_number_fastq_pass}\t\${reads_after_pychop}\t\${reads_after_NanoporeConvert}\t\${reads_after_pipseeker}\t${num_trimmed_fastq}\t\${reads_number_aligned}\t\${reads_number_aligned_filtered}" > "${id}_num_reads.tsv"
       
        echo "${id}\t\${N50_fastq}\t\${median_read_length_fastq}\t\${N50_alignment}\t\${median_read_length_alignment}" > "${id}_read_length.tsv"
       
        echo "${id}\t${qscore_thresh}\t${mapq}" > "${id}_quality_thresholds.tsv"
       
        """

}


process MERGE_QC_REPORT {

    publishDir "results/${params.out_dir}/reads_report/", pattern: "*", mode: "copy", overwrite: true

    label 'small'

    input:
        path(num_reads)
        path(read_length)
        path(qscore_thresh)

    output:
        path("*")

    script:
        """
        
        cat $num_reads >> "Number_of_Reads.tsv"
        FIELD_COUNT=\$(head -n 1 Number_of_Reads.tsv | tr '\t' '\n' | wc -l)
        
        echo "# plot_type: 'table'" >> "Number_of_Reads_mqc.tsv"
        echo "# id: 'number of reads custom'" >> "Number_of_Reads_mqc.tsv" 
        echo "# section_name: 'Number of reads per sample'" >> "Number_of_Reads_mqc.tsv"

	echo "Sample_ID\tAll Reads\tPass Reads\tReads after pychopper\tReads after NanoporeConvert\tReads after Pipseeker\tTrimmed & Processed Pass Reads\tPrimary Alignments\tFiltered Primary Alignments (MAPQ)" >> "Number_of_Reads_mqc.tsv"
        cat "Number_of_Reads.tsv" >> "Number_of_Reads_mqc.tsv"
        
        echo "# plot_type: 'table'" >> "Read_Length_mqc.tsv"
        echo "# id: 'read length custom'" >> "Read_Length_mqc.tsv" 
        echo "# section_name: 'Read lengths per sample'" >> "Read_Length_mqc.tsv"
        echo "Sample_ID\tN50 FASTQ\tMedian Read Length FASTQ\tN50 BAM\tMedian Read Length BAM" >> "Read_Length_mqc.tsv"
        cat $read_length >> "Read_Length_mqc.tsv"

        echo "# plot_type: 'table'" >> "Quality_Thresholds_mqc.tsv"
        echo "# id: 'quality threholds'" >> "Quality_Thresholds_mqc.tsv" 
        echo "# section_name: 'Quality thresholds for each sample'" >> "Quality_Thresholds_mqc.tsv"
        echo "Sample_ID\tRead Mean Base Quality Score Threshold (PHRED)\tMapping Quality Threshold (MAPQ)" >> "Quality_Thresholds_mqc.tsv"
        cat $qscore_thresh >> "Quality_Thresholds_mqc.tsv"
       
        """

}
