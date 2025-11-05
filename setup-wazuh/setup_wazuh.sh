#!/bin/sh

set -eu

if [ -z "$WAZUH_MANAGER" ]; then
    WAZUH_MANAGER="wazuh.manager"
fi

if [ -z "$WAZUH_API_USER" ]; then
    WAZUH_API_USER="wazuh-wui"
fi

if [ -z "$WAZUH_API_PASSWORD" ]; then
    WAZUH_API_PASSWORD="MyS3cr37P450r.*-"
fi

if [ -z "$WAZUH_INDEXER" ]; then
    WAZUH_INDEXER="wazuh.indexer"
fi

if [ -z "$WAZUH_INDEXER_USER" ]; then
    WAZUH_INDEXER_USER="admin"
fi

if [ -z "$WAZUH_INDEXER_PASSWORD" ]; then
    WAZUH_INDEXER_PASSWORD="SuperSecret"
fi

###
### Adding decoder and rules to Wazuh
###

echo "Checking API liveness..."

until nc -z "$WAZUH_MANAGER" 55000;
do
    echo "Wazuh API is not ready yet..."
    sleep 5
done
# Sometimes the API is reachable on port 55000 but not ready to respond.
# Thus we add a bit more delay.
sleep 10

echo "Authenticating to API..."

JWT="$(curl -sSf -X POST -u "$WAZUH_API_USER:$WAZUH_API_PASSWORD" -k \
    "https://$WAZUH_MANAGER:55000/security/user/authenticate" | jq -r .data.token)"

echo "Adding Application Honeypot decoder..."

curl -sSf -X PUT -H "Authorization: Bearer $JWT" -H "Content-Type: application/octet-stream" -k \
    "https://$WAZUH_MANAGER:55000/decoders/files/honeypot_decoder.xml?wait_for_complete=true&overwrite=true" \
    --data-binary @honeypot_decoder.xml # --data-binary preserves newlines

echo ""
echo "Adding Industrial Honeypot decoder..."

curl -sSf -X PUT -H "Authorization: Bearer $JWT" -H "Content-Type: application/octet-stream" -k \
    "https://$WAZUH_MANAGER:55000/decoders/files/industrial_honeypot_decoder.xml?wait_for_complete=true&overwrite=true" \
    --data-binary @industrial_honeypot_decoder.xml # --data-binary preserves newlines

echo ""
echo "Adding Application Honeypot rules..."

curl -sSf -X PUT -H "Authorization: Bearer $JWT" -H "Content-Type: application/octet-stream" -k \
    "https://$WAZUH_MANAGER:55000/rules/files/honeypot_rules.xml?wait_for_complete=true&overwrite=true" \
    --data-binary @honeypot_rules.xml # --data-binary preserves newlines

echo ""
echo "Adding Industrial Honeypot rules..."

curl -sSf -X PUT -H "Authorization: Bearer $JWT" -H "Content-Type: application/octet-stream" -k \
    "https://$WAZUH_MANAGER:55000/rules/files/industrial_honeypot_rules.xml?wait_for_complete=true&overwrite=true" \
    --data-binary @industrial_honeypot_rules.xml # --data-binary preserves newlines

###
### Configuration update
###

curl -sSf -H "Authorization: Bearer $JWT" -k "https://$WAZUH_MANAGER:55000/manager/configuration?raw=true" > wazuh_manager.conf

# Enable forced agent re-registration otherwise the agent on a container restart will not re-register
sed -i '/<auth>/a\
    <force>\
        <enabled>yes</enabled>\
        <disconnected_time enabled="no">0</disconnected_time>\
        <after_registration_time>0</after_registration_time>\
        <key_mismatch>yes</key_mismatch>\
    </force>' wazuh_manager.conf

# Disable SCA for better alert reading...
sed -i '/<sca>/,/<\/sca>/ s/<enabled>yes<\/enabled>/<enabled>no<\/enabled>/' wazuh_manager.conf

CONF_TO_ADD='

