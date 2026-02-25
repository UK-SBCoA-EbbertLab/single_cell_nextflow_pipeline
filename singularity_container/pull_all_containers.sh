#!/bin/bash

## NOTE: nextflow should pull all these containers for you. But if you want to look at them personally, here are the commands

# Bambu container
singularity pull --arch amd64 library://ebbertlab-madeline/pip_single_cell/bambu:sha256.92aa5d23643ff1341e372ffc73c9f61e8bf666027a18f8ebb2c19f16ce4cf990

# Nanopore container
singularity pull --arch amd64 library://ebbertlab-madeline/pip_single_cell/nanopore:sha256.a50552a9ec75d90397d8c278a03927a7ea683b7279344922b41cf695f994c8a9

# Nanopore container with polars
singularity pull --arch amd64 library://ebbertlab-madeline/pip_single_cell/nanopore:sha256.298521b5069230957dc2b1d58d377cfae37db264fb7a6d62bf3c436a9e89b3c7

# quality control container
singularity pull --arch amd64 library://ebbertlab-madeline/pip_single_cell/quality_control:sha256.7bc6081546d36db6e32e1258fdec988bb799468b96390d75342c2ae233fe7cac

# pycoqc container
singularity pull --arch amd64 library://ebbertlab-madeline/pip_single_cell/pycoqc:sha256.861887d11355c6d6ff4c6b9a52670a7f80ea6524ce126f808805e53b65db09f9
