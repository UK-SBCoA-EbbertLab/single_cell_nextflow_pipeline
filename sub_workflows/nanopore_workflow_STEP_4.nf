include {MERGE_MATRICES} from '../modules/merge'

workflow NANOPORE_STEP_4 {
        
    take:
	ont_reads_fq_dir
	demultiplex_name

    main:
	
	MERGE_MATRICES(ont_reads_fq_dir, demultiplex_name)	


}
