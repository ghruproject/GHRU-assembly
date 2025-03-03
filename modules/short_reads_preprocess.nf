process DETERMINE_MIN_READ_LENGTH {
    tag { meta.sample_id }
    label 'process_single'
    label 'bash_container'        
    
    input:
    tuple val(meta), path(short_reads1), path(short_reads2)
    
    output:
    path(min_length)

    script:

    read_one="${short_reads1}"
    read_two="${short_reads2}"
    min_length="${meta.sample_id}_min_length.txt"
    """
    gzip -cd ${read_one} | head -n 400000 | printf "%.0f" \$(awk 'NR%4==2{sum+=length(\$0)}END{print sum/(NR/4)/3}') > $min_length
    """
}

process TRIMMING{
    tag { meta.sample_id }
    label 'process_single'
    label 'trimmomatic_container'

    input:
    tuple val(meta), path(short_reads1), path(short_reads2)
    path(min_read_length)
    path(adapter_file)


    output:
    tuple val(meta), path(processed_one), path(processed_two)

    script:
    read_one="${short_reads1}"
    read_two="${short_reads2}"
    processed_one="processed-${meta.sample_id}_1.fastq.gz"
    processed_two="processed-${meta.sample_id}_2.fastq.gz"

    """
    MINSIZE=\$(cat $min_read_length)
    trimmomatic PE -threads $task.cpus -phred33 $read_one $read_two $processed_one /dev/null $processed_two /dev/null ILLUMINACLIP:$adapter_file:2:30:10 SLIDINGWINDOW:4:20 LEADING:25 TRAILING:25 MINLEN:\$MINSIZE  
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

    mv processed-"$meta.sample_id"_1_fastqc.zip "$meta.sample_id"_1.zip
    mv processed-"$meta.sample_id"_1_fastqc.html "$meta.sample_id"_1.html
    mv processed-"$meta.sample_id"_2_fastqc.zip "$meta.sample_id"_2.zip
    mv processed-"$meta.sample_id"_2_fastqc.html "$meta.sample_id"_2.html

    """   
}