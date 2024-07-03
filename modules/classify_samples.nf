process CLASSIFY_SAMPLES {
    input:
    tuple val(sample_name), file(short_reads1), file(short_reads2), file(long_reads), val(genome_size) from parsed_samples

    output:
    tuple val(sample_name), val('short'), file(short_reads1), file(short_reads2), val(genome_size) into short_reads_channel
    tuple val(sample_name), val('long'), file(long_reads), val(genome_size) into long_reads_channel
    tuple val(sample_name), val('both'), file(short_reads1), file(short_reads2), file(long_reads), val(genome_size) into hybrid_reads_channel

    script:
    """
    if [[ -f $short_reads1 && -f $short_reads2 && ! -f $long_reads ]]; then
        echo "$sample_name short $short_reads1 $short_reads2 $genome_size" > short_reads.txt
    elif [[ -f $long_reads && ! -f $short_reads1 && ! -f $short_reads2 ]]; then
        echo "$sample_name long $long_reads $genome_size" > long_reads.txt
    elif [[ -f $short_reads1 && -f $short_reads2 && -f $long_reads ]]; then
        echo "$sample_name both $short_reads1 $short_reads2 $long_reads $genome_size" > hybrid_reads.txt
    fi
    """
}