# Test
Questo servizio prova a loggarsi sui servizi SSH, FTP, MySQL dell'honeypot, e usa sqlmap per effettuare exploit sul componente "web-app-with-wazuh".

## Contenuto
- `ssh_test.py`, `ftp_test.py`, `mysql_test.py`: login su alcuni servizi dell'honeypot
- `sqlmap.sh`: vari exploit SQL Injection con sqlmap
- `entrypoint.sh`: avvia gli script
