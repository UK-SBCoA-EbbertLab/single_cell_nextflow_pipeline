process UNZIP_AND_CONCATENATE {

    publishDir "results/${params.out_dir}/concatenated_fastq_and_sequencing_summary_files/", mode: 'copy', overwrite: true, pattern: "*.fastq"
    
    label "medium"

    input:
        tuple val(id), file(reads)

    output:
        tuple val("$id"), path("${id}.fastq")

    script:
    """

        find -L . -maxdepth 1 -name "*.fastq.gz" | parallel -j 16 'gunzip --keep --force {}'
        
        find . -type f -maxdepth 1 -name "*.fastq" ! -name "${id}.fastq" -exec cat {} \\; >> "${id}.fastq"

        find . -maxdepth 1 -type f -name "*.fastq" ! -name "${id}.fastq" -exec rm {} \\;
    
    """
}

process FIX_SEQUENCING_SUMMARY_NAME {

    publishDir "results/${params.out_dir}/concatenated_fastq_and_sequencing_summary_files/", mode: 'copy', overwrite: true, pattern: "*.txt"

    label "small"

    input: 
        tuple val(id), file(txt)

    output:
        path "${id}.txt"

    script:
    """
    
        mv $txt "${id}.txt"
    
    """

}

process UNZIP_AND_CONCATENATE_WITH_FLOWCELL {

    publishDir "results/${params.out_dir}/pre_processing/concatenated_fastq_and_sequencing_summary_files/", mode: 'copy', overwrite: true, pattern: "*.fastq"
    
    label "medium"

    input:
	tuple val(samp), val(flowcell), file(reads)

    output:
	tuple val(samp), val(flowcell), path("${samp}_${flowcell}.fastq")

    script:
    """

        find -L . -maxdepth 1 -name "*.fastq.gz" | parallel -j 16 'gunzip --keep --force {}'
        
        find . -type f -maxdepth 1 -name "*.fastq" ! -name "${samp}_${flowcell}.fastq" -exec cat {} \\; >> "${samp}_${flowcell}.fastq"

        find . -maxdepth 1 -type f -name "*.fastq" ! -name "${samp}_${flowcell}.fastq" -exec rm {} \\;
    
    """
}

process FIX_SEQUENCING_SUMMARY_NAME_WITH_FLOWCELL {

    publishDir "results/${params.out_dir}/pre_processing/concatenated_fastq_and_sequencing_summary_files/", mode: 'copy', overwrite: true, pattern: "*.txt"

    label "local"

    input: 
	tuple val(samp), val(flowcell), file(txt)

    output:
	tuple val(samp), val(flowcell), path("${samp}_${flowcell}.txt")

    script:
    """
    	while IFS= read -r file_path; do
	    ln -s \${file_path} .
	    filename=\$(basename \${file_path})
	    cat \${filename} >> "${samp}_${flowcell}.txt"
        done < "${txt}"
    
    """

}
