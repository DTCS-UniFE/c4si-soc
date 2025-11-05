#!/bin/sh

if [ -z "$SLEEP" ]; then
    SLEEP=60
fi

if [ -z "$HONEYPOT" ]; then
    HONEYPOT="honeypot"
fi

if [ -z "$INDUSTRIAL_HONEYPOT" ]; then
    INDUSTRIAL_HONEYPOT="industrial-honeypot"
fi

if [ -z "$WEBAPP" ]; then
    WEBAPP="web-app-with-wazuh"
fi

while [ "$SLEEP" -gt 0 ]; do
    sleep 5
    echo "Tests will begin in $SLEEP seconds..."
    SLEEP=$((SLEEP - 5))
done


echo "Testing application Honeypot..."

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
sleep 3


echo "Testing industrial Honeypot..."

python ftp_test.py "$INDUSTRIAL_HONEYPOT" "nobody" "nobody"
sleep 3

sh ./bacnet_test.sh "$INDUSTRIAL_HONEYPOT"
sleep 3

python modbus_test.py "$INDUSTRIAL_HONEYPOT"
sleep 3

python enip_test.py "$INDUSTRIAL_HONEYPOT"
sleep 3

python s7_test.py "$INDUSTRIAL_HONEYPOT"
sleep 3

python snmp_test.py "$INDUSTRIAL_HONEYPOT"
sleep 3

echo "Replaying industrial PCAPs..."

# Do we have at least one pcap or pcapng?
we_have_pcaps=false
for f in pcaps/*.pcap pcaps/*.pcapng
do
    case "$f" in
        pcaps/\*.pcap|pcaps/\*.pcapng)
            # No files match
            ;;
        *)
            we_have_pcaps=true
            break
            ;;
    esac
done

if [ "$we_have_pcaps" = true ]; then
    echo "Rewriting pcaps..."
    # Rewriting needs to happen at runtime, we need to resolve container IPs
    sh prepare_pcaps.sh

    if [ -z "$REPLAY_PACKETS_PER_SECOND" ]; then
        REPLAY_PACKETS_PER_SECOND=50
    fi

    echo "Will replay:"
    ls pcaps/*.pcap
    # ^ After rewriting them, they all take names such as
    # 1-conv.pcap, 2-conv.pcap, etc.

    for i in pcaps/*.pcap; do
        echo "Replaying $i..."
        tcpreplay --stats=10 -i eth0 -p "$REPLAY_PACKETS_PER_SECOND" "$i" 2>/dev/null
    done
else
    echo "No .pcap or .pcapng files found, no traffic to replay."
fi

echo "All tests completed."
echo "You can now see the alerts in Wazuh dashboard -> Threat Hunting -> Events (top left)."
