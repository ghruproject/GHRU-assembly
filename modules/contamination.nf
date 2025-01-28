process CHECKM_MARKERS {
    tag { meta.sample_id }
    label 'process_low'
    label 'checkm_container'
    
    input:
    tuple val(meta), val(genusNAME)

    output:
    path(marker_file)

    script:
    genera="${genusNAME}"
    marker_file="checkm_markerfile"

    """    
    checkm taxon_set species "$genera" $marker_file
    """
}

process CONTAMINATION_CHECKM {
    tag { meta.sample_id }
    label 'process_medium'
    label 'checkm_container'

    publishDir "${params.outdir}/checkm_summary", mode: 'copy', pattern: "*.tsv"

    input:
    tuple val(meta), path(fasta)
    path(marker_file)

    output:
    tuple val(meta), path(report)

    script:
    fasta="${fasta}"
    marker_file="${marker_file}"
    outdir="checkm_out"
    checkm_qa_out="checkm_qa_out.tsv"
    report="${meta.sample_id}.${meta.type}.tsv"

    """
    checkm analyze $marker_file -x fasta . $outdir
    checkm qa -f $checkm_qa_out -o 2 --tab_table $marker_file $outdir
    mv ${checkm_qa_out} ${report}
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

    publishDir "${params.outdir}/sylph_summary", mode: 'copy', pattern: "*.csv"


    input:
    tuple val(meta), path(short_reads1), path(short_reads2), val(genome_size)
    path(database_directory)
    
    output:
    tuple val(meta), path(slyph_report)

    script:
    slyph_report="${meta.sample_id}_slyph_report.csv"

    """
    sylph profile $database_directory/gtdb-r220-c1000-dbv1.syldb -1 $short_reads1 -2 $short_reads2 > $slyph_report
    """
}
