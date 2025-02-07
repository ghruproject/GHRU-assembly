process QUAST {
    tag { meta.sample_id }
    label 'process_single'
    label 'quast_container'
    
    publishDir "${params.outdir}/quast_summary", mode: 'copy', pattern: "*.tsv"

    input:
    tuple val(meta), path(assembly)

    output:
    tuple val(meta), path("${meta.sample_id}.${meta.type}.tsv"), emit: report
    tuple val(meta), env('assembly_length'), emit: assembly_length
    tuple val(meta), path("ori_${meta.sample_id}.${meta.type}.report.tsv"), emit: orireport

    script:
    report="${meta.sample_id}.${meta.type}.tsv"
    orireport="ori_${meta.sample_id}.${meta.type}.report.tsv"
    """
    quast.py -o results "$assembly"
    bash transpose_tsv.sh results/report.tsv > ${report}
    mv results/report.tsv ${orireport}
    assembly_length=\$(awk 'BEGIN {total_bases=0} !/^>/ {total_bases += length(\$0)} END {print total_bases}' ${assembly})
    """
}