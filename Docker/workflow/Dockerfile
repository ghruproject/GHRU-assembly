# Use an official Ubuntu runtime as a parent image
FROM ubuntu:24.04

# Set the Nextflow version
ENV NEXTFLOW_VERSION=24.10.3

# Install dependencies
RUN apt-get update && \
    apt-get install -y openjdk-11-jre curl git apt-transport-https ca-certificates gnupg2 software-properties-common && \
    apt-get clean
# Install Docker
RUN apt-get update && \
    apt-get install -y docker.io && \
    apt-get clean

# Install Nextflow
RUN curl -s https://get.nextflow.io | bash && \
    mv nextflow /usr/local/bin/ && \
    chmod +x /usr/local/bin/nextflow

# Verify installation
RUN nextflow -version

# Get ghru assembly pipeline 
RUN git clone https://github.com/cgps-discovery/GHRU-assembly.git 
RUN nextflow plugin install nf-schema@2.2.0
WORKDIR /GHRU-assembly

# Set the entrypoint
# ENTRYPOINT ["nextflow"]
