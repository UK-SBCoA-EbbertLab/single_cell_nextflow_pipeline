// Import Modules
include {BAMBU_DISCOVERY; BAMBU_QUANT} from '../modules/bambu'
include {GFFCOMPARE; GFFCOMPARE_NOVEL as GFFCOMPARE_NOVEL_GLINOS ; GFFCOMPARE_NOVEL as GFFCOMPARE_NOVEL_LEUNG ; GFFCOMPARE_NOVEL as GFFCOMPARE_NOVEL_HEBERLE; ISOLATE_NOVEL_ISOFORMS} from '../modules/gffcompare'
include {MAKE_TRANSCRIPTOME} from '../modules/make_transcriptome'
include {MULTIQC_GRCh38} from '../modules/multiqc'
include {MAKE_CONTAMINATION_REPORT_2} from '../modules/make_contamination_report.nf'
include {MERGE_QC_REPORT} from '../modules/num_reads_report.nf'

workflow NANOPORE_STEP_3 {

    take:
        ref
        fai
        annotation
        NDR
        track_reads
        bambu_rds
        multiqc_input
        multiqc_config
        contamination
        num_reads
        read_length 
        quality_thresholds
	heberle_annotation
	glinos_annotation
	leung_annotation

    main:
 
       
        MAKE_CONTAMINATION_REPORT_2(contamination.collect())
            
        MERGE_QC_REPORT(num_reads.collect(), read_length.collect(), quality_thresholds.collect())
       
        MULTIQC_GRCh38(multiqc_input.concat(MAKE_CONTAMINATION_REPORT_2.out.flatten(), MERGE_QC_REPORT.out.flatten()).collect(), multiqc_config)
        
        if (params.is_discovery == true)
        {

            BAMBU_DISCOVERY(bambu_rds.collect(), ref, annotation, fai, NDR, track_reads)
            new_annotation = BAMBU_DISCOVERY.out.gtf
	    ISOLATE_NOVEL_ISOFORMS(new_annotation, "BambuTx")
            GFFCOMPARE(new_annotation, annotation)
	    GFFCOMPARE_NOVEL_GLINOS(new_annotation, glinos_annotation, "Glinos_comparison", "Our_SC_vs_glinos_annotation")
	    GFFCOMPARE_NOVEL_LEUNG(new_annotation, leung_annotation, "Leung_comparison", "Our_SC_vs_leung_annotation")
	    GFFCOMPARE_NOVEL_HEBERLE(new_annotation, heberle_annotation, "Heberle_comparison", "Our_SC_vs_heberle_annotation")

        }

        else
        {
            
            BAMBU_QUANT(bambu_rds.collect(), ref, annotation, fai)
            new_annotation = BAMBU_QUANT.out.gtf

        }

        MAKE_TRANSCRIPTOME(ref, fai, new_annotation)
        
}
