#!/usr/bin/env nextflow

nextflow.enable.dsl=2

params.sampleSheet = 'samplesheet.csv'

process parseSampleSheet {
    input:
    path sampleSheet

    output:
    tuple val(sample_name), val(sr1), val(sr2), val(lr), val(size) into allSamples

    script:
    """
    awk 'NR>1 {print \$0}' ${sampleSheet} | while IFS=, read -r sample_name sr1 sr2 lr size; do
        sr1=\${sr1:-}
        sr2=\${sr2:-}
        lr=\${lr:-}
        size=\${size:-}
        echo -e "\${sample_name},\${sr1},\${sr2},\${lr},\${size}"
    done
    """
}

workflow {
    parseSampleSheet(params.sampleSheet)
    allSamples = parseSampleSheet.out

    shortChannel = allSamples.filter { sample_name, sr1, sr2, lr, size -> sr1 && sr2 && !lr }
    hybridChannel = allSamples.filter { sample_name, sr1, sr2, lr, size -> sr1 && sr2 && lr }
    longChannel = allSamples.filter { sample_name, sr1, sr2, lr, size -> !sr1 && !sr2 && lr }

    shortChannel.subscribe { row ->
        println "Short channel: ${row}"
    }

    hybridChannel.subscribe { row ->
        println "Hybrid channel: ${row}"
    }

    longChannel.subscribe { row ->
        println "Long channel: ${row}"
    }
}
