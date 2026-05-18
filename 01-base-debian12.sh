#!/usr/bin/env bash
set -euo pipefail

LOG_FILE="/var/log/server-bootstrap.log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "=== Bootstrap started: $(date) ==="

if [ "$(id -u)" -ne 0 ]; then
  echo "Run as root"
  exit 1
fi

echo "[1/8] Updating system"
apt update
apt upgrade -y

echo "[2/8] Installing base packages"
apt install -y \
  curl wget git nano htop iftop iotop vnstat \
  fail2ban ca-certificates gnupg lsb-release \
  binutils nload fzf zoxide rsync openssl iproute2 \
  sqlite3 unzip jq net-tools dnsutils tcpdump \

echo "[3/8] Setting timezone"
timedatectl set-timezone Europe/Moscow

echo "[4/8] Creating swap if missing"
if ! swapon --show | grep -q "/swapfile"; then
  fallocate -l 2G /swapfile
  chmod 600 /swapfile
  mkswap /swapfile
  swapon /swapfile
  grep -q '^/swapfile ' /etc/fstab || echo '/swapfile none swap sw 0 0' >> /etc/fstab
else
  echo "Swap already exists"
fi

echo "[5/8] Applying sysctl tuning"
cat >/etc/sysctl.d/99-vpn-baseline.conf <<'SYSCTL'
net.core.somaxconn = 4096
net.core.netdev_max_backlog = 4096
net.ipv4.tcp_fin_timeout = 15
net.ipv4.tcp_keepalive_time = 600
net.ipv4.tcp_keepalive_intvl = 60
net.ipv4.tcp_keepalive_probes = 5
net.ipv4.ip_forward = 1
vm.swappiness = 10
SYSCTL

sysctl --system

#echo "[6/8] Configuring UFW"
#ufw allow OpenSSH
#ufw allow 443/tcp
#ufw allow 8443/tcp
#ufw --force enable

echo "[7/8] Configuring Fail2ban (systemd backend)"
cat >/etc/fail2ban/jail.d/sshd.local <<'F2B'
[sshd]
enabled = true
backend = systemd
port = ssh
filter = sshd
maxretry = 5
findtime = 10m
bantime = 1h
F2B

systemctl enable fail2ban
systemctl restart fail2ban

echo "[8/8] Disabling SSH password auth"
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup.$(date +%F-%H%M%S)

sed -i 's/^#\?PasswordAuthentication .*/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/^#\?PermitRootLogin .*/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config

sshd -t
systemctl reload ssh

echo "[9/9] Generating temporary SSL certificate"

mkdir -p /root/ssl-temp

if [ ! -f /root/ssl-temp/cert.pem ]; then
  openssl req -x509 -nodes -days 365 \
  -newkey rsa:2048 \
  -keyout /root/ssl-temp/key.pem \
  -out /root/ssl-temp/cert.pem \
  -subj "/CN=localhost"

  chmod 600 /root/ssl-temp/key.pem
  chmod 644 /root/ssl-temp/cert.pem

  echo "SSL temp cert created at /root/ssl-temp"
else
  echo "SSL temp cert already exists"
fi

echo "=== Bootstrap finished: $(date) ==="
echo "Log: $LOG_FILE"
