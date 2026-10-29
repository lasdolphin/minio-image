#!/usr/bin/env bash
set -euo pipefail

image="${1:?candidate image is required}"
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
name="minio-verify-${GITHUB_RUN_ID:-local}-$$"
probe="$root/.tmp-tls-probe"

cleanup() {
  docker rm -f "$name" >/dev/null 2>&1 || true
  rm -f "$probe"
}
trap cleanup EXIT

go build -o "$probe" "$root/tests/tls-probe/main.go"
docker run -d --rm --name "$name" -p 9000 \
  -e MINIO_ROOT_USER=minioadmin \
  -e MINIO_ROOT_PASSWORD=minioadmin \
  "$image" >/dev/null

# Docker may return both IPv4 and IPv6 bindings. Select one port before
# constructing the health-check URL, otherwise the embedded newline produces
# an invalid URL for curl.
host_port="$(docker port "$name" 9000/tcp | sed -n '1{s/.*://;p;}')"
test -n "$host_port"

for _ in $(seq 1 30); do
  if curl --fail --silent --show-error "http://127.0.0.1:${host_port}/minio/health/live" >/dev/null; then
    break
  fi
  sleep 1
done

curl --fail --silent --show-error "http://127.0.0.1:${host_port}/minio/health/live" >/dev/null
docker cp "$probe" "$name:/tmp/tls-probe"
docker exec "$name" /tmp/tls-probe
