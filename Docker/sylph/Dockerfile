FROM quay.io/biocontainers/sylph:0.8.0--ha6fb395_0
    RUN mkdir /opt/sylph
    COPY ./gtdb-r220-c1000-dbv1.syldb /opt/sylph
    WORKDIR /opt/sylph
    RUN chmod -R 777 /opt/sylph
    