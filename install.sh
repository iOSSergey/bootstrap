#!/usr/bin/env bash
set -euo pipefail

SCRIPTS=(
  "01-base-debian12.sh"
  "02-install-3xui.sh"
  "03-shell-aliases.sh"
  "04-firewall-vpn-ports.sh"
)

for script in "${SCRIPTS[@]}"; do
  echo
  echo "======================================"
  echo "RUNNING: $script"
  echo "======================================"

  chmod +x "$script"
  ./"$script"
done

echo
echo "Bootstrap complete"
