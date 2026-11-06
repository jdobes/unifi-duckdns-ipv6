FROM docker.io/library/alpine:3.24.4@sha256:93b41ef40b1677fce8fcc64ff4af09daddfacf5040afde618bc46c1e2d1cc7d4

RUN apk add --no-cache curl openssh-client sshpass tini

COPY entrypoint.sh /usr/local/bin/unifi-duckdns

ENTRYPOINT ["/sbin/tini", "-g", "--", "/usr/local/bin/unifi-duckdns"]
