// Make this pipeline a nextflow 2 implementation
nextflow.enable.dsl=2

// Define valid step numbers
def validSteps = [0, 1, 2, 3, 4, "c", "C"]

// Check if params.step is set and valid
//if (!params.step || !validSteps.contains(step)) {
  //  exit 1, "Invalid or missing 'params.step'. Please set it to one of the following: ${validSteps.join(', ')}."
//}

if (params.step == 0) {

log.info """
            OXFORD NANOPORE PIPSEQ SINGLE-CELL cDNA SEQUENCING PIPELINE - STEP 0: SINGLE-CELL DEMULTIPLEXING - Bernardo Aguzzoli Heberle/Madeline L. Page - EBBERT LAB - University of Kentucky
 ==============================================================================================================================================================================================================
 step: 0 = pre processing, 2 = mapping, 3 = quantification			: ${params.step}
 
 sample id table								: ${params.sample_id_table}
 nanopore fastq file directory							: ${params.ont_reads_fq_dir}

 Threshold of reads per barcode							: ${params.barcode_thresh}
 Number of threads to demultiplex with 						: ${params.n_threads}
 
 nanopore library prep kit							: ${params.cdna_kit}
 basecall quality score threshold for basecalling				: ${params.qscore_thresh}
 writeable dir for mathplotlib							: ${params.mpldir}

 output directory								: ${params.out_dir}
 ==============================================================================================================================================================================================================
"""

} else if (params.step == 2 && params.bam == "None") {

log.info """
            OXFORD NANOPORE PIPSEQ SINGLE-CELL cDNA SEQUENCING PIPELINE - STEP 2: QC, Alignment, and Bambu pre-processing - Bernardo Aguzzoli Heberle/Madeline L. Page - EBBERT LAB - University of Kentucky
 ============================================================================================================================================================================================================================
 step: 0 = pre processing, 2 = mapping, 3 = quantification			: ${params.step}

 nanopore fastq files								: ${params.ont_reads_fq}
 nanopore sequencing summary files						: ${params.ont_reads_txt}
 submission output file prefix							: ${params.prefix}

 reference genome								: ${params.ref}
 reference annotation								: ${params.annotation}
 track read_ids with bambu?							: ${params.track_reads}
 nanopore library prep kit							: ${params.cdna_kit}

 minimum threshold for mapped reads						: ${params.mapped_reads_thresh}
 MAPQ value for filtering bam file						: ${params.mapq}

 output directory								: ${params.out_dir}
 ============================================================================================================================================================================================================================
"""

} else if (params.step == 3) {

log.info """
            OXFORD NANOPORE PIPSEQ SINGLE-CELL cDNA SEQUENCING PIPELINE - STEP 3: Transcript Quantification and/or Discovery -  Bernardo Aguzzoli Heberle/Madeline L. Page/Brendan White - EBBERT LAB - University of Kentucky
 ==============================================================================================================================================================================================================
 step: 0 = pre processing, 2 = mapping, 3 = quantification			: ${params.step}

 reference genome								: ${params.ref}
 reference genome index								: ${params.fai}
 reference annotation								: ${params.annotation}
 reference genome is CHM13							: ${params.is_chm13}

 multiqc configuration file							: ${params.multiqc_config}
 multiqc input path								: ${params.multiqc_input} 
 intermediate qc file paths							: ${params.intermediate_qc}

 transcript discovery status							: ${params.is_discovery}
 track read_ids with bambu?							: ${params.track_reads}
 path to pre-processed bambu RDS files						: ${params.bambu_rds}

 # of barcodes (cells) to process at a time					: ${params.n_cells_process}

 output directory								: ${params.out_dir}
 =============================================================================================================================================================================================================
"""

}

// Import Workflows
include {NANOPORE_STEP_0} from '../sub_workflows/nanopore_workflow_STEP_0'
include {NANOPORE_cDNA_STEP_2} from '../sub_workflows/nanopore_cDNA_workflow_STEP_2'
include {NANOPORE_STEP_3} from '../sub_workflows/nanopore_workflow_STEP_3'



// ===== Define initial files and channels ========================================================================================
def prefix = (params.prefix == "None") ? "" : "${params.prefix}_"

// ----- Step 0 -------------------------------------------------------------------------------------------------------------------

ont_reads_fq_dir = params.ont_reads_fq_dir

// ----- Step 2 (Normal and BAM) --------------------------------------------------------------------------------------------------

println prefix
cdna_kit = Channel.value(params.cdna_kit)
mapped_reads_thresh = Channel.value(params.mapped_reads_thresh)
mapq = Channel.value(params.mapq)

if (params.ont_reads_fq != "None") {
    ont_reads_fq = Channel.fromPath(params.ont_reads_fq)
	.toSortedList( { a, b -> a[0] <=> b[0] } )
	.flatten()
	.collate(250)
	.map { batch ->
	    def base_names = batch.collect { "${prefix}" + it.baseName }
	    tuple(base_names, batch)
	}
}


// ----- Step 3 -------------------------------------------------------------------------------------------------------------------

fai = file(params.fai)
NDR = Channel.value(params.NDR)
track_reads = Channel.value(params.track_reads)
bambu_rds = Channel.fromPath(params.bambu_rds)

// ----- Multiple steps ----------------------------------------------------------------------------------------------------------

sample_id_table = params.sample_id_table
ref = file(params.ref)
annotation = file(params.annotation)
quality_score = Channel.value(params.qscore_thresh)


// ===== Begin Workflow ================================================================================================================


workflow {
    if (params.step == 0) {
	NANOPORE_STEP_0(ont_reads_fq_dir, sample_id_table, cdna_kit, quality_score)
    } 
    
    else if ((params.step == 2) && (params.bam == "None") && (params.path == "None")){

        NANOPORE_cDNA_STEP_2(ref, annotation, ont_reads_fq, track_reads, mapq, mapped_reads_thresh)    }

    else if(params.step == 3){
        
        NANOPORE_STEP_3(ref, fai, annotation, track_reads, bambu_rds, params.n_cells_process)
    }

}
