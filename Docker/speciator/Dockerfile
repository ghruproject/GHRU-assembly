FROM varunshamanna/speciator:v4.0.0

LABEL authors="Julio Diaz Caballero" \
      description="Modified Docker image for speciator"

RUN apt update; apt-get install -y jq

# Error with base entry point
#ENTRYPOINT [ "/bin/sh" ]

# Error with finding speciator.py or permissions
ENTRYPOINT [ "/usr/bin/env" ]
RUN ["chmod", "a+rwx", "/speciator.py"]
RUN ["chmod", "-R", "a+rwx", "/libraries"]
RUN ["chmod", "-R", "a+rwx", "/bactinspector"]
CMD ["/bin/bash"]