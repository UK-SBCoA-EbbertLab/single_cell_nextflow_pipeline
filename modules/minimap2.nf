process MINIMAP2_cDNA {

    publishDir "results/${params.out_dir}/mapping_cDNA/", pattern: "*.ba*", mode: "copy", overwrite: true
    publishDir "results/${params.out_dir}/testing_values", mode: 'copy', overwrite: true, pattern: "*.tsv"

    label 'medium_small'

    input:
        tuple val(id), path(fastq)
        file(index)

    output:
        tuple val(id), path("*.bam"), path("*.bam.bai"), emit: bam_unfiltered

    script:
        """
	the_ids="${id}"
	the_ids="\${the_ids//[\\[\\],]/}"
	read -ra id_array <<< "\$the_ids"

	for c_id in "\${id_array[@]}"; do
	    minimap2 -t 4 -ax splice \
		-uf \
		$index \
		"\${c_id}.fastq" > "\${c_id}_all.bam"

	    samtools sort -@ -4 "\${c_id}_all.bam" -o "\${c_id}.bam" 
	    samtools index "\${c_id}.bam"

	    echo "\${c_id}.bam"
	    samtools view -F 0x40 "\${c_id}.bam" | cut -f1 | sort | uniq | wc -l

	    rm "\${c_id}_all.bam"
	done
        """

}

process FILTER_BAM {

    publishDir "results/${params.out_dir}/qc_stats", mode: "copy", pattern: "*.*stat", overwrite: true
    publishDir "results/${params.out_dir}/filtered_bams", mode: "copy", pattern: "*.ba*", overwrite: true
   
    label 'small'

    input:
        tuple val(id), path(bam), path(bai)
        val(mapq)
	val(mapped_reads_thresh)

    output:
	tuple env(FILTERED_IDS), path("*_filtered_mapq_${mapq}.bam"), path("*_filtered_mapq_${mapq}.bam.bai"), emit: bam_filtered
        path("*.*stat"), emit: QC

    script:
        """
	the_ids="${id}"
	the_ids="\${the_ids//[\\[\\],]/}"
	read -ra id_array <<< "\$the_ids"

	declare -a FILTERED_IDS

	for c_id in "\${id_array[@]}"; do
	    samtools flagstat "\${c_id}.bam" > "\${c_id}_unfiltered.flagstat"
	    samtools idxstats "\${c_id}.bam" > "\${c_id}_unfiltered.idxstat"

	    samtools view -b -q $mapq -F 2304 -@ 4 "\${c_id}.bam" > 'intermediate.bam'
	    samtools sort -@ 4 "intermediate.bam" -o "\${c_id}_filtered_mapq_${mapq}.bam"
	    samtools index "\${c_id}_filtered_mapq_${mapq}.bam"
	    samtools flagstat "\${c_id}_filtered_mapq_${mapq}.bam" > "\${c_id}_filtered_mapq_${mapq}.flagstat"
	    samtools idxstats "\${c_id}_filtered_mapq_${mapq}.bam" > "\${c_id}_filtered_mapq_${mapq}.idxstat"

	    rm "intermediate.bam"

	    var=\$(awk 'NR==8 {print \$1}' "\${c_id}_filtered_mapq_${mapq}.flagstat")
			
	    ## If flagstat file says there are no mapped reads then delete bam and bai files.

	    ## Since we passed optional on the output statement lines the script should still run fine even
	    ## When the files are deleted. However, I never used optional before so I am not 100% sure

	    if [ \$var -lt ${mapped_reads_thresh} ]; then
		rm \${c_id}_filtered_mapq_${mapq}.ba*
	    else
		FILTERED_IDS+=("\${c_id}")
	    fi
	done
        """

}
