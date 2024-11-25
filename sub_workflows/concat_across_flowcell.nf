include {SEP_DIR_BY_SAMP_KEEP_SAMP ; MERGE_SUMMARY ; MERGE_FASTQ} from '../modules/merge'

workflow MERGE_FLOWCELL {

	take: 
		sample_id_table
		ont_fq_to_merge
	main:
		SEP_DIR_BY_SAMP_KEEP_SAMP(sample_id_table)
		SEP_DIR_BY_SAMP_KEEP_SAMP.out.dir_by_samp.view()
		MERGE_SUMMARY(SEP_DIR_BY_SAMP_KEEP_SAMP.out.dir_by_samp.flatten(), ont_fq_to_merge)
		MERGE_FASTQ(SEP_DIR_BY_SAMP_KEEP_SAMP.out.dir_by_samp.flatten(), ont_fq_to_merge)
}		
