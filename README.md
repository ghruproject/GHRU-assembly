# GHRU2 New Assembly Pipeline
[![Nextflow](https://img.shields.io/badge/nextflow%20DSL2-24.04.4-23aa62.svg)](https://www.nextflow.io/)
[![run with docker](https://img.shields.io/badge/run%20with-docker-0db7ed?labelColor=000000&logo=docker)](https://www.docker.com/)

## Overview

The GHRU Assembly Pipeline (version 3.0) is designed for assembling genomic data based on a provided samplesheet. The pipeline supports different assemblers depending on the type of sequencing reads provided. 

The pipeline is built as parth of GHRU project funded by NIHR.

### Authors
 - Julio Diaz Caballero     @juliofdiaz       <julio.diaz@cgps.group>  
 - Varun Shammana           @varunshamanna    <varunshamanna4@gmail.com>  
 - Angela Sofia Garcia      @as-garciav       <agarciav@agrosavia.co>
 - Christopher Ocampo       @arsp-dev         <christopher.ocampo@ritm.gov.ph> 


## Assemblers

- **Short Reads Only**: Assembled using **Shovill**.
- **Long Reads Only**: Assembled using **Dragonflye**.
- **Both Long and Short Reads**: Assembled using **Unicycler**.

### Setup 
1. Clone the repository
    ```
    git clone   https://github.com/cgps-discovery/GHRU-assembly.git
    ```
    or 
    
    Download and unzip/extract the [latest release]

## Inputs

### Mandatory
- `--samplesheet` (string): The absolute path to the CSV file containing the sample information. This is the only mandatory input.

### Optional
- `--output` (string): The path where the results will be stored. Default is `./output`.
- `--medaka_model` (string): The path to the Medaka model file used for polishing assemblies. Default is `r941_e81_fast_g514`.
- `--adapter_file` (string): The path to the adapter sequences file. Default is `data/adapter.fas`.
- `--min_contig_length` (integer): The minimum length of contigs to consider. Default is `500`.

## Example Command

To run the pipeline with the mandatory `samplesheet` and optional `output` path, use:

```bash
nextflow run main.nf --samplesheet /path/to/samplesheet --output /path/to/output
```

&nbsp;
## Usage
1. Prepare the Samplesheet: Ensure your CSV samplesheet contains the necessary fields for your samples. The required format is as follows:

```bash
sample_id,short_reads1,short_reads2,long_reads,genome_size
```
An example sample sheet has been provided in the project directory

2. Run the Pipeline: Execute the Nextflow command with the appropriate arguments:
```bash
nextflow run main.nf --samplesheet /data/nihr/nextflow_pipelines/test_input/samplesheet.csv -resume
```

## Requirements
### Software
    - The pipeline is built only for Linux operating systems  (e.g. Linux, Windows with [WSL](https://en.wikipedia.org/wiki/Windows_Subsystem_for_Linux))
    - As of now the pipeline is not supported for macOS because of the issue with medaka which is incompatible with some of the macos versions and macbook models
    - Nextflow >22
    - Docker must be running (with 10 cores and 16GB ram allocated in the docker desktop app if using windows wsl)
### Hardware 
It is recommended to have at least 10 cores and 16GB of RAM and 50GB of free storage


# Troubleshooting
    - Give the absolute path of the sample sheet for example `/data/test/samplesheet.csv`
    - File Not Found Errors: Ensure that all specified file paths (samplesheet, output directory, medaka model, adapter file) are correct and accessible.
    - Permission Issues: Verify that you have the necessary permissions to read the input files and write to the output directory.



