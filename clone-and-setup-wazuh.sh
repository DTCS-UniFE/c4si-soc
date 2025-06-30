#!/bin/bash

set -euo pipefail

# Clone the wazuh-docker repo if necessary
if [ ! -d ./wazuh-docker ]; then
    echo "Wazuh (Docker) not found, cloning it..."
    if [ ! "$(which git)" ]; then
        echo "git not found, please install it and try again."
        exit 1
    fi
    git clone https://github.com/wazuh/wazuh-docker.git --depth=1 -b v4.12.0
fi

# Generate the necessary certificates
if [ ! -d ./wazuh-docker/single-node/config/wazuh_indexer_ssl_certs ]; then
    pushd wazuh-docker/single-node || exit 1
    docker compose -f generate-indexer-certs.yml run --rm generator
    popd || exit 1
    echo "Certificates successfully created."
else
    echo "Certificates already created."
fi

echo "Wazuh setup completed."
echo "You can now start the SOC with:"
echo "docker compose up --build --force-recreate"
