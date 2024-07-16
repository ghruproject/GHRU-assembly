//import modules
include { CALCULATE_GENOME_SIZE       } from '../modules/long_reads_preprocess'
include { NANOPLOT                    }  from '../modules/long_reads_preprocess'
include { PORECHOP                    }  from '../modules/long_reads_preprocess'
include { ASSEMBLY_DRAGONFLYE         } from '../modules/long_read_assembly'
include { QUAST_LR                    } from '../modules/quast'


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

    //calculate genomesize for which it is not available and create a channel for reads with genome size
    read_with_genome_size = CALCULATE_GENOME_SIZE(lng_reads)

    //do nanoplot of the long reads
    NANOPLOT(read_with_genome_size, params.assembler_thread)

    //trim adapters with porechop
    PORECHOP(read_with_genome_size, params.assembler_thread)
    
    //processed_long_read assembly channel
    preprocessed_long_reads=PORECHOP.out.long_read_assembly

    //do long read assembly with dragonflye
    ASSEMBLY_DRAGONFLYE(preprocessed_long_reads, params.medaka_model, params.assembler_thread, params.assembler_ram)

    //assess assembly using quast
    QUAST_LR(ASSEMBLY_DRAGONFLYE.out)

}
