FROM alpine:latest

RUN apk add --no-cache curl jq

COPY . .

CMD ["sh", "setup_wazuh.sh"]
