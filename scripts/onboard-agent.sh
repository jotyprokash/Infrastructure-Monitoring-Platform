#!/usr/bin/env bash
set -Eeuo pipefail

INVENTORY_FILE="inventory/agents.yml"

usage() {
  cat <<'EOF'
Usage:
  ./scripts/onboard-agent.sh [--name NAME --address IP --type vm|lxc|proxmox] [options]

Options:
  --node-exporter true|false
  --cadvisor true|false
  --cadvisor-port PORT
  --proxmox-exporter true|false

Without flags, the script starts prompt mode.
EOF
}

prompt() {
  local var_name="$1"
  local label="$2"
  local default_value="${3:-}"
  local value

  if [ -n "$default_value" ]; then
    read -r -p "$label [$default_value]: " value
    printf -v "$var_name" '%s' "${value:-$default_value}"
  else
    read -r -p "$label: " value
    printf -v "$var_name" '%s' "$value"
  fi
}

NAME=""
ADDRESS=""
TYPE=""
NODE_EXPORTER="true"
CADVISOR="false"
CADVISOR_PORT="8080"
PROXMOX_EXPORTER="false"

while [ "$#" -gt 0 ]; do
  case "$1" in
    --name) NAME="${2:-}"; shift 2 ;;
    --address) ADDRESS="${2:-}"; shift 2 ;;
    --type) TYPE="${2:-}"; shift 2 ;;
    --node-exporter) NODE_EXPORTER="${2:-}"; shift 2 ;;
    --cadvisor) CADVISOR="${2:-}"; shift 2 ;;
    --cadvisor-port) CADVISOR_PORT="${2:-}"; shift 2 ;;
    --proxmox-exporter) PROXMOX_EXPORTER="${2:-}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) printf 'Unknown option: %s\n' "$1" >&2; usage; exit 1 ;;
  esac
done

if [ -z "$NAME" ] && [ -z "$ADDRESS" ] && [ -z "$TYPE" ]; then
  prompt NAME "Agent display name" "app-vm-01"
  prompt ADDRESS "Agent IP address" "192.168.1.100"
  prompt TYPE "Agent type (vm/lxc/proxmox)" "vm"
  prompt NODE_EXPORTER "Install/register Node Exporter? (true/false)" "true"
  prompt CADVISOR "Install/register cAdvisor? (true/false)" "false"
  if [ "$CADVISOR" = "true" ]; then
    prompt CADVISOR_PORT "cAdvisor port" "8080"
  fi
  if [ "$TYPE" = "proxmox" ]; then
    prompt PROXMOX_EXPORTER "Register Proxmox API exporter? (true/false)" "true"
  fi
fi

case "$TYPE" in
  vm|lxc|proxmox) ;;
  *) printf 'Type must be vm, lxc, or proxmox.\n' >&2; exit 1 ;;
esac

case "$NODE_EXPORTER" in true|false) ;; *) printf 'node-exporter must be true or false.\n' >&2; exit 1 ;; esac
case "$CADVISOR" in true|false) ;; *) printf 'cadvisor must be true or false.\n' >&2; exit 1 ;; esac
case "$PROXMOX_EXPORTER" in true|false) ;; *) printf 'proxmox-exporter must be true or false.\n' >&2; exit 1 ;; esac

if [ -z "$NAME" ] || [ -z "$ADDRESS" ]; then
  usage
  exit 1
fi

mkdir -p "$(dirname "$INVENTORY_FILE")"
if [ ! -f "$INVENTORY_FILE" ]; then
  printf 'agents:\n' > "$INVENTORY_FILE"
fi

if grep -Eq "^[[:space:]]*-[[:space:]]*name:[[:space:]]*${NAME}$" "$INVENTORY_FILE"; then
  printf 'Agent already exists in %s: %s\n' "$INVENTORY_FILE" "$NAME" >&2
  exit 1
fi

cat >> "$INVENTORY_FILE" <<EOF
  - name: ${NAME}
    address: ${ADDRESS}
    type: ${TYPE}
    node_exporter: ${NODE_EXPORTER}
    cadvisor: ${CADVISOR}
    cadvisor_port: ${CADVISOR_PORT}
    proxmox_exporter: ${PROXMOX_EXPORTER}
EOF

printf 'Added %s to %s\n' "$NAME" "$INVENTORY_FILE"
"$(dirname "$0")/sync-agent-targets.sh"

