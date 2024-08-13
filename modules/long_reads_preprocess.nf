process CALCULATE_GENOME_SIZE{
    label 'kmc_container'

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

process NANOPLOT {

    label 'nanoplot_container'

    publishDir "${params.output}/long_read_stats", mode: 'copy', pattern: '*.html'

    tag { sample_id }

    input:
    tuple val(sample_id), path(long_reads), val(genome_size)
    val(assembler_thread)

    output:
    tuple val(sample_id), path("*.html"), emit: html

    script:
    LR="${long_reads}"
    CPU="${assembler_thread}"

    """
    NanoPlot --fastq $LR -t $CPU -o nanoplot_out
    mv nanoplot_out/NanoPlot-report.html ${sample_id}_nanoplot_report.html
    """
}



process PORECHOP{

    label 'porechop_container'

    publishDir "${params.output}/processed_long_reads", mode: 'copy', pattern: '*.fastq.gz'

    tag { sample_id }

    input:
    tuple val(sample_id), path(long_reads), val(genome_size)
    val(assembler_thread)

    output:
    tuple val(sample_id), path(preprocessed_ont), val(genome_size), emit: long_read_assembly
    path(preprocessed_ont), emit: long_reads

    script:
    
    LR="${long_reads}"
    CPU="${assembler_thread}"
    preprocessed_ont="preprocessed-${sample_id}-ont.fastq.gz"
    """
    porechop -i $LR -o $preprocessed_ont -t $CPU
    """

}