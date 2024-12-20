process ASSEMBLY_DEPTH {

    label 'bash_container'
    label 'process_medium'
    
    tag "$sample_id"

    input:
    tuple val(sample_id), val(type), val(assembly_length)
    tuple val(sample_id), val(total_bases)
    val(read_type)
    output:
    tuple val(sample_id), path("${sample_id}.${type}${read_type}.depth.tsv"), emit: report

    script:
    depth_report="${sample_id}.${type}${read_type}.depth.tsv"
    """
    depth=\$(echo "scale=2; ${total_bases} / ${assembly_length}" | bc)

    #Write header and values to the TSV file
    echo -e "Sample_id\tRead_type\tDepth" > ${depth_report}
    echo -e "${sample_id}\t${type}\t\${depth}" >> ${depth_report}    
    """
}

// Process to combine the outputs
process COMBINE_DEPTH_REPORTS {
    
    label 'bash_container'
    label 'process_medium'

    input:
    tuple val(sample_id), path(sr_depth_reports)
    tuple val(sample_id), path(lr_depth_reports)

    output:
    tuple val(sample_id), path ("combined_depth_report.tsv")

    script:
    """
    # Create header for combined report
    echo -e "Sample_id\tShort_read_Depth\tLong_read_Depth" > combined_depth_report.tsv

    # Read SR and LR depths and combine into a single line per sample
    paste <(cut -f1,3 ${sr_depth_reports} | tail -n +2) \
          <(cut -f3 ${lr_depth_reports} | tail -n +2) >> combined_depth_report.tsv
    """
}