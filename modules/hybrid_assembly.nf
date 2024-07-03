process HYBRID_ASSEMBLY {
    tag { sample_name }

    input:
    tuple( val(sample_name), path(short_reads1), path(short_reads2), path(long_reads), val(genome_size) )
    
    script:
    """
    echo "Hybrid assembly for $sample_name"
    echo ${short_reads1}
    echo ${short_reads2}
    echo ${long_reads}
    echo ${genome_size}
    """
}