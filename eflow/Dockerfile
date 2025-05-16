# Set build arguments
ARG EFLOW_VERSION=12.2.122040.24

# Base image
FROM epsusllc/eflow:${EFLOW_VERSION}

# Set working directory
WORKDIR /eflow

# Expose ports
EXPOSE 8081 6543 6161 9200

ENV STATE \
    CENTRAL_EFLOW \
    EMAIL \
    COMPANY \
    MACHINENAME

USER root
COPY ./scripts/installProperties.sh /eflow/dockerfiles/scripts/installProperties.sh

RUN echo "eflowdocker ALL=(root) NOPASSWD:SETENV: /eflow/dockerfiles/scripts/installProperties.sh" >> /etc/sudoers.d/eflowdocker \
    && chmod 0440 /etc/sudoers.d/eflowdocker

USER eflowdocker

ENTRYPOINT ["/bin/sh", "-c", "sudo -E /eflow/dockerfiles/scripts/installProperties.sh  && sudo /eflow/dockerfiles/scripts/setupPostgres.sh && sudo /eflow/dockerfiles/scripts/starteFlow.sh && tail -F /eflow/logs/eflowservice-error.log"]