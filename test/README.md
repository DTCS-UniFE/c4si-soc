# Test
This service attempts to log into the SSH, FTP, MySQL, HTTP and HTTPS services of the honeypot, and uses sqlmap to perform exploits on the "web-app-with-wazuh" component.

## Contents
- `*_test.py`: login attempts on some honeypot services
- `sqlmap.sh`: various SQL Injection exploits using sqlmap
- `entrypoint.sh`: runs the scripts
