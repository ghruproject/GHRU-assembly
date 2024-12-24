//import modules for the short read only assembly workflow

include { CALCULATE_GENOME_SIZE          } from '../modules/short_reads_preprocess'
include { DETERMINE_MIN_READ_LENGTH      } from '../modules/short_reads_preprocess'
include { TRIMMING                       } from '../modules/short_reads_preprocess'
include { FASTQC                         } from '../modules/short_reads_preprocess'
include { ASSEMBLY_SHOVILL               } from '../modules/short_read_assembly'
include { QUAST                          } from '../modules/quast'
include { SPECIATION                     }  from '../modules/speciation' 
include { CHECKM_MARKERS                 } from '../modules/contamination'
include { CONTAMINATION_CHECKM           } from '../modules/contamination'
include { CALCULATEBASES_SR              } from '../modules/calculate_bases'
include { ASSEMBLY_DEPTH                 } from '../modules/assembly_depth'
include { COMBINE_REPORTS                } from '../modules/combine_reports'


workflow SR_ASSEMBLY{

    take:

    //take the short reads read channel from the main
    srt_reads

    //main workflow for short read assembly
    main:
    //calculate genomesize for which it is not available and create a channel for reads with genome size
    reads_with_genome_size = CALCULATE_GENOME_SIZE(srt_reads)

    //determine min read length required for trimming
    DETERMINE_MIN_READ_LENGTH(reads_with_genome_size)

    //qc trimming using trimmomatic
    TRIMMING (reads_with_genome_size, DETERMINE_MIN_READ_LENGTH.out, params.adapter_file)

    //create channel called processed short reads from trimming out
    processed_short_reads= TRIMMING.out

    //do fastqc for the trimmed reads
    FASTQC(processed_short_reads)

    //do assembly using shovill
    ASSEMBLY_SHOVILL(processed_short_reads, params.min_contig_length)
    
    //assess assembly using quast
    QUAST (ASSEMBLY_SHOVILL.out)

    //speciate with speciator
    SPECIATION(ASSEMBLY_SHOVILL.out)

    //contamination check checkm
    CHECKM_MARKERS(SPECIATION.out.species_name)
    CONTAMINATION_CHECKM(ASSEMBLY_SHOVILL.out, CHECKM_MARKERS.out)

    //calculate bases
    CALCULATEBASES_SR(processed_short_reads)

    //calculate depth of short reads based on assembly length and short read bases
    ASSEMBLY_DEPTH(QUAST.out.assembly_length, CALCULATEBASES_SR.out, "short_reads")

    //Consolidate all reports
    COMBINE_REPORTS(QUAST.out.report, SPECIATION.out, CONTAMINATION_CHECKM.out, ASSEMBLY_DEPTH.out)
}