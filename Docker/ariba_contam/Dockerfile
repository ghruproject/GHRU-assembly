FROM quay.io/biocontainers/ariba:2.14.6--py38h40d3509_6
    RUN mkdir /opt/ariba
    RUN mkdir /opt/ariba/mlst_db
    COPY ./ariba_mlst/ /opt/ariba/mlst_db
    WORKDIR /opt/ariba
    COPY ./run_ariba.py /opt/ariba/run_ariba.py
    RUN chmod -R 777 /opt/ariba
    