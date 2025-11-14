//import modules for the short read only assembly workflow

include { TRIMMING                       } from '../modules/short_reads_preprocess'
include { FASTQC                         } from '../modules/short_reads_preprocess'
include { ASSEMBLY_SHOVILL               } from '../modules/short_read_assembly'
include { QUAST                          } from '../modules/quast'
include { SPECIATION                     } from '../modules/speciation' 
include { CONTAMINATION_CHECKM           } from '../modules/contamination'
include { CALCULATEBASES_SR              } from '../modules/calculate_bases'
include { ASSEMBLY_DEPTH                 } from '../modules/assembly_depth'
include { COMBINE_REPORTS                } from '../modules/combine_reports'
include { SPECCHECK                      } from '../modules/speccheck'
include { SPECCHECK_SUMMARY_DETAILED     } from '../modules/speccheck'
include { SPECCHECK_SUMMARY               } from '../modules/speccheck'
include { SYLPH_FASTQS                   } from '../modules/contamination'



workflow SR_ASSEMBLY{

    take:

    //take the short reads read channel from the main
    srt_reads

    //main workflow for short read assembly
    main:

    //qc trimming using trimmomatic
    TRIMMING (srt_reads, params.adapter_file)

    //create channel called processed short reads from trimming out
    processed_short_reads= TRIMMING.out

    // Confindr on reads 
    SYLPH_FASTQS(processed_short_reads)
    
    //do fastqc for the trimmed reads
    FASTQC(processed_short_reads)

    //do assembly using shovill
    ASSEMBLY_SHOVILL(processed_short_reads, params.min_contig_length)
    
    //assess assembly using quast
    QUAST (ASSEMBLY_SHOVILL.out)

    //speciate with speciator
    SPECIATION(ASSEMBLY_SHOVILL.out)
    SPECIATION.out.species_name.map { meta, file -> tuple(meta, file.text.trim()) }.set { species }

    //contamination check checkm
    CONTAMINATION_CHECKM(ASSEMBLY_SHOVILL.out)

    //calculate bases
    CALCULATEBASES_SR(processed_short_reads)

    //calculate depth of short reads based on assembly length and short read bases
    ASSEMBLY_DEPTH(QUAST.out.assembly_length, CALCULATEBASES_SR.out, "short_reads")
 
    combined_reports_speccheck = QUAST.out.orireport
       .join(species, failOnDuplicate: true)
       .join(SPECIATION.out.species_report, failOnDuplicate: true)
       .join(CONTAMINATION_CHECKM.out, failOnDuplicate: true)
       .join(ASSEMBLY_DEPTH.out, failOnDuplicate: true)
       .join(SYLPH_FASTQS.out, failOnDuplicate: true)
    
    //run speccheck
    SPECCHECK(combined_reports_speccheck)

    // Collect files from SPECCHECK and give to SPECCHECK_SUMMARY
    sum_detailed = SPECCHECK.out.detailed_report.map({ meta, filepath -> filepath}).collect()
    SPECCHECK_SUMMARY_DETAILED(sum_detailed, "short")
    //to generate simple summary as well
    sum = SPECCHECK.out.report.map({ meta, filepath -> filepath}).collect()
    SPECCHECK_SUMMARY(sum, "short")

}
