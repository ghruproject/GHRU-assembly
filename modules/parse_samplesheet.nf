process PARSE_SAMPLESHEET {
    input:
    path samplesheet from params.samplesheet

    output:
    tuple val(sample_name), file(short_reads1), file(short_reads2), file(long_reads), val(genome_size) into parsed_samples

    script:
    """
    awk -F, 'NR>1 { print \$1, \$2, \$3, \$4, (\$5 == "" ? "NA" : \$5) }' $samplesheet > parsed_samples.txt
    """
}