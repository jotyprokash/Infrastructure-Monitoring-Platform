#!/usr/bin/env bash
set -Eeuo pipefail

CADVISOR_IMAGE="${CADVISOR_IMAGE:-gcr.io/cadvisor/cadvisor:v0.52.1}"
CADVISOR_PORT="${CADVISOR_PORT:-8080}"

if ! command -v docker >/dev/null 2>&1; then
  printf 'Docker is required before installing cAdvisor.\n' >&2
  exit 1
fi

docker rm -f cadvisor >/dev/null 2>&1 || true

docker run -d \
  --name cadvisor \
  --restart unless-stopped \
  --privileged \
  --security-opt apparmor=unconfined \
  -p "${CADVISOR_PORT}:8080" \
  -v /:/rootfs:ro \
  -v /var/run:/var/run:ro \
  -v /sys:/sys:ro \
  -v /var/lib/docker:/var/lib/docker:ro \
  -v /dev/disk:/dev/disk:ro \
  "$CADVISOR_IMAGE"

docker ps --filter name=cadvisor

