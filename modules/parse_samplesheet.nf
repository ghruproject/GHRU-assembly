process PARSE_SAMPLESHEET {
    input:
    path (samplesheet)

    output:
    tuple val(sample_name), path(short_reads1), path(short_reads2), path(long_reads), val(genome_size), emit: parsed_samples

    script:
    """
    awk -F, 'NR>1 { print \$1, \$2, \$3, \$4, (\$5 == "" ? "NA" : \$5) }' $samplesheet > parsed_samples.txt
    """
}