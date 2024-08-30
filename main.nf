#!/usr/bin/env nextflow
nextflow.enable.dsl=2

//Pipiline version
pipelineVersion = '3.0'

//include help and start message
include { startMessage; helpMessage; printSelectedParameters } from "$projectDir/modules/messages"

// Start message
startMessage(pipelineVersion)

//include subworkflows for short, long and hybrid assemblies
include { SR_ASSEMBLY          } from './workflows/sr_assembly'
include { LR_ASSEMBLY          } from './workflows/lr_assembly'
include { HY_ASSEMBLY          } from './workflows/hybrid_assembly'
include { GATHER_GUNC_DB       } from './modules/contamination'
include { VALIDATE_SAMPLESHEET } from './modules/validatesamplesheet.nf'

if (params.help) {
        helpMessage()
}else{
    
    //print the selected params
    printSelectedParameters()

    //sleep for 5 seconds
    sleep(1000)

    //start the actual workflow
    workflow{

        // Run the validation step
        validated_samplesheet_ch = VALIDATE_SAMPLESHEET(params.samplesheet)
     
        // Evaluates the samplesheet and classifies the samples
        validated_samplesheet_ch
            .splitCsv( header: true, sep: ',' )
            .branch { row ->
                 srt: row.long_reads == "" && row.short_reads1 != "" && row.short_reads2 != ""
                 lng: row.long_reads != "" && row.short_reads1 == "" && row.short_reads2 == ""
                 hyb: row.long_reads != "" && row.short_reads1 != "" && row.short_reads2 != ""
            }
            .set { assembly }

        // Feeds short-read reads channel
        assembly.srt
        .map { row -> tuple(row.sample_id, row.short_reads1, row.short_reads2, row.genome_size) }
        .set { srt_reads }


        // Feeds long-read reads channel
        assembly.lng
        .map { row -> tuple(row.sample_id, row.long_reads, row.genome_size) }
        .set { lng_reads }

        // Feeds short-read read channel for hybrid assembly
        assembly.hyb
        .map { row -> tuple(row.sample_id, row.short_reads1, row.short_reads2, row.genome_size) }
        .set { hyb_srt_reads }
    
        // Feeds long-read read channel for hybrid assembly
        assembly.hyb
        .map { row -> tuple(row.sample_id, row.long_reads, row.genome_size) }
        .set { hyb_lng_reads }

        //download the guncDB for contamination check
        //GATHER_GUNC_DB(params.gunc_db)

        //run short read assembly workflow
        SR_ASSEMBLY (srt_reads)

        //run long read assembly workflow
        LR_ASSEMBLY (lng_reads)
    
        //run hybrid assembly workflow
        HY_ASSEMBLY(hyb_srt_reads, hyb_lng_reads)
    }
}
