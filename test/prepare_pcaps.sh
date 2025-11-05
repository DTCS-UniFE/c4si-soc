#!/bin/sh

set -eu

MY_IP=$(ip -br a | grep eth0 | awk '{print $3}' | awk -F "/" '{print $1}')
MY_MAC=$(ip -br l | grep eth0 | awk '{print $3}')

ping -c1 industrial-honeypot > /dev/null 2>&1

INDUSTRIAL_IP=$(getent hosts industrial-honeypot | awk '{print $1}')
INDUSTRIAL_MAC=$(arp -n industrial-honeypot | awk '{print $4}')

echo "PCAP traffic will be sent from $MY_IP (MAC: $MY_MAC)"
echo "PCAP traffic will be sent to $INDUSTRIAL_IP (MAC: $INDUSTRIAL_MAC)"

count=1
for i in pcaps/*.pcap pcaps/*.pcapng; do
    [ -e "$i" ] || continue
    # ^ If for example no *.pcapng files are found, it
    # will match the literal pcaps/*.pcapng. In Bash
    # you can turn this off with the shell option
    # "nullglob", but there's no equivalent in POSIX sh.

    tcprewrite --infile="$i" --outfile="pcaps/${count}-conv.pcap" \
        --srcipmap="0.0.0.0/0:$MY_IP" \
        --dstipmap="0.0.0.0/0:$INDUSTRIAL_IP" \
        --enet-smac="$MY_MAC" \
        --enet-dmac="$INDUSTRIAL_MAC" \
        --fixcsum --fixhdrlen
    
    count=$((count+1))
done

# Delete all non-converted pcaps
find pcaps ! -name '*-conv.pcap' -type f -delete
