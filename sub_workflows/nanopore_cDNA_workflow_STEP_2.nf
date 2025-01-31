// Import Modules
include {MAKE_FAI} from '../modules/make_fai'
include {MAKE_INDEX_cDNA ; MAKE_INDEX_cDNA_CONTAMINATION_CHM13} from '../modules/make_index'
include {MAKE_INDEX_cDNA as MAKE_INDEX_CONTAMINANTS} from '../modules/make_index'
include {CHM13_GTF; CHM13_GTF_ERCC} from '../modules/chm13_gff3_to_gtf'
//include {PYCHOPPER} from '../modules/pychopper'
include {PYCOQC} from '../modules/pycoqc'
include {MINIMAP2_cDNA; FILTER_BAM} from '../modules/minimap2'
include {RSEQC} from '../modules/rseqc'
include {BAMBU_PREP} from '../modules/bambu'
include {MAP_CONTAMINATION_cDNA} from '../modules/contamination'
include {MAKE_CONTAMINATION_REPORT_1 ; MAKE_CONTAMINATION_REPORT_2} from '../modules/make_contamination_report.nf'

workflow NANOPORE_cDNA_STEP_2 {

    take:
        ref
        annotation
        housekeeping
        ont_reads_txt
        ont_reads_fq
        ercc
        cdna_kit
        track_reads
        mapq
        contamination_ref
	mapped_reads_thresh

    main:
        MAKE_FAI(ref)
        MAKE_INDEX_cDNA(ref)
  //      PYCHOPPER(ont_reads_fq, ont_reads_txt, cdna_kit)
        MINIMAP2_cDNA(ont_reads_fq,  MAKE_INDEX_cDNA.out, ont_reads_txt)
        FILTER_BAM(MINIMAP2_cDNA.out.id, mapq, MINIMAP2_cDNA.out.bam, MINIMAP2_cDNA.out.bai, mapped_reads_thresh)
        BAMBU_PREP(FILTER_BAM.out.id, mapq, FILTER_BAM.out.bam, FILTER_BAM.out.bai, ref, annotation, MAKE_FAI.out, track_reads)
        
        if (params.contamination_ref != "None") {

            MAKE_INDEX_CONTAMINANTS(contamination_ref)

            MAKE_INDEX_cDNA_CONTAMINATION_CHM13()

            BAM_AND_INDEX = MINIMAP2_cDNA.out.bam.combine(MAKE_INDEX_CONTAMINANTS.out).combine(MAKE_INDEX_cDNA_CONTAMINATION_CHM13.out)
            
            MAP_CONTAMINATION_cDNA(MINIMAP2_cDNA.out.id, BAM_AND_INDEX, MINIMAP2_cDNA.out.bai, MINIMAP2_cDNA.out.num_reads)

            MAKE_CONTAMINATION_REPORT_1(MAP_CONTAMINATION_cDNA.out.id, MAP_CONTAMINATION_cDNA.out.num_reads, MAP_CONTAMINATION_cDNA.out.num_unmapped_reads_before_chm13, 
            MAP_CONTAMINATION_cDNA.out.num_unmapped_reads_after_chm13, MAP_CONTAMINATION_cDNA.out.num_contaminant_reads)

            MAKE_CONTAMINATION_REPORT_2(MAKE_CONTAMINATION_REPORT_1.out.collect())
        }


        if (params.ont_reads_txt != "None") {
            PYCOQC(MINIMAP2_cDNA.out.id, MINIMAP2_cDNA.out.fastq, MINIMAP2_cDNA.out.txt, MINIMAP2_cDNA.out.bam, MINIMAP2_cDNA.out.bai)
        }

        if (params.is_chm13 == true)
        {
            if (params.ercc == "None") 
            { 
                CHM13_GTF(annotation)
                annotation = CHM13_GTF.out.collect()
            }
            
            else 
            {
                CHM13_GTF_ERCC(annotation, ercc)
                annotation = CHM13_GTF_ERCC.out.collect()
            }
        }
        

}
