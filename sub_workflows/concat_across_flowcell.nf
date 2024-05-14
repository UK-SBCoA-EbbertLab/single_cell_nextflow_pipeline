include {MERGE_SUMMARY ; MERGE_FASTQ} from '../modules/merge'

workflow MERGE_FLOWCELL {

	take: 
		sampleIDtable
		ont_reads_fq_dir
	main:
		MERGE_SUMMARY(sampleIDtable, ont_reads_fq_dir)
		MERGE_FASTQ(sampleIDtable, ont_reads_fq_dir)
}		
