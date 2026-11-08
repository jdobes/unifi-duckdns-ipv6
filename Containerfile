FROM docker.io/library/alpine:3.24.4@sha256:f59abe656b692d901e184be3445e084786602108599d2a51d229c0f5a48c71bf

RUN apk add --no-cache curl openssh-client sshpass tini

COPY entrypoint.sh /usr/local/bin/unifi-duckdns

ENTRYPOINT ["/sbin/tini", "-g", "--", "/usr/local/bin/unifi-duckdns"]
