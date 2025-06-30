# Web App with Wazuh
Vulnerable PHP Web Application + MySQL Database + Wazuh agent for monitoring logins, suspicious events, and access to sensitive files (honeyfiles).

## Contents
- `app/`: vulnerable PHP application
- `honeyfiles/`: sensitive files for auditing activities
- `entrypoint.sh`: setup and startup script
- `apache-config.conf`, `ossec.conf`: Apache and Wazuh agent configurations
- `cyberbase.sql`: database dump for restoration on startup
