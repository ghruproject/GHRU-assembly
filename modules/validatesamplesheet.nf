process VALIDATE_SAMPLESHEET {

    label 'python_container'

    input:
    path samplesheet

    output:
    path 'validated_samplesheet.csv', emit: validated_samplesheet

    script:
    """
    #!/bin/bash
    set -e

    # Ensure the samplesheet file exists
    if [ ! -f "${samplesheet}" ]; then
        echo "Error: The samplesheet file '${samplesheet}' does not exist."
        exit 1
    fi

    # Run the Python script to validate the samplesheet
    validate_samplesheet.py "${samplesheet}"

    # Copy the validated samplesheet to the output path
    cp "${samplesheet}" validated_samplesheet.csv
    """
}
