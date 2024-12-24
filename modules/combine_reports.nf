process COMBINE_REPORTS{
    tag { meta.sample_id }
    label 'process_single'
    label 'bash_container'
    
    publishDir "${params.outdir}/summary", mode: 'copy', pattern: "*.tsv"

    input:
    tuple val(meta), path(quast_report, stageAs: 'quast.tsv')
    tuple val(meta_1), val(species_name)
    tuple val(meta_2), path(species_report, stageAs: 'species.tsv')
    tuple val(meta_3), path(contamination_report, stageAs: 'contamination.tsv')
    tuple val(meta_4), path(depth_report, stageAs: 'depth.tsv') 

    output:
    tuple val(meta.sample_id), path("${meta.sample_id}.${meta.type}.tsv"), emit: report

    script:
    report="${meta.sample_id}.${meta.type}.tsv"
    """
    # Remove first column from the reports
    cut -f2- quast.tsv > quast_2.tsv
    cut -f2- species.tsv > species_2.tsv
    cut -f2- contamination.tsv > contamination_2.tsv
    cut -f2- depth.tsv > depth_2.tsv 

    head -1 quast_2.tsv | awk 'BEGIN {FS="\t"; OFS="\t"} {for (i=1; i<=NF; i++) \$i = "quast."\$i} 1' > quast_3.tsv
    tail -1 quast_2.tsv >> quast_3.tsv

    head -1 species_2.tsv | awk 'BEGIN {FS="\t"; OFS="\t"} {for (i=1; i<=NF; i++) \$i = "speciator."\$i} 1' > species_3.tsv
    tail -1 species_2.tsv >> species_3.tsv

    head -1 contamination_2.tsv | awk 'BEGIN {FS="\t"; OFS="\t"} {for (i=1; i<=NF; i++) \$i = "checkM."\$i} 1' > contamination_3.tsv
    tail -1 contamination_2.tsv >> contamination_3.tsv

    head -1 depth_2.tsv | awk 'BEGIN {FS="\t"; OFS="\t"} {for (i=1; i<=NF; i++) \$i = "depth_calc."\$i} 1' > depth_3.tsv
    tail -1 depth_2.tsv >> depth_3.tsv

    echo "sample_id\tassembly_type\n"${meta.sample_id}"\t"${meta.type} > info.tsv

    paste info.tsv quast_3.tsv species_3.tsv contamination_3.tsv depth_3.tsv > ${report}

    rm quast.tsv species.tsv contamination.tsv quast_2.tsv species_2.tsv contamination_2.tsv quast_3.tsv species_3.tsv contamination_3.tsv depth.tsv depth_2.tsv depth_3.tsv info.tsv
    """   
}