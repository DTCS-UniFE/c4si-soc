#!/bin/bash

# Exit on first error
set -eu

# Username and password for the MySQL (MariaDB) user
SQL_USERNAME="cyberuser"
SQL_PASSWORD="very_secure_password"

# Insert username and password into the php file
sed -i "s/DATABASE_USER/$SQL_USERNAME/" /var/www/html/db.php
sed -i "s/DATABASE_PASSWORD/$SQL_PASSWORD/" /var/www/html/db.php

# Start MySQL (MariaDB) as mysql user
su -s /bin/bash mysql -c "/usr/sbin/mysqld" &

# Wait for the database to start
# There MUST NOT be a space between -p and the password.
until mysqladmin ping -u $SQL_USERNAME -p$SQL_PASSWORD >/dev/null 2>&1;
do
    echo "MySQL (MariaDB) is not ready yet..."
    sleep 3
done

# Create a new user and set its password, import the database and some sample data
/usr/bin/mysql -e "CREATE USER '$SQL_USERNAME'@'localhost' IDENTIFIED BY '$SQL_PASSWORD';"
/usr/bin/mysql -e "GRANT ALL PRIVILEGES ON *.* TO '$SQL_USERNAME'@'localhost';"
/usr/bin/mysql -e "FLUSH PRIVILEGES;"
# There MUST NOT be a space between -p and the password.
/usr/bin/mysql -u $SQL_USERNAME -p$SQL_PASSWORD < /cyberbase.sql

# Start apache2
/usr/sbin/apache2ctl start

# Set the manager address
sed -i "s/WAZUH_MANAGER_IP/${WAZUH_MANAGER}/" /var/ossec/etc/ossec.conf

# Set the client name
sed -i "s/WAZUH_AGENT_NAME/${WAZUH_AGENT_NAME}/" /var/ossec/etc/ossec.conf

# Start the Wazuh agent
/usr/bin/env /var/ossec/bin/wazuh-control start
/usr/bin/env /var/ossec/bin/wazuh-control status
status=$?
if [ $status -ne 0 ]; then
    echo "Failed to start agent: $status"
    exit $status
fi

echo "Wazuh agent running"

# Modify Suricata configuration
# Set the external network to "any", since we are working inside Docker with always private IPs
# Note: These are not shell variables, they must not be replaced.
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
' /etc/suricata/suricata.yaml > /etc/suricata/suricata.yaml.tmp && \
mv /etc/suricata/suricata.yaml.tmp /etc/suricata/suricata.yaml

# Start Suricata in the background
suricata -c /etc/suricata/suricata.yaml -i eth0 -D

# Cat Apache's access log to keep the container open
tail -f /var/log/apache2/access.log
