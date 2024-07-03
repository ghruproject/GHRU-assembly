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
//include { HYBRID_ASSEMBLY } from './modules/hybrid_assembly'
//include { QUAST } from './modules/quast'


//include { QUALIFYR } from './modules/qualifyr'



workflow {
    Channel.fromPath(params.samplesheet) | PARSE_SAMPLESHEET | CLASSIFY_SAMPLES

    short_reads_channel
        .map { tuple(it[0], it[2], it[3]) }
        .set { kraken2_inputs; confindr_inputs }
    
    kraken2_inputs
        .combine(short_reads_channel)
        .map { tuple(it[0], it[1], it[2]) }
        .set { shovill_inputs }
    
    long_reads_channel
        .map { tuple(it[0], it[2], it[4]) }
        .set { unicycler_inputs }
    
    hybrid_reads_channel
        .map { tuple(it[0], it[2], it[3], it[4], it[5]) }
        .set { bacass_inputs }
    
    shovill_inputs
        .map { tuple(it[0], 'short', it[1], it[2], it[3]) }
        .set { shovill_reads }
    
    unicycler_inputs
        .map { tuple(it[0], 'long', it[1], it[2]) }
        .set { unicycler_reads }
    
    bacass_inputs
        .map { tuple(it[0], 'both', it[1], it[2], it[3], it[4]) }
        .set { bacass_reads }
    
    shovill_reads
        .map { tuple(it[0], it[2], it[3]) }
        .combine(kraken2_reports)
        .map { tuple(it[0], it[1], it[2]) }
        .combine(confindr_reports)
        .map { tuple(it[0], it[1], it[2]) }
        .combine(shovill_assemblies)
        .map { tuple(it[0], it[1], it[2], it[3]) }
        .set { quast_inputs }
    
    unicycler_reads
        .combine(unicycler_assemblies)
        .set { quast_inputs }
    
    bacass_reads
        .combine(bacass_assemblies)
        .set { quast_inputs }
    
    quast_inputs
        .map { it[3] }
        .combine(quast_reports)
        .map { tuple(it[0], it[1]) }
        .set { qualifyr_inputs }
    
    qualifyr_inputs
        .combine(kraken2_reports)
        .map { tuple(it[0], it[1]) }
        .combine(confindr_reports)
        .map { tuple(it[0], it[1]) }
        .set { qualifyr_reports }
}
