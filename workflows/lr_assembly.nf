//import modules
include { CALCULATE_GENOME_SIZE_LR       }  from '../modules/long_reads_preprocess'
include { NANOPLOT                       }  from '../modules/long_reads_preprocess'
include { PORECHOP                       }  from '../modules/long_reads_preprocess'
include { ASSEMBLY_DRAGONFLYE            }  from '../modules/long_read_assembly'
include { QUAST                          }  from '../modules/quast'
include { SPECIATION                     }  from '../modules/speciation' 
include { CHECKM_MARKERS                 }  from '../modules/contamination'
include { CONTAMINATION_CHECKM           }  from '../modules/contamination'
include { CALCULATEBASES_LR              }  from '../modules/calculate_bases'
include { ASSEMBLY_DEPTH                 }  from '../modules/assembly_depth'
include { COMBINE_REPORTS                }  from '../modules/combine_reports'
include { SPECCHECK                      } from '../modules/speccheck'
include { SPECCHECK_SUMMARY              } from '../modules/speccheck'
include { CONFINDR_FASTQS                } from '../modules/contamination'
include { SYLPH_FASTQS                   } from '../modules/contamination'


workflow LR_ASSEMBLY{

    take:

    //take the long reads read channel from the main
    lng_reads
    
    //main workflow for long read assembly
    main:

    //calculate genomesize for which it is not available and create a channel for reads with genome size
    read_with_genome_size = CALCULATE_GENOME_SIZE_LR(lng_reads)

    //do nanoplot of the long reads
    NANOPLOT(read_with_genome_size)

    //trim adapters with porechop
    PORECHOP(read_with_genome_size)
    
    //processed_long_read assembly channel
    preprocessed_long_reads=PORECHOP.out.long_read_assembly
    SYLPH_FASTQS(preprocessed_long_reads)

    // CONFINDR_FASTQS(preprocessed_long_reads, "Nanopore", SYLPH_FASTQS.out)

    //do long read assembly with dragonflye
    ASSEMBLY_DRAGONFLYE(preprocessed_long_reads, params.medaka_model)

    //assess assembly using quast
    QUAST(ASSEMBLY_DRAGONFLYE.out)

    //speciate with speciator
    SPECIATION(ASSEMBLY_DRAGONFLYE.out)
    
   //contamination check checkm
    CHECKM_MARKERS(SPECIATION.out.species_name)
    CONTAMINATION_CHECKM(ASSEMBLY_DRAGONFLYE.out, CHECKM_MARKERS.out)
    
    //calculate bases
    CALCULATEBASES_LR(preprocessed_long_reads)

    //calculate long read depth based on LR assembly length and LR bases
    ASSEMBLY_DEPTH(QUAST.out.assembly_length,CALCULATEBASES_LR.out, "long_reads")

    //Consolidate all reports
    COMBINE_REPORTS(QUAST.out.report, SPECIATION.out, CONTAMINATION_CHECKM.out, ASSEMBLY_DEPTH.out)

    SPECCHECK(QUAST.out.orireport, SPECIATION.out, CONTAMINATION_CHECKM.out)

    // Collect files from SPECCHECK and give to SPECCHECK_SUMMARY
    sum = SPECCHECK.out.report.map({ meta, filepath -> filepath}).collect()
    SPECCHECK_SUMMARY(sum, "long")


}
