FROM varunshamanna/speciator:v4.0.0

LABEL authors="Julio Diaz Caballero" \
      description="Modified Docker image for speciator"

RUN apt update; apt-get install -y jq

ADD test2 .

ENTRYPOINT [ "/bin/sh" ]