include {PIPSEEKER} from '../modules/get_barcodes.nf'
include {CONVERT_NANOPORE} from '../modules/get_barcodes.nf'
include {CREATE_FASTA} from '../modules/create_barcode_fasta.nf'
include {BARCODE_CONFIG} from '../modules/create_barcode_config.nf'
include {FILTER_PIP} from '../modules/filter_pipseq.nf'
workflow NANOPORE_STEP_0 {
        take:
		ont_reads_fq_dir
		demultiplex_name
        main:
                CONVERT_NANOPORE(ont_reads_fq_dir)

                PIPSEEKER(ont_reads_fq_dir, CONVERT_NANOPORE.out.dir.collect())

               // CREATE_FASTA(PIPSEEKER.out.barcode_list)

               // BARCODE_CONFIG(PIPSEEKER.out.barcode_list)
		
		FILTER_PIP(PIPSEEKER.out.barcoded_fastqs.collect(), demultiplex_name)
}
