#!/usr/bin/env python
import os
import shutil
import subprocess
import argparse
import re


def main(args):
    accessions = []
    with open(args.slyph_report, "r", encoding="utf-8") as file:
        header = file.readline().strip().split("\t")
        contig_name_index = header.index("Contig_name")
        for line in file:
            columns = line.strip().split("\t")
            if columns[contig_name_index] != "Contig_name":
                accession = re.search(r"([A-Z]{2}_[A-Z0-9]+\.\d+)", columns[contig_name_index]).group(1)
                accessions.append(accession)
    print("Accession detected: " + ",".join(accessions))
    if len(accessions) > 1:
        print("Skipping due to contamination detected in SLYPH report")
        with open(args.confindr_out, "w", encoding="utf-8") as file:
            file.write(
                "Sample,Genus,NumContamSNVs,ContamStatus,BasesExamined,DatabaseDownloadDate\n"
            )
            file.write(f"{args.meta_sample_id}_1,Slyph_contamination,ND,True,0,ND\n")
            file.write(f"{args.meta_sample_id}_2,Slyph_contamination,ND,True,0,ND\n")
    else:
        sample_id = args.meta_sample_id
        os.makedirs(sample_id, exist_ok=True)
        shutil.copy(args.read_one, sample_id)
        shutil.copy(args.read_two, sample_id)
        confindr_out_dir = os.path.join(f"confindr_out_{sample_id}")

        # Figure out if reads are _R1 or _1
        read_one_suffix = "_R1" if "_R1" in args.read_one else "_1"
        read_two_suffix = "_R2" if "_R2" in args.read_two else "_2"

        subprocess.run(
            [
                "confindr",
                "-i",
                sample_id,
                "-o",
                confindr_out_dir,
                "--rmlst",
                "-fid",
                read_one_suffix,
                "-rid",
                read_two_suffix,
                "-dt",
                args.type,
                "-d",
                os.path.join(args.database_directory, "confindr_db"),
            ],
            check=True
        )

        shutil.move(
            os.path.join(confindr_out_dir, "confindr_report.csv"), args.confindr_out
        )


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Run ConFindr with given parameters.")
    parser.add_argument(
        "--slyph_report", required=True, help="Path to the SLYPH report"
    )
    parser.add_argument("--meta_sample_id", required=True, help="Sample ID")
    parser.add_argument("--type", required=True, help="type of reads")
    parser.add_argument("--read_one", required=True, help="Path to read one")
    parser.add_argument("--read_two", required=True, help="Path to read two")
    parser.add_argument("--confindr_out", required=True, help="Path to ConFindr output")
    parser.add_argument(
        "--database_directory", required=True, help="Path to database directory"
    )
    main(parser.parse_args())
