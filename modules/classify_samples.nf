process CLASSIFY_SAMPLES {
    tag { sample_name }

    input:
    tuple( val(sample_name), val(short_reads1), val(short_reads2), val(long_reads), val(genome_size) )

    output:
    tuple( val(sample_name), val(short_reads1), val(short_reads2), val(long_reads), val(genome_size), stdout)

    script:
    // Check with Nigeria and team if we require single fastq file short-read assembly channel
    // Check proper samplesheet format
    """
    if [[ "$short_reads1" != "" && "$short_reads2" != "" && "$long_reads" != "" ]]; then
        echo -n "hybrid"
    elif [[ "$short_reads1" != "" && "$short_reads2" != "" && "$long_reads" == "" ]]; then
        echo -n "short"
    elif [[ "$short_reads1" == "" && "$short_reads2" == "" && "$long_reads" != "" ]]; then
        echo -n "long"
    fi
    """
}