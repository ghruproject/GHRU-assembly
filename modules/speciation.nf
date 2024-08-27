process SPECIATION {

    label 'speciation_container'

    tag { sample_id }

    input:
    tuple val(sample_id), path(fasta_file)

    output:
    tuple val(sample_id), env(species_name)

    script:
    
    """
    python3 /speciator.py ${fasta_file} /libraries /bactinspector/data/taxon_info.pqt > "${sample_id}_speciator_output.json"
    species_name=\$(cat "${sample_id}_speciator_output.json" | jq '.speciesName')
    """
    

}