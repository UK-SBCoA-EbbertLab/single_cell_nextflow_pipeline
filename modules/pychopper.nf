process PYCHOPPER_SC {

    publishDir "results/${params.out_dir}/multiQC_input/pychopper/${sampleID}_${flowcellID}", mode: 'copy', overwrite: true, pattern: "*pychopper*"
    publishDir "results/${params.out_dir}/pre_processing/stats/${sampleID}_${flowcellID}", mode: 'copy', overwrite: true, pattern: "*_num_pass_reads_by_file.tsv"
    publishDir "results/${params.out_dir}/pre_processing/01_pychopper/${sampleID}_${flowcellID}", mode: 'copy', overwrite: true, pattern: "*_pychop.fastq.gz"
    
    label "pychopper"

    input:
        tuple val(sampleID), val(flowcellID), val(fileNumber), path(input_fastqs)
        val(cdna_kit)
        val(quality_score)
	val(mpldir)

    output:
        tuple val(sampleID), val(flowcellID), val(fileNumber), path("*_pychop.fastq.gz"), emit: pychop_fqs
        path "*pychopper*", emit: multiQC
	tuple val(sampleID), val(flowcellID), path("${sampleID}_${flowcellID}_${fileNumber}_num_pass_reads_by_file.tsv"), emit: num_pass_reads

    script:
    
    """
    export MPLCONFIGDIR=${mpldir}

    ## we are actually using custom primers due to the nature of connecting PIP and ONT
    if [[ "${cdna_kit}" == "PCS114" ]]; then
    
        ## Create primer config file ##
        echo "+:MySSP,-MyVNP|-:MyVNP,-MySSP" > primer_config.txt
    
        ## Create custom primers for PCS114 ##
        echo ">MyVNP" > custom_pimers.fas
        echo "ACTTGCCTGTCGCTCTATCTTCCTCTTTCCCTACACGACGCTC" >> custom_pimers.fas
        echo ">MySSP" >> custom_pimers.fas
        echo "TTTCTGTTGGTGCTGATATTGC" >> custom_pimers.fas
    fi

    echo -e "File\tnum_pass_reads\tnum_reads_after_pychop" > "${sampleID}_${flowcellID}_${fileNumber}_num_pass_reads_by_file.tsv"
    
    # Loop through each line in the input file
    while IFS= read -r file_path; do
        # Create a symbolic link in the current directory with the base name
        ln -s "\$file_path" .
    done < "${input_fastqs}"

    for file in *.fastq.gz; do
	fastq=\$(basename "\$file" .gz)
	basename=\$(basename "\$fastq" .fastq)

	gzip -dkc "\$file" > "\$fastq"

        NUM_PASS_READS=\$(filter_by_mean_base_quality.py "\${fastq}" "${quality_score}" "\${basename}_qscore_${quality_score}.fastq")

	
	## Pychopper does not have PCS114 primers yes, need to use the created files ##
	if [[ "${cdna_kit}" == "PCS114" ]]; then
	    ## Run pychopper with the custom primers and primer config ##
	    pychopper -m edlib -b custom_pimers.fas -c primer_config.txt \
	        -t 4 \
		-Q $quality_score \
		-r "\${basename}_pychopper_report.pdf" \
		-u "\${basename}_pychopper.unclassified.fq" \
		-w "\${basename}_pychopper.rescued.fq" \
		-S "\${basename}_pychopper.stats" \
		-A "\${basename}_pychopper.scores" \
		"\${basename}_qscore_${quality_score}.fastq" "\${basename}_pychop.fastq"

	## All other kits just use default settings ##
	else
	    pychopper -m edlib \
	        -t 4 \
	        -Q $quality_score \
		-k $cdna_kit \
		-r "\${basename}_pychopper_report.pdf" \
		-u "\${basename}_pychopper.unclassified.fq" \
		-w "\${basename}_pychopper.rescued.fq" \
		-S "\${basename}_pychopper.stats" \
		-A "\${basename}_pychopper.scores" \
		"\${basename}_qscore_${quality_score}.fastq" "\${basename}_pychop.fastq"
    	fi

	# append the rescued reads to the bottom of the fastq
	cat "\${basename}_pychopper.rescued.fq"  >> "\${basename}_pychop.fastq"
	num_reads_after_pychopper=\$(awk 'END {print NR/4}' "\${basename}_pychop.fastq")
	
	echo -e "\${file}\t\${NUM_PASS_READS}\t\${num_reads_after_pychopper}" >> "${sampleID}_${flowcellID}_${fileNumber}_num_pass_reads_by_file.tsv"
	   
	rm "\${basename}_qscore_${quality_score}.fastq"
	rm "\${fastq}"
	
	gzip "\${basename}_pychop.fastq"
    done

    """
}
