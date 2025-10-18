process ASSEMBLY_DEPTH {
    tag { meta.sample_id }
    label 'process_medium'
    label 'bash_container'

    input:
    tuple val(meta), val(assembly_length)
    tuple val(meta_again), path(total_bases)
    val(read_type)

    output:
    tuple val(meta), path("${meta.sample_id}.${meta.type}${read_type}.depth.tsv"), emit: report

    script:
    depth_report="${meta.sample_id}.${meta.type}${read_type}.depth.tsv"
    """
    TOTAL_BASES=\$(cat $total_bases)
    depth=\$(echo "scale=2; \$TOTAL_BASES / ${assembly_length}" | bc)

    #Write header and values to the TSV file
    echo -e "Sample_id\tRead_type\tDepth" > ${depth_report}
    echo -e "${meta.sample_id}\t${meta.type}\t\${depth}" >> ${depth_report}    
    """
}

// Process to combine the outputs
process COMBINE_DEPTH_REPORTS {
    tag { meta.sample_id }    
    label 'bash_container'
    label 'process_medium'

    input:
    tuple val(meta), path(sr_depth_reports)
    tuple val(meta_again), path(lr_depth_reports)

    output:
    tuple val(meta), path("${meta.sample_id}.hybrid.depth.tsv"), emit: combined_report

    script:
    depth_report="${meta.sample_id}.hybrid.depth.tsv"
    """
    # Create header for combined report
    echo -e "Sample_id\tRead_type\tDepth" > ${depth_report}

    # Add short-read depth
    awk 'NR>1 {print \$1"\\tShort\\t"\$3}' ${sr_depth_reports} >> ${depth_report}

    # Add long-read depth
    awk 'NR>1 {print \$1"\\tLong\\t"\$3}' ${lr_depth_reports} >> ${depth_report}
    """
}