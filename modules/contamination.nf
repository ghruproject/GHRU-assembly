process CONTAMINATION_CHECKM {
    tag { meta.sample_id }
    // label 'process_high'
    label 'process_medium'
    // label 'process_high_memory'
    label 'checkm_container'

    publishDir "${params.outdir}/checkm_summary", mode: 'copy', pattern: "*.tsv"

    input:
    tuple val(meta), path(fasta)

    output:
    tuple val(meta), path(report)

    script:
    fasta="${fasta}"
    outdir="checkm_out"
    report="${meta.sample_id}.${meta.type}.tsv"

    """
    checkm2 predict -i . -o ${outdir} -x fasta --force -t $task.cpus 
    mv ${outdir}/quality_report.tsv ${report}
    """
}


process SYLPH_FASTQS {
    label 'sylph_container'
    label 'process_low'
    tag { meta.sample_id }

    publishDir "${params.outdir}/sylph_summary", mode: 'copy', pattern: "*.tsv"


    input:
    tuple val(meta), path(short_reads1), path(short_reads2)
    
    output:
    tuple val(meta), path(slyph_report)

    script:
    slyph_report="${meta.sample_id}_slyph_report.tsv"

    """
    sylph profile /opt/sylph/gtdb-r220-c1000-dbv1.syldb -1 $short_reads1 -2 $short_reads2 > $slyph_report
    """
}


process SYLPH_FASTQS_LR {
    label 'sylph_container'
    label 'process_low'
    tag { meta.sample_id }

    publishDir "${params.outdir}/sylph_summary", mode: 'copy', pattern: "*.tsv"


    input:
    tuple val(meta), path(long_reads), val(genome_size)
    
    output:
    tuple val(meta), path(slyph_report)

    script:
    slyph_report="${meta.sample_id}_slyph_report.tsv"

    """
    sylph profile /opt/sylph/gtdb-r220-c1000-dbv1.syldb $long_reads  > $slyph_report
    """
}
