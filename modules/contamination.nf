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
