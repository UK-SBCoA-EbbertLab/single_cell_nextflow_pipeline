include { GET_ALL_FASTQ_GZ } from '../modules/merge.nf'
include { UNZIP_AND_CONCATENATE_WITH_FLOWCELL ; FIX_SEQUENCING_SUMMARY_NAME_WITH_FLOWCELL } from '../modules/unzip_and_concatenate.sh'
include {PYCHOPPER_SC} from '../modules/pychopper'
include {CONVERT_NANOPORE ; CONVERT_NANOPORE_RESCUE ; CAT_BARCODE_WHITELIST ; CAT_NANOPORE_CONVERT_STATS ; PIPSEEKER ; COMBINE_STATS_BY_SAMP_AND_FLOWCELL; COUNT_AND_FILTER_BARCODES } from '../modules/get_barcodes.nf'
include {DEMULTIPLEX ; COMBINE_DEMULTIPLEX} from '../modules/demultiplex_pipseq.nf'

import java.util.zip.GZIPInputStream
import java.nio.file.Files

def isGzipFileEmpty(file) {
	def filePath = file.toPath()
	if (Files.size(filePath) == 0) {
		return true
	}
	GZIPInputStream gis = null
	try {
		gis = new GZIPInputStream(Files.newInputStream(filePath))
		return gis.read() == -1
	} catch (IOException e) {
		println "Error reading file: ${filePath}"
		return true
	} finally {
		if (gis != null) {
		gis.close()
		}
	}
}


workflow NANOPORE_STEP_0 {
        take:
		ont_reads_fq_dir
		sample_id_table
		cdna_kit
		quality_score

        main:

		GET_ALL_FASTQ_GZ(sample_id_table, ont_reads_fq_dir)

		seq_sum_files = GET_ALL_FASTQ_GZ.out.seq_sum_files
			.flatten()
			.map { filePath ->
				def fileName = filePath.getName()
				def match = fileName =~ /(.+)_(.+)_seq_summary_file.txt/
				if (!match) {
					throw new IllegalArgumentException("Filename ${fileName} does not match expected pattern")
				}
				
				def sampID = match[0][1]  // Extract sample ID
				def flowcellID = match[0][2]  // Extract flowcell ID
				
				// Emit a tuple containing sampID, flowcellID, and filePath
				return [sampID, flowcellID, filePath]
			}
					
	
		PYCHOPPER_SC(
			GET_ALL_FASTQ_GZ.out.split_files
			.flatten()
			.map { filePath -> 
				def fileName = filePath.getName()
				def match = fileName =~ /(.+)_(.+)_samp_to_dir_chunk_(\d+)/
				if (!match) {
					throw new IllegalArgumentException("Filename ${fileName} does not match expected pattern")
				}
        
				def sampID = match[0][1]  // Extract sample ID
				def flowcellID = match[0][2]  // Extract flowcell ID
				def fileNumber = match[0][3]  // Extract file number
        
				// Emit a tuple containing sampID, flowcellID, fileNumber, and filePath
				return [sampID, flowcellID, fileNumber, filePath]
			}, cdna_kit, quality_score, params.mpldir)

		CONVERT_NANOPORE(PYCHOPPER_SC.out.pychop_fqs)

		CAT_BARCODE_WHITELIST(CONVERT_NANOPORE.out
					.barcodes
					.groupTuple(by: 0))

		rescue_ch = CONVERT_NANOPORE.out.to_rescue.combine(
					CAT_BARCODE_WHITELIST.out, by: 0)

		CONVERT_NANOPORE_RESCUE(rescue_ch)

		stats_ch = CONVERT_NANOPORE.out.stats
					.concat(CONVERT_NANOPORE_RESCUE.out.stats)
					.groupTuple(by: [0,1])

		CAT_NANOPORE_CONVERT_STATS(stats_ch)

		PIPSEEKER(
			CONVERT_NANOPORE.out.good
				.concat(CONVERT_NANOPORE_RESCUE.out.good)
		)	

		COMBINE_STATS_BY_SAMP_AND_FLOWCELL(PYCHOPPER_SC.out.num_pass_reads.groupTuple(by: [0,1]).combine(CAT_NANOPORE_CONVERT_STATS.out.groupTuple(by: [0,1]).combine(PIPSEEKER.out.pip_read_stats.groupTuple(by: [0,1]), by: [0,1]), by: [0,1]))

		UNZIP_AND_CONCATENATE_WITH_FLOWCELL(PIPSEEKER.out.concat_for_bulk)
		FIX_SEQUENCING_SUMMARY_NAME_WITH_FLOWCELL(seq_sum_files)

		COUNT_AND_FILTER_BARCODES(PIPSEEKER.out.barcode_counts.groupTuple())
		
		PIPSEEKER.out.to_demultiplex.groupTuple().combine(COUNT_AND_FILTER_BARCODES.out.barcodes_to_keep, by:0).view()

		DEMULTIPLEX(PIPSEEKER.out.to_demultiplex.groupTuple().combine(COUNT_AND_FILTER_BARCODES.out.barcodes_to_keep, by: 0))

}
