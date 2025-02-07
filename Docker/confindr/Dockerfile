FROM quay.io/biocontainers/confindr:0.8.1--pyhdfd78af_1

# Download and extract the ConFindr database
RUN wget https://quadram-bioinfo-rlmst.s3.climb.ac.uk/confindr_db_2024_2_12.tar.gz -O /tmp/confindr_db.tar.gz && \
    mkdir -p /opt/confindr_db && \
    tar -xzf /tmp/confindr_db.tar.gz -C /opt/confindr_db && \
    rm /tmp/confindr_db.tar.gz

# Set permissions to read, write, and execute
RUN chmod -R 777 /opt/confindr_db

# Set environment variable to point to the database
ENV CONFINDr_DB=/opt/confindr_db
# Set permissions to read, write, and execute
RUN mkdir /opt/contemp
RUN chmod -R 777 /opt/contemp