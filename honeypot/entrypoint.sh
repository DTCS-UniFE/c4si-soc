#!/bin/sh

set -eu

# Print IPs
echo "Honeypot: my IPs are:"
ip --color -br a | grep -v lo

if [ -z "$WAZUH_MANAGER" ]; then
    WAZUH_MANAGER="wazuh.manager"
fi

# Set the Wazuh address in the configuration file
sed -i "s/WAZUH_MANAGER_IP/${WAZUH_MANAGER}/" config.json

# Print configuration
#cat config.json

# Start various honeypots
python -m honeypots \
    --config config.json \
    --setup all \
    --options capture_commands \
    --termination-strategy signal
