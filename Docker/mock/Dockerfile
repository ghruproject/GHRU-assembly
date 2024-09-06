FROM ubuntu:latest

COPY entrypoint.sh /entrypoint.sh
COPY assembly.fasta /assembly.fasta
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]