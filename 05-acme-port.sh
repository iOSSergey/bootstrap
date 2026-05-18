#!/usr/bin/env bash
set -euo pipefail

case "${1:-}" in
  open)
    echo "Opening port 80 for ACME..."
    ufw allow 80/tcp
    ;;
  close)
    echo "Closing port 80..."
    ufw delete allow 80/tcp || true
    ;;
  *)
    echo "Usage: $0 {open|close}"
    exit 1
    ;;
esac

ufw status numbered
