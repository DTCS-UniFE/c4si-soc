#!/bin/sh

SLEEP=30

if [ -z "$HONEYPOT" ]; then
    HONEYPOT="honeypot"
fi

if [ -z "$WEBAPP" ]; then
    WEBAPP="web-app-with-wazuh"
fi

while [ "$SLEEP" -gt 0 ]; do
    sleep 5
    echo "I test inizieranno fra $SLEEP secondi..."
    SLEEP=$((SLEEP - 5))
done

python ftp_test.py "$HONEYPOT"
sleep 3

python mysql_test.py "$HONEYPOT"
sleep 3

python ssh_test.py "$HONEYPOT"
sleep 3

sh ./sqlmap.sh "$WEBAPP"
