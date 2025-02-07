process ASSEMBLY_DEPTH {
    tag { meta.sample_id }
    label 'process_medium'
    label 'bash_container'

    input:
    tuple val(meta), val(assembly_length)
    tuple val(meta_again), val(total_bases)
    val(read_type)

    output:
    tuple val(meta), path("${meta.sample_id}.${meta.type}${read_type}.depth.tsv"), emit: report

    script:
    depth_report="${meta.sample_id}.${meta.type}${read_type}.depth.tsv"
    """
    depth=\$(echo "scale=2; ${total_bases} / ${assembly_length}" | bc)

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
    tuple val(meta), path ("combined_depth_report.tsv")

    script:
    """
    # Create header for combined report
    echo -e "Sample_id\tShort_read_Depth\tLong_read_Depth" > combined_depth_report.tsv

    # Read SR and LR depths and combine into a single line per sample
    paste <(cut -f1,3 ${sr_depth_reports} | tail -n +2) \
          <(cut -f3 ${lr_depth_reports} | tail -n +2) >> combined_depth_report.tsv
    """
}