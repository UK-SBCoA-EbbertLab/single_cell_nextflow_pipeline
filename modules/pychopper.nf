process PYCHOPPER_SC {

    publishDir "results/${params.out_dir}/multiQC_input/pychopper/${sampleID}_${flowcellID}", mode: 'copy', overwrite: true, pattern: "*pychopper*"
    publishDir "results/${params.out_dir}/pre_processing/stats/${sampleID}_${flowcellID}", mode: 'copy', overwrite: true, pattern: "*_num_pass_reads_by_file.tsv"
    publishDir "results/${params.out_dir}/pre_processing/01_pychopper/${sampleID}_${flowcellID}", mode: 'copy', overwrite: true, pattern: "*_pychop_*.fastq.gz"
    
    label "pychopper"

    input:
        tuple val(sampleID), val(flowcellID), val(fileNumber), path(input_fastqs)
        val(cdna_kit)
        val(quality_score)
	val(mpldir)

    output:
        tuple val(sampleID), val(flowcellID), val(fileNumber), path("*_pychop_*.fastq.gz"), emit: pychop_fqs
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
        echo "TTTCTGTTGGTGCTGATATTGCAAGCAGTGGTATCAACGCAGAG" >> custom_pimers.fas
    fi

    echo -e "File\tnum_pass_reads\tnum_reads_after_pychop" > "${sampleID}_${flowcellID}_${fileNumber}_num_pass_reads_by_file.tsv"
    
    # Loop through each line in the input file
    while IFS= read -r file_path; do
        # Create a symbolic link in the current directory with the base name
        # ln -s "\$file_path" .
	zcat "\${file_path}" >> concatted_fastq.fastq
    done < "${input_fastqs}"

    NUM_PASS_READS=\$(filter_by_mean_base_quality.py concatted_fastq.fastq "${quality_score}" "${sampleID}_${flowcellID}_${fileNumber}_qscore_${quality_score}.fastq")

	
    ## Run pychopper with the custom primers and primer config ##
    pychopper -m edlib -b custom_pimers.fas -c primer_config.txt \
	-t 4 \
	-Q $quality_score \
	-r "${sampleID}_${flowcellID}_${fileNumber}_pychopper_report.pdf" \
	-u "${sampleID}_${flowcellID}_${fileNumber}_pychopper.unclassified.fq" \
	-w "${sampleID}_${flowcellID}_${fileNumber}_pychopper.rescued.fq" \
	-S "${sampleID}_${flowcellID}_${fileNumber}_pychopper.stats" \
	-A "${sampleID}_${flowcellID}_${fileNumber}_pychopper.scores" \
	"${sampleID}_${flowcellID}_${fileNumber}_qscore_${quality_score}.fastq" "${sampleID}_${flowcellID}_${fileNumber}_pychop.fastq"

    # append the rescued reads to the bottom of the fastq
    cat "${sampleID}_${flowcellID}_${fileNumber}_pychopper.rescued.fq"  >> "${sampleID}_${flowcellID}_${fileNumber}_pychop.fastq"
    num_reads_after_pychopper=\$(awk 'END {print NR/4}' "${sampleID}_${flowcellID}_${fileNumber}_pychop.fastq")
   
    echo -e "${sampleID}_${flowcellID}_${fileNumber}\t\${NUM_PASS_READS}\t\${num_reads_after_pychopper}" >> "${sampleID}_${flowcellID}_${fileNumber}_num_pass_reads_by_file.tsv"
   
    rm "${sampleID}_${flowcellID}_${fileNumber}_qscore_${quality_score}.fastq"
    rm concatted_fastq.fastq
    
    split -l 32000 -d --additional-suffix=".fastq" "${sampleID}_${flowcellID}_${fileNumber}_pychop.fastq" "${sampleID}_${flowcellID}_${fileNumber}_pychop_"
    gzip ${sampleID}_${flowcellID}_${fileNumber}_pychop_*.fastq
	

    """
}
