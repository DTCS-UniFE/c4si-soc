FROM alpine:latest

WORKDIR /tests

# Install python, some dependencies and utilities
RUN apk add --no-cache python3 py3-pip git build-base iproute2 tcpreplay

# Compile and install libsnap7
RUN git clone --depth=1 https://github.com/davenardella/snap7 \
    && cd snap7/build/linux \
    && make \
    && make install

COPY requirements.txt .

RUN pip install --break-system-packages -r requirements.txt

COPY . .

CMD ["sh", "entrypoint.sh"]
