#!/bin/bash

if [ -e "/data/reads/forward.fastq.gz" ] && [ -e "/data/reads/reverse.fastq.gz" ]; then
  echo found short
  short=true
  label=short
fi
if [ -e "/data/reads/long.fastq.gz" ]; then
  echo found long
  long=true
  label=long
fi
if [ "$long" = "$short" ]; then
echo found hybrid
  label=hybrid
fi
cp /assembly.fasta /output/$label.fasta