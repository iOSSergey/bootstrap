#!/usr/bin/env bash
set -euo pipefail

echo "=== Xray / 3X-UI healthcheck ==="

echo
echo "[1] x-ui service"
systemctl status x-ui --no-pager || true

echo
echo "[2] Listening ports"
ss -tulpen | grep -E ':443|:8443|xray|x-ui' || true

echo
echo "[3] BBR"
sysctl net.ipv4.tcp_congestion_control

echo
echo "[4] IPv6"
ip a | grep inet6 || true

echo
echo "[5] UFW"
ufw status numbered

echo
echo "[6] Recent access log"
tail -20 /usr/local/x-ui/access.log || true
