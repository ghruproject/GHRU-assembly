#!/usr/bin/env nextflow
nextflow.enable.dsl=2

/*
========================================================================================
        IMPORT PLUGINS
========================================================================================
*/

include { validateParameters; paramsSummaryLog; samplesheetToList } from 'plugin/nf-schema'
include { startMessage } from './modules/messages'
/*
========================================================================================
    IMPORT SUBWORKFLOWS
========================================================================================
*/

include { SR_ASSEMBLY          } from './workflows/sr_assembly'
include { LR_ASSEMBLY          } from './workflows/lr_assembly'
include { HY_ASSEMBLY          } from './workflows/hybrid_assembly'

/*
========================================================================================
    RUN MAIN WORKFLOW
========================================================================================
*/

workflow {
    startMessage(workflow.manifest.version)
    // Validate input parameters
    validateParameters()
    // Print summary of supplied parameters
    log.info paramsSummaryLog(workflow)    
    
    // Create a new channel of metadata from a sample sheet passed to the pipeline through the --input parameter    
    validated_samplesheet_ch = Channel.fromList(samplesheetToList(params.samplesheet, "assets/schema_input.json"))
    assembly = Channel.fromList()
    // Evaluates the samplesheet and classifies the samples#
    validated_samplesheet_ch
    | branch { meta, short_r1, short_r2, long_reads ->
        hyb: long_reads && short_r1 && short_r2 
            return [meta + [type: 'hybrid'], short_r1, short_r2, long_reads]     
        srt: short_r1 && short_r2 
            return [meta + [type: 'short'], short_r1, short_r2]
        lng: long_reads
            return [meta + [type: 'long'], long_reads]
    }
    | set { assembly }
    //run short read assembly workflow
    SR_ASSEMBLY (assembly.srt)

    //run long read assembly workflow
    LR_ASSEMBLY (assembly.lng)

    //run hybrid assembly workflow
    // Split Hybrid assembly reads 
    assembly.hyb
    .multiMap { meta, short_r1, short_r2, long_reads ->
        longreads: [meta, long_reads]
        shortreads: [meta, short_r1, short_r2]
    }
    .set { hybSplit }

   HY_ASSEMBLY (hybSplit.shortreads, hybSplit.longreads)


}

/*
========================================================================================
    WORKFLOW COMPLETION
========================================================================================
*/
 workflow.onComplete {
        workDir = new File("${workflow.workDir}")

        println """
        GHRU Assembly Execution Summary
        ---------------------------
        Pipeline Version : ${workflow.manifest.version}
        Nextflow Version : ${nextflow.version}
        Command Line     : ${workflow.commandLine}
        Resumed          : ${workflow.resume}
        Completed At     : ${workflow.complete}
        Duration         : ${workflow.duration}
        Success          : ${workflow.success}
        Exit Code        : ${workflow.exitStatus}
        Error Report     : ${workflow.errorReport ?: '-'}
        Launch Dir       : ${workflow.launchDir}
        """
    }    

/*
========================================================================================
    THE END
========================================================================================
*/
