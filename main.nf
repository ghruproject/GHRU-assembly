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


workflow{
    Channel
        .fromPath( params.samplesheet )
        .splitCsv( header: true, sep: ',' )
        .map { row -> tuple( row.sample_name, row.short_reads1, row.short_reads2, row.long_reads, row.genome_size ) }
        .branch { row ->
            srt: row[3] == "" && row[1] != "" && row[2] != ""
            lng: row[3] != "" && row[1] == "" && row[2] == ""
            hyb: row[3] != "" && row[1] != "" && row[2] != ""
        }
        .set { assembly }

    assembly.srt
    .map { row -> tuple(row[0], row[1], row[2], row[4]) }
    .set { srt_assembly }

    assembly.lng
    .map { row -> tuple(row[0], row[3], row[4]) }
    .set { lng_assembly }

    assembly.hyb
    .map { row -> tuple(row[0], row[1], row[2], row[3], row[4]) }
    .set { hyb_assembly }

    //assembly.srt.view { "short "+it }
    //assembly.lng.view { "long "+it }
    //assembly.hyb.view { "hybrid "+it }

    srt_assembly.view { "srt "+it }
    lng_assembly.view { "lng "+it }
    hyb_assembly.view { "hyb "+it }

    HYBRID_ASSEMBLY( hyb_assembly )
}
