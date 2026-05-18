#!/usr/bin/env bash
set -euo pipefail

mkdir -p ~/bootstrap

if [ ! -d ~/bootstrap/.git ]; then
  git clone https://github.com/iOSSergey/bootstrap.git ~/bootstrap
else
  git -C ~/bootstrap pull
fi

find ~/bootstrap -type f -name "*.sh" -exec chmod +x {} \;

echo "Bootstrap installed"
echo
echo "Run:"
echo "cd ~/bootstrap && ./install.sh"
