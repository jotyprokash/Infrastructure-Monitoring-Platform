#!/usr/bin/env bash
set -Eeuo pipefail

usage() {
  cat <<'EOF'
Usage:
  ./scripts/register-target.sh <job> <target> <role> [name]

Jobs:
  node-exporter-proxmox-host
  node-exporter-lxc
  node-exporter-vms
  cadvisor-defectdojo-vm

Examples:
  ./scripts/register-target.sh node-exporter-proxmox-host 192.168.1.2:9100 proxmox-host pve01
  ./scripts/register-target.sh node-exporter-lxc 192.168.1.30:9100 lxc monitoring
  ./scripts/register-target.sh node-exporter-vms 192.168.1.40:9100 vm defectdojo
  ./scripts/register-target.sh cadvisor-defectdojo-vm 192.168.1.40:8080 defectdojo-vm defectdojo
EOF
}

JOB="${1:-}"
TARGET="${2:-}"
ROLE="${3:-}"
NAME="${4:-$TARGET}"

if [ -z "$JOB" ] || [ -z "$TARGET" ] || [ -z "$ROLE" ]; then
  usage
  exit 1
fi

case "$JOB" in
  node-exporter-proxmox-host|node-exporter-lxc|node-exporter-vms|cadvisor-defectdojo-vm) ;;
  *) printf 'Unsupported job: %s\n' "$JOB" >&2; usage; exit 1 ;;
esac

TARGET_FILE="configs/prometheus/targets/${JOB}.yml"
mkdir -p "$(dirname "$TARGET_FILE")"

if [ ! -f "$TARGET_FILE" ] || [ "$(tr -d '[:space:]' < "$TARGET_FILE")" = "[]" ]; then
  : > "$TARGET_FILE"
fi

if grep -Fq -- "- ${TARGET}" "$TARGET_FILE"; then
  printf 'Target already registered: %s\n' "$TARGET"
else
  cat >> "$TARGET_FILE" <<EOF
- targets:
  - ${TARGET}
  labels:
    role: ${ROLE}
    name: ${NAME}
EOF
  printf 'Registered %s in %s\n' "$TARGET" "$TARGET_FILE"
fi

docker compose exec prometheus promtool check config /etc/prometheus/prometheus.yml
curl -fsS -X POST "http://localhost:${PROMETHEUS_HTTP_PORT:-9090}/-/reload"
