// Make this pipeline a nextflow 2 implementation
nextflow.enable.dsl=2

// Define valid step numbers
def validSteps = [0, 1, 2, 3, 4, "c", "C"]

// Check if params.step is set and valid
//if (!params.step || !validSteps.contains(step)) {
  //  exit 1, "Invalid or missing 'params.step'. Please set it to one of the following: ${validSteps.join(', ')}."
//}

if (params.step == "c" || params.step == "C") {

log.info """
            OXFORD NANOPORE PIPSEQ SINGLE-CELL cDNA SEQUENCING PIPELINE - STEP C: MERGE FASTQs - Madeline L. Page - EBBERT LAB - University of Kentucky
 ==============================================================================================================================================================================================================
 step: c = merge fastqs, 0 = pre processing, 1 = basecalling, 
       2 = mapping, 3 = quantification, 4 = merge output			: ${params.step}
 
 sample id table								: ${params.sample_id_table}
 nanopore fastqs to merge file directory					: ${params.ont_fq_to_merge}

 output directory								: ${params.out_dir}
 ==============================================================================================================================================================================================================
""" 

} else if (params.step == 0) {

log.info """
            OXFORD NANOPORE PIPSEQ SINGLE-CELL cDNA SEQUENCING PIPELINE - STEP 0: SINGLE-CELL DEMULTIPLEXING - Bernardo Aguzzoli Heberle/Madeline L. Page - EBBERT LAB - University of Kentucky
 ==============================================================================================================================================================================================================
 step: c = merge fastqs, 0 = pre processing, 1 = basecalling, 
       2 = mapping, 3 = quantification, 4 = merge output			: ${params.step}
 
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

} else if (params.step == 1) {

log.info """
           OXFORD NANOPORE PIPSEQ SINGLE-CELL cDNA SEQUENCING PIPELINE - STEP 1: BASECALLING - Bernardo Aguzzoli Heberle - EBBERT LAB - University of Kentucky
 ============================================================================================================================================================================
 step: c = merge fastqs, 0 = pre processing, 1 = basecalling, 
       2 = mapping, 3 = quantification, 4 = merge output			: ${params.step}
 
 path containing samples and files to be basecalled (basecall only)             : ${params.basecall_path}
 basecall speed (basecall only)                                                 : ${params.basecall_speed}
 basecall modifications  (basecall only)                                        : ${params.basecall_mods}
 basecall config (If "None" the basecaller will automatically pick one)         : ${params.basecall_config}
 basecall read trimming option                                                  : ${params.basecall_trim}
 basecall quality score threshold for basecalling                               : ${params.qscore_thresh}
 basecall demultiplexing                                                        : ${params.basecall_demux}
 basecall compute node type							: ${params.basecall_compute}
 trim barcodes during demultiplexing                                            : ${params.trim_barcode}
 submission output file prefix							: ${params.prefix}
 
 output directory								: ${params.out_dir}
 =============================================================================================================================================================================
"""

} else if (params.step == 2 && params.bam == "None") {

log.info """
            OXFORD NANOPORE PIPSEQ SINGLE-CELL cDNA SEQUENCING PIPELINE - STEP 2: QC, Alignment, and Bambu pre-processing - Bernardo Aguzzoli Heberle/Madeline L. Page - EBBERT LAB - University of Kentucky
 ============================================================================================================================================================================================================================
 step: c = merge fastqs, 0 = pre processing, 1 = basecalling, 
       2 = mapping, 3 = quantification, 4 = merge output			: ${params.step}

 RAW unzipped nanopore fastq.gz file path (Don't use for single-cell)		: ${params.path} 

 nanopore fastq files								: ${params.ont_reads_fq}
 nanopore sequencing summary files						: ${params.ont_reads_txt}
 submission output file prefix							: ${params.prefix}

 reference genome								: ${params.ref}
 reference annotation								: ${params.annotation}
 housekeeping genes 3' bias assessment						: ${params.housekeeping}
 track read_ids with bambu?							: ${params.track_reads}
 nanopore library prep kit							: ${params.cdna_kit}

 reference genome is CHM13							: ${params.is_chm13}
 path to ERCC annotations (CHM13 only)						: ${params.ercc}

 basecall quality score threshold for basecalling				: ${params.qscore_thresh}
 minimum threshold for mapped reads						: ${params.mapped_reads_thresh}
 MAPQ value for filtering bam file						: ${params.mapq}

 Reference for contamination analysis						: ${params.contamination_ref}
 Preform RSEQC TIN analysis (time consuming)					: ${params.rseqc_tin}

 output directory								: ${params.out_dir}
 ============================================================================================================================================================================================================================
"""

} else if (params.step == 2 && params.bam != "None") {

log.info """
            OXFORD NANOPORE PIPSEQ SINGLE-CELL cDNA SEQUENCING PIPELINE - STEP 2 - Filtering BAM  - Bernardo Aguzzoli Heberle/Madeline L. Page - EBBERT LAB - University of Kentucky
 ===================================================================================================================================================================================================
 step: c = merge fastqs, 0 = pre processing, 1 = basecalling, 
       2 = mapping, 3 = quantification, 4 = merge output			: ${params.step}

 bam files									: ${params.bam}
 bai files									: ${params.bai}
 submission output file prefix							: ${params.prefix}

 reference genome								: ${params.ref}
 reference annotation								: ${params.annotation}

 reference genome is CHM13							: ${params.is_chm13}
 path to ERCC annotations (CHM13 only)						: ${params.ercc}

 minimum threshold for mapped reads						: ${params.mapped_reads_thresh}
 MAPQ value for filtering bam file						: ${params.mapq}

 output directory								: ${params.out_dir}
 ===================================================================================================================================================================================================
"""

} else if (params.step == 3) {

log.info """
            OXFORD NANOPORE PIPSEQ SINGLE-CELL cDNA SEQUENCING PIPELINE - STEP 3: Transcript Quantification and/or Discovery -  Bernardo Aguzzoli Heberle/Madeline L. Page/Brendan White - EBBERT LAB - University of Kentucky
 ==============================================================================================================================================================================================================
 step: c = merge fastqs, 0 = pre processing, 1 = basecalling, 
       2 = mapping, 3 = quantification, 4 = merge output			: ${params.step}

 reference genome								: ${params.ref}
 reference genome index								: ${params.fai}
 reference annotation								: ${params.annotation}
 reference genome is CHM13							: ${params.is_chm13}

 multiqc configuration file							: ${params.multiqc_config}
 multiqc input path								: ${params.multiqc_input} 
 intermediate qc file paths							: ${params.intermediate_qc}

 transcript discovery status							: ${params.is_discovery}
 NDR Value for Bambu (Novel Discovery Rate)					: ${params.NDR}
 track read_ids with bambu?							: ${params.track_reads}
 path to pre-processed bambu RDS files						: ${params.bambu_rds}

 # of barcodes (cells) to process at a time					: ${params.n_cells_process}

 output directory								: ${params.out_dir}
 =============================================================================================================================================================================================================
"""

} else if (params.step == 4) {
log.info """
            OXFORD NANOPORE PIPSEQ SINGLE-CELL cDNA SEQUENCING PIPELINE - STEP 4: Merge Bambu Txt outputs - Madeline L. Page/Brendan White  - EBBERT LAB - University of Kentucky
 =============================================================================================================================================================================================================
 step: c = merge fastqs, 0 = pre processing, 1 = basecalling, 
       2 = mapping, 3 = quantification, 4 = merge output			: ${params.step}
 
 directory to bambu txt outputs							: ${params.bambu_outputs}
 
 output directory								: ${params.out_dir}
 =============================================================================================================================================================================================================
"""

}

// Import Workflows
include {NANOPORE_UNZIP_AND_CONCATENATE} from '../sub_workflows/nanopore_unzip_and_concatenate.nf'
include {MERGE_FLOWCELL} from '../sub_workflows/concat_across_flowcell'
include {NANOPORE_STEP_0} from '../sub_workflows/nanopore_workflow_STEP_0'
include {NANOPORE_STEP_1} from '../sub_workflows/nanopore_workflow_STEP_1'
include {NANOPORE_cDNA_STEP_2} from '../sub_workflows/nanopore_cDNA_workflow_STEP_2'
include {NANOPORE_STEP_2_BAM} from '../sub_workflows/nanopore_workflow_STEP_2_BAM'
include {NANOPORE_STEP_3} from '../sub_workflows/nanopore_workflow_STEP_3'
include {NANOPORE_STEP_4} from '../sub_workflows/nanopore_workflow_STEP_4'



// ===== Define initial files and channels ========================================================================================
def prefix = (params.prefix == "None") ? "" : "${params.prefix}_"

// ----- Step c -------------------------------------------------------------------------------------------------------------------

ont_fq_to_merge = Channel.value(params.ont_fq_to_merge)

// ----- Step 0 -------------------------------------------------------------------------------------------------------------------

ont_reads_fq_dir = params.ont_reads_fq_dir

// ----- Step 1 -------------------------------------------------------------------------------------------------------------------

basecall_speed = Channel.value(params.basecall_speed)
basecall_mods = Channel.value(params.basecall_mods)
basecall_config = Channel.value(params.basecall_config)
basecall_trim = Channel.value(params.basecall_trim)
basecall_compute = Channel.value(params.basecall_compute)
trim_barcode = Channel.value(params.trim_barcode)

if (params.prefix == "None") {

    fast5_path = Channel.fromPath("${params.basecall_path}/**.fast5").map{file -> tuple(file.parent.toString().split("/")[-2] + "_" + file.simpleName.split('_')[0] + "_" + file.simpleName.split('_')[-3..-2].join("_"), file) }.groupTuple()
    pod5_path = Channel.fromPath("${params.basecall_path}/**.pod5").map{file -> tuple(file.parent.toString().split("/")[-2] + "_" + file.simpleName.split('_')[0] + "_" + file.simpleName.split('_')[-3..-2].join("_"), file) }.groupTuple()

} else {

    fast5_path = Channel.fromPath("${params.basecall_path}/**.fast5").map{file -> tuple("${prefix}" + file.parent.toString().split("/")[-2] + "_" + file.simpleName.split('_')[0] + "_" + file.simpleName.split('_')[2..-2].join("_"), file) }.groupTuple()
    pod5_path = Channel.fromPath("${params.basecall_path}/**.pod5").map{file -> tuple("${prefix}" +  file.parent.toString().split("/")[-2] + "_" + file.simpleName.split('_')[0] + "_" + file.simpleName.split('_')[2..-2].join("_"), file) }.groupTuple()

}   

// ----- Step 2 (Normal and BAM) --------------------------------------------------------------------------------------------------

println prefix
cdna_kit = Channel.value(params.cdna_kit)
housekeeping = file(params.housekeeping)
contamination_ref = Channel.fromPath(params.contamination_ref)
mapped_reads_thresh = Channel.value(params.mapped_reads_thresh)
mapq = Channel.value(params.mapq)

fastq_path = Channel.fromPath("${params.path}/**.fastq.gz").map{file -> tuple("${prefix}sample_" + file.parent.toString().split("/")[-3] + "_" + file.simpleName.split('_')[0] + "_" + file.simpleName.split('_')[-3..-2].join("_"), file)}.groupTuple()
txt_path = Channel.fromPath("${params.path}/**uencing_summary*.txt").map{file -> tuple("${prefix}sample_" + file.parent.toString().split("/")[-2] + "_" + file.simpleName.split('_')[-3..-1].join("_"), file)}.groupTuple()

if (params.ont_reads_fq != "None") {
    ont_reads_fq = Channel.fromPath(params.ont_reads_fq)
	.toSortedList( { a, b -> a[0] <=> b[0] } )
	.flatten()
	.collate(50)
	.map { batch ->
	    def base_names = batch.collect { "${prefix}" + it.baseName }
	    tuple(base_names, batch)
	}
	.view()
}

if (params.ont_reads_txt != "None") {
    ont_reads_txt = Channel.fromPath(file(params.ont_reads_txt))
	.toSortedList( { a, b -> a.baseName <=> b.baseName } )
	.flatten()
	.colate(50)
} else {
    ont_reads_txt = Channel.value(params.ont_reads_txt)
}

if ((params.bam != "None") && (params.bai != "None")) {
    bam = Channel.fromPath(params.bam)
	.toSortedList( { a, b -> a[0] <=> b[0] } )
	.flatten()
	.collate(50)
	.map { batch ->
	    def base_names = batch.collect { "${prefix}" + it.baseName }
	    tuple(base_names, batch)
	}
    
    bai = Channel.fromPath(params.bai)
	.toSortedList( { a, b -> a.baseName <=> b.baseName } )
	.flatten()
	.collate(50)
	.map { batch ->
	    batch.collect { file ->
		file.parent.resolve("${prefix}${file.name}")
	    }
	}
}
	

if (params.ercc != "None") {
    ercc = Channel.fromPath(params.ercc)
    }
else {
    ercc = params.ercc
    }


// ----- Step 3 -------------------------------------------------------------------------------------------------------------------

fai = file(params.fai)
multiqc_config = Channel.fromPath(params.multiqc_config)
multiqc_input = Channel.fromPath(params.multiqc_input, type: "file")
NDR = Channel.value(params.NDR)
track_reads = Channel.value(params.track_reads)
bambu_rds = Channel.fromPath(params.bambu_rds)
contamination = Channel.fromPath("${params.intermediate_qc}/contamination/*")
num_reads = Channel.fromPath("${params.intermediate_qc}/number_of_reads/*")
read_length = Channel.fromPath("${params.intermediate_qc}/read_length/*")
quality_thresholds = Channel.fromPath("${params.intermediate_qc}/quality_score_thresholds/*")

// ----- Step 4 -------------------------------------------------------------------------------------------------------------------

bambu_outputs = params.bambu_outputs

// ----- Multiple steps ----------------------------------------------------------------------------------------------------------

sample_id_table = params.sample_id_table
ref = file(params.ref)
annotation = file(params.annotation)
quality_score = Channel.value(params.qscore_thresh)


// ===== Begin Workflow ================================================================================================================


workflow {
    if ((params.step == 'c') || (params.step == 'C')) {	
	MERGE_FLOWCELL(sample_id_table, ont_fq_to_merge)
    }
 
    else if (params.step == 0) {
	NANOPORE_STEP_0(ont_reads_fq_dir, sample_id_table, cdna_kit, quality_score)
    } 
    
    else if (params.step == 1) {
        NANOPORE_STEP_1(pod5_path, fast5_path, basecall_speed, basecall_mods, basecall_config, basecall_trim, quality_score, trim_barcode)
    }

    else if ((params.step == 2) && (params.path != "None")) {
        
        NANOPORE_UNZIP_AND_CONCATENATE(fastq_path, txt_path)

        NANOPORE_cDNA_STEP_2(ref, annotation, housekeeping, NANOPORE_UNZIP_AND_CONCATENATE.out[1], NANOPORE_UNZIP_AND_CONCATENATE.out[0], ercc, cdna_kit, track_reads, mapq, contamination_ref, quality_score, mapped_reads_thresh)
        
    }

    else if ((params.step == 2) && (params.bam == "None") && (params.path == "None")){

        NANOPORE_cDNA_STEP_2(ref, annotation, housekeeping, ont_reads_txt, ont_reads_fq, ercc, cdna_kit, track_reads, mapq, contamination_ref, quality_score, mapped_reads_thresh)
    }


    else if ((params.step == 2) && (params.bam != "None") && (params.path == "None")) {
        
        NANOPORE_STEP_2_BAM(ref, annotation, bam, bai, ercc, track_reads, mapq)

    }

    else if(params.step == 3){
        
        NANOPORE_STEP_3(ref, fai, annotation, NDR, track_reads, bambu_rds, multiqc_input, multiqc_config, contamination, num_reads, read_length, quality_thresholds)
    }

    else if(params.step == 4){
	NANOPORE_STEP_4(ont_reads_fq_dir, demultiplex_name)
    }

}
