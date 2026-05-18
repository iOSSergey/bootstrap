#!/usr/bin/env bash
set -euo pipefail

echo "Opening VPN ports..."

ufw allow 443/tcp
ufw allow 8443/tcp

echo "Current UFW status:"
ufw status numbered
