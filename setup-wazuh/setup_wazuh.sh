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
### Aggiunta decoder e regole a Wazuh
###

echo "Checking API liveness..."

until nc -z "$WAZUH_MANAGER" 55000;
do
    echo "Wazuh API is not ready yet..."
    sleep 5
done
# A volte l'API non è pronta a rispondere anche se è contattabile
# sulla porta 55000, aggiungiamo un altro po' di delay
sleep 10

echo "Authenticating to API..."

JWT="$(curl -sSf -X POST -u "$WAZUH_API_USER:$WAZUH_API_PASSWORD" -k \
    "https://$WAZUH_MANAGER:55000/security/user/authenticate" | jq -r .data.token)"

echo "Adding decoders..."

curl -sSf -X PUT -H "Authorization: Bearer $JWT" -H "Content-Type: application/octet-stream" -k \
    "https://$WAZUH_MANAGER:55000/decoders/files/honeypot_decoder.xml?wait_for_complete=true&overwrite=true" \
    --data-binary @honeypot_decoder.xml # --data-binary mantiene i newline

echo ""
echo "Adding rules..."

curl -sSf -X PUT -H "Authorization: Bearer $JWT" -H "Content-Type: application/octet-stream" -k \
    "https://$WAZUH_MANAGER:55000/rules/files/honeypot_rules.xml?wait_for_complete=true&overwrite=true" \
    --data-binary @honeypot_rules.xml # --data-binary mantiene i newline

###
### Aggiornamento configurazione
###

curl -sSf -H "Authorization: Bearer $JWT" -k "https://$WAZUH_MANAGER:55000/manager/configuration?raw=true" > wazuh_manager.conf

CONF_TO_ADD='

<!-- Abilita la ricezione di eventi tramite Syslog -->
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
    --data-binary @wazuh_manager.conf # --data-binary mantiene i newline

###
### Wazuh Manager restart
###

echo ""
echo "Restarting wazuh manager..."

curl -sSf -X PUT -H "Authorization: Bearer $JWT" -k \
    "https://$WAZUH_MANAGER:55000/manager/restart?wait_for_complete=true"

echo ""
echo "Decoders, rules and configuration setup complete"

###
### Update pipeline Filebeat
###

until nc -z "$WAZUH_INDEXER" 9200;
do
    echo "Wazuh Indexer API is not ready yet..."
    sleep 5
done

echo "Updating Filebeat pipeline..."

# Togliamo -f dalle opzioni di curl, riproviamo a fare la richiesta finchè
# la pipeline non è caricata (richiede un po' di tempo).
# Il comando awk serve a togliere eventuali spazi e tab agli estremi.
until [ "$(curl -sS -k -u "$WAZUH_INDEXER_USER:$WAZUH_INDEXER_PASSWORD" \
    "https://$WAZUH_INDEXER:9200/_ingest/pipeline" | awk '{$1=$1};1')" != "{}" ];
do
    echo "Pipeline is not loaded yet (usually takes a while)..."
    sleep 5
done

PIPELINE="$(curl -sSf -k -u "$WAZUH_INDEXER_USER:$WAZUH_INDEXER_PASSWORD" "https://$WAZUH_INDEXER:9200/_ingest/pipeline")"

echo "Pipeline:"
echo "$PIPELINE" | jq -c

# Ci dovrebbe essere una sola pipeline, quella di Filebeat.
if [ "$(echo "$PIPELINE" | jq 'keys | length')" != "1" ]; then
    echo "Trovate 0 o più di 1 pipeline di ingestion! Dovrebbe essercene solo 1! Esco..."
    exit 1
fi

NOME_PIPELINE="$(echo "$PIPELINE" | jq -r 'keys[0]')"

echo "Nome pipeline: $NOME_PIPELINE"

# Rinomina il campo "data" mandato dagli honeypot quando rilevano un comando
# ("action": "command") in "info" perchè "data" va in conflitto con un campo
# già esistente nell'indexer.
# NUOVO_PROCESSOR='
# {
#   "rename": {
#     "field": "data.data",
#     "target_field": "data.info",
#     "if": "(ctx?.data?.action == '\''command'\'')"
#   }
# }
# '

# La condizione "if" limita questa trasformazione ai log generati dal nostro honeypot,
# in particolare quelli decodificati dal decoder specificato (honeypot-syslog)
NUOVO_PROCESSOR='
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


# Il nome della pipeline va messo fra doppi apici (dentro gli apici singoli)
# perchè contiene dei punti (.)
echo "$PIPELINE" | jq '.'"\"$NOME_PIPELINE\""'.processors += ['"$NUOVO_PROCESSOR"']' \
    | jq '.'"\"$NOME_PIPELINE\"" \
    > updated_pipeline.json

# Aggiorna la pipeline
curl -sSf -k -u "$WAZUH_INDEXER_USER:$WAZUH_INDEXER_PASSWORD" -X PUT \
    "https://$WAZUH_INDEXER:9200/_ingest/pipeline/$NOME_PIPELINE" \
    -H "Content-Type: application/json" \
    -d @updated_pipeline.json

# Ho visto che non serve restartare Filebeat perchè venga applicata la
# nuova configurazione (anche perchè non sembra esserci modo tramite l'API)

echo ""
echo "Pipeline aggiornata con successo"
