process MINIMAP2_cDNA {

    publishDir "results/${params.out_dir}/mapping_cDNA/", pattern: "*.ba*", mode: "copy", overwrite: true
    publishDir "results/${params.out_dir}/multiQC_input/minimap2/", pattern: "*.*stat", mode: "copy", overwrite: true

    label 'small'

    input:
        tuple val(id), path(fastq)
        file(index)
        val(txt)

    output:
        val("$id"), emit: id
        path("$fastq"), emit: fastq
        path("${id}.bam"), emit: bam
        path("${id}.bam.bai"), emit: bai
        path("${id}*stat"), emit: QC_out
        val("$txt"), emit: txt
        env(NUM_READS), emit: num_reads

    script:
        """
        minimap2 -t 4 -ax splice \
            -uf \
            $index \
            $fastq > "${id}_all.bam" \
     

        samtools sort -@ -4 "${id}_all.bam" -o "${id}.bam" 
        samtools index "${id}.bam"
        samtools flagstat "${id}.bam" > "${id}.flagstat"
        samtools idxstats "${id}.bam" > "${id}.idxstat"
        
        NUM_READS=\$(samtools view -F 0x40 "${id}.bam" | cut -f1 | sort | uniq | wc -l)

        rm "${id}_all.bam"
        """

}

process MINIMAP2_dRNA {

    publishDir "results/${params.out_dir}/mapping_dRNA/", pattern: "*.ba*", mode: "copy", overwrite: true
    publishDir "results/${params.out_dir}/multiQC_input/minimap2/", pattern: "*.*stat", mode: "copy", overwrite: true

    label 'tiny'

    input:
        tuple val(id), path(fastq)
        file(index)
        val(txt)

    output:
        val("$id"), emit: id
        path("$fastq"), emit: fastq
        path("${id}.bam"), emit: bam
        path("${id}.bam.bai"), emit: bai
        path("${id}*stat"), emit: QC_out
        val("$txt"), emit: txt
        env(NUM_READS), emit: num_reads

    script:
        """
        minimap2 -t 4 -ax splice \
            -k14 -uf \
            $index \
            $fastq > "${id}_all.bam" \


        samtools sort -@ -4 "${id}_all.bam" -o "${id}.bam"
        samtools index "${id}.bam"
        samtools flagstat "${id}.bam" > "${id}.flagstat"
        samtools idxstats "${id}.bam" > "${id}.idxstat"

        NUM_READS=\$(samtools view -F 0x40 "${id}.bam" | cut -f1 | sort | uniq | wc -l)

        rm "${id}_all.bam"
        """

}

process FILTER_BAM {

    publishDir "results/${params.out_dir}/bam_filtering/", mode: "copy", pattern: "*.*stat"
    publishDir "results/${params.out_dir}/bam_filtering/", mode: "copy", pattern: "*.bam*"

    label 'tiny'

    input:
        val(id)
        val(mapq)
        path(bam)
        path(bai)
	val(mapped_reads_thresh)

    output:
        env(id), emit: id, optional: true
        path("${id}_filtered_mapq_${mapq}.bam"), emit: bam, optional: true
        path("${id}_filtered_mapq_${mapq}.bam.bai"), emit: bai, optional: true
        path("*.*stat"), emit: QC

    script:
        """

        samtools view -b -q $mapq -F 2304 -@ 4 $bam > 'intermediate.bam'
        samtools sort -@ 4 "intermediate.bam" -o '${id}_filtered_mapq_${mapq}.bam'
        samtools index '${id}_filtered_mapq_${mapq}.bam'
        samtools flagstat "${id}_filtered_mapq_${mapq}.bam" > "${id}_filtered_mapq_${mapq}.flagstat"
        samtools idxstats "${id}_filtered_mapq_${mapq}.bam" > "${id}_filtered_mapq_${mapq}.idxstat"

        rm "intermediate.bam"

	var=\$(awk 'NR==8 {print \$1}' "${id}_filtered_mapq_${mapq}.flagstat")
				
        ## If flagstat file says there are no mapped reads then delete bam and bai files.
				## Since we passed optional on the output statement lines the script should still run fine even
				## When the files are deleted. However, I never used optional before so I am not 100% sure
				if [ \$var -lt ${mapped_reads_thresh} ]; then
					rm ${id}_filtered_mapq_${mapq}.ba*
				else
        	id="${id}"
        fi
        """

}

process FILTER_BAM_ONLY {

    publishDir "results/${params.out_dir}/bam_filtering/", mode: "copy", pattern: "*.*stat"

    label 'tiny'

    input:
        tuple val(id), path(bam)
        val(bai)
        val(mapq)

    output:
        val("$id"), emit: id
        path("${id}_filtered_mapq_${mapq}.bam"), emit: bam, optional: true
        path("${id}_filtered_mapq_${mapq}.bam.bai"), emit: bai, optional : true
        path("*.*stat"), emit: QC

    script:
        """

        samtools view -b -q $mapq -F 2304 -@ 4 $bam > 'intermediate.bam'
        samtools sort -@ 4 "intermediate.bam" -o '${id}_filtered_mapq_${mapq}.bam'
        samtools index '${id}_filtered_mapq_${mapq}.bam'
        samtools flagstat "${id}_filtered_mapq_${mapq}.bam" > "${id}_filtered_mapq_${mapq}.flagstat"
        samtools idxstats "${id}_filtered_mapq_${mapq}.bam" > "${id}_filtered_mapq_${mapq}.idxstat"

        rm "intermediate.bam"

	var=\$(awk 'NR==8 {print \$1}' "${id}_filtered_mapq_${mapq}.flagstat")

	## If flagstat file says there are no mapped reads then delete bam and bai files.
                                ## Since we passed optional on the output statement lines the script should still run fine even
                                ## When the files are deleted. However, I never used optional before so I am not 100% sure
                                if [ \$var -lt 500 ]; then
                                        rm ${id}_filtered_mapq_${mapq}.ba*
                                else
                id="${id}"
        fi
        """

}
