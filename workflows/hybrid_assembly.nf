//import modules
include { CALCULATE_GENOME_SIZE       } from '../modules/short_reads_preprocess'
include { DETERMINE_MIN_READ_LENGTH   } from '../modules/short_reads_preprocess'
include { TRIMMING                    } from '../modules/short_reads_preprocess'
include { FASTQC                      } from '../modules/short_reads_preprocess'
include { NANOPLOT                    }  from '../modules/long_reads_preprocess'
include { PORECHOP                    }  from '../modules/long_reads_preprocess'
include { UNICYCLER                   }  from '../modules/hybrid_assemblers'
include { QUAST_HY                    }  from '../modules/quast' 

 workflow HY_ASSEMBLY{
    Channel
        .fromPath( params.samplesheet )
        .splitCsv( header: true, sep: ',' )
        .branch { row ->
            srt: row.long_reads == "" && row.short_reads1 != "" && row.short_reads2 != ""
            lng: row.long_reads != "" && row.short_reads1 == "" && row.short_reads2 == ""
            hyb: row.long_reads != "" && row.short_reads1 != "" && row.short_reads2 != ""
        }
        .set { assembly }
    
    // Feeds short-read read channel
    assembly.hyb
    .map { row -> tuple(row.sample_id, row.short_reads1, row.short_reads2, row.genome_size) }
    .set { hyb_srt_reads }
    
    // Feeds long-read read channel
    assembly.hyb
    .map { row -> tuple(row.sample_id, row.long_reads, row.genome_size) }
    .set { hyb_lng_reads }

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










 }