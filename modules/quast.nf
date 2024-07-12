process QUAST_SR {
    label 'quast_container'

    
    tag "$sample_id"

    publishDir "${params.output}/shortread_assembly_quast_summary", mode: 'copy'

    input:
    tuple val(sample_id), path(assembly)

    output:
    tuple val(sample_id), path('results/report.tsv'), emit: report

    script:
    """
    quast.py -o results "$assembly"
    """
}


process QUAST_LR{
        label 'quast_container'

    
    tag "$sample_id"

    publishDir "${params.output}/longread_assembly_quast_summary", mode: 'copy'

    input:
    tuple val(sample_id), path(assembly)

    output:
    tuple val(sample_id), path('results/report.tsv'), emit: report

    script:
    """
    quast.py -o results "$assembly"
    """

}


process QUAST_HY{
        label 'quast_container'

    
    tag "$sample_id"

    publishDir "${params.output}/hybrid_assembly_quast_summary", mode: 'copy'

    input:
    tuple val(sample_id), path(assembly)

    output:
    tuple val(sample_id), path('results/report.tsv'), emit: report

    script:
    """
    quast.py -o results "$assembly"
    """

}