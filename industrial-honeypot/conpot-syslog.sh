#!/bin/sh
set -eu

SYSLOG_SERVER="${1:-}"

SYSLOG_PORT="${2:-514}"

SYSLOG_TAG="${3:-conpotjsonlog}"
SYSLOG_FAC="${4:-user.info}"

CONPOT_FILE="${5:-/tmp/conpot.json}"

if [ -z "$SYSLOG_SERVER" ]; then
  echo "Error: SYSLOG_SERVER unset" >&2
  exit 1
fi

# Wait for file to exist
i=0
while [ ! -e "$CONPOT_FILE" ]; do
  i=$((i+1))
  if [ $i -le 30 ]; then
    echo "Waiting for $CONPOT_FILE ..." >&2
    sleep 1
  else
    # If it doesn't after a while, create it
    touch "$CONPOT_FILE"
    break
  fi
done

# If request or response:
# - are missing, set them to null
# - are null, leave them null
# - are strings, leave them strings
# - are json objects, escape them so they become strings
jq_filter='
  if has("request") | not then .request = null else . end |
  if has("response") | not then .response = null else . end |
  .request  |= (if . == null then null elif type == "string" then . else tostring end) |
  .response |= (if . == null then null elif type == "string" then . else tostring end)
'

tail -F "$CONPOT_FILE" | while IFS= read -r line; do
  # Skip empty lines
  [ -z "$line" ] && continue

  # Process JSON to normalize request/response objects
  if processed="$(printf '%s' "$line" | jq -c "$jq_filter" 2>/dev/null)"; then
    line="$processed"
  fi

  #echo "Conpot Sending to $SYSLOG_SERVER:$SYSLOG_PORT: $line"

  logger -n "$SYSLOG_SERVER" -P "$SYSLOG_PORT" -t "$SYSLOG_TAG" -p "$SYSLOG_FAC" -- "$line"
done
