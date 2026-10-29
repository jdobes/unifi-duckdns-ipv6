FROM docker.io/library/alpine:3.24.3

RUN apk add --no-cache curl openssh-client sshpass tini

COPY entrypoint.sh /usr/local/bin/unifi-duckdns

ENTRYPOINT ["/sbin/tini", "-g", "--", "/usr/local/bin/unifi-duckdns"]
