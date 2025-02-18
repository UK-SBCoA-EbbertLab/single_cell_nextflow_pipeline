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
	n_cells_process

    main:
        BAMBU_QUANT(bambu_rds.collate(n_cells_process), ref, annotation, fai)
	MERGE_MATRICES(BAMBU_QUANT.out.quant_files.collect(), params.out_dir)
       
}
