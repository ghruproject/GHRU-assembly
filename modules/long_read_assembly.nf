process ASSEMBLY_DRAGONFLYE{
    tag { meta.sample_id }
    label 'process_high'
    label 'dragonflye_container'
    
    publishDir "${params.outdir}/assemblies", mode: 'copy', pattern: '*.long.fasta'

    input:
    tuple val(meta), path(long_reads), val(genome_size)
    val(medaka_model)

    output:
    tuple val(meta), path(fasta)


    script:
    LR="$long_reads"
    GSIZE="$genome_size"
    fasta="${meta.sample_id}.long.fasta"
    """
    dragonflye --gsize $GSIZE --reads $LR --cpus $task.cpus --ram $task.memory \
    --prefix $meta.sample_id --racon 1 --medaka 1 --model $medaka_model \
    --outdir "$meta.sample_id" --force --keepfiles --depth 150
    mv "$meta.sample_id"/"$meta.sample_id".fa $fasta
    """
}