#!/usr/bin/env bash
set -Eeuo pipefail

NODE_EXPORTER_VERSION="${NODE_EXPORTER_VERSION:-1.9.1}"
NODE_EXPORTER_LISTEN="${NODE_EXPORTER_LISTEN:-:9100}"
ARCH="$(uname -m)"

case "$ARCH" in
  x86_64) NODE_ARCH="amd64" ;;
  aarch64 | arm64) NODE_ARCH="arm64" ;;
  *) printf 'Unsupported architecture: %s\n' "$ARCH" >&2; exit 1 ;;
esac

run_as_root() {
  if [ "$(id -u)" -eq 0 ]; then
    "$@"
  else
    sudo "$@"
  fi
}

install_packages() {
  run_as_root apt-get update
  run_as_root apt-get install -y ca-certificates curl tar
}

install_binary() {
  tmp_dir="$(mktemp -d)"
  trap 'rm -rf "$tmp_dir"' EXIT

  archive="node_exporter-${NODE_EXPORTER_VERSION}.linux-${NODE_ARCH}.tar.gz"
  url="https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/${archive}"

  curl -fsSL "$url" -o "$tmp_dir/$archive"
  tar -xzf "$tmp_dir/$archive" -C "$tmp_dir"

  run_as_root useradd --system --no-create-home --shell /usr/sbin/nologin node_exporter 2>/dev/null || true
  run_as_root install -m 0755 "$tmp_dir/node_exporter-${NODE_EXPORTER_VERSION}.linux-${NODE_ARCH}/node_exporter" /usr/local/bin/node_exporter
  run_as_root chown node_exporter:node_exporter /usr/local/bin/node_exporter
}

install_service() {
  run_as_root tee /etc/systemd/system/node_exporter.service >/dev/null <<EOF
[Unit]
Description=Prometheus Node Exporter
After=network-online.target
Wants=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter --web.listen-address=${NODE_EXPORTER_LISTEN}
Restart=always
RestartSec=5
NoNewPrivileges=true
ProtectHome=true
ProtectSystem=strict
ProtectControlGroups=true
ProtectKernelModules=true
ProtectKernelTunables=true

[Install]
WantedBy=multi-user.target
EOF

  run_as_root systemctl daemon-reload
  run_as_root systemctl enable --now node_exporter
}

install_packages
install_binary
install_service
systemctl --no-pager --full status node_exporter

