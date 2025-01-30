#!/usr/bin/env python3
import os
import argparse

def lookup_database(species_name):
    # Make sure genus first word is capitalized
    genus, *rest = species_name.split(' ')
    species_name = ' '.join([genus.capitalize()] + [word.lower() for word in rest])
    # Replace spaces with underscores
    folder_name = species_name.replace(' ', '_')
    # Define the path to the mlst_db directory
    mlst_db_path = '/opt/ariba/mlst_db'
    
    # Construct the full path to the species folder
    species_folder_path = os.path.join(mlst_db_path, folder_name)
    
    # Check if the folder exists
    if os.path.isdir(species_folder_path):
        print(f"Database found for species '{species_name}' at: {species_folder_path}")
    else:
        print(f"No database found for species '{species_name}'.")
        return None
    return species_folder_path +'/ref_db'

def run_ariba(database_path, reads_1, reads_2, output_dir, threads=2):
    # Run Ariba
    command = f"ariba run --force --threads {threads} {database_path} {reads_1} {reads_2} {output_dir}"
    print(f"Running Ariba with command: {command}")
    os.system(command)

def give_results(output_dir, output_prefix):
    # Give the results
    # get list of genes and count from mlst_report.details.tsv first column 
    gene_counts = {}
    with open(f"{output_dir}/mlst_report.details.tsv", encoding='utf-8') as file:
        for line in file:
            gene = line.split('\t')[0]
            if gene == 'gene':
                continue
            if gene in gene_counts:
                gene_counts[gene] += 1
            else:
                gene_counts[gene] = 1
    with open(f"{output_dir}/mlst_report.details.tsv", encoding='utf-8') as file:
        lines = file.readlines()
        gene_status = {}
        for line in lines[1:]:
            fields = line.strip().split('\t')
            gene = fields[0]
            ctgs = int(fields[4])
            hetmin = fields[6]
            status = 'PASS'
            if ctgs > 1 or hetmin != '.':
                status = 'FAIL'
            gene_status[gene] = status

    with open(f"{output_dir}/mlst_report.tsv", encoding='utf-8') as mlst_file:
        mlst_file.readline()  # Skip the first line
        st_line = mlst_file.readline().strip()  # Read the second line
        st = st_line.split('\t')[0].replace('*','')

    genes = list(gene_counts.keys())
    with open(f"{output_dir}/{output_prefix}_qc_details.tsv", 'w', encoding='utf-8') as qc_file:
        qc_file.write('ST\t' + '\t'.join(genes) + '\n')
        status_list = [gene_status.get(gene, 'PASS') for gene in genes]
        qc_file.write(f"{st}\t" + '\t'.join(status_list) + '\n')
    # Create a generic summary ; ST & number of genes passed / total genes
    with open(f"{output_dir}/{output_prefix}_qc_summary.tsv", 'w', encoding='utf-8') as qc_file:
        total_genes = len(gene_counts)
        passed_genes = sum(1 for status in gene_status.values() if status == 'PASS')
        qc_file.write("ST\tPassed\tTotal\tStatus\n")
        if passed_genes == total_genes:
            stat = 'PASS'
        else:
            stat = 'FAIL'
        qc_file.write(f"{st}\t{passed_genes}\t{total_genes}\t{stat}\n")
    # Rename the other ariba files, debug.report.tsv, mlst_report.tsv, mlst_report.details.tsv, report.tsv
    os.rename(f"{output_dir}/debug.report.tsv", f"{output_dir}/{output_prefix}_debug.report.tsv")
    os.rename(f"{output_dir}/mlst_report.tsv", f"{output_dir}/{output_prefix}_mlst_report.tsv")
    os.rename(f"{output_dir}/mlst_report.details.tsv", f"{output_dir}/{output_prefix}_mlst_report.details.tsv")
    os.rename(f"{output_dir}/report.tsv", f"{output_dir}/{output_prefix}_report.tsv")


def no_result_stub(output_dir, output_prefix):
    # make output_dir
    os.makedirs(output_dir, exist_ok=True)
    with open(f"{output_dir}/{output_prefix}_qc_summary.tsv", 'w', encoding='utf-8') as qc_file:
        qc_file.write("ST\tPassed\tTotal\tStatus\n")
        qc_file.write("NA\t0\t0\tPASS\n")


def main():
    parser = argparse.ArgumentParser(description='Run Ariba with species name')
    parser.add_argument('--output_prefix', type=str, help='Prefix', default='ariba_out')
    parser.add_argument('species_name', type=str, help='Name of the species to lookup')
    parser.add_argument('reads_1', type=str, help='Path to the first reads file')
    parser.add_argument('reads_2', type=str, help='Path to the second reads file')
    parser.add_argument('output_dir', type=str, help='Directory to store the output')
    parser.add_argument('--threads', type=int, help='Threads', default=1)

    args = parser.parse_args()
    # ariba run get_mlst/ref_db reads_1.fq reads_2.fq ariba_out
    database_path = lookup_database(args.species_name)
    if database_path:
        run_ariba(database_path, args.reads_1, args.reads_2, args.output_dir, args.threads)
        give_results(args.output_dir, args.output_prefix)
    else:
        print("No database found for the specified species.")
        no_result_stub(args.output_dir, args.output_prefix)
        


if __name__ == '__main__':
    main()