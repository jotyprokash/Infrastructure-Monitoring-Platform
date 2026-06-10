#!/usr/bin/env bash
set -Eeuo pipefail

usage() {
  cat <<'EOF'
Usage:
  ./scripts/configure-proxmox-exporter.sh <host> <user> <token_name> <token_value> [verify_ssl]

Example:
  ./scripts/configure-proxmox-exporter.sh 192.168.1.1 prometheus@pve monitoring 'TOKEN_SECRET' false
EOF
}

PVE_HOST="${1:-}"
USER_NAME="${2:-}"
TOKEN_NAME="${3:-}"
TOKEN_VALUE="${4:-}"
VERIFY_SSL="${5:-false}"
CONFIG_FILE="configs/proxmox-exporter/pve.yml"
TARGET_FILE="configs/prometheus/targets/proxmox-exporter.yml"

if [ -z "$PVE_HOST" ] || [ -z "$USER_NAME" ] || [ -z "$TOKEN_NAME" ] || [ -z "$TOKEN_VALUE" ]; then
  usage
  exit 1
fi

case "$VERIFY_SSL" in
  true|false) ;;
  *) printf 'verify_ssl must be true or false.\n' >&2; exit 1 ;;
esac

mkdir -p "$(dirname "$CONFIG_FILE")"

cat > "$CONFIG_FILE" <<EOF
default:
  user: ${USER_NAME}
  token_name: ${TOKEN_NAME}
  token_value: ${TOKEN_VALUE}
  verify_ssl: ${VERIFY_SSL}
EOF

chmod 644 "$CONFIG_FILE"

mkdir -p "$(dirname "$TARGET_FILE")"
cat > "$TARGET_FILE" <<EOF
- targets:
  - ${PVE_HOST}
  labels:
    environment: proxmox
    role: proxmox-host
    name: ${PVE_HOST}
EOF

printf 'Wrote %s\n' "$CONFIG_FILE"
printf 'Wrote %s\n' "$TARGET_FILE"
printf 'Restart with: docker compose up -d --force-recreate proxmox-exporter prometheus\n'
