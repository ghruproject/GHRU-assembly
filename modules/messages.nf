// Start message
def startMessage(String pipelineVersion) {
    log.info( 
        $/
        |
        |╔═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗
        |║                                                                                                                   ║░
        |║    ██████   ██   ██  █████    ██    ██      █████   █████  █████  █████  ███   ███  ███████  ██      ██      ██   ║░
        |║   ██        ██   ██  ██   ██  ██    ██     ██   ██ ██     ██     ██     ██ ██ ██ ██ ██    ██ ██        ██  ██     ║░
        |║   ██   ███  ███████  █████    ██    ██     ███████ ██████ ██████ ██████ ██   █   ██ ███████  ██          ██       ║░
        |║   ██    ██  ██   ██  ██  ██   ██    ██     ██   ██     ██     ██ ██     ██       ██ ██    ██ ██          ██       ║░
        |║    ██████   ██   ██  ██   ██   ██████      ██   ██ █████  █████   █████ ██       ██ ███████   ███████    ██       ║░
        |║                                                                                                                   ║░   
        |║                                                                                                                   ║░
        |║                              ░░░░░   ░  ░░░░░   ░░░░░  ░      ░  ░░    ░  ░░░░░                                   ║░ 
        |║                              ░    ░  ░  ░    ░  ░      ░      ░  ░ ░   ░  ░                                       ║░
        |║                              ░░░░░   ░  ░░░░░   ░░░░   ░      ░  ░  ░  ░  ░░░░                                    ║░
        |║                              ░       ░  ░       ░      ░      ░  ░   ░ ░  ░                                       ║░   
        |║                              ░       ░  ░       ░░░░░  ░░░░░  ░  ░    ░░  ░░░░░                                   ║░
        |${String.format('║  v %-46s',     pipelineVersion)}                                                                 ║░
        |╚═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝░
        |  ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
       /$.stripMargin()
    )
}





// Help message
void helpMessage() {
    log.info(
        '''
        |GHRU Assembly Pipeline

        This pipeline performs short-read, long-read, and hybrid genome assemblies.

        USAGE:
            nextflow run assembly_pipeline.nf --input <input_file> --output <output_directory> [options]

        MANDATORY PARAMETERS:
            --input <input_file>        Path to the input samplesheet file containing information about the samples.
            --output <output_directory> Directory where the output files will be saved.

        OPTIONAL PARAMETERS:
            --genome_size <size>         Estimated genome size (e.g., 5m for 500000).
            --kraken_db <path>           Path to the Kraken2 database for taxonomic classification.
            --confindr_db <path>         Path to the ConFindr database for contamination detection.
            --adapter_file <path>        Path to the adapter file for read trimming.
            --min_contig_length <num>    minimum contig length
            --assembler_thread <num>     Number of threads to use for the assembly (default: 8).
            --assembler_ram <num>        RAM to use for the assembly (default: 16).
            --medaka_model <model>       Medaka model to be 


        EXAMPLES:
            nextflow run assembly_pipeline.nf --input samplesheet.csv --output results 
            nextflow run assembly_pipeline.nf --input samplesheet.csv --output results 
            nextflow run assembly_pipeline.nf --input samplesheet.csv --output results --hybrid --genome_size 5m

        DESCRIPTION:
            This GHRU assembly pipeline is designed to handle various types of genome assemblies using different sequencing technologies. It includes steps for trimming, quality control, assembly, and optional taxonomic classification and contamination detection.

        For more information, visit our documentation at: [link to documentation]
        '''.stripMargin()
    )
    System.exit(0) 
}


// Workflow selection message
void printSelectedParameters() {
    log.info(
      """
      GHRU Assembly Pipeline - Selected Parameters:

        Input File:        ${params.samplesheet}
        Output Directory:  ${params.output}
        Threads:           ${params.assembler_thread}
        RAM:               ${params.assembler_ram}
        Kraken2 Database:  ${params.kraken_db ?: 'Not Provided'}
        ConFindr Database: ${params.confindr_db ?: 'Not Provided'}
        Adapter File:      ${params.adapter_file ?: 'Not Provided'}
        MedakaModel:       ${params.medaka_model}
      """.stripMargin()
    )    
}