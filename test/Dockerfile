FROM alpine:latest

RUN apk add --no-cache python3 py3-pip

COPY requirements.txt .

RUN pip install --break-system-packages -r requirements.txt

COPY . .

CMD ["sh", "entrypoint.sh"]
