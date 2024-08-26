process CHECKM_MARKERS {
    label 'checkm_container'

    tag { sample_id }
    
    input:
    val(genusNAME)

    output:
    path(marker_file)

    script:
    genera="${genusNAME}"
    marker_file="${genusNAME}_markerfile"

    """    
    checkm taxon_set genus $genera $marker_file
    """
}

process CONTAMINATION_CHECKM {
    label 'checkm_container'

    tag { sample_id }

    input:
    tuple val(sample_id), path(fasta)
    path(marker_file)

    output:
    tuple val(sample_id), path(checkm_qa_out)

    script:
    fasta="${fasta}"
    marker_file="${marker_file}"
    outdir="checkm_out"
    checkm_out="${checkm_qa_out}"

    """
    checkm analyze $marker_file -x fasta $fasta $outdir
    checkm qa $outdir > $checkm_out
    """
}

process GUNC_DB {
    label 'gunc_container'

    output: 
    path(guncDB)

    script:
    
    """
    mkdir guncDB
    gunc download_db guncDB
    """
}

process CONTAMINATION_GUNC {
    label 'gunc_container'

    tag { sample_id }

    input:
    tuple val(sample_id), path(fasta)
    path(gunc_db)

    output:
    tuple val(sample_id), path(gunc_out)

    script:
    fasta="${fasta}"
    guncDB="${gunc_db}"
    gunc_out="$gunc_out"

    """
    gunc run -i $fasta -r $guncDB/gunc_db_progenomes2.1dmnd -sensitive -detailed_output -use_species_level species -o $gunc_out
    """
    
}