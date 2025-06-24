#!/bin/bash

TYPE="SYSCALL"
ARCH_X86="40000003"
SYSCALL="5"
MY_UID="$(id -u)"
if [ -z "$MY_UID" ]; then MY_UID="1000"; fi
TTY="$(tty | awk -F"/" '{print $3 $4}')"
if [ -z "$TTY" ]; then TTY="pts1"; fi
this_prog="$(basename "$0")"

function send_log() {
    KEY="audit-wazuh-r" # La chiave identifica un accesso in lettura
    TIMESTAMP="$(date +%s).000:000"
    LOG_LINE="type=$TYPE msg=audit($TIMESTAMP): arch=$ARCH_X86 syscall=$SYSCALL success=yes exit=3 a0=123 a1=123 a2=123 a3=123 items=1 ppid=123 pid=123 auid=$MY_UID uid=$MY_UID gid=$MY_UID euid=$MY_UID suid=$MY_UID fsuid=$MY_UID egid=$MY_UID sgid=$MY_UID fsgid=$MY_UID tty=$TTY ses=1 comm=\"cat\" exe=\"/bin/cat\" key=\"$KEY\""
    echo "$LOG_LINE" | tee -a /home/gb/audit.log
    sleep 1
}

while IFS= read -r -d '' file
do
    filename="$(basename "$file")"
    if [ "$filename" != "$this_prog" ]; then send_log "$filename"; fi 
done <   <(find /home/gb -type f -print0)
