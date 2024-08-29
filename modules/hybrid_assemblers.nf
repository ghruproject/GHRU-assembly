process UNICYCLER{
    label 'unicycler_container'
    label 'process_high'

    publishDir "${params.output}/assemblies", mode: 'copy', pattern: '*.hybrid.fasta'

    tag { sample_id }

    input:
    tuple val(sample_id), path(short_reads1), path(short_reads2), val(genome_size)
    path(long_reads)
    val(assembler_thread)

    output:
    tuple val(sample_id), path(fasta)

    script:
    read_one="${short_reads1}"
    read_two="${short_reads2}"
    LR="${long_reads}"
    CPU="${assembler_thread}"
    fasta="${sample_id}.hybrid.fasta"

    """
    unicycler --threads $task.cpus -1 $read_one -2 $read_two -l $LR -o unicycler_out
    mv unicycler_out/assembly.fasta $fasta
    """
}