#!/usr/bin/env python
import pandas as pd
import os
import glob
import argparse
import re
import gzip

def concat_samp_flowcell_pychopper_stats(input_folder, output_folder):
     # Find all files matching the pattern *_num_pass_reads_by_file.tsv
    tsv_files = glob.glob(os.path.join(input_folder, "*_num_pass_reads_by_file.tsv"))

    if not tsv_files:
        print("No matching TSV files found in the specified directory.")
        return
    # Dictionary to store dataframes grouped by (sampleID, flowcellID)
    grouped_data = {}
    return_grouped_data = {}

    pattern = re.compile(r"(?P<sampleID>[^_]+)_(?P<flowcellID>[^_]+)_(?P<fileNumber>\d+)_num_pass_reads_by_file.tsv")
    for file in tsv_files:
        filename = os.path.basename(file)
        match = pattern.match(filename)
        if match:
            sampleID = match.group("sampleID")
            flowcellID = match.group("flowcellID")
            key = (sampleID, flowcellID)

            df = pd.read_csv(file, sep="\t")

            if key in grouped_data:
                grouped_data[key].append(df)
            else:
                grouped_data[key] = [df]

    # Combine and save grouped files
    for (sampleID, flowcellID), dataframes in grouped_data.items():
        combined_df = pd.concat(dataframes, ignore_index=True)
        output_filename = f"{sampleID}_{flowcellID}_combined_pass_reads.tsv"
        output_path = os.path.join(output_folder, output_filename)
        combined_df.to_csv(output_path, sep="\t", index=False)
        print(f"Combined data for {sampleID}_{flowcellID} saved to {output_filename}")

        # summarize the data
        summary = {
                'sampleID': [sampleID],
                'flowcellID': [flowcellID],
                'total_pass_reads': [combined_df['num_pass_reads'].sum()],
                'total_after_pychop': [combined_df['num_reads_after_pychop'].sum()]
                }
        return_grouped_data[(sampleID, flowcellID)] = summary

    return return_grouped_data


def concat_samp_flowcell_nanopore_converter_stats(input_folder, output_folder, pychop_stats_dict):
    stats_files = glob.glob(os.path.join(input_folder, "*_stats_sorted.txt"))

    if not stats_files:
        print("No matching _stats_sorted.txt files found in the specified directory.")
        return

    pattern = re.compile(r"(?P<sampleID>[^_]+)_(?P<flowcellID>[^_]+)_nanopore_converter_stats_sorted.txt")
    combined_stats_dict = {}

    for file in stats_files:
        filename = os.path.basename(file)
        match = pattern.match(filename)
        if match:
            sampleID = match.group("sampleID")
            flowcellID = match.group("flowcellID")
            key = (sampleID, flowcellID)

            df = pd.read_csv(file, sep="\t")

            summary = {
                    'sampleID': [sampleID],
                    'flowcellID': [flowcellID],
                    'total_after_NanoporeConvert': [df['TotalKeptReads'].sum()]
                    }

            combined_stats_dict[key] = {**pychop_stats_dict[key], **summary}

    return combined_stats_dict

def concat_samp_flowcell_pipseeker(input_folder, output_folder, combined_stats_dict):
    pipseeker_files = glob.glob(os.path.join(input_folder, "*_num_reads_after_pipseeker.tsv"))

    if not pipseeker_files:
        print("No matching _num_reads_after_pipseeker.tsv files found in the specified directory.")
        return

    pattern = re.compile(r"(?P<sampleID>[^_]+)_(?P<flowcellID>[^_]+)_(?P<fileNumber>\d+)(?:_rescued)?_num_reads_after_pipseeker.tsv")
    grouped_data = {}
    stats_dict = {}

    for file in pipseeker_files:
        filename = os.path.basename(file)
        match = pattern.match(filename)
        if match:
            sampleID = match.group("sampleID")
            flowcellID = match.group("flowcellID")
            key = (sampleID, flowcellID)

            df = pd.read_csv(file, sep="\t")

            if key in grouped_data:
                grouped_data[key].append(df)
            else:
                grouped_data[key] = [df]

    # Combine and save grouped files
    for (sampleID, flowcellID), dataframes in grouped_data.items():
        combined_df = pd.concat(dataframes, ignore_index=True)
        output_filename = f"{sampleID}_{flowcellID}_combined_pipseeker_read_stats.tsv"
        output_path = os.path.join(output_folder, output_filename)
        combined_df.to_csv(output_path, sep="\t", index=False)
        print(f"Combined data for {sampleID}_{flowcellID} saved to {output_filename}")

        summary = {
            'sampleID': [sampleID],
            'flowcellID': [flowcellID],
            'total_after_pipseeker': [combined_df['n_reads_after_pipseeker'].sum()]
            }

        stats_dict[key] = {**combined_stats_dict[key], **summary}

    return stats_dict


def merge_on_filename():
    return ""


def main():
    parser = argparse.ArgumentParser(description="Combine stats files by sampleID and flowcellID")
    parser.add_argument("--input_folder", required=True, help="Path to the folder containing stats files")
    parser.add_argument("--output_folder", required=True, help="Path to the folder where combined files will be saved")

    args = parser.parse_args()

    os.makedirs(args.output_folder, exist_ok=True)

    pychopper_stats = concat_samp_flowcell_pychopper_stats(args.input_folder, args.output_folder)
    print(pychopper_stats)
    pychop_and_nc_stats = concat_samp_flowcell_nanopore_converter_stats(args.input_folder, args.output_folder, pychopper_stats)
    print(pychop_and_nc_stats)
    combined_stats = concat_samp_flowcell_pipseeker(args.input_folder, args.output_folder, pychop_and_nc_stats)
    print(combined_stats)

    for (sampleID, flowcellID), stats_dict in combined_stats.items():
        print(stats_dict)
        summary_df = pd.DataFrame.from_dict(stats_dict).reset_index(drop=True)
        print(summary_df)
        outname = f"{sampleID}_{flowcellID}_combined_stats.tsv"
        outpath = os.path.join(args.output_folder, outname)
        summary_df.to_csv(outpath, sep="\t", index=False)


if __name__ == "__main__":
    main()
