#!/bin/bash
echo "running installProperties.sh"

#display env variables
echo "STATE: ${STATE}"
echo "CENTRAL_EFLOW: ${CENTRAL_EFLOW}"
echo "EMAIL: ${EMAIL}"
echo "COMPANY: ${COMPANY}"
echo "MACHINENAME: ${MACHINENAME}"

# Read environment variables and create install.properties
cat <<EOF > /eflow/install.properties
state=${STATE}
centraleflow=${CENTRAL_EFLOW}
Email=${EMAIL}
Company=${COMPANY}
machinename=${MACHINENAME}
EOF