import pandas as pd
import csv

heberle_extended_annotation = pd.read_csv("Heberle_extended_annotations.gtf", header=None, delimiter="\t", low_memory=False, comment="#", names=["chr", "source", "type", "start", "end", "dot_1", "strand", "dot_2", "other"])
heberle_novel_high_confidence = pd.read_csv("Heberle_high_confidence_novel_bambu.gtf", header=None, delimiter="\t", low_memory=False, comment="#", names=["chr", "source", "type", "start", "end", "dot_1", "strand", "dot_2", "other"])

# remove all bambu isoforms from Heberle_extended_annotation
heberle_extended_annotation = heberle_extended_annotation.loc[~heberle_extended_annotation["other"].str.contains("transcript_id \"BambuTx")].copy()
heberle_annotation = pd.concat([heberle_extended_annotation, heberle_novel_high_confidence])
heberle_annotation = heberle_annotation.sort_values(by=["chr", "start", "end"])


glinos_annotation = pd.read_csv("flair_filter_transcripts.gtf", header=None, delimiter="\t", low_memory=False, comment="#", names=["chr", "source", "type", "start", "end", "dot_1", "strand", "dot_2", "other"])
glinos_annotation["chr"] = glinos_annotation["chr"].str.replace("chr", "").copy()
glinos_annotation["chr"] = glinos_annotation["chr"].str.replace("M", "MT").copy()

leung_annotation = pd.read_csv("HumanCTX.collapsed_classification.filtered_lite.gtf", header=None, delimiter="\t", low_memory=False, comment="#", names=["chr", "source", "type", "start", "end", "dot_1", "strand", "dot_2", "other"])
leung_annotation["chr"] = leung_annotation["chr"].str.replace("chr", "").copy()
leung_annotation["chr"] = leung_annotation["chr"].str.replace("M", "MT").copy()

glinos_annotation.to_csv("glinos_annotation_clean.gtf", index=False, header=False, sep="\t", quoting=csv.QUOTE_NONE)

leung_annotation.to_csv("leung_annotation_clean.gtf", index=False, header=False, sep="\t", quoting=csv.QUOTE_NONE)

heberle_annotation.to_csv("heberle_annotation_clean.gtf", index=False, header=False, sep="\t", quoting=csv.QUOTE_NONE)
