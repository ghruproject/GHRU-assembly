// Return sample_id and assembly, and publish the assembly to ${params.output}/assemblies directory based on ${params.assembly_publish}
process ASSEMBLY_SHOVILL {
    label 'shovill_container'
    label 'process_medium'
 
    errorStrategy 'ignore'

    tag "$sample_id"

    publishDir "${params.output}/assemblies", mode: 'copy', pattern: '*.short.fasta'

    input:
    tuple val(sample_id), path(short_reads1), path(short_reads2), val(genome_size)
    val min_contig_length
    val assembler_thread
    val assembler_ram

    output:
    tuple val(sample_id), path(fasta)

    script:
    fasta="${sample_id}.short.fasta"
    """  
    shovill --R1 $short_reads1 --R2 $short_reads2 --outdir results --cpus $task.cpus --ram $task.memory --minlen $min_contig_length --force
    mv results/contigs.fa $fasta
    """
}

//add any other tools if needed
//any other tools can be  incorporated