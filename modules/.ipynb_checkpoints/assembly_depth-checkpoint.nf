process ASSEMBLY_DEPTH {

    label 'bash_container'
    
    tag "$sample_id"

    input:
    tuple val(sample_id), val(type), val(assembly_length)
    tuple val(sample_id), val(total_bases)

    output:
    tuple val(sample_id), path("${sample_id}.${type}.depth.tsv"), emit: report

    script:
    depth_report="${sample_id}.${type}.depth.tsv"
    """
    depth=\$(echo "scale=2; ${total_bases} / ${assembly_length}" | bc)

    #Write header and values to the TSV file
    echo -e "Sample_id\tRead_type\tDepth" > ${depth_report}
    echo -e "${sample_id}\t${type}\t\${depth}" >> ${depth_report}    
    """
}