process SPECCHECK{
    tag { meta.sample_id }
    label 'process_single'
    label 'speccheck_container'
    publishDir "${params.outdir}/speccheck", mode: 'copy'    
    
    input:
    tuple val(meta), path(quast_report, stageAs: 'quast.report.tsv')
    tuple val(meta_1), val(species_name)
    tuple val(meta_2), path(species_report, stageAs: 'species.tsv')
    tuple val(meta_3), path(contamination_report, stageAs: 'contamination.tsv')
    tuple val(meta_4), path(depth_report, stageAs: 'depth.tsv') 
    tuple val(meta_5), path(sylph_report, stageAs: 'sylph.tsv') 
    tuple val(meta_6), path(ariba_report, stageAs: 'ariba.tsv') 


    output:
    tuple val(meta), path("${meta.sample_id}.${meta.type}.csv"), emit: report

    script:
    report="${meta.sample_id}.${meta.type}.csv"
    """
    python /app/speccheck.py collect --sample ${meta.sample_id} --criteria-file /app/criteria.csv --organism "${species_name}" --output-file ${report} *
    """   
}

process SPECCHECK_LR{
    tag { meta.sample_id }
    label 'process_single'
    label 'speccheck_container'
    publishDir "${params.outdir}/speccheck", mode: 'copy'    
    
    input:
    tuple val(meta), path(quast_report, stageAs: 'quast.report.tsv')
    tuple val(meta_1), val(species_name)
    tuple val(meta_2), path(species_report, stageAs: 'species.tsv')
    tuple val(meta_3), path(contamination_report, stageAs: 'contamination.tsv')
    tuple val(meta_4), path(depth_report, stageAs: 'depth.tsv') 
    tuple val(meta_5), path(sylph_report, stageAs: 'sylph.tsv') 

    output:
    tuple val(meta), path("${meta.sample_id}.${meta.type}.csv"), emit: report

    script:
    report="${meta.sample_id}.${meta.type}.csv"
    """
    python /app/speccheck.py collect --sample ${meta.sample_id} --criteria-file /app/criteria.csv --organism "${species_name}" --output-file ${report} *
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
    path("qc_report.${type}.html"), emit: html

    script:
    """
    python /app/speccheck.py summary ./  --plot --templates /app/templates/report.html 
    mv yes.html qc_report.${type}.html
    mv qc_report.csv qc_report.${type}.csv
    """   
}