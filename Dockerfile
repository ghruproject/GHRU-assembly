# Use the official Amazon Corretto 17 base image for Alpine
FROM amazoncorretto:17-alpine

# Install bash (Alpine doesn't include it by default)
RUN apk add --no-cache bash

# Install wget for downloading Nextflow
RUN apk add --no-cache wget

# Install Nextflow
RUN wget -qO- https://get.nextflow.io | bash && mv nextflow /usr/local/bin/

# Verify installation
RUN nextflow -version

# Set the entry point to Nextflow
CMD ["nextflow"]
