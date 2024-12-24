#!/usr/bin/env nextflow
nextflow.enable.dsl=2

//include help and start message
include { validateParameters; paramsSummaryLog; samplesheetToList } from 'plugin/nf-schema'

//include subworkflows for short, long and hybrid assemblies
include { SR_ASSEMBLY          } from './workflows/sr_assembly'
include { LR_ASSEMBLY          } from './workflows/lr_assembly'
include { HY_ASSEMBLY          } from './workflows/hybrid_assembly'
include { VALIDATE_SAMPLESHEET } from './modules/validatesamplesheet.nf'

//start the actual workflow
workflow {

    // Validate input parameters
    validateParameters()

    // Print summary of supplied parameters
    log.info paramsSummaryLog(workflow)    
    //Pipiline version
    pipelineVersion = '4.0.0'
    
    // Create a new channel of metadata from a sample sheet passed to the pipeline through the --input parameter    
    validated_samplesheet_ch = Channel.fromList(samplesheetToList(params.samplesheet, "assets/schema_input.json"))
    assembly = Channel.fromList()
    // Evaluates the samplesheet and classifies the samples#
    validated_samplesheet_ch
    | branch { meta, short_r1, short_r2, long_reads ->
        hyb: long_reads && short_r1 && short_r2 
            return [meta + [type: 'hybrid'], short_r1, short_r2, long_reads]     
        srt: short_r1 && short_r2 // Channel name and Conditional
            return [meta + [type: 'short'], short_r1, short_r2]
        lng: long_reads
            return [meta + [type: 'long'], long_reads]
    }
    | set { assembly }
    //run short read assembly workflow
    SR_ASSEMBLY (assembly.srt)

    //run long read assembly workflow
    // LR_ASSEMBLY (assembly.lng)

    // //run hybrid assembly workflow
 //   HY_ASSEMBLY (assembly.hyb)
}

