process CALCULATE_GENOME_SIZE{
    label 'kmc_cntainer'

     tag { sample_id }

    input:
     tuple val(sample_id), path(long_reads), val(genome_size)

    output:
    tuple val(sample_id), path(long_reads), env(genome_size)

    script:

    """
    LR=$long_reads
    GSIZE=$genome_size 
    source get_genome_size_long.sh
    genome_size=`cat gsize.txt`
    """
}