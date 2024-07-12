//import modules for the short read only assembly workflow

include { CALCULATE_GENOME_SIZE       } from '../modules/short_reads_preprocess'
include { DETERMINE_MIN_READ_LENGTH   } from '../modules/short_reads_preprocess'
include { TRIMMING                    } from '../modules/short_reads_preprocess'
include { FASTQC                      } from '../modules/short_reads_preprocess'
include { ASSEMBLY_SHOVILL            } from '../modules/short_read_assembly'
include { QUAST_SR                       } from '../modules/quast'

workflow SR_ASSEMBLY{
    Channel
        .fromPath( params.samplesheet )
        .splitCsv( header: true, sep: ',' )
        .branch { row ->
            srt: row.long_reads == "" && row.short_reads1 != "" && row.short_reads2 != ""
        }
        .set { assembly }

    // Feeds short-read reads channel
    assembly.srt
    .map { row -> tuple(row.sample_id, row.short_reads1, row.short_reads2, row.genome_size) }
    .set { srt_reads }

    //calculate genomesize for which it is not available and create a channel for reads with genome size
    reads_with_genome_size = CALCULATE_GENOME_SIZE(srt_reads)

    //determine min read length required for trimming
    DETERMINE_MIN_READ_LENGTH(reads_with_genome_size)

    //qc trimming using trimmomatic
    TRIMMING (reads_with_genome_size, DETERMINE_MIN_READ_LENGTH.out, params.adapter_file)

    //create channel called processed short reads from trimming out
    processed_short_reads= TRIMMING.out

    //do fastqc for the trimmed reads
    FASTQC(processed_short_reads)

    //do assembly using shovill
    ASSEMBLY_SHOVILL(processed_short_reads, params.min_contig_length, params.assembler_thread)
    
    //assess assembly using quast
    QUAST_SR (ASSEMBLY_SHOVILL.out)

}