process QUAST {
    label 'quast_container'

    
    tag "$sample_id"

    publishDir "${params.output}/quast_summary", mode: 'copy', pattern: "*report.tsv"

    input:
    tuple val(sample_id), path(assembly)

    output:
    tuple val(sample_id), path("${sample_id}_report.tsv"), emit: report

    script:
    report="${sample_id}_report.tsv"
    """
    quast.py -o results "$assembly"
    mv results/report.tsv $report
    """
}

process QUAST_SR {
    label 'quast_container'

    
    tag "$sample_id"

    publishDir "${params.output}/shortread_assembly_quast_summary", mode: 'copy', pattern: "*report.tsv"

    input:
    tuple val(sample_id), path(assembly)

    output:
    tuple val(sample_id), path("${sample_id}_report.tsv"), emit: report

    script:
    report="${sample_id}_report.tsv"
    """
    quast.py -o results "$assembly"
    mv results/report.tsv $report
    """
}


process QUAST_LR{
        label 'quast_container'

    
    tag "$sample_id"

    publishDir "${params.output}/longread_assembly_quast_summary", mode: 'copy', pattern: "*report.tsv"

    input:
    tuple val(sample_id), path(assembly)

    output:
    tuple val(sample_id), path("${sample_id}_report.tsv"), emit: report

    script:
    report="${sample_id}_report.tsv"
    """
    quast.py -o results "$assembly"
    mv results/report.tsv $report
    """
}


process QUAST_HY{
        label 'quast_container'

    
    tag "$sample_id"

    publishDir "${params.output}/hybrid_assembly_quast_summary", mode: 'copy', pattern: "*report.tsv"

    input:
    tuple val(sample_id), path(assembly)

    output:
    tuple val(sample_id), path("${sample_id}_report.tsv"), emit: report

    script:
    report="${sample_id}_report.tsv"
    """
    quast.py -o results "$assembly"
    mv results/report.tsv $report
    """

}