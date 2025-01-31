process MINIMAP2_cDNA {

    publishDir "results/${params.out_dir}/mapping_cDNA/", pattern: "*.ba*", mode: "copy", overwrite: true

    label 'large'

    input:
        tuple val(id), path(fastq)
        file(index)

    output:
	tuple val(id), path("${id}.bam"), path("${id}.bam.bai"), emit: bam_unfiltered
        tuple val(id), env(NUM_READS), emit: num_reads

    script:
        """
        minimap2 -t 50 -ax splice \
            -uf \
            $index \
            $fastq > "${id}_all.bam" \
     

        samtools sort -@ -12 "${id}_all.bam" -o "${id}.bam" 
        samtools index "${id}.bam"

        NUM_READS=\$(samtools view -F 0x40 "${id}.bam" | cut -f1 | sort | uniq | wc -l)
	
        rm "${id}_all.bam"
        """

}

process FILTER_BAM {

    publishDir "results/${params.out_dir}/bam_filtering/", mode: "copy", pattern: "*filtered_mapq*.*stat", overwrite: true
    publishDir "results/${params.out_dir}/multiQC_input/minimap2/", mode: "copy", pattern: "*unfiltered.*stat", overwrite: true

   
    label 'medium_small'

    input:
        tuple val(id), path(bam), path(bai)
        val(mapq)

    output:
        tuple val(id), path("${id}_filtered_mapq_${mapq}.bam"), path("${id}_filtered_mapq_${mapq}.bam.bai"), emit: bam_filtered
        tuple val(id), path("*.*stat"), emit: QC
        tuple val(id), path("*unfiltered.flagstat"), emit: flagstat_unfiltered 
        tuple val(id), path("*filtered_mapq*.flagstat"), emit: flagstat_filtered

    script:
        """
 
        samtools flagstat $bam > "${id}_unfiltered.flagstat"
        samtools idxstats $bam > "${id}_unfiltered.idxstat"

       
        samtools view -b -q $mapq -F 2304 -@ 12 $bam > 'intermediate.bam'
        samtools sort -@ 12 "intermediate.bam" -o '${id}_filtered_mapq_${mapq}.bam'
        samtools index '${id}_filtered_mapq_${mapq}.bam'
        samtools flagstat "${id}_filtered_mapq_${mapq}.bam" > "${id}_filtered_mapq_${mapq}.flagstat"
        samtools idxstats "${id}_filtered_mapq_${mapq}.bam" > "${id}_filtered_mapq_${mapq}.idxstat"

        rm "intermediate.bam"
        """

}

