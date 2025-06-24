# Honeypot
Il servizio honeypot espone numerosi servizi, definiti in `config.json`, grazie alla libreria Python [honeypots](https://pypi.org/project/honeypots/). I log generati dai vari honeypot vengono mandati a Wazuh tramite Syslog.

## Note
Non installiamo la libreria honeypots direttamente da PyPI per applicare una patch [`syslog_valid_json.patch`](syslog_valid_json.patch) al codice. Infatti, i messaggi Syslog generati dall'honeypot contengono JSON non valido (stringhe delimitate da apici invece che da virgolette). La patch che applichiamo sistema questo problema, in modo che i log siano più facilmente parsabili da Wazuh.
