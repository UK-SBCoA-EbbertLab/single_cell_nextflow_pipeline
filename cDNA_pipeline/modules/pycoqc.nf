process PYCOQC {

    publishDir "results/${params.out_dir}/multiQC_input/pycoqc/", mode: 'copy', overwrite: true, pattern: "*pycoqc*"

    label 'huge'

    input:
        tuple val(id), path(fastq), path(seq_summary), path(total_bam), path(total_bai), path(flagstat_unfiltered), path(flagstat_filtered)
	val(quality_score)
        val(mapq)

    output:
        path "*pycoqc*", emit: multiQC
        tuple val(id), env(num_reads_trimmed), path("${id}_pycoqc.json"), path(flagstat_unfiltered), path(flagstat_filtered), emit: num_reads_report

    script:
        """
	export PYTHON_EGG_CACHE=${params.tmpwritedir}
	echo ${fastq}
        num_reads_trimmed=\$(fix_sequencing_summary_pychopper.py $fastq $seq_summary "${id}_sequencing_summary_pyco.txt")

        pycoQC -f "${id}_sequencing_summary_pyco.txt" \
            -v \
            -a $total_bam \
            --min_pass_qual $quality_score \
            -o "./${id}_pycoqc.html" \
            -j "./${id}_pycoqc.json"
        """
}

