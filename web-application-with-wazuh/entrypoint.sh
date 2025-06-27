#!/bin/bash

# Esce al primo errore
set -eu

# Username e password per l'utente di MySQL (MariaDB)
SQL_USERNAME="cyberuser"
SQL_PASSWORD="password_molto_sicura"

# Inserisce nome utente e password nel file php
sed -i "s/UTENTE_DATABASE/$SQL_USERNAME/" /var/www/html/db.php
sed -i "s/PASSWORD_DATABASE/$SQL_PASSWORD/" /var/www/html/db.php

# Avvia MySQL (MariaDB) come utente mysql
su -s /bin/bash mysql -c "/usr/sbin/mysqld" &

# Aspetta che il database si avvii
# NON ci deve essere uno spazio fra -p e la password.
until mysqladmin ping -u $SQL_USERNAME -p$SQL_PASSWORD >/dev/null 2>&1;
do
    echo "MySQL (MariaDB) is not ready yet..."
    sleep 3
done

# Crea un nuovo utente e ne imposta la password, importa il database e dei dati di esempio
/usr/bin/mysql -e "CREATE USER '$SQL_USERNAME'@'localhost' IDENTIFIED BY '$SQL_PASSWORD';"
/usr/bin/mysql -e "GRANT ALL PRIVILEGES ON *.* TO '$SQL_USERNAME'@'localhost';"
/usr/bin/mysql -e "FLUSH PRIVILEGES;"
# NON ci deve essere uno spazio fra -p e la password.
/usr/bin/mysql -u $SQL_USERNAME -p$SQL_PASSWORD < /cyberbase.sql

# Avvia apache2
/usr/sbin/apache2ctl start

# Imposta l'indirizzo del manager
sed -i "s/WAZUH_MANAGER_IP/${WAZUH_MANAGER}/" /var/ossec/etc/ossec.conf

# Imposta il nome del client
sed -i "s/WAZUH_AGENT_NAME/${WAZUH_AGENT_NAME}/" /var/ossec/etc/ossec.conf


# Avvia l'agente Wazuh
/usr/bin/env /var/ossec/bin/wazuh-control start
/usr/bin/env /var/ossec/bin/wazuh-control status
status=$?
if [ $status -ne 0 ]; then
    echo "Failed to start agent: $status"
    exit $status
fi

echo "Agente Wazuh in esecuzione"

# Modifica la configurazione di Suricata
# Imposta la rete esterna a "any", visto che lavoriamo dentro Docker con IP sempre privati
# NB: Queste non sono variabili shell, non devono essere sostituite.
sed -i 's/EXTERNAL_NET: "!$HOME_NET"/EXTERNAL_NET: "any"/' /etc/suricata/suricata.yaml

# Disabilitiamo la scrittura di statistiche, molto pesanti e che
# spammano log su wazuh-manager, sia in eve.json che in stats.log
# Disattiva le statistiche globalmente
sed -i '/stats:/ {n; s/enabled: yes/enabled: no/}' /etc/suricata/suricata.yaml
# Disattiva le statistiche anche in eve.json in modo che non vengano dati errori o warning all'avvio
awk '
/- stats:/ {
    print;                   # stampa la riga - stats:
    getline nextLine;        # leggi la riga successiva
    if (nextLine ~ /totals: yes/) {
        print "            enabled: no";  # stampa la nuova riga (12 spazi di indentazione)
    }
    print nextLine;          # stampa comunque la riga successiva
    next;
}
{ print }                    # per tutte le altre righe, stampa normalmente
' /etc/suricata/suricata.yaml > /etc/suricata/suricata.yaml.tmp && \
mv /etc/suricata/suricata.yaml.tmp /etc/suricata/suricata.yaml

# Avvia Suricata
suricata -c /etc/suricata/suricata.yaml -i eth0 &

# Cat dell'access log di Apache per tenere aperto il container
tail -f /var/log/apache2/access.log
