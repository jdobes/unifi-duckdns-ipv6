# UniFi IPv6 DuckDNS updater

A small POSIX shell service in an Alpine container. It connects to the UniFi router over SSH, reads the first usable global IPv6 address from `ip -o -6 addr show scope global`, and updates DuckDNS at startup and whenever that address changes.

## Configuration

| Variable | Description |
| --- | --- |
| `UNIFI_SSH_HOST` | **Required.** Router hostname or address. |
| `UNIFI_SSH_PASSWORD` | **Required.** SSH password. |
| `DUCKDNS_TOKEN` | **Required.** DuckDNS account token. |
| `DUCKDNS_DOMAIN` | **Required.** DuckDNS subdomain, without `duckdns.org`. |
| `POLL_INTERVAL` | Polling period in seconds; defaults to `3600`. |

The script selects the first global IPv6 address and strips its interface prefix length before updating DuckDNS.

## Build and run

SSH connects as `root` on port `22`. The first connection automatically accepts and stores the router's host key; later connections reject a changed key.

Build the image with Podman:

```sh
podman build -t unifi-duckdns-ipv6 .
```

Then run the service:

```sh
podman run \
  --rm \
  --name unifi-duckdns-ipv6 \
  -e UNIFI_SSH_HOST='unifi-router-host' \
  -e UNIFI_SSH_PASSWORD='pass' \
  -e DUCKDNS_TOKEN='your-duckdns-token' \
  -e DUCKDNS_DOMAIN='your-subdomain' \
  -e POLL_INTERVAL=3600 \
  unifi-duckdns-ipv6
```
