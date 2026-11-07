#!/usr/bin/env bash
set -euo pipefail

certificate_root="/etc/letsencrypt/live/waitlist-api.drakestapleton.com"
service_tls_root="/etc/drake-waitlist/tls"

install -d -m 0750 -o root -g drake-waitlist "$service_tls_root"
install -m 0644 -o root -g drake-waitlist "$certificate_root/fullchain.pem" "$service_tls_root/fullchain.pem"
install -m 0640 -o root -g drake-waitlist "$certificate_root/privkey.pem" "$service_tls_root/privkey.pem"
systemctl restart drake-waitlist-api.service
