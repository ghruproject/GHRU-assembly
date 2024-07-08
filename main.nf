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

//include { QUALIFYR } from './modules/qualifyr'


workflow{
    // Evaluates the samplesheet and classifies the samples
    Channel
        .fromPath( params.samplesheet )
        .splitCsv( header: true, sep: ',' )
        .branch { row ->
            srt: row.long_reads == "" && row.short_reads1 != "" && row.short_reads2 != ""
            lng: row.long_reads != "" && row.short_reads1 == "" && row.short_reads2 == ""
            hyb: row.long_reads != "" && row.short_reads1 != "" && row.short_reads2 != ""
        }
        .set { assembly }

    // Feeds short-read assembly channel
    assembly.srt
    .map { row -> tuple(row.sample_name, row.short_reads1, row.short_reads2) }
    .set { srt_assembly }

    // Feeds short-read reads channel
    assembly.srt
    .map { row -> tuple(row.sample_name, row.short_reads1, row.short_reads2) }
    .set { srt_reads }

    // Feeds long-read assembly channel
    assembly.lng
    .map { row -> tuple(row.sample_name, row.long_reads, row.genome_size) }
    .set { lng_assembly }

    // Feeds long-read reads channel
    assembly.lng
    .map { row -> tuple(row.sample_name, row.long_reads) }
    .set { lng_reads }

    // Feeds hybrid assembly channel
    assembly.hyb
    .map { row -> tuple(row.sample_name, row.short_reads1, row.short_reads2, row.long_reads, row.genome_size) }
    .set { hyb_assembly }

    // Feeds short-read read channel
    assembly.hyb
    .map { row -> tuple(row.sample_name, row.short_reads1, row.short_reads2) }
    .set { srt_reads }
    
    // Feeds long-read read channel
    assembly.hyb
    .map { row -> tuple(row.sample_name, row.long_reads) }
    .set { lng_reads }


    //HYBRID_ASSEMBLY( hyb_assembly )
    //LONG_ASSEMBLY( lng_assembly )
    //SHORT_ASSEMBLY( srt_assembly )
}

