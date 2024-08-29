process COMBINE_REPORTS{
    tag "$sample_id"

    publishDir "${params.output}/summary", mode: 'copy', pattern: "*.tsv"

    input:
    tuple val(sample_id), path(quast_report, stageAs: 'quast.tsv')
    tuple val(sample_id), val(species_name)
    tuple val(sample_id), path(species_report, stageAs: 'species.tsv')
    tuple val(sample_id), path(contamination_report, stageAs: 'contamination.tsv')
    val(type)

    output:
    tuple val(sample_id), path("${sample_id}.${type}.tsv"), emit: report

    script:
    report="${sample_id}.${type}.tsv"
    """
    # Remove first column from the reports
    cut -f2- quast.tsv > quast_2.tsv
    cut -f2- species.tsv > species_2.tsv
    cut -f2- contamination.tsv > contamination_2.tsv

    head -1 quast_2.tsv | awk 'BEGIN {FS="\t"; OFS="\t"} {for (i=1; i<=NF; i++) \$i = "quast."\$i} 1' > quast_3.tsv
    tail -1 quast_2.tsv >> quast_3.tsv

    head -1 species_2.tsv | awk 'BEGIN {FS="\t"; OFS="\t"} {for (i=1; i<=NF; i++) \$i = "speciator."\$i} 1' > species_3.tsv
    tail -1 species_2.tsv >> species_3.tsv

    head -1 contamination_2.tsv | awk 'BEGIN {FS="\t"; OFS="\t"} {for (i=1; i<=NF; i++) \$i = "checkM."\$i} 1' > contamination_3.tsv
    tail -1 contamination_2.tsv >> contamination_3.tsv

    echo "sample_id\tassembly_type\n"${sample_id}"\t"${type} > info.tsv

    paste info.tsv quast_3.tsv species_3.tsv contamination_3.tsv > ${report}

    rm quast.tsv species.tsv contamination.tsv quast_2.tsv species_2.tsv contamination_2.tsv quast_3.tsv species_3.tsv contamination_3.tsv info.tsv
    """   
}