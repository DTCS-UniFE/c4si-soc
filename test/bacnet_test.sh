#!/bin/sh

IP="industrial-honeypot"

if [ ! -z "$1" ]; then
    IP="$1"
fi

# Note: disabled most of the tests since they
# don't work due to a bug in Conpot, which
# uses an outdated Bacnet library.

# READ
python -m bacpypes3 2>/dev/null <<EOF
read $IP analog-input,14 present-value
read $IP binary-input,12 present-value
EOF

# READ
# python -m bacpypes3 2>/dev/null <<EOF
# read $IP analog-input,14 present-value
# read $IP binary-input,12 present-value
# read $IP access-door,16 present-value
# read $IP access-door,16 out-of-service
# read $IP access-door,16 maintenance-required
# EOF

# WRITE
# python -m bacpypes3 2>/dev/null <<EOF
# write $IP access-door,16 out-of-service true
# read  $IP access-door,16 out-of-service
# EOF

# python -m bacpypes3 2>/dev/null <<EOF
# write $IP access-door,16 maintenance-required 2
# read  $IP access-door,16 maintenance-required
# EOF

# python -m bacpypes3 2>/dev/null <<EOF
# write $IP analog-input,14 present-value 70.5
# read  $IP analog-input,14 present-value
# EOF

echo "Note: no-responses are due to a bug in conpot! Requests are sent successfully!"
