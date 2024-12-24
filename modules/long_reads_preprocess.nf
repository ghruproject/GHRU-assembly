process CALCULATE_GENOME_SIZE{
    tag { meta.sample_id }    
    label 'process_medium'
    label 'kmc_container'

    input:
    tuple val(meta), path(long_reads)

    output:
    tuple val(meta), path(long_reads), env('genome_size')

    script:

    """
    LR=$long_reads
    GSIZE=$meta.genome_size 
    source get_genome_size_long.sh
    genome_size=`cat gsize.txt`
    """
}

process NANOPLOT {
    tag { meta.sample_id }
    label 'process_low'
    label 'nanoplot_container'

    publishDir "${params.outdir}/long_read_stats", mode: 'copy', pattern: '*.html'

    input:
    tuple val(meta), path(long_reads), val(genome_size)

    output:
    tuple val(meta), path("*.html"), emit: html

    script:
    LR="${long_reads}"

    """
    NanoPlot --fastq $LR -t $task.cpus -o nanoplot_out --no_static
    mv nanoplot_out/NanoPlot-report.html ${meta.sample_id}_nanoplot_report.html
    """
}



process PORECHOP{
    tag { meta.sample_id }
    label 'process_high'    
    label 'porechop_container'

    input:
    tuple val(meta), path(long_reads), val(genome_size)

    output:
    tuple val(meta), path(preprocessed_ont), val(genome_size), emit: long_read_assembly
    path(preprocessed_ont), emit: long_reads

    script:
    
    LR="${long_reads}"
    preprocessed_ont="preprocessed-${meta.sample_id}-ont.fastq.gz"

    """
    porechop -i $LR -o $preprocessed_ont -t $task.cpus
    """

}