#!/bin/bash

## NOTE: nextflow should pull all these containers for you. But if you want to look at them personally, here are the commands

singularity pull --arch amd64 library://ebbertlab-madeline/pip_single_cell/bambu:sha256.7fc006a6030cc57ee89262c5b9c47070046471557255594341562b1d3643aff9

singularity pull --arch amd64 library://ebbertlab-madeline/pip_single_cell/dorado:sha256.93fc58c931ac05d43297eb82e4de0a6e2c73e683153b0b6a2c42e39f3f1f2502

singularity pull --arch amd64 library://ebbertlab-madeline/pip_single_cell/nanopore:sha256.80d11d0c1550956f3a44332e51ee9c4712d939d212024fd1293975dc324c1c20

singularity pull --arch amd64 library://ebbertlab-madeline/pip_single_cell/quality_control:sha256.303598cdb11777068e57a9afb9f916bc9b33d765f7c09166903f290c5541cc71
