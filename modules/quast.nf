process QUAST {
    label 'quast_container'

    
    tag "$sample_id"

    publishDir "${params.output}/short_read_quast_summary", mode: 'copy'

    input:
    tuple val(sample_id), path(assembly)

    output:
    tuple val(sample_id), path('results/report.tsv'), emit: report

    script:
    """
    quast.py -o results "$assembly"
    """
}