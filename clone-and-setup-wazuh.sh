#!/bin/bash

set -euo pipefail

# Clona la repo di wazuh-docker se necessario
if [ ! -d ./wazuh-docker ]; then
    echo "Wazuh (Docker) non trovato, lo clono..."
    if [ ! "$(which git)" ]; then
        echo "git non trovato, installalo e riprova."
        exit 1
    fi
    git clone https://github.com/wazuh/wazuh-docker.git --depth=1 -b v4.12.0
fi

# Genera i certificati necessari
if [ ! -d ./wazuh-docker/single-node/config/wazuh_indexer_ssl_certs ]; then
    pushd wazuh-docker/single-node || exit 1
    docker compose -f generate-indexer-certs.yml run --rm generator
    popd || exit 1
else
    echo "Certificati già creati."
fi

echo "Setup di Wazuh terminato."
echo "Ora puoi far partire il SOC con:"
echo "docker compose up --build --force-recreate"
