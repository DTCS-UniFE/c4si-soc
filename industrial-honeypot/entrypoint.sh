#!/bin/sh

set -eu

# Print IPs
echo "Industrial honeypot: my IPs are:"
ip -br a | grep -v lo

# Start suricata in the background
suricata -c /etc/suricata/suricata.yaml -i eth0 -l /tmp/ -D

# Start conpot
CONPOT_TMP=/tmp/
CONPOT_TEMPLATE=default
CONPOT_LOG=/tmp/conpot.log
CONPOT_JSON_LOG=/tmp/conpot.json
CONPOT_CONFIG=/etc/conpot/conpot.cfg

su - conpot -c \
    "export CONPOT_TMP=$CONPOT_TMP \
    && export CONPOT_TEMPLATE=$CONPOT_TEMPLATE \
    && export CONPOT_LOG=$CONPOT_LOG \
    && export CONPOT_JSON_LOG=$CONPOT_JSON_LOG \
    && export CONPOT_CONFIG=$CONPOT_CONFIG \
    && /usr/bin/conpot \
    --mibcache \$CONPOT_TMP \
    --temp_dir \$CONPOT_TMP \
    --template \$CONPOT_TEMPLATE \
    --logfile \$CONPOT_LOG \
    --config \$CONPOT_CONFIG & \
    sh /conpot-syslog.sh $SYSLOG_SERVER & \
    sh /suricata-syslog.sh $SYSLOG_SERVER"
