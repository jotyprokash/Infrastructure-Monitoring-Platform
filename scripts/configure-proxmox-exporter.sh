#!/usr/bin/env bash
set -Eeuo pipefail

usage() {
  cat <<'EOF'
Usage:
  ./scripts/configure-proxmox-exporter.sh <user> <token_name> <token_value> [verify_ssl]

Example:
  ./scripts/configure-proxmox-exporter.sh prometheus@pve monitoring 'TOKEN_SECRET' false
EOF
}

USER_NAME="${1:-}"
TOKEN_NAME="${2:-}"
TOKEN_VALUE="${3:-}"
VERIFY_SSL="${4:-false}"
CONFIG_FILE="configs/proxmox-exporter/pve.yml"

if [ -z "$USER_NAME" ] || [ -z "$TOKEN_NAME" ] || [ -z "$TOKEN_VALUE" ]; then
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

printf 'Wrote %s\n' "$CONFIG_FILE"
printf 'Restart with: docker compose restart proxmox-exporter prometheus\n'
