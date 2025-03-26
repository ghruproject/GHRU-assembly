FROM quay.io/biocontainers/checkm2:1.1.0--pyh7e72e81_1
    RUN mkdir /opt/checkm_data
    COPY ./uniref100.KO.1.dmnd /opt/checkm_data/
    ENV CHECKM2DB=/opt/checkm_data/uniref100.KO.1.dmnd
    