#!/usr/bin/env bash

    # --NDR "auto" \

nextflow ../main.nf --bambu_rds "./results/44B_Cerebellum_test_results/bambu_prep/*.rds" \
    --ref "../../references/Homo_sapiens.GRCh38_ERCC.fa" \
    --annotation "../../references/Homo_sapiens.GRCh38.107_ERCC.gtf" \
    --out_dir "./44B_Cerebellum_test_results/" \
    --is_discovery "False" \
    --bambu_track_reads "True" \
    --multiqc_input "./results/44B_Cerebellum_test_results/multiQC_input/**" \
    --multiqc_config "../../references/multiqc_config.yaml" \
    --fai "./results/44B_Cerebellum_test_results/fai/*.fai" \
    --step 3 \
    --is_chm13 "False" -resume
