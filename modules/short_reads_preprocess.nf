process CALCULATE_GENOME_SIZE{
    
    label 'kmc_container'
    label 'process_medium'

    tag {sample_id}

    input:
     tuple val(sample_id), path(short_reads1), path(short_reads2), val(genome_size)

    output:
    tuple val(sample_id), path(short_reads1), path(short_reads2), env(genome_size)

    script:
    
    """
    read_one="${short_reads1}"
    read_two="${short_reads2}"
    GSIZE="${genome_size }"
    source get_genome_size.sh
    genome_size=`cat gsize.txt`
    """
}


process DETERMINE_MIN_READ_LENGTH{
    label 'bash_container'
    //label 'process_low'
    
    tag { sample_id }

    input:
    tuple val(sample_id), path(short_reads1), path(short_reads2), val(genome_size)
    
    output:
    env(min_length)

    script:

    read_one="${short_reads1}"
    read_two="${short_reads2}"
    """
    min_length=`gzip -cd ${read_one} | head -n 400000 | printf "%.0f" \$(awk 'NR%4==2{sum+=length(\$0)}END{print sum/(NR/4)/3}')`
    """
}

process TRIMMING{

    label 'trimmomatic_container'

    tag "$sample_id"

    //publishDir "${params.output}/processed_short_reads", mode: 'copy'

    input:
    tuple val(sample_id), path(short_reads1), path(short_reads2), val(genome_size)
    val(min_read_length)
    path('adapter_file.fas')


    output:
    tuple val(sample_id), path(processed_one), path(processed_two), val(genome_size)

    script:
    read_one="${short_reads1}"
    read_two="${short_reads2}"
    processed_one="processed-${sample_id}_1.fastq.gz"
    processed_two="processed-${sample_id}_2.fastq.gz"

    """
    trimmomatic PE -threads $task.cpus -phred33 $read_one $read_two $processed_one /dev/null $processed_two /dev/null ILLUMINACLIP:adapter_file.fas:2:30:10 SLIDINGWINDOW:4:20 LEADING:25 TRAILING:25 MINLEN:${min_read_length}  
    """
}

//Post trimming fastqc
process FASTQC{

    //define container
    label 'fastqc_container'

    tag "$sample_id"

    publishDir "${params.output}/post_trimming_short_read_stats", mode: 'copy'

    input:
    tuple val(sample_id), path(short_reads1), path(short_reads2), val(genome_size)

    output:
    tuple val(sample_id), path("*.html"), emit: html
    tuple val(sample_id), path("*.zip") , emit: zip

    script:
    read_one="${short_reads1}"
    read_two="${short_reads2}"
    """
    fastqc $read_one $read_two

    mv processed-"$sample_id"_1_fastqc.zip "$sample_id"_1.zip
    mv processed-"$sample_id"_1_fastqc.html "$sample_id"_1.html
    mv processed-"$sample_id"_2_fastqc.zip "$sample_id"_2.zip
    mv processed-"$sample_id"_2_fastqc.html "$sample_id"_2.html

    """   
}