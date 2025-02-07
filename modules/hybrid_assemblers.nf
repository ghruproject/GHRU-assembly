process UNICYCLER{
    tag { meta.sample_id }
    label 'unicycler_container'
    label 'process_high'

    publishDir "${params.outdir}/assemblies", mode: 'copy', pattern: '*.hybrid.fasta'

    input:
    tuple val(meta), path(short_reads1), path(short_reads2), val(genome_size)
    path(long_reads)

    output:
    tuple val(meta), path(fasta)

    script:
    read_one="${short_reads1}"
    read_two="${short_reads2}"
    LR="${long_reads}"
    fasta="${meta.sample_id}.hybrid.fasta"

    """
    unicycler --threads $task.cpus -1 $read_one -2 $read_two -l $LR -o unicycler_out
    mv unicycler_out/assembly.fasta $fasta
    """
}