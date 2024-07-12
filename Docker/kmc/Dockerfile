FROM ubuntu:22.04 as base

LABEL authors="Varun Shamanna" \
      description="Docker image for kmc"

RUN apt update; apt-get install -y  gcc procps jq wget bash

RUN mkdir -p /opt/conda 

RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /opt/conda/miniconda.sh
RUN bash /opt/conda/miniconda.sh -b -p /opt/miniconda 

ENV PATH /bin:/usr/bin:/usr/local/bin

ENV PATH /opt/miniconda/bin:/opt/miniconda/condabin

RUN conda create -n kmc -c bioconda kmc  && conda clean -a

RUN conda create -n coreutils -c conda-forge -c bioconda coreutils bc gawk grep && conda clean -a

ENV PATH /opt/miniconda/bin:/opt/miniconda/condabin:/opt/miniconda/envs/kmc/bin:/opt/miniconda/envs/coreutils/bin