//import modules
include { CALCULATE_GENOME_SIZE       } from '../modules/short_reads_preprocess'
include { DETERMINE_MIN_READ_LENGTH   } from '../modules/short_reads_preprocess'
include { TRIMMING                    } from '../modules/short_reads_preprocess'
include { FASTQC                      } from '../modules/short_reads_preprocess'
include { NANOPLOT                    }  from '../modules/long_reads_preprocess'
include { PORECHOP                    }  from '../modules/long_reads_preprocess'
include { UNICYCLER                   }  from '../modules/hybrid_assemblers'
include { QUAST_HY                    }  from '../modules/quast' 
include { SPECIATION                  }  from '../modules/speciation' 


workflow HY_ASSEMBLY{

    take:
    
    //take short reads from hybrid channel
    hyb_srt_reads

    //take long reads from hybrid channel
    hyb_lng_reads


    //main workflow for hybrid assembly
    main: 

    //calculate genomesize for which it is not available and create a channel for reads with genome size
    reads_with_genome_size = CALCULATE_GENOME_SIZE(hyb_srt_reads)

    //determine min read length required for trimming
    DETERMINE_MIN_READ_LENGTH(reads_with_genome_size)

    //qc trimming using trimmomatic
    TRIMMING (reads_with_genome_size, DETERMINE_MIN_READ_LENGTH.out, params.adapter_file)

    //create channel called processed short reads from trimming out
    processed_short_reads= TRIMMING.out

    //do fastqc for the trimmed reads
    FASTQC(processed_short_reads)

    //qc of long reads using nanoplot
    NANOPLOT(hyb_lng_reads, params.assembler_thread)

    //trim adapters using porechop
    PORECHOP(hyb_lng_reads, params.assembler_thread)

    //create only long reads channel
    processed_long_reads= PORECHOP.out.long_reads

    //hybrid assembly with unicycler
    UNICYCLER(processed_short_reads, processed_long_reads, params.assembler_thread)

    QUAST_HY(UNICYCLER.out)

    //speciate with speciator
    SPECIATION(UNICYCLER.out)
 }