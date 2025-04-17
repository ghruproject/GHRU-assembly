process TRIMMING{
    tag { meta.sample_id }
    label 'process_medium'
    label 'trimmomatic_container'

    publishDir "${params.outdir}", mode: 'copy', pattern: 'trimmed_fastqs/*.fastq.gz'

    input:
    tuple val(meta), path(short_reads1), path(short_reads2)
    //path(min_read_length)
    path(adapter_file)


    output:
    tuple val(meta), path("trimmed_fastqs/${processed_one}"), path("trimmed_fastqs/${processed_two}")

    script:
    read_one="${short_reads1}"
    read_two="${short_reads2}"
    processed_one="${meta.sample_id}_1.fastq.gz"
    processed_two="${meta.sample_id}_2.fastq.gz"

    """
    echo "$adapter_file"
    cp $adapter_file adapter_file.fas
    mkdir trimmed_fastqs
    trimmomatic PE -threads $task.cpus -phred33 $read_one $read_two trimmed_fastqs/${processed_one} /dev/null trimmed_fastqs/${processed_two} /dev/null ILLUMINACLIP:adapter_file.fas:2:30:10 SLIDINGWINDOW:4:20 LEADING:25 TRAILING:25 MINLEN:50  
    """
}

//Post trimming fastqc
process FASTQC{
    tag { meta.sample_id }
    label 'process_single'
    label 'fastqc_container'

    publishDir "${params.outdir}/post_trimming_short_read_stats", mode: 'copy'

    input:
    tuple val(meta), path(short_reads1), path(short_reads2)

    output:
    tuple val(meta), path("*.html"), emit: html
    tuple val(meta), path("*.zip") , emit: zip

    script:
    read_one="${short_reads1}"
    read_two="${short_reads2}"
    """
    fastqc $read_one $read_two

    """   
}