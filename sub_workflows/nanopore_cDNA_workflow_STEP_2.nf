// Import Modules
include {MAKE_FAI} from '../modules/make_fai'
include {MAKE_INDEX_cDNA } from '../modules/make_index'
include {MINIMAP2_cDNA; FILTER_BAM} from '../modules/minimap2'
include {BAMBU_PREP} from '../modules/bambu'


workflow NANOPORE_cDNA_STEP_2 {

    take:
        ref
        annotation
        ont_reads_fq
        track_reads
        mapq
	mapped_reads_thresh

    main:
        MAKE_FAI(ref)
        MAKE_INDEX_cDNA(ref)
        MINIMAP2_cDNA(ont_reads_fq,  MAKE_INDEX_cDNA.out)
        FILTER_BAM(MINIMAP2_cDNA.out.bam_unfiltered, mapq, mapped_reads_thresh)
	BAMBU_PREP(FILTER_BAM.out.bam_filtered, mapq, ref, annotation, MAKE_FAI.out, track_reads)

}
