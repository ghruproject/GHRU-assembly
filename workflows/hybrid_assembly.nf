//import modules
include { TRIMMING                            } from '../modules/short_reads_preprocess'
include { FASTQC                              } from '../modules/short_reads_preprocess'
include { CALCULATE_GENOME_SIZE_LR            } from '../modules/long_reads_preprocess'
include { NANOPLOT                            } from '../modules/long_reads_preprocess'
include { PORECHOP                            } from '../modules/long_reads_preprocess'
include { UNICYCLER                           } from '../modules/hybrid_assemblers'
include { QUAST                               } from '../modules/quast' 
include { SPECIATION                          } from '../modules/speciation' 
include { CONTAMINATION_CHECKM                } from '../modules/contamination'
include { CALCULATEBASES_SR                   } from '../modules/calculate_bases'
include { CALCULATEBASES_LR                   } from '../modules/calculate_bases'
include { ASSEMBLY_DEPTH as ASSEMBLY_DEPTH_SR } from '../modules/assembly_depth'
include { ASSEMBLY_DEPTH as ASSEMBLY_DEPTH_LR } from '../modules/assembly_depth'
include { COMBINE_DEPTH_REPORTS               } from '../modules/assembly_depth'
include { COMBINE_REPORTS                     } from '../modules/combine_reports'
include { SPECCHECK                           } from '../modules/speccheck'
include { SPECCHECK_SUMMARY                   } from '../modules/speccheck'
include { SPECCHECK_SUMMARY_DETAILED          } from '../modules/speccheck'
include { SYLPH_FASTQS                        } from '../modules/contamination'

workflow HY_ASSEMBLY{

    take:
    
    hyb_short
    hyb_long


    //main workflow for hybrid assembly
    main: 

    //qc trimming using trimmomatic
    TRIMMING (hyb_short, params.adapter_file)

    //create channel called processed short reads from trimming out
    processed_short_reads= TRIMMING.out

    //do fastqc for the trimmed reads
    FASTQC(processed_short_reads)
    
    //check inter and intra species contamination using sylph
    SYLPH_FASTQS(processed_short_reads)

    //calculate genome size for long reads if not available
    long_reads_with_genome_size = CALCULATE_GENOME_SIZE_LR(hyb_long)
    
    //qc of long reads using nanoplot
    NANOPLOT(long_reads_with_genome_size)

    //trim adapters using porechop
    PORECHOP(long_reads_with_genome_size)

    //create only long reads channel
    processed_long_reads= PORECHOP.out.long_reads

    //hybrid assembly with unicycler
    UNICYCLER(processed_short_reads, processed_long_reads)

    //run quast for assessing assembly
    QUAST(UNICYCLER.out)

    //speciate with speciator
    SPECIATION(UNICYCLER.out)
    SPECIATION.out.species_name.map { meta, file -> tuple(meta, file.text.trim()) }.set { species }    

    //contamination check checkm
    CONTAMINATION_CHECKM(UNICYCLER.out)
    
    //calculate bases
    CALCULATEBASES_SR(processed_short_reads)

    //calculate bases
    CALCULATEBASES_LR(PORECHOP.out.long_read_assembly)

    //calculate short read depth based on assembly length
    ASSEMBLY_DEPTH_SR (QUAST.out.assembly_length, CALCULATEBASES_SR.out, "short_reads")

    //calculate long read depth based on assembly length
    ASSEMBLY_DEPTH_LR (QUAST.out.assembly_length, CALCULATEBASES_LR.out, "long_reads")

    //combine SR and LR depth reports
    COMBINE_DEPTH_REPORTS(ASSEMBLY_DEPTH_SR.out, ASSEMBLY_DEPTH_LR.out)


    //combine files for speccheck
    combined_reports_speccheck = QUAST.out.orireport
        .join(species, failOnDuplicate: true)
        .join(SPECIATION.out.species_report, failOnDuplicate: true)
        .join(CONTAMINATION_CHECKM.out, failOnDuplicate: true)
        .join(COMBINE_DEPTH_REPORTS.out, failOnDuplicate: true)
        .join(SYLPH_FASTQS.out, failOnDuplicate: true)

    //run speccheck    
    SPECCHECK(combined_reports_speccheck)

    // Collect files from SPECCHECK and give to SPECCHECK_SUMMARY
    sum_detailed = SPECCHECK.out.detailed_report.map({ meta, filepath -> filepath}).collect()
    SPECCHECK_SUMMARY_DETAILED(sum_detailed, "hybrid")

    //to generate simple summary as well
    sum = SPECCHECK.out.detailed_report.map({ meta, filepath -> filepath}).collect()
    SPECCHECK_SUMMARY(sum, "hybrid")

 }