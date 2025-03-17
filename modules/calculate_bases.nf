process CALCULATEBASES_SR {
    tag { meta.sample_id }
    label 'process_medium'
    label 'bash_container'

    input:
    tuple val(meta), path(short_reads1), path(short_reads2)


    output:
    tuple val(meta), path(total_bases)

    script:
    total_bases="total_bases.txt"
    """
    R1_total=\$(gunzip -c ${short_reads1} | awk 'NR % 4 == 2 {total += length(\$0)} END {print total}')
    R2_total=\$(gunzip -c ${short_reads2} | awk 'NR % 4 == 2 {total += length(\$0)} END {print total}')
    total_bases=\$((R1_total + R2_total))
    echo \$total_bases > total_bases.txt
    """
}

process CALCULATEBASES_LR {
    tag { meta.sample_id }
    label 'process_medium'
    label 'bash_container'
    
    input:
    tuple val(meta), path(long_reads), val(genome_size)

    output:
    tuple val(meta), path(total_bases)

    script:
    total_bases="total_bases.txt"
    """
    total_bases=\$(gunzip -c ${long_reads} | awk 'NR % 4 == 2 {total += length(\$0)} END {print total}')
    echo \$total_bases > total_bases.txt
    """
}