process BARCODE_CONFIG {

	publishDir "results/${params.out_dir}/barcoding", mode: "copy", overwrite: true
	
	label 'tiny'

	input:

	path(barcodes)

	output:
	
	path("barcode_arrs_PIPSEQ.toml"), emit: barcode_config

	shell:
	"""
	barcode_list=${barcodes}
	num_barcodes=\$(wc -l < "\$barcode_list" | awk '{print \$1}')
	digits=\$(echo -n "\$num_barcodes" | wc -c)

	echo "[loading_options]" >> barcode_arrs_PIPSEQ.toml
	echo \$(printf 'barcodes_filename = "barcodes_PIPSEQ.fasta"') >> barcode_arrs_PIPSEQ.toml
	echo "double_variants_frontrear = false" >> barcode_arrs_PIPSEQ.toml
	echo "" >> barcode_arrs_PIPSEQ.toml
	echo "[arrangement]" >> barcode_arrs_PIPSEQ.toml
	echo \$(printf 'name = "barcode_arrs_PIPSEQ"') >> barcode_arrs_PIPSEQ.toml
	echo \$(printf 'id_pattern = "PIPSEQ_%%0'\$digits'i"' ) >> barcode_arrs_PIPSEQ.toml
	echo \$(printf 'compatible_kits = ["PIPSEQ"]') >> barcode_arrs_PIPSEQ.toml
	echo "first_index = 1" >> barcode_arrs_PIPSEQ.toml
	echo "last_index = \$num_barcodes" >> barcode_arrs_PIPSEQ.toml
	echo \$(printf 'kit = "PIPSEQ"') >> barcode_arrs_PIPSEQ.toml
	echo \$(printf 'normalised_id = "barcode_%%0'\$digits'i"') >> barcode_arrs_PIPSEQ.toml
	echo \$(printf 'scoring_function = "MAX"') >> barcode_arrs_PIPSEQ.toml
	echo \$(printf 'barcode1_pattern = "PIPSEQ_%%0'\$digits'i"') >> barcode_arrs_PIPSEQ.toml
	"""
}
