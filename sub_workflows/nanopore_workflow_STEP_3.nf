// Import Modules
include {BAMBU_QUANT} from '../modules/bambu'
include {MERGE_MATRICES} from '../modules/merge'

workflow NANOPORE_STEP_3 {

    take:
        ref
        fai
        annotation
        track_reads
        bambu_rds

    main:
        BAMBU_QUANT(bambu_rds, ref, annotation, fai)
	BAMBU_QUANT.out.quant_files
		.transpose()
		.groupTuple()
		.view()
	MERGE_MATRICES(BAMBU_QUANT.out.quant_files
		.transpose()
		.groupTuple() , params.out_dir)
       
}
