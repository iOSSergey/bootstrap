#!/usr/bin/env bash
set -euo pipefail

LOG_FILE="/var/log/3xui-install.log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "=== 3X-UI install started: $(date) ==="

if [ "$(id -u)" -ne 0 ]; then
  echo "Run as root"
  exit 1
fi

apt update
apt install -y curl ca-certificates ufw

echo "[1/4] Installing 3X-UI"
bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)

echo "[2/4] Checking service"
systemctl status x-ui --no-pager || true

echo "[3/4] Showing listening ports"
ss -tulpn | grep -E 'x-ui|xray|:443|:2053|:54321' || true

echo "[4/4] Firewall reminder"
echo "IMPORTANT:"
echo "Open only the 3X-UI panel port you selected during installation."
echo "Example:"
echo "ufw allow YOUR_PANEL_PORT/tcp"

echo "=== 3X-UI install finished: $(date) ==="
echo "Log: $LOG_FILE"
