#!/usr/bin/env bash
set -Eeuo pipefail

INSTALL_NODE_EXPORTER="${INSTALL_NODE_EXPORTER:-true}"
INSTALL_CADVISOR="${INSTALL_CADVISOR:-false}"
CADVISOR_PORT="${CADVISOR_PORT:-8080}"
REPO_RAW_BASE="${REPO_RAW_BASE:-https://raw.githubusercontent.com/jotyprokash/Infrastructure-Monitoring-Platform/main/scripts}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TMP_DIR=""

case "$INSTALL_NODE_EXPORTER" in
  true|false) ;;
  *) printf 'INSTALL_NODE_EXPORTER must be true or false.\n' >&2; exit 1 ;;
esac

case "$INSTALL_CADVISOR" in
  true|false) ;;
  *) printf 'INSTALL_CADVISOR must be true or false.\n' >&2; exit 1 ;;
esac

if [ "$INSTALL_NODE_EXPORTER" = "true" ]; then
  node_installer="$SCRIPT_DIR/install-node-exporter.sh"
  if [ ! -f "$node_installer" ]; then
    TMP_DIR="${TMP_DIR:-$(mktemp -d)}"
    node_installer="$TMP_DIR/install-node-exporter.sh"
    curl -fsSL "$REPO_RAW_BASE/install-node-exporter.sh" -o "$node_installer"
    chmod +x "$node_installer"
  fi
  "$node_installer"
fi

if [ "$INSTALL_CADVISOR" = "true" ]; then
  cadvisor_installer="$SCRIPT_DIR/install-cadvisor-agent.sh"
  if [ ! -f "$cadvisor_installer" ]; then
    TMP_DIR="${TMP_DIR:-$(mktemp -d)}"
    cadvisor_installer="$TMP_DIR/install-cadvisor-agent.sh"
    curl -fsSL "$REPO_RAW_BASE/install-cadvisor-agent.sh" -o "$cadvisor_installer"
    chmod +x "$cadvisor_installer"
  fi
  CADVISOR_PORT="$CADVISOR_PORT" "$cadvisor_installer"
fi

if [ -n "$TMP_DIR" ]; then
  rm -rf "$TMP_DIR"
fi

printf 'Agent install complete.\n'
