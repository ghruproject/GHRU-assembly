process SPECIATION {

    label 'speciation_container'

    publishDir "${params.output}/speciation_out", mode: 'copy', pattern: '*.tsv'

    tag { sample_id }

    input:
    tuple val(sample_id), path(fasta_file)

    output:
    tuple val(sample_id), env(species_name), emit: species_name
    tuple val(sample_id), path(species_report), emit: species_report

    script:
    species_report="${sample_id}_species_report.tsv"
    
    """
    python3 /speciator.py ${fasta_file} /libraries /bactinspector/data/taxon_info.pqt > "${sample_id}_speciator_output.json"
    species_name=\$(cat "${sample_id}_speciator_output.json" | jq -r '.speciesName')

    # write to report
    echo "Sample_id\tSpecies" > ${species_report}
    echo "${sample_id}\t\${species_name}" >> ${species_report}
    """
}