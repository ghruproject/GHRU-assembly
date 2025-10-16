process SPECCHECK{
    tag { meta.sample_id }
    label 'process_single'
    label 'speccheck_container'

    publishDir "${params.outdir}/speccheck", mode: 'copy'    
    
    input:
    tuple val(meta), path(quast_report, stageAs: 'quast.report.tsv'), val(species_name), path(species_report, stageAs: 'species.tsv'), path(contamination_report, stageAs: 'contamination.tsv'), path(depth_report, stageAs: 'depth.tsv'), path(sylph_report, stageAs: 'sylph.tsv')

    output:
    tuple val(meta), path("${meta.sample_id}.${meta.type}.csv"), emit: report

    script:
    report="${meta.sample_id}.${meta.type}.csv"
    """
    speccheck collect --sample ${meta.sample_id} --criteria-file /app/criteria.csv --organism "${species_name}" --output-file ${report} *
    """   
}

process SPECCHECK_LR{
    tag { meta.sample_id }
    label 'process_single'
    label 'speccheck_container'
    publishDir "${params.outdir}/speccheck", mode: 'copy'    
    
    input:
    tuple val(meta), path(quast_report, stageAs: 'quast.report.tsv'), val(species_name), path(species_report, stageAs: 'species.tsv'), path(contamination_report, stageAs: 'contamination.tsv'), path(depth_report, stageAs: 'depth.tsv'), path(sylph_report, stageAs: 'sylph.tsv') 

    output:
    tuple val(meta), path("${meta.sample_id}.${meta.type}.csv"), emit: report

    script:
    report="${meta.sample_id}.${meta.type}.csv"
    """
    speccheck collect --sample ${meta.sample_id} --criteria-file /app/criteria.csv --organism "${species_name}" --output-file ${report} *
    """   
}


process SPECCHECK_SUMMARY{
    tag 'QC Summary' 
    label 'process_single'
    label 'speccheck_container'
    
    publishDir "${params.outdir}/qc_summary", mode: 'copy'

    input:
    path(spec_report)
    val(type)

    output:
    path("qc_report.${type}.csv"), emit: report
    path("html.${type}_report"), emit:qc_html

    script:
    """
    speccheck summary ./  --templates /app/templates/report.html --plot
    mv qc_report/report.csv qc_report.${type}.csv
    mv qc_report html.${type}_report
    """   
}