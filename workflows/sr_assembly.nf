//import modules for the short read only assembly workflow

include { CALCULATE_GENOME_SIZE       } from '../modules/short_reads_preprocess'
include { DETERMINE_MIN_READ_LENGTH   } from '../modules/short_reads_preprocess'
include { TRIMMING                    } from '../modules/short_reads_preprocess'
include { FASTQC                      } from '../modules/short_reads_preprocess'
include { ASSEMBLY_SHOVILL            } from '../modules/short_read_assembly'
include { QUAST                       } from '../modules/quast'
include { SPECIATION                  }  from '../modules/speciation' 
include { CHECKM_MARKERS                 } from '../modules/contamination'
include { CONTAMINATION_CHECKM           } from '../modules/contamination'
include { CONTAMINATION_GUNC             } from '../modules/contamination'
include { COMBINE_CONTAMINATION_REPORTS  } from '../modules/contamination'


workflow SR_ASSEMBLY{

    take:

    //take the short reads read channel from the main
    srt_reads

    //take the guncDB path from main
    //gunc_db

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
    ASSEMBLY_SHOVILL(processed_short_reads, params.min_contig_length, params.assembler_thread, params.assembler_ram)
    
    //assess assembly using quast
    QUAST (ASSEMBLY_SHOVILL.out, "short")

    //speciate with speciator
    SPECIATION(ASSEMBLY_SHOVILL.out, "short")

    //contamination check checkm
    CHECKM_MARKERS(params.genusNAME)
    CONTAMINATION_CHECKM(ASSEMBLY_SHOVILL.out, CHECKM_MARKERS.out, "short")

    //contamination check gunc
    //CONTAMINATION_GUNC(ASSEMBLY_SHOVILL.out, gunc_db)

    //Merge Checkm and Gunc Outputs using gunc-merge
    //COMBINE_CONTAMINATION_REPORTS(CONTAMINATION_CHECKM.out, CONTAMINATION_GUNC.out)

}