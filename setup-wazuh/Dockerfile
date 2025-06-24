FROM alpine:latest

RUN apk add curl jq

COPY . .

#CMD ["tail", "-f", "/dev/null"]

CMD ["sh", "setup_wazuh.sh"]
