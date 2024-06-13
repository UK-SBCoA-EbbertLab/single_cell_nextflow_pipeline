include {SEP_DIR_BY_SAMP ; MERGE_FASTQ} from '../modules/merge.nf'
include {PIPSEEKER} from '../modules/get_barcodes.nf'
include {CONVERT_NANOPORE ; CAT_CONVERTED_FASTQS} from '../modules/get_barcodes.nf'
include {CREATE_FASTA} from '../modules/create_barcode_fasta.nf'
include {BARCODE_CONFIG} from '../modules/create_barcode_config.nf'
include {FILTER_PIP} from '../modules/filter_pipseq.nf'

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
		use_split

        main:
		// IF WE WANT TO DO THE CONVERSION STEP AND THEN CONCAT THE FILES TOGETHER. I think this will speed up the conversion
		if (use_split) {
			SEP_DIR_BY_SAMP(sample_id_table)
			SEP_DIR_BY_SAMP.out.dir_by_samp.view()
			// create a channel with directories for each sample
			ch_samples = SEP_DIR_BY_SAMP.out.dir_by_samp.flatten()
				.flatMap { sampleFile -> 
					def sampleName = sampleFile.baseName.replace('_samp_to_dir', '')
//					println "Processing sample file: ${sampleFile}"
					sampleFile.text.readLines().collect { line -> 
						def parts = line.split('\t')
						def dirPath = ont_reads_fq_dir + parts[0]
//						println "Sample: ${sampleName}, Directory: ${dirPath}"
						[sampleName, file(dirPath)]
					}
				}

			// get the files within each directory and keep track of the sample they belong to
			ch_files = ch_samples
				.flatMap { sampName, dir ->
//					println "Processing directory: ${dir} for sample: ${sampName}"
					dir.listFiles().findAll { file -> 
						file.name.endsWith('.fastq.gz') && !isGzipFileEmpty(file.toFile())
					}
					.collect { file -> 
						[sampName, file]
					}
				}
	
//			println('printing files')
			ch_files.view()

			CONVERT_NANOPORE(ch_files)

			CONVERT_NANOPORE
				.out
				.map { sample -> 
					def (sampName, files) = sample
					def pattern = ~/\w+_(R[12])\.fastq\.gz/

					// Extract patterns from filenames
					def extractedFiles = files.collect { file ->
						def fileName = file.toString()
						def matcher = pattern.matcher(fileName)
						if (matcher.find()) {
							def extractedPart = matcher.group(1)
							[sampName, extractedPart, file]
						} else {
							println "THIS DIDN'T WORK"
							[sampName, null, file] // Or handle unmatched files differently
						}
					}
				}
				.flatMap {it}
				.groupTuple(by: [0,1])
				.set { grouped_samples }
			grouped_samples.view()

			CAT_CONVERTED_FASTQS(grouped_samples)

			
			CAT_CONVERTED_FASTQS
			.out
			.groupTuple()
			.view()
			
			PIPSEEKER(
				CAT_CONVERTED_FASTQS
				.out
				.groupTuple()
			)	
		} 
		else {
			ont_reads_fq_dir.view()

			//TODO: this needs to be tested that it works the way we want it to!!
			ch_files = ont_reads_fq_dir.map { file -> 
				def sampleName = file.getBaseName().replace('.fastq', '')
				return [sampleName, file] 
			}

			// convert the ONT long-reads into short reads ( I think we just make sure we have the barcode )
	                CONVERT_NANOPORE(ch_files)
	                PIPSEEKER(CONVERT_NANOPORE.out)
		}

		
               // CREATE_FASTA(PIPSEEKER.out.barcode_list)

               // BARCODE_CONFIG(PIPSEEKER.out.barcode_list)
		
		FILTER_PIP(PIPSEEKER.out.barcoded_fastq_R1, PIPSEEKER.out.barcoded_fastq_R2, PIPSEEKER.out.sampName)
}
