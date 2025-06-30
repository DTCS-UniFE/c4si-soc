FROM python:3.13-alpine

ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

WORKDIR /app

# For correct date/time
RUN apk add --no-cache tzdata \
    && ln -s /usr/share/zoneinfo/Europe/Rome /etc/localtime

RUN apk add --no-cache \
    git \
    patch \
    gcc \
    # this will actually pull musl-dev on Alpine
    libc-dev \
    linux-headers \
    iproute2

# https://pypi.org/project/honeypots/

# The honeypots dependency "cgi" in Python 3.13 has been renamed to "legacy-cgi"
# because "cgi" has been deprecated.
# Note: it looks like installing this library manually is not needed.
#RUN pip install --no-cache-dir legacy-cgi

# Copy our patch
COPY syslog_valid_json.patch syslog_json.patch

# We clone the repository and apply our own patch to
# ensure that Syslog messages contain valid JSON. To make
# everything more future-proof, we checkout to a specific commit.
RUN git clone https://github.com/qeeqbox/honeypots \
    && cd honeypots \
    && git checkout 3f52129fbe9a712e86c54207ceb088c3b2c2af17 \
    && patch -p1 < ../syslog_json.patch \
    && cd ..
    # "cd .." likely unneeded, but for clarity

# netifaces, an indirect dependency, fails to build due to a
# int to "void *". We turn this error into a warning with the
# following CFLAGS variable. This error has appeared with GCC 14
# which Alpine now uses; will need to be fixed from netifaces devs.
RUN CFLAGS="-Wno-int-conversion" pip install honeypots/

COPY config.json entrypoint.sh ./

#CMD ["python", "-m", "honeypots", "--config", "config.json"]
CMD ["sh", "entrypoint.sh"]
