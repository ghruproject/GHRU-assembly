# Use the official Amazon Corretto 17 base image for Alpine
FROM amazoncorretto:17-alpine

RUN apk add --no-cache bash
RUN apk add --no-cache wget
RUN wget -qO- https://get.nextflow.io | bash && mv nextflow /usr/local/bin/


# Set the entry point to Nextflow
CMD ["nextflow"]
