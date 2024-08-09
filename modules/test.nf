process TEST {
    input:
    tuple val(sample_id), path(short_reads1), path(short_reads2), val(genome_size)
    
    script:
    """
    echo "$sample_id , $short_reads1 , $short_reads2 , $genome_size"
    """
}