# Set build arguments
ARG EFLOW_VERSION=12.2.122040.24
ARG STATE=down
ARG CENTRAL_EFLOW=1
ARG EMAIL=portal@epssw.com
ARG COMPANY=DefaultCompany
ARG MACHINENAME=DefaultMachine

# Base image
FROM epsusllc/eflow:${EFLOW_VERSION}

# Set working directory
WORKDIR /eflow

# Re-declare build ARGs
ARG STATE
ARG CENTRAL_EFLOW
ARG EMAIL
ARG COMPANY
ARG MACHINENAME

# Switch to root for file ops
USER root

# Create install.properties file with ARG values
RUN echo "state=${STATE}" > /eflow/install.properties && \
    echo "centraleflow=${CENTRAL_EFLOW}" >> /eflow/install.properties && \
    echo "Email=${EMAIL}" >> /eflow/install.properties && \
    echo "Company=${COMPANY}" >> /eflow/install.properties && \
    echo "machinename=${MACHINENAME}" >> /eflow/install.properties

# Expose ports
EXPOSE 8081 6543 6161 9200

# switch back to eflowdocker user
USER eflowdocker