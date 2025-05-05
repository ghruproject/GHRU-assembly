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

process CONFINDR_FASTQS {
    label 'confindr_container'
    label 'process_low'
    tag { meta.sample_id }

    publishDir "${params.outdir}/confindr_summary", mode: 'copy', pattern: "*.csv"


    input:
    tuple val(meta), path(short_reads1), path(short_reads2), val(genome_size)
    path(database_directory)
    val(type)
    tuple val(meta_2), val(slyph_report)
    
    output:
    tuple val(meta), path(confindr_report)

    script:
    confindr_report="${meta.sample_id}_confindr_report.csv"
    """
    do_confindr.py --slyph_report $slyph_report --meta_sample_id $meta.sample_id --type $type --read_one $short_reads1 --read_two $short_reads2 --confindr_out $confindr_report --database_directory $database_directory
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
