include {COMBINE_DEMULTIPLEX} from '../modules/demultiplex_pipseq.nf'

workflow NANOPORE_STEP_0_comb_demulti {
        take:
		demulti_fastqs

        main:

		COMBINE_DEMULTIPLEX(demulti_fastqs.collate(500))
}
