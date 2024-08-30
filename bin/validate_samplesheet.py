#!/usr/bin/env python3

import csv
import os
import sys

def main(samplesheet):
    seen_sample_ids = set()
    with open(samplesheet, 'r') as csvfile:
        reader = csv.DictReader(csvfile)
        for row in reader:
            sample_id = row.get('sample_id')
            if not sample_id:
                sys.exit(f"Error: Missing sample_id in row: {row}")
            if sample_id in seen_sample_ids:
                sys.exit(f"Error: Duplicate sample_id '{sample_id}' found.")
            seen_sample_ids.add(sample_id)

            # Check if the files exist
            #for field in ['short_reads1', 'short_reads2', 'long_reads']:
            #    file_path = row.get(field)
            #    if file_path and not os.path.exists(file_path):
            #        sys.exit(f"Error: File '{file_path}' for sample '{sample_id}' does not exist.")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python validate_samplesheet.py <samplesheet>")
        sys.exit(1)
    main(sys.argv[1])