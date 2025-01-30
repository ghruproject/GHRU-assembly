//import modules
include { CALCULATE_GENOME_SIZE_SR            } from '../modules/short_reads_preprocess'
include { DETERMINE_MIN_READ_LENGTH           } from '../modules/short_reads_preprocess'
include { TRIMMING                            } from '../modules/short_reads_preprocess'
include { FASTQC                              } from '../modules/short_reads_preprocess'
include { CALCULATE_GENOME_SIZE_LR            } from '../modules/long_reads_preprocess'
include { NANOPLOT                            } from '../modules/long_reads_preprocess'
include { PORECHOP                            } from '../modules/long_reads_preprocess'
include { UNICYCLER                           } from '../modules/hybrid_assemblers'
include { QUAST                               } from '../modules/quast' 
include { SPECIATION                          } from '../modules/speciation' 
include { CHECKM_MARKERS                      } from '../modules/contamination'
include { CONTAMINATION_CHECKM                } from '../modules/contamination'
include { CALCULATEBASES_SR                   } from '../modules/calculate_bases'
include { CALCULATEBASES_LR                   } from '../modules/calculate_bases'
include { ASSEMBLY_DEPTH as ASSEMBLY_DEPTH_SR } from '../modules/assembly_depth'
include { ASSEMBLY_DEPTH as ASSEMBLY_DEPTH_LR } from '../modules/assembly_depth'
include { COMBINE_DEPTH_REPORTS               } from '../modules/assembly_depth'
include { COMBINE_REPORTS                     } from '../modules/combine_reports'
include { resolveRelativePath                 } from '../modules/messages'
include { SPECCHECK                           } from '../modules/speccheck'
include { SPECCHECK_SUMMARY                   } from '../modules/speccheck'
include { CONFINDR_FASTQS                     } from '../modules/contamination'
include { SYLPH_FASTQS                        } from '../modules/contamination'
include { ARIBA_CONTAM                        } from '../modules/ariba'

workflow HY_ASSEMBLY{

    take:
    
    hyb_short
    hyb_long


    //main workflow for hybrid assembly
    main: 

    //calculate genomesize for which it is not available and create a channel for reads with genome size
    reads_with_genome_size = CALCULATE_GENOME_SIZE_SR(hyb_short)

    //determine min read length required for trimming
    DETERMINE_MIN_READ_LENGTH(reads_with_genome_size)

    //qc trimming using trimmomatic
    def adapter_yes_file = resolveRelativePath(projectDir, params.adapter_file)
    TRIMMING (reads_with_genome_size, DETERMINE_MIN_READ_LENGTH.out, params.adapter_file)

    //create channel called processed short reads from trimming out
    processed_short_reads= TRIMMING.out

    //do fastqc for the trimmed reads
    FASTQC(processed_short_reads)
    
    SYLPH_FASTQS(processed_short_reads)
    // CONFINDR_FASTQS(processed_short_reads, params.database_directory, "Illumina", SYLPH_FASTQS.out)


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
    ARIBA_CONTAM(processed_short_reads, SPECIATION.out.species_name)

    //contamination check checkm
    CHECKM_MARKERS(SPECIATION.out.species_name)
    CONTAMINATION_CHECKM(UNICYCLER.out, CHECKM_MARKERS.out)
    
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
 
    //Consolidate all reports
    COMBINE_REPORTS(QUAST.out.report, SPECIATION.out.species_report, CONTAMINATION_CHECKM.out, COMBINE_DEPTH_REPORTS.out, SYLPH_FASTQS.out, ARIBA_CONTAM.out.report)

    SPECCHECK(QUAST.out.orireport, SPECIATION.out.species_name, SPECIATION.out.species_report, CONTAMINATION_CHECKM.out, COMBINE_DEPTH_REPORTS.out, SYLPH_FASTQS.out, ARIBA_CONTAM.out.details)


    // Collect files from SPECCHECK and give to SPECCHECK_SUMMARY
    sum = SPECCHECK.out.report.map({ meta, filepath -> filepath}).collect()
    SPECCHECK_SUMMARY(sum, "hybrid")
 }