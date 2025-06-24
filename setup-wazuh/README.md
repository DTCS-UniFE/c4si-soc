# Setup Wazuh
Container di configurazione per Wazuh. Carica regole e decoder personalizzati all'avvio, oltre che a modificare la configurazione di Wazuh Manager per accettare log con Syslog. Per fare tutte le operazioni fa chiamate all'API di Wazuh.

## Contenuto
- `honeypot_rules.xml`, `honeypot_decoder.xml`: regole e decoder personalizzati
- `setup_wazuh.sh`: script di configurazione
