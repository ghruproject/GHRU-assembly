// Return sample_id and assembly, and publish the assembly to ${params.output}/assemblies directory based on ${params.assembly_publish}
process ASSEMBLY_SHOVILL {
    tag { meta.sample_id }
    label 'process_medium'
    label 'shovill_container'
 
    errorStrategy 'ignore'

    publishDir "${params.outdir}/assemblies", mode: 'copy', pattern: '*.short.fasta'

    input:
    tuple val(meta), path(short_reads1), path(short_reads2), val(genome_size)
    val min_contig_length

    output:
    tuple val(meta), path(fasta)

    script:
    fasta="${meta.sample_id}.short.fasta"
    """  
    shovill --R1 $short_reads1 --R2 $short_reads2 --outdir results --cpus $task.cpus --ram $task.memory --minlen $min_contig_length --force
    mv results/contigs.fa $fasta
    """
}

//add any other tools if needed
//any other tools can be  incorporated