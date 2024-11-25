include {SEP_DIR_BY_SAMP ; GET_ALL_FASTQ_GZ } from '../modules/merge.nf'
include {CONVERT_NANOPORE ; CONVERT_NANOPORE_RESCUE ; CAT_BARCODE_WHITELIST ; CAT_STATS ; PIPSEEKER ; COUNT_AND_FILTER_BARCODES } from '../modules/get_barcodes.nf'
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

        main:

		GET_ALL_FASTQ_GZ(sample_id_table, ont_reads_fq_dir)
//		SEP_DIR_BY_SAMP(GET_ALL_FASTQ_GZ.out.all_files)

//		// create a channel with directories for each sample
//		ch_samples = SEP_DIR_BY_SAMP.out.dir_by_samp.flatten()
//			.flatMap { sampleFile -> 
//				def sampleName = sampleFile.baseName.replace('_samp_to_dir', '')
////				println "Processing sample file: ${sampleFile}"
//				sampleFile.text.readLines().collect { line -> 
//					def parts = line.split('\t')
//					def dirPath = ont_reads_fq_dir + parts[0]
////					println "Sample: ${sampleName}, Directory: ${dirPath}"
//					[sampleName, file(dirPath)]
//				}
//			}
//
//		// get the files within each directory and keep track of the sample they belong to
//		ch_files = ch_samples
//			.flatMap { sampName, dir ->
//				println "Processing directory: ${dir} for sample: ${sampName}"
//				dir.listFiles().findAll { file -> 
//					file.name.endsWith('.fastq.gz') && !isGzipFileEmpty(file.toFile())
//				}
//				.collect { file -> 
//					def fileName = file.name
//					[sampName, file]  // Return the tuple with the sample name, file
//				}
//			}
//			.groupTuple()
//			.flatMap { sampName, items -> {
//				def counter = 0
//				items.collate(500).collect { group ->
//					counter += 1
//					def files = group.collect { it }
//					[sampName, counter, files]
//					}
//				}
//			}

	
		CONVERT_NANOPORE(
			GET_ALL_FASTQ_GZ.out.split_files
			.flatten()
			.map { filePath -> 
				def fileName = filePath.getName()
				def match = fileName =~ /(.+)_samp_to_dir_chunk_(\d+)/
				if (!match) {
					throw new IllegalArgumentException("Filename ${fileName} does not match expected pattern")
				}
        
				def sampID = match[0][1]  // Extract sample ID
				def fileNumber = match[0][2]  // Extract file number
        
				// Emit a tuple containing sampID, fileNumber, and filePath
				return [sampID, fileNumber, filePath]
			})
		
		CAT_BARCODE_WHITELIST(CONVERT_NANOPORE.out
					.barcodes
					.groupTuple())

		rescue_ch = CONVERT_NANOPORE.out.to_rescue.combine(
					CAT_BARCODE_WHITELIST.out, by: 0)

		CONVERT_NANOPORE_RESCUE(rescue_ch)

		stats_ch = CONVERT_NANOPORE.out.bad_stats
					.concat(CONVERT_NANOPORE_RESCUE.out.stats)
					.groupTuple()

		CAT_STATS(stats_ch)

		PIPSEEKER(
			CONVERT_NANOPORE.out.good
				.concat(CONVERT_NANOPORE_RESCUE.out.good)
		)	


		COUNT_AND_FILTER_BARCODES(PIPSEEKER.out.barcode_counts.groupTuple())
		
		PIPSEEKER.out.to_demultiplex.groupTuple().combine(COUNT_AND_FILTER_BARCODES.out.barcodes_to_keep, by:0).view()

		DEMULTIPLEX(PIPSEEKER.out.to_demultiplex.groupTuple().combine(COUNT_AND_FILTER_BARCODES.out.barcodes_to_keep, by: 0))
		//DEMULTIPLEX(PIPSEEKER.out.to_demultiplex.combine(COUNT_AND_FILTER_BARCODES.out.barcodes_to_keep, by: 0))

//		DEMULTIPLEX.out.demult_fastq
//			.transpose()
//			.map { sample -> 
//				def (sampName, file) = sample
//				def pattern = ~/\w+_(\w+)\.fastq\.gz$/
//				def fileName = file.toString()
//                                def matcher = pattern.matcher(fileName)
//                                if (matcher.find()) {
//                                	def extractedPart = matcher.group(1)
//	                                return [sampName, extractedPart, file]
//				}
//			}	
//			.groupTuple(by: [0,1])
//			// group barcodes into groups
//			.collate(500).collect { group ->
//				group.groupBy { it[0] }
//				// collapse down all the barcodes into a list and all the files into a list
//				.collect { sampName , values ->
//					def barcodes = values.collect { it[1] }
//					def files = values.collectMany { it[2] }
//					return [sampName, barcodes, files]
//				} 
//				
//			}
//			.flatMap()					
//			.set { sorted_demultiplexed_files }
//
//			//sorted_demultiplexed_files.view()
//
//		COMBINE_DEMULTIPLEX(sorted_demultiplexed_files)
}
