process BAMBU_PREP {

    publishDir "results/${params.out_dir}/bambu_prep", mode: "copy", overwrite: true

    label 'bambu_prep_job'

    input:
        tuple val(id), path(bam), path(bai)
        val(mapq)
        path(ref)
        path(gtf)
        path(fai)
        val(track_reads)

    output:
        path("*.rds")

    script:
        """
	the_ids="${id}"
	the_ids="\${the_ids//[\\[\\],]/}"
	read -ra id_array <<< "\$the_ids"
	    
	for c_id in "\${id_array[@]}"; do
	    mkdir -p bambu_prep
	    bambu_prep.R "\${c_id}_filtered_mapq_${mapq}.bam" $ref $gtf $track_reads
	    mv ./bambu_prep/*.rds "./bambu_prep/\${c_id}_mapq_${mapq}.rds"
	    mv ./bambu_prep "./\${c_id}"
	done

	mv **/*.rds .
	
        """
}

process BAMBU_QUANT {

    publishDir "results/${params.out_dir}/", mode: "copy", overwrite: true

    label 'medium_small'

    input:
        tuple val(id), val(batch), path(rc_files)
        path(ref)
        path(gtf)
        path(fai)
        

    output:
	tuple val(id), path("bambu_quant/*.txt"), emit: quant_files
        path("bambu_quant/*"), emit: out_dir

    shell:
        '''

        mkdir bambu_quant

        dummy="!{rc_files}"

        rc_files2="$(tr ' ' ',' <<<$dummy)"
    
        bambu_quant.R $rc_files2 "!{ref}" "!{gtf}"

        cd ./bambu_quant/
        
        # Create a SHA-256 hash of the files
        hash_value=$(echo -n "$dummy" | openssl dgst -sha256 | sed 's/SHA2-256(stdin)= //')

        # Rename each file in the directory by prepending the hash value
        for file in ./*; do

            # Extract the base name and directory name
            base_name=$(basename "$file")

            # Rename the file by prepending the hash value
            mv "$file" "${hash_value}_${base_name}"
        
        done

        cd ..

        pwd
        '''
}
