#!/bin/bash

# Stampa IP
echo "Honeypot: i miei IP sono:"
ip --color -br a | grep -v lo

if [ -z "$WAZUH_MANAGER" ]; then
    WAZUH_MANAGER="wazuh.manager"
fi

# Imposta l'indirizzo di Wazuh nel file di configurazione
sed -i "s/WAZUH_MANAGER_IP/${WAZUH_MANAGER}/" config.json

# Stampa configurazione
#cat config.json

# Avvio vari honeypot
python -m honeypots \
    --config config.json \
    --setup all \
    --options capture_commands \
    --termination-strategy signal
