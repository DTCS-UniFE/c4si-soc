# Web App with Wazuh
Applicazione Web PHP (vulnerabile) + Database MySQL + agente Wazuh per il monitoraggio di accessi, eventi sospetti e accesso a file sensibili (honeyfiles).

## Contenuto
- `app/`: applicazione PHP vulnerabile
- `honeyfiles/`: file sensibili per attività di auditing
- `entrypoint.sh`: configurazione e avvio
- `apache-config.conf`, `ossec.conf`: configurazioni Apache e agente Wazuh
- `cyberbase.sql`: dump del database per ripristino
