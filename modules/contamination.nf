process CHECKM_MARKERS {
    label 'checkm_container'

    tag { sample_id }
    
    input:
    val(genusNAME)

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
    label 'checkm_container'
    label 'process_medium'

    tag { sample_id }

    publishDir "${params.output}/checkm_summary", mode: 'copy', pattern: "*.tsv"

    input:
    tuple val(sample_id), path(fasta)
    path(marker_file)
    val(type)

    output:
    tuple val(sample_id), path(report)

    script:
    fasta="${fasta}"
    marker_file="${marker_file}"
    outdir="checkm_out"
    checkm_qa_out="checkm_qa_out.tsv"
    report="${sample_id}.${type}.tsv"

    """
    checkm analyze $marker_file -x fasta . $outdir
    checkm qa -f $checkm_qa_out -o 2 --tab_table $marker_file $outdir
    mv ${checkm_qa_out} ${report}
    """
}

process GATHER_GUNC_DB {
    label 'gunc_container'

    input:
    path gunc_db

    output: 
    path gunc_db, emit: path

    script:
    gunc_db="${gunc_db}"

    """
    if [ ! -f "${gunc_db}/gunc_db.dmnd" ]; then
        mkdir new_guncDB
        gunc download_db new_guncDB
        new_db_file=\$(ls new_guncDB)
        mv new_guncDB/"\$new_db_file" "$gunc_db"/gunc_db.dmnd
    fi    
    """
}

process CONTAMINATION_GUNC {
    label 'gunc_container'
    label 'process_medium'

    tag { sample_id }

    input:
    tuple val(sample_id), path(fasta)
    path(gunc_db)

    output:
    tuple val(sample_id), path(gunc_scores_file)

    script:
    fasta="${fasta}"
    guncDB="${gunc_db}"
    gunc_out="gunc_out"
    gunc_scores_file="sample_id_scores_file.tsv"

    """
    mkdir $gunc_out
    gunc run -i $fasta -r $guncDB/gunc_db.dmnd --sensitive --detailed_output --use_species_level -o $gunc_out
    scores_file=\$(ls $gunc_out/gunc_output/)
    mv $gunc_out/gunc_output/"\$scores_file" $gunc_scores_file
    """
    
}


process COMBINE_CONTAMINATION_REPORTS{
    label 'gunc_container'

    tag { sample_id }

    input:
    tuple val(sample_id), path(checkm_qa_out)
    tuple val(sample_id), path(gunc_scores_file)

    output:
    tuple val(sample_id), path(contamination_report)

    script:
    gunc_merge_out="gunc_merge_out"
    contamination_report="sample_id_contamination_report.tsv"
    """
    mkdir $gunc_merge_out
    gunc merge_checkm --checkm_file $checkm_qa_out  --gunc_file $gunc_scores_file -o $gunc_merge_out
    final_report=\$(ls $gunc_merge_out)
    mv $gunc_merge_out/"\$final_report" $contamination_report
    """
}