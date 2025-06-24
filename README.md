# Security Operations Center (SOC)
Questo progetto consente di creare un SOC velocemente in un ambiente containerizzato. Il SOC è composto da:
- Wazuh (SIEM): raccolta, analisi, aggregazione e visualizzazione di log, generazione alert
- Applicazione Web PHP (con vulnerabilità), con database MySQL (MariaDB) e agente Wazuh. Contiene file "sensibili" (finti)
- Honeypot di numerosi servizi, che loggano i tentativi di accesso e i comandi ricevuti e li inoltrano a Wazuh mediante Syslog

## Servizi principali
- **honeypot/**: honeypot di numerosi servizi
- **test/**: tentativi di accesso ad alcuni servizi honeypot (SSH, FTP, MySQL) ed exploit Web App con Sqlmap
- **setup-wazuh/**: carica regole e decoder personalizzati in Wazuh, oltre che a modificarne la configurazione, tutto tramite API
- **web-application-with-wazuh/**: applicazione PHP vulnerabile + database + honeyfiles + Wazuh agent

## File principali
- `docker-compose.yml`: definisce e orchestra tutti i container
- `clone-and-setup-wazuh.sh`: clona la repository Wazuh-Docker e genera i certificati richiesti
- `.gitmodules`: include una dipendenza Git esterna (app Web PHP)

## Avvio
```bash
bash ./clone-and-setup-wazuh.sh
docker compose up --build --force-recreate
```
Wazuh sarà accessibile all'indirizzo https://localhost, credenziali di default "admin" / "SecretPassword".
L'elenco degli eventi (log) di sicurezza si potrà vedere cliccando su "Threat Hunting" e poi, in alto a sinistra, "Events".

## Spegnimento
```bash
docker compose down --volumes
```
Si consiglia di rimuovere anche i volumi (--volumes) per evitare problemi con l'enrollment degli agenti Wazuh, oltre che la ridefinizione di regole, decoder e configurazione di Wazuh Manager.
