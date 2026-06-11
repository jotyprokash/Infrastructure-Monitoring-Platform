#!/usr/bin/env bash
set -Eeuo pipefail

INVENTORY_FILE="${INVENTORY_FILE:-inventory/agents.yml}"
TARGET_DIR="${TARGET_DIR:-configs/prometheus/targets}"
SKIP_RELOAD="${SKIP_RELOAD:-false}"

NODE_PROXMOX_FILE="${TARGET_DIR}/node-exporter-proxmox-host.yml"
NODE_LXC_FILE="${TARGET_DIR}/node-exporter-lxc.yml"
NODE_VM_FILE="${TARGET_DIR}/node-exporter-vms.yml"
CADVISOR_FILE="${TARGET_DIR}/cadvisor-docker.yml"
PVE_FILE="${TARGET_DIR}/proxmox-exporter.yml"

trim() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "$value"
}

reset_targets() {
  mkdir -p "$TARGET_DIR"
  for file in "$NODE_PROXMOX_FILE" "$NODE_LXC_FILE" "$NODE_VM_FILE" "$CADVISOR_FILE" "$PVE_FILE"; do
    printf '[]\n' > "$file"
  done
}

ensure_file_group() {
  local file="$1"
  if [ "$(tr -d '[:space:]' < "$file")" = "[]" ]; then
    : > "$file"
  fi
}

append_target() {
  local file="$1"
  local target="$2"
  local role="$3"
  local name="$4"
  local extra_key="${5:-}"
  local extra_value="${6:-}"

  ensure_file_group "$file"
  cat >> "$file" <<EOF
- targets:
  - ${target}
  labels:
    role: ${role}
    name: ${name}
EOF
  if [ -n "$extra_key" ]; then
    printf '    %s: %s\n' "$extra_key" "$extra_value" >> "$file"
  fi
}

flush_agent() {
  [ -n "${name:-}" ] || return 0

  case "${type:-}" in
    proxmox) node_file="$NODE_PROXMOX_FILE"; node_role="proxmox-host" ;;
    lxc) node_file="$NODE_LXC_FILE"; node_role="lxc" ;;
    vm) node_file="$NODE_VM_FILE"; node_role="vm" ;;
    *) printf 'Unsupported type for %s: %s\n' "$name" "${type:-missing}" >&2; exit 1 ;;
  esac

  if [ "${node_exporter:-false}" = "true" ]; then
    append_target "$node_file" "${address}:9100" "$node_role" "$name"
  fi

  if [ "${cadvisor:-false}" = "true" ]; then
    append_target "$CADVISOR_FILE" "${address}:${cadvisor_port:-8080}" "docker" "$name"
  fi

  if [ "${proxmox_exporter:-false}" = "true" ]; then
    append_target "$PVE_FILE" "$address" "proxmox-host" "$name" "environment" "proxmox"
  fi
}

if [ ! -f "$INVENTORY_FILE" ]; then
  printf 'Inventory not found: %s\n' "$INVENTORY_FILE" >&2
  printf 'Create it with: cp inventory/agents.yml.example inventory/agents.yml\n' >&2
  exit 1
fi

reset_targets

name=""
address=""
type=""
node_exporter="false"
cadvisor="false"
cadvisor_port="8080"
proxmox_exporter="false"

while IFS= read -r raw_line || [ -n "$raw_line" ]; do
  line="$(trim "$raw_line")"
  [ -n "$line" ] || continue
  case "$line" in
    agents:) continue ;;
    "- name:"*)
      flush_agent
      name="$(trim "${line#- name:}")"
      address=""
      type=""
      node_exporter="false"
      cadvisor="false"
      cadvisor_port="8080"
      proxmox_exporter="false"
      ;;
    address:*) address="$(trim "${line#address:}")" ;;
    type:*) type="$(trim "${line#type:}")" ;;
    node_exporter:*) node_exporter="$(trim "${line#node_exporter:}")" ;;
    cadvisor:*) cadvisor="$(trim "${line#cadvisor:}")" ;;
    cadvisor_port:*) cadvisor_port="$(trim "${line#cadvisor_port:}")" ;;
    proxmox_exporter:*) proxmox_exporter="$(trim "${line#proxmox_exporter:}")" ;;
  esac
done < "$INVENTORY_FILE"

flush_agent

for file in "$NODE_PROXMOX_FILE" "$NODE_LXC_FILE" "$NODE_VM_FILE" "$CADVISOR_FILE" "$PVE_FILE"; do
  if [ ! -s "$file" ]; then
    printf '[]\n' > "$file"
  fi
done

if [ "$SKIP_RELOAD" = "false" ]; then
  docker compose exec prometheus promtool check config /etc/prometheus/prometheus.yml
  curl -fsS -X POST "http://localhost:${PROMETHEUS_HTTP_PORT:-9090}/-/reload"
fi
printf 'Agent targets synced from %s\n' "$INVENTORY_FILE"