<!-- Allow receiving events via Syslog -->
<ossec_config>
  <remote>
    <connection>syslog</connection>
    <port>514</port>
    <protocol>udp</protocol>
    <allowed-ips>172.16.0.0/12</allowed-ips>
  </remote>
</ossec_config>
'

echo "$CONF_TO_ADD" >> wazuh_manager.conf

sed -i 's:<logall>no</logall>:<logall>yes</logall>:' wazuh_manager.conf

echo ""
curl -sSf -X PUT -H "Authorization: Bearer $JWT" -H "Content-Type: application/octet-stream" -k \
    "https://$WAZUH_MANAGER:55000/manager/configuration?wait_for_complete=true" \
    --data-binary @wazuh_manager.conf # --data-binary preserves newlines

###
### Wazuh Manager restart
###

echo ""
echo "Restarting wazuh manager..."

curl -sSf -X PUT -H "Authorization: Bearer $JWT" -k \
    "https://$WAZUH_MANAGER:55000/manager/restart"

echo ""
echo "Decoders, rules and configuration setup complete"

###
### Update Filebeat pipeline
###

until nc -z "$WAZUH_INDEXER" 9200;
do
    echo "Wazuh Indexer API is not ready yet..."
    sleep 5
done

echo "Updating Filebeat pipeline..."

# Remove -f from curl options, retry the request until
# the pipeline is loaded (it takes some time).
# The awk command trims any leading/trailing spaces and tabs.
until [ "$(curl -sS -k -u "$WAZUH_INDEXER_USER:$WAZUH_INDEXER_PASSWORD" \
    "https://$WAZUH_INDEXER:9200/_ingest/pipeline" | awk '{$1=$1};1')" != "{}" ];
do
    echo "Pipeline is not loaded yet (usually takes a while)..."
    sleep 5
done

PIPELINE="$(curl -sSf -k -u "$WAZUH_INDEXER_USER:$WAZUH_INDEXER_PASSWORD" "https://$WAZUH_INDEXER:9200/_ingest/pipeline")"

echo "Existing pipeline:"
echo "$PIPELINE" | jq -c

# There should be only one pipeline, the Filebeat one.
if [ "$(echo "$PIPELINE" | jq 'keys | length')" != "1" ]; then
    echo "Found 0 or more than 1 ingestion pipeline! There should be only 1! Exiting..."
    exit 1
fi

PIPELINE_NAME="$(echo "$PIPELINE" | jq -r 'keys[0]')"

echo "Pipeline name: $PIPELINE_NAME"


# Renames the "data" field sent by honeypots when they detect a command
# ("action": "command") to "info" because "data" conflicts with an
# existing field in the indexer.
# The "if" condition limits this transformation to logs generated by our honeypot,
# specifically those decoded by the specified decoder (honeypot-syslog).
NEW_PROCESSOR='
{
  "rename": {
    "field": "data.data",
    "target_field": "data.info",
    "ignore_missing": true,
    "if": "(ctx?.decoder?.name == '\''honeypot-syslog'\'')"
  }
}
'
#&& ctx?.data?.data != null


# The pipeline name must be in double quotes (inside single quotes)
# because it contains dots (.) which jq would complain about.
echo "$PIPELINE" | jq '.'"\"$PIPELINE_NAME\""'.processors += ['"$NEW_PROCESSOR"']' \
    | jq '.'"\"$PIPELINE_NAME\"" \
    > updated_pipeline.json

# Update the pipeline
curl -sSf -k -u "$WAZUH_INDEXER_USER:$WAZUH_INDEXER_PASSWORD" -X PUT \
    "https://$WAZUH_INDEXER:9200/_ingest/pipeline/$PIPELINE_NAME" \
    -H "Content-Type: application/json" \
    -d @updated_pipeline.json

# It looks like it is not mandatory to restart Filebeat for the new configuration
# to be applied (there also does not seem to be a way to do so via API).

echo ""
echo "Pipeline updated successfully"
