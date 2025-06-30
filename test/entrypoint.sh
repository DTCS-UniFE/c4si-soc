#!/bin/sh

SLEEP=60

if [ -z "$HONEYPOT" ]; then
    HONEYPOT="honeypot"
fi

if [ -z "$WEBAPP" ]; then
    WEBAPP="web-app-with-wazuh"
fi

while [ "$SLEEP" -gt 0 ]; do
    sleep 5
    echo "Tests will begin in $SLEEP seconds..."
    SLEEP=$((SLEEP - 5))
done

python ftp_test.py "$HONEYPOT"
sleep 3

python mysql_test.py "$HONEYPOT"
sleep 3

python ssh_test.py "$HONEYPOT"
sleep 3

python http_test.py "$HONEYPOT"
sleep 3

python https_test.py "$HONEYPOT"
sleep 3

sh ./sqlmap.sh "$WEBAPP"

echo "All tests completed."
echo "You can now see the alerts in Wazuh dashboard -> Threat Hunting -> Events (top left)."
