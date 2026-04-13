#!/usr/bin/env bash
set -euo pipefail

APP_NAME="ygti"
SITE_DIR="/var/www/${APP_NAME}"
NGINX_SERVICE="nginx"
PUBLIC_URL="https://ygti.icehe.life/?cheat=1"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

if [[ ! -f "${PROJECT_DIR}/index.html" ]]; then
  echo "index.html not found in ${PROJECT_DIR}" >&2
  exit 1
fi

install -d -m 0755 "${SITE_DIR}"
install -m 0644 "${PROJECT_DIR}/index.html" "${SITE_DIR}/index.html"

if [[ -d "${PROJECT_DIR}/assets" ]]; then
  if command -v rsync >/dev/null 2>&1; then
    rsync -a --delete "${PROJECT_DIR}/assets/" "${SITE_DIR}/assets/"
  else
    rm -rf "${SITE_DIR}/assets"
    cp -R "${PROJECT_DIR}/assets" "${SITE_DIR}/assets"
  fi
fi

if command -v nginx >/dev/null 2>&1; then
  nginx -t
fi

if command -v systemctl >/dev/null 2>&1 && systemctl is-active --quiet "${NGINX_SERVICE}"; then
  systemctl reload "${NGINX_SERVICE}"
fi

sync "${SITE_DIR}"

echo "Deployed ${PROJECT_DIR} -> ${SITE_DIR}"
echo "Refresh: ${PUBLIC_URL}"
