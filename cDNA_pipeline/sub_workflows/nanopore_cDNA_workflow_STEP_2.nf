// Import Modules
include {MAKE_FAI} from '../modules/make_fai'
include {MAKE_INDEX_cDNA ; MAKE_INDEX_cDNA_CONTAMINATION_CHM13} from '../modules/make_index'
include {MAKE_INDEX_cDNA as MAKE_INDEX_CONTAMINANTS} from '../modules/make_index'
include {CHM13_GTF; CHM13_GTF_ERCC} from '../modules/chm13_gff3_to_gtf'
include {PYCOQC} from '../modules/pycoqc'
include {MINIMAP2_cDNA; FILTER_BAM} from '../modules/minimap2'
include {RSEQC_GENE_BODY_COVERAGE ; RSEQC_BAM_STAT ; RSEQC_READ_GC ; CONVERT_GTF_TO_BED12 ; RSEQC_JUNCTION_ANNOTATION ; RSEQC_JUNCTION_SATURATION ; RSEQC_TIN ; RSEQC_READ_DISTRIBUTION} from '../modules/rseqc'
include {BAMBU_PREP} from '../modules/bambu'
include {MAP_CONTAMINATION_cDNA} from '../modules/contamination'
include {MAKE_CONTAMINATION_REPORT_1} from '../modules/make_contamination_report.nf'
include {MAKE_QC_REPORT_TRIM} from '../modules/num_reads_report.nf'


workflow NANOPORE_cDNA_STEP_2 {

    take:
        ref
        annotation
        housekeeping
        ont_reads_txt
        ont_reads_fq
	read_stats
        ercc
        cdna_kit
        track_reads
        mapq
        contamination_ref
        quality_score

    main:

        MAKE_FAI(ref)
        MAKE_INDEX_cDNA(ref)
        MINIMAP2_cDNA(ont_reads_fq, MAKE_INDEX_cDNA.out)
        FILTER_BAM(MINIMAP2_cDNA.out.bam_unfiltered, mapq)
        
        if (params.contamination_ref != "None") {

            MAKE_INDEX_CONTAMINANTS(contamination_ref)

            MAKE_INDEX_cDNA_CONTAMINATION_CHM13()

            BAM_AND_INDEX = MINIMAP2_cDNA.out.bam_unfiltered.combine(MAKE_INDEX_CONTAMINANTS.out).combine(MAKE_INDEX_cDNA_CONTAMINATION_CHM13.out)
           
	    //TODO: check that this is acting how I want it to 
            MAP_CONTAMINATION_cDNA(BAM_AND_INDEX)

	    REPORT_INPUTS = MINIMAP2_cDNA.out.num_reads.combine(MAP_CONTAMINATION_cDNA.out.contamination_results, by: 0) 

            MAKE_CONTAMINATION_REPORT_1(REPORT_INPUTS)

        }

        if ((params.ont_reads_txt != "None") || (params.path != "None")) {

	    PYCOQC_INPUTS = ont_reads_fq.combine(ont_reads_txt, by: 0).combine(MINIMAP2_cDNA.out.bam_unfiltered, by: 0).combine(FILTER_BAM.out.flagstat_unfiltered, by: 0).combine(FILTER_BAM.out.flagstat_filtered, by: 0)

	    PYCOQC_INPUTS.view()
	    read_stats.view()	
            
	    PYCOQC(PYCOQC_INPUTS, quality_score, mapq)

	    PYCOQC.out.num_reads_report.combine(read_stats, by:0).view()

	    MAKE_QC_REPORT_TRIM(PYCOQC.out.num_reads_report.combine(read_stats, by: 0), quality_score, mapq)

        }

        if (params.is_chm13 == true)
        {
           //TODO: need to not have this as an option 
        }

        else if ((params.is_chm13 == false) && (params.housekeeping != "None"))
        {
       	    //TODO: fix the module processed for these
            CONVERT_GTF_TO_BED12(annotation)
            RSEQC_GENE_BODY_COVERAGE(FILTER_BAM.out.bam_filtered, housekeeping)
            RSEQC_BAM_STAT(FILTER_BAM.out.bam_filtered, mapq)
            RSEQC_READ_GC(FILTER_BAM.out.bam_filtered, mapq)
            RSEQC_JUNCTION_ANNOTATION(FILTER_BAM.out.bam_filtered, CONVERT_GTF_TO_BED12.out.bed12)
            RSEQC_JUNCTION_SATURATION(FILTER_BAM.out.bam_filtered, CONVERT_GTF_TO_BED12.out.bed12)
            RSEQC_READ_DISTRIBUTION(FILTER_BAM.out.bam_filtered, CONVERT_GTF_TO_BED12.out.bed12)        
            
            if (params.rseqc_tin == true) {

                RSEQC_TIN(FILTER_BAM.out.bam_filtered, CONVERT_GTF_TO_BED12.out.bed12)
            
            } 
        
        }
        
        
        BAMBU_PREP(FILTER_BAM.out.bam_filtered, mapq, ref, annotation, MAKE_FAI.out, track_reads)

}
