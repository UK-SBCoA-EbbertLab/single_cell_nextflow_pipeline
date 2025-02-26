#!/bin/bash

## NOTE: nextflow should pull all these containers for you. But if you want to look at them personally, here are the commands

# Bambu container
singularity pull --arch amd64 library://ebbertlab-madeline/pip_single_cell/bambu:sha256.7fc006a6030cc57ee89262c5b9c47070046471557255594341562b1d3643aff9

# Nanopore container
singularity pull --arch amd64 library://ebbertlab-madeline/pip_single_cell/nanopore:sha256.80d11d0c1550956f3a44332e51ee9c4712d939d212024fd1293975dc324c1c20

# Nanopore container with polars
singularity pull --arch amd64 library://ebbertlab-madeline/pip_single_cell/nanopore:sha256.298521b5069230957dc2b1d58d377cfae37db264fb7a6d62bf3c436a9e89b3c7

# quality control container
singularity pull --arch amd64 library://ebbertlab-madeline/pip_single_cell/quality_control:sha256.303598cdb11777068e57a9afb9f916bc9b33d765f7c09166903f290c5541cc71

# pycoqc container
singularity pull --arch amd64 library://ebbertlab-madeline/pip_single_cell/pycoqc:sha256.861887d11355c6d6ff4c6b9a52670a7f80ea6524ce126f808805e53b65db09f9
