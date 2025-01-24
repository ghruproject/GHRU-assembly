process SPECIATION {

    label 'speciation_container'
    label 'process_medium'

    publishDir "${params.output}/speciation_summary", mode: 'copy', pattern: '*.tsv'

    tag { sample_id }

    input:
    tuple val(sample_id), path(fasta_file)
    val(type)

    output:
    tuple val(sample_id), env(species_name), emit: species_name
    tuple val(sample_id), path(species_report), emit: species_report

    script:
    species_report="${sample_id}.${type}.tsv"
    
    """
    python3 /speciator.py ${fasta_file} /libraries /bactinspector/data/taxon_info.pqt > "${sample_id}_speciator_output.json"
    species_name=\$(cat "${sample_id}_speciator_output.json" | jq -r '.speciesName')

    # Extract keys (header) and values from JSON
    keys=\$(jq -r 'keys_unsorted | @tsv' "${sample_id}_speciator_output.json")
    values=\$(jq -r '[.[]] | @tsv' "${sample_id}_speciator_output.json")
    
    # Write header and values to the TSV file
    echo -e "Sample_id\t\${keys}" > ${species_report}
    echo -e "${sample_id}\t\${values}" >> ${species_report}
    """
}