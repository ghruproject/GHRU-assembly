//import modules
include { CALCULATE_GENOME_SIZE       } from '../modules/long_reads_preprocess'
include { ASSEMBLY_DRAGONFLYE         } from '../modules/long_read_assembly'



workflow LR_ASSEMBLY{
    Channel
        .fromPath( params.samplesheet )
        .splitCsv( header: true, sep: ',' )
        .branch { row ->
            lng: row.long_reads != "" && row.short_reads1 == "" && row.short_reads2 == ""
        }
        .set { assembly }

    // Feeds long-read reads channel
    assembly.lng
    .map { row -> tuple(row.sample_id, row.long_reads, row.genome_size) }
    .set { lng_reads }

    read_with_genome_size = CALCULATE_GENOME_SIZE(lng_reads)
    ASSEMBLY_DRAGONFLYE(read_with_genome_size, params.medaka_model, params.assembler_thread, params.assembler_ram)
}
