# Setup Wazuh
Container for configuring Wazuh. Loads custom rules and decoders at startup, and modifies the Wazuh Manager configuration to accept logs via Syslog. All operations are performed through calls to the Wazuh API.

## Contents
- `honeypot_rules.xml`, `honeypot_decoder.xml`: custom rules and decoders
- `setup_wazuh.sh`: configuration script
