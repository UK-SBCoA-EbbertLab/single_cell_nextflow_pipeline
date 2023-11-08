process CREATE_FASTA {

	publishDir "results/${params.out_dir}/barcoding", mode: "copy", overwrite: true
	
	label 'small'

        input:
                path(list)
        output:
                path("barcodes_PIPSEQ.fasta"), emit: barcode_fasta

        script:
        """
	barcode_list=${list}
        num_barcodes=\$(wc -l < "\$barcode_list" | awk '{print \$1}')
        bash numbers.sh \$num_barcodes
        bash create_fasta.sh "numbers.txt" \$barcode_list "barcodes_PIPSEQ.fasta"
        """
}
