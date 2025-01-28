process SPECCHECK{
    tag { meta.sample_id }
    label 'process_single'
    label 'speccheck_container'
    
    input:
    tuple val(meta), path(quast_report, stageAs: 'quast.report.tsv')
    tuple val(meta_1), val(species_name)
    tuple val(meta_2), path(species_report, stageAs: 'species.tsv')
    tuple val(meta_3), path(contamination_report, stageAs: 'contamination.tsv')
    tuple val(meta_4), path(confindr_report, stageAs: 'confindr.tsv')

    output:
    tuple val(meta), path("${meta.sample_id}.${meta.type}.csv"), emit: report

    script:
    report="${meta.sample_id}.${meta.type}.csv"
    """
    python /app/speccheck.py collect --sample ${meta.sample_id} --criteria-file /app/criteria.csv --organism "${species_name}" --output-file ${report} *
    """   
}

process SPECCHECK_SUMMARY{
    tag { meta.sample_id }
    label 'process_single'
    label 'speccheck_container'
    
    publishDir "${params.outdir}/qc_summary", mode: 'copy', pattern: "*.csv"

    input:
    tuple val(meta), path(spec_report)

    output:
    tuple val(meta), path("qc_report.${meta.type}.csv"), emit: report

    script:
    """
    python /app/speccheck.py summary ./ 
    mv qc_report.csv qc_report.${meta.type}.csv
    """   
}