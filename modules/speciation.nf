process SPECIATION {
    tag { meta.sample_id }
    label 'process_single'
    label 'speciation_container'

    publishDir "${params.output}/speciation_summary", mode: 'copy', pattern: '*.tsv'

    input:
    tuple val(meta), path(fasta_file)

    output:
    tuple val(meta), env('species_name'), emit: species_name
    tuple val(meta), path(species_report), emit: species_report

    script:
    species_report="${meta.sample_id}.${meta.type}.tsv"
    
    """
    python3 /speciator.py ${fasta_file} /libraries /bactinspector/data/taxon_info.pqt > "${meta.sample_id}_speciator_output.json"
    species_name=\$(cat "${meta.sample_id}_speciator_output.json" | jq -r '.speciesName')

    # Extract keys (header) and values from JSON
    keys=\$(jq -r 'keys_unsorted | @tsv' "${meta.sample_id}_speciator_output.json")
    values=\$(jq -r '[.[]] | @tsv' "${meta.sample_id}_speciator_output.json")
    
    # Write header and values to the TSV file
    echo -e "Sample_id\t\${keys}" > ${species_report}
    echo -e "${meta.sample_id}\t\${values}" >> ${species_report}
    """
}