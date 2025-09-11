
process ARIBA_CONTAM {
    label 'ariba_container'
    label 'process_low'
    tag { meta.sample_id }

    publishDir "${params.outdir}/ariba_summary", mode: 'copy', pattern: "*.tsv"


    input:
    tuple val(meta), path(short_reads1), path(short_reads2)
    tuple val(species_meta), val(species)
    
    output:
    tuple val(meta), path(ariba_report), emit: report
    tuple val(meta), path(ariba_report_details), emit: details



    script:
    ariba_report="${meta.sample_id}_qc_summary.tsv"
    ariba_report_details="${meta.sample_id}_mlst_report.details.tsv"
    """
    /opt/ariba/run_ariba.py  --output_prefix $meta.sample_id '$species' $short_reads1 $short_reads2  ariba_out
    mv ariba_out/*.tsv . 
    """
}
