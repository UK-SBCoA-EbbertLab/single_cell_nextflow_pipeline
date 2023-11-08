#!/usr/bin/env python

import os
import sys
import gzip
import glob
import itertools

def filter_pip(fastq_dir, output_dir, file_name):

        os.makedirs(output_dir, exist_ok=True)

        pattern = 'barcoded_?_R{1,2}.fastq.gz'

        file_paths = glob.glob(f"{fastq_dir}/{pattern}")
        
        index = 1

        while True:

            r1 = os.path.join(fastq_dir, f"barcoded_{index}_R1.fastq.gz")
            r2 = os.path.join(fastq_dir, f"barcoded_{index}_R2.fastq.gz")
            if os.path.exists(r1) and os.path.exists(r2):
                with gzip.open(r1, 'rt') as file1, gzip.open(r2, 'rt') as file2:
                    line1 = next(file1)
                    while True:
                        try:
                            line2 = next(file2)

                            if line1 != line2:
                                for _ in range(3):
                                    line1 = next(file1)
                                    next(file2)
                                continue

                            line1 = next(file1).strip()[0:16]

                            output_filename = f"{file_name}_{line1}.fastq"
                            output_file_path = os.path.join(output_dir, output_filename)

                            lines_to_write = [line2] + [next(file2) for _ in range(3)]
                            with open(output_file_path, 'a') as output_file:
                                output_file.write("".join(lines_to_write))
                            
                            for _ in range(3):
                                line1 = next(file1)

                        except StopIteration:
                            break;
                        
                index += 1
            else:
                break

if __name__ == '__main__':
    fastq_dir = os.path.expanduser(sys.argv[1])
    output_dir = os.path.expanduser(sys.argv[2])
    file_name = os.path.expanduser(sys.argv[3])
    filter_pip(fastq_dir, output_dir, file_name)
