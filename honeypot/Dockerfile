FROM python:3.12-slim

# La dipendenza di honeypots "cgi" in Python 3.13 è stata rinominata
# "legacy-cgi" perchè è stata deprecata. Usiamo python:3.12.

ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

WORKDIR /app

# Per data/ora corretti
ENV TZ=Europe/Rome
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    tzdata \
    gcc \
    python3-dev \
    iproute2 \
    git \
    patch \
    && dpkg-reconfigure -f noninteractive tzdata \
    && rm -rf /var/lib/apt/lists/*

# https://pypi.org/project/honeypots/
#RUN pip install --no-cache-dir honeypots
#RUN pip install --no-cache-dir git+https://github.com/qeeqbox/honeypots

# Cloniamo la repository ed applichiamo una nostra patch per fare in
# modo che i messaggi Syslog contengano JSON valido. Per rendere il
# tutto più future-proof ci spostiamo  un commit preciso.
RUN git clone https://github.com/qeeqbox/honeypots \
    && cd honeypots \
    && git checkout 3f52129fbe9a712e86c54207ceb088c3b2c2af17 \
    && cd ..

COPY syslog_valid_json.patch syslog_json.patch

RUN cd honeypots \
    && patch -p1 < ../syslog_json.patch \
    && cd ..

RUN pip install honeypots/

COPY config.json entrypoint.sh ./

#CMD ["python", "-m", "honeypots", "--config", "config.json"]
CMD ["bash", "entrypoint.sh"]
