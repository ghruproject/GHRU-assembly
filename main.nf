#!/usr/bin/env nextflow
nextflow.enable.dsl=2

//Pipiline version
pipelineVersion = '3.0'

//include help and start message
include { startMessage; helpMessage; printSelectedParameters } from "$projectDir/modules/messages"

// Start message
startMessage(pipelineVersion)

//include subworkflows for short, long and hybrid assemblies
include { SR_ASSEMBLY     } from './workflows/sr_assembly'
include { LR_ASSEMBLY     } from './workflows/lr_assembly'
include { HY_ASSEMBLY     } from './workflows/hybrid_assembly'



if (params.help) {
        helpMessage()
}else{
    
    //print the selected params
    printSelectedParameters()

    //sleep for 5 seconds
    sleep(5000)

    //start the actual workflow
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
        .map { row -> tuple(row.sample_id, row.short_reads1, row.short_reads2) }
        .set { srt_assembly }

        // Feeds short-read reads channel
        assembly.srt
        .map { row -> tuple(row.sample_id, row.short_reads1, row.short_reads2) }
        .set { srt_reads }

        // Feeds long-read assembly channel
        assembly.lng
        .map { row -> tuple(row.sample_id, row.long_reads, row.genome_size) }
        .set { lng_assembly }

        // Feeds long-read reads channel
        assembly.lng
        .map { row -> tuple(row.sample_id, row.long_reads) }
        .set { lng_reads }

        // Feeds hybrid assembly channel
        assembly.hyb
        .map { row -> tuple(row.sample_id, row.short_reads1, row.short_reads2, row.long_reads, row.genome_size) }
        .set { hyb_assembly }

        // Feeds short-read read channel
        assembly.hyb
        .map { row -> tuple(row.sample_id, row.short_reads1, row.short_reads2) }
        .set { srt_reads }
    
        // Feeds long-read read channel
        assembly.hyb
        .map { row -> tuple(row.sample_id, row.long_reads) }
        .set { lng_reads }

        //run short read assembly workflow
        SR_ASSEMBLY ()

        //run long read assembly workflow
        LR_ASSEMBLY ()
    
        //run hybrid assembly workflow
        HY_ASSEMBLY()
    }
}
