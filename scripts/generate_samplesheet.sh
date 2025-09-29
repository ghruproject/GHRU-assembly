#!/bin/bash

# Check for FASTQ directory input
if [ -z "$1" ]; then
    echo "Usage: $0 /path/to/fastq_files"
    exit 1
fi

FASTQ_DIR="$1"
echo "sample_id,short_reads1,short_reads2,long_reads,genome_size" > samplesheet.csv

declare -A sample_short1
declare -A sample_short2
declare -A sample_long

# Gather all files and classify
for file in "$FASTQ_DIR"/*.fastq.gz; do
    [[ -e "$file" ]] || continue
    fname=$(basename "$file")

    # Remove extensions and identify base sample
    if [[ "$fname" =~ (_R1|_1)\.fastq\.gz$ ]]; then
        sample_id=$(echo "$fname" | sed -E 's/_R1\.fastq\.gz$|_1\.fastq\.gz$//')
        sample_short1["$sample_id"]="$(realpath "$file")"
    elif [[ "$fname" =~ (_R2|_2)\.fastq\.gz$ ]]; then
        sample_id=$(echo "$fname" | sed -E 's/_R2\.fastq\.gz$|_2\.fastq\.gz$//')
        sample_short2["$sample_id"]="$(realpath "$file")"
    else
        sample_id=$(basename "$file" .fastq.gz)
        sample_long["$sample_id"]="$(realpath "$file")"
    fi
done

# Merge into samplesheet
all_sample_ids=($(printf "%s\n" "${!sample_short1[@]}" "${!sample_short2[@]}" "${!sample_long[@]}" | sort -u))

for sample_id in "${all_sample_ids[@]}"; do
    short1="${sample_short1[$sample_id]}"
    short2="${sample_short2[$sample_id]}"
    longr="${sample_long[$sample_id]}"
    echo "$sample_id,${short1:-},${short2:-},${longr:-},"
    echo "$sample_id,${short1:-},${short2:-},${longr:-}," >> samplesheet.csv
done

echo "samplesheet.csv generated in current directory."
