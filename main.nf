#!/usr/bin/env nextflow

params.samplesheet = "samplesheet.csv"
params.kraken_db = "/path/to/kraken_db"
params.confindr_db = "/path/to/confindr_db"
params.threads = 8

nextflow.enable.dsl=2

include { PARSE_SAMPLESHEET } from './modules/parse_samplesheet'
include { CLASSIFY_SAMPLES } from './modules/classify_samples'

//include { CONTAMINATION } from './modules/contamination'
//include { SPECIATION } from './modules/speciation'

//include { LR_ASSEMBLY } from './modules/lr_assembly'
//include { SR_ASSEMBLY } from './modules/sr_assembly'
include { HYBRID_ASSEMBLY } from './modules/hybrid_assembly'
//include { QUAST } from './modules/quast'


//include { QUALIFYR } from './modules/qualifyr'

process test{
    input:
    tuple( val(sample_name), val(short_reads1), val(short_reads2), val(long_reads), val(genome_size))

    script:
    """
    echo ${sample_name}
    """

}

workflow{
    Channel
        .fromPath( params.samplesheet )
        .splitCsv( header: true, sep: ',' )
        .map { row -> tuple( row.sample_name, row.short_reads1, row.short_reads2, row.long_reads, row.genome_size ) }
        .set { sample_channel }

    // Takes values from PARSE_SAMPLESHEET and classifies samples into relevant channels
    CLASSIFY_SAMPLES(sample_channel)
    


    test(CLASSIFY_SAMPLES.out)


    if (CLASSIFY_SAMPLES.out == "short") {
        SR_ASSEMBLY( sample_channel )
    } else if (CLASSIFY_SAMPLES.out == "long") {
        LR_ASSEMBLY( sample_channel )
    } else if (CLASSIFY_SAMPLES.out == "hybrid") {
        HYBRID_ASSEMBLY( sample_channel )
    }

}
