#!/usr/bin/env bash
set -Eeuo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOCKER_KEYRING="/etc/apt/keyrings/docker.gpg"
DOCKER_LIST="/etc/apt/sources.list.d/docker.list"

log() {
  printf '[bootstrap] %s\n' "$*"
}

require_ubuntu() {
  if [ ! -r /etc/os-release ]; then
    printf 'Unsupported system: /etc/os-release not found.\n' >&2
    exit 1
  fi

  . /etc/os-release

  if [ "${ID:-}" != "ubuntu" ]; then
    printf 'Unsupported system: expected Ubuntu, found %s.\n' "${ID:-unknown}" >&2
    exit 1
  fi

  if [ "${VERSION_ID:-}" != "24.04" ]; then
    log "Ubuntu ${VERSION_ID:-unknown} detected; this repository targets Ubuntu 24.04."
  fi
}

run_as_root() {
  if [ "$(id -u)" -eq 0 ]; then
    "$@"
  else
    sudo "$@"
  fi
}

install_base_packages() {
  log "Installing base packages."
  run_as_root apt-get update
  run_as_root apt-get install -y ca-certificates curl git gnupg make sudo
}

install_docker_repo() {
  log "Configuring Docker apt repository."
  run_as_root install -m 0755 -d /etc/apt/keyrings

  if [ ! -f "$DOCKER_KEYRING" ]; then
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | run_as_root gpg --dearmor -o "$DOCKER_KEYRING"
  fi

  run_as_root chmod a+r "$DOCKER_KEYRING"

  ARCH="$(dpkg --print-architecture)"
  CODENAME="$(
    . /etc/os-release
    printf '%s' "${VERSION_CODENAME:-noble}"
  )"

  printf 'deb [arch=%s signed-by=%s] https://download.docker.com/linux/ubuntu %s stable\n' "$ARCH" "$DOCKER_KEYRING" "$CODENAME" \
    | run_as_root tee "$DOCKER_LIST" >/dev/null
}

install_docker() {
  if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
    log "Docker and Docker Compose plugin already installed."
  else
    install_docker_repo
    log "Installing Docker Engine and Compose plugin."
    run_as_root apt-get update
    run_as_root apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  fi

  log "Enabling Docker services at boot."
  run_as_root systemctl enable --now containerd
  run_as_root systemctl enable --now docker
}

configure_user() {
  TARGET_USER="${SUDO_USER:-$USER}"

  if getent group docker >/dev/null 2>&1; then
    log "Adding ${TARGET_USER} to docker group."
    run_as_root usermod -aG docker "$TARGET_USER"
  fi
}

init_env() {
  cd "$REPO_ROOT"

  if [ ! -f .env ]; then
    log "Creating .env from .env.example."
    cp .env.example .env
  else
    log ".env already exists."
  fi
}

main() {
  require_ubuntu
  install_base_packages
  install_docker
  configure_user
  init_env

  log "Bootstrap complete."
  log "If this user was newly added to the docker group, log out and back in before deploying."
}

main "$@"
