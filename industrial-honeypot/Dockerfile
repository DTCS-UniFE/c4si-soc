FROM dtagdevsec/conpot:24.04.1
# Alpine-based image with Python 3.11 and conpot

# Default user is conpot
USER root

# Install Suricata, ip, util-linux for "logger", jq for processing logs
RUN apk add --no-cache suricata iproute2 util-linux jq \
    && suricata-update

# Download custom rules
RUN mkdir /rules \
    && wget -O /rules/scada-scan.rules https://raw.githubusercontent.com/CyberICS/Suricata-Rules-for-ICS-SCADA/refs/heads/main/scada-scan.rules \
    && wget -O /rules/emerging-scada.rules https://raw.githubusercontent.com/seanlinmt/suricata/refs/heads/master/files/rules/emerging-scada.rules \  
    && wget -O /rules/emerging-tftp.rules https://raw.githubusercontent.com/seanlinmt/suricata/refs/heads/master/files/rules/emerging-tftp.rules \  
    && wget -O /rules/emerging-snmp.rules https://raw.githubusercontent.com/seanlinmt/suricata/refs/heads/master/files/rules/emerging-snmp.rules \  
    && wget -O /rules/all-quickdraw.rules https://raw.githubusercontent.com/digitalbond/Quickdraw-Snort/refs/heads/master/all-quickdraw.rules

# Edit quickdraw rules
# All servers are $HOME_NET
RUN sed -E -i 's/\$\w+_SERVER/\$HOME_NET/g' /rules/all-quickdraw.rules \
    # All clients are "any" - just log everything
    && sed -E -i 's/!\$\w+_CLIENT/any/g' /rules/all-quickdraw.rules \
    && sed -E -i 's/\$\w+_CLIENT/any/g' /rules/all-quickdraw.rules

# Update suricata config
RUN <<EOF
# Add our industrial rules
sed -i '/rule-files:/a\  - /rules/scada-scan.rules' /etc/suricata/suricata.yaml
sed -i '/rule-files:/a\  - /rules/emerging-scada.rules' /etc/suricata/suricata.yaml
sed -i '/rule-files:/a\  - /rules/emerging-tftp.rules' /etc/suricata/suricata.yaml
sed -i '/rule-files:/a\  - /rules/emerging-snmp.rules' /etc/suricata/suricata.yaml
sed -i '/rule-files:/a\  - /rules/all-quickdraw.rules' /etc/suricata/suricata.yaml

# Set the external network to any
sed -i 's/EXTERNAL_NET: "!$HOME_NET"/EXTERNAL_NET: "any"/' /etc/suricata/suricata.yaml

# Disable statistics writing, which is heavy and spams logs on wazuh-manager, both in eve.json and stats.log
# Disable statistics globally
sed -i '/stats:/ {n; s/enabled: yes/enabled: no/}' /etc/suricata/suricata.yaml
# Also disable statistics in eve.json to avoid errors or warnings at startup
awk '
/- stats:/ {
    print;                   # print the line - stats:
    getline nextLine;        # read the next line
    if (nextLine ~ /totals: yes/) {
        print "            enabled: no";  # print the new line (12 spaces indentation)
    }
    print nextLine;          # always print the next line
    next;
}
{ print }                    # for all other lines, print normally
' /etc/suricata/suricata.yaml > /etc/suricata/suricata.yaml.tmp
mv /etc/suricata/suricata.yaml.tmp /etc/suricata/suricata.yaml
EOF

COPY entrypoint.sh conpot-syslog.sh suricata-syslog.sh /

CMD ["/bin/sh", "/entrypoint.sh"]
