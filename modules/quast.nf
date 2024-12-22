process QUAST {
    
    label 'quast_container'
    
    tag "$sample_id"

    publishDir "${params.output}/quast_summary", mode: 'copy', pattern: "*.tsv"

    input:
    tuple val(sample_id), path(assembly)
    val(type)

    output:
    tuple val(sample_id), path("${sample_id}.${type}.tsv"), emit: report
    tuple val(sample_id), val(type), env(assembly_length), emit: assembly_length

    script:
    report="${sample_id}.${type}.tsv"
    """
    quast.py -o results "$assembly"
    bash transpose_tsv.sh results/report.tsv > ${report}

    assembly_length=\$(awk 'BEGIN {total_bases=0} !/^>/ {total_bases += length(\$0)} END {print total_bases}' ${assembly})
    """
}