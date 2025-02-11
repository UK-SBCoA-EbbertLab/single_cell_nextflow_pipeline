process GFFCOMPARE {

    publishDir "results/${params.out_dir}/gffcompare/", mode: "copy", overwrite: true

    label 'small'

    input:
        path(extended_annotation)
        path(reference_annotation)

    output:
        path "*"

    script:
        """
        gffcompare -r $reference_annotation $extended_annotation -o "gffcompare_output"
        """
}

process GFFCOMPARE_NOVEL {

    publishDir "results/${params.out_dir}/gffcompare/${comparison_dir}/", mode: "copy", overwrite: true

    label 'small'

    input:
	path(our_novel_isoforms)
	path(other_annotation)
	val(comparison_dir)
	val(comparison_prefix)

    output:
	path "*"

    script:
	"""
	gffcompare -r ${other_annotation} ${our_novel_isoforms} -o ${comparison_prefix}

	"""

}

process ISOLATE_NOVEL_ISOFORMS {

    publishDir "results/${params.out_dir}/gffcompare/novel_isoforms_/", mode: "copy", overwrite: true

    label 'small'

    input:
	path(gtf)
	val(novel_pattern)

    output:
	path "*"

    script:
	"""
	grab_novel_isoforms_only.py $gtf $novel_pattern "\$(basename $gtf | cut -d. -f1)"_novel_only.gtf
	"""

}
