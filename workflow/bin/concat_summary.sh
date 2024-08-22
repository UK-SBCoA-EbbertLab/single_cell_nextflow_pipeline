#!/bin/bash

# Check if a TSV file is provided
if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <tsv_file> <directory>"
    exit 1
fi

tsv_file="$1"
directory="$2"


# Read the TSV file and process each line
while IFS=$'\t' read -r folder_id sample_id; do
    output_file="${sample_id}_sequencing_summary.txt"

    echo "Processing folder: ${directory}${folder_id}"
    echo "Output file: $output_file"

    txt_files=$(find "${directory}${folder_id}" -name "*.txt" | sort)
    if [ -z "$txt_files" ]; then
        echo "No .txt files found in ${directory}${folder_id}. Skipping..."
    else
        # Process the first file
        first_file=$(echo "$txt_files" | head -n 1)
        echo "Processing first file: $first_file"
        cat "$first_file" > "$output_file"

        # Process the rest of the files
        for file in $(echo "$txt_files" | tail -n +2); do
            echo "Processing subsequent file: $file"
            sed '1d' "$file" >> "$output_file"
        done
    fi
done < "$tsv_file"



## Read the TSV file and process each line
#while IFS=$'\t' read -r folder_id sample_id; do
#    output_file="${sample_id}_sequencing_summary.txt"
#    first_file=true
#
#    echo "${directory}${folder_id}"
#
#    txt_files=$(find "${directory}${folder_id}" -name "*.txt")
#    if [ -z "$txt_files" ]; then
#        echo "No .txt files found in ${directory}${folder_id}. Exiting..."
#    else
#
#    # Find and concatenate files based on folder_id
#        for file in $(echo "$txt_files" | sort); do
#            echo $file
#  	    if [ ! -f ${file} ]; then
#    		echo '${file} does not exist, skipping...'
#    	    fi
#	    echo $first_file
#            if [ "$first_file" = true ]; then
#		echo "IS FIRST FILE"
#                # Copy the entire content of the first file
#                cat "$file" >> "$output_file"
#                first_file=false
#		echo $first_file
#            else
#                # Append file content except the first line to the output file
#                sed '1d' "$file" >> "$output_file"
#            fi
#        done
#    fi
#done < "$tsv_file"

