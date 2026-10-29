#!/bin/sh
set -eu

log() {
    level=$1
    shift
    printf '%s %s %s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" "$level" "$*"
}

: "${UNIFI_SSH_HOST:?UNIFI_SSH_HOST is required}"
: "${UNIFI_SSH_PASSWORD:?UNIFI_SSH_PASSWORD is required}"
: "${DUCKDNS_TOKEN:?DUCKDNS_TOKEN is required}"
: "${DUCKDNS_DOMAIN:?DUCKDNS_DOMAIN is required}"

POLL_INTERVAL=${POLL_INTERVAL:-3600}

fetch_unifi_ipv6() {
    response=$(SSHPASS="$UNIFI_SSH_PASSWORD" sshpass -e ssh \
        -T \
        -o ConnectTimeout=15 \
        -o StrictHostKeyChecking=accept-new \
        "root@$UNIFI_SSH_HOST" \
        'ip -o -6 addr show scope global') || return 1

    address=$(printf '%s\n' "$response" | awk '
        $3 == "inet6" && $5 == "scope" && $6 == "global" {
            # ip prints an interface prefix; Strip it.
            sub(/\/.*/, "", $4)
            print $4
            exit
        }
    ')
    [ -n "$address" ] || return 1

    printf '%s\n' "$address"
}

update_duckdns() {
    address=$1
    response=$(curl --silent --fail --connect-timeout 10 --max-time 30 \
        --get \
        --data-urlencode "domains=$DUCKDNS_DOMAIN" \
        --data-urlencode "token=$DUCKDNS_TOKEN" \
        --data-urlencode "ipv6=$address" \
        https://www.duckdns.org/update 2>/dev/null) || return 1

    [ "$(printf '%s' "$response" | tr -d '\r\n')" = 'OK' ]
}

last_published_ipv6=
log INFO "starting; polling every ${POLL_INTERVAL}s"

while :; do
    if current_ipv6=$(fetch_unifi_ipv6); then
        if [ "$current_ipv6" != "$last_published_ipv6" ]; then
            log INFO 'WAN IPv6 changed or not yet published; updating DuckDNS'
            if update_duckdns "$current_ipv6"; then
                last_published_ipv6=$current_ipv6
                log INFO "DuckDNS update succeeded; ${DUCKDNS_DOMAIN}.duckdns.org points to $current_ipv6"
            else
                log WARN 'DuckDNS update failed; will retry on the next poll'
            fi
        fi
    else
        log WARN 'could not read a valid global WAN IPv6 address from UniFi over SSH'
    fi

    sleep "$POLL_INTERVAL"
done
