#!/bin/sh
set -eu

SYSLOG_SERVER="${1:-}"

SYSLOG_PORT="${2:-514}"

SYSLOG_TAG="${3:-suricatajsonlog}"
SYSLOG_FAC="${4:-user.info}"

SURICATA_FILE="${5:-/tmp/eve.json}"

if [ -z "$SYSLOG_SERVER" ]; then
  echo "Error: SYSLOG_SERVER unset" >&2
  exit 1
fi

# Wait for file to exist
i=0
while [ ! -e "$SURICATA_FILE" ]; do
  i=$((i+1))
  if [ $i -le 30 ]; then
    echo "Waiting for $SURICATA_FILE ..." >&2
    sleep 1
  else
    # If it doesn't after a while, create it
    touch "$SURICATA_FILE"
    break
  fi
done

tail -F "$SURICATA_FILE" | while IFS= read -r line; do
  # Skip empty lines
  [ -z "$line" ] && continue

  #echo "Suricata Sending to $SYSLOG_SERVER:$SYSLOG_PORT: $line"

  logger -n "$SYSLOG_SERVER" -P "$SYSLOG_PORT" -t "$SYSLOG_TAG" -p "$SYSLOG_FAC" -- "$line"
done
