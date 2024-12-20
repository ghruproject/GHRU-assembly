process CALCULATEBASES_SR {

    label 'bash_container'
    label 'process_medium'


    input:
    tuple val(sample_id), path(short_reads1), path(short_reads2), val(genome_size)


    output:
    tuple val(sample_id), env(total_bases)

    script:
    """
    R1_total=\$(gunzip -c ${short_reads1} | awk 'NR % 4 == 2 {total += length(\$0)} END {print total}')
    R2_total=\$(gunzip -c ${short_reads2} | awk 'NR % 4 == 2 {total += length(\$0)} END {print total}')
    total_bases=\$((R1_total + R2_total))
    """
}

process CALCULATEBASES_LR {

    label 'bash_container'
    label 'process_medium'

    
    input:
    tuple val(sample_id), path(long_reads), val(genome_size)

    output:
     tuple val(sample_id), env(total_bases)

    script:
    """
    total_bases=\$(gunzip -c ${long_reads} | awk 'NR % 4 == 2 {total += length(\$0)} END {print total}')
    """
}