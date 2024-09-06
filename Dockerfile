FROM amazoncorretto:17-alpine

RUN apk add --no-cache bash
RUN apk add --no-cache wget
RUN wget -qO- https://get.nextflow.io | bash && mv nextflow /usr/local/bin/

RUN mkdir assembly
WORKDIR /assembly

COPY . /assembly/

RUN chmod +x /assembly/entrypoint.sh
RUN apk add --no-cache bash wget docker-cli

# Set the entry point to Nextflow
CMD ["./entrypoint.sh"]
