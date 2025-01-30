#!/bin/bash

singularity exec /project/mteb223_uksr/singularity_files/ebbert_lab_base_environment.sif javac LevenshteinDistance.java

singularity exec /project/mteb223_uksr/singularity_files/ebbert_lab_base_environment.sif javac pBarcode.java

singularity exec /project/mteb223_uksr/singularity_files/ebbert_lab_base_environment.sif javac NanoporeConverter.java

singularity exec /project/mteb223_uksr/singularity_files/ebbert_lab_base_environment.sif javac NanoporeConverter_rescue.java

singularity exec /project/mteb223_uksr/singularity_files/ebbert_lab_base_environment.sif javac combinedBarcodeWhitelists.java
