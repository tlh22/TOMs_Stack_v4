#!/bin/sh
# Starts qwc-postgis, waits until Postgres accepts connections, then prints server_version.
# Avoids racing `docker compose exec psql` right after `up` when the server is still starting or has crashed.
#
# Usage (from DOCKER/qwc-mhtc):
#   ./scripts/wait-qwc-postgis-and-show-version.sh
#
# Optional: run repair first (creates missing pg_* subdirs under volumes/db):
#   REPAIR=1 ./scripts/wait-qwc-postgis-and-show-version.sh
#
# Env:
#   MAX_WAIT_SEC  default 120

set -eu

COMPOSE_DIR="${COMPOSE_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$COMPOSE_DIR"
MAX_WAIT_SEC="${MAX_WAIT_SEC:-120}"

dc() { docker compose -f "$COMPOSE_DIR/docker-compose.yml" "$@"; }

log() { echo "[qwc-postgis] $*"; }

if [ "${REPAIR:-}" = "1" ]; then
  log "running repair script first"
  sh "$COMPOSE_DIR/scripts/repair-qwc-postgis-pgdata-subdirs.sh"
fi

log "starting qwc-postgis"
dc up -d qwc-postgis

i=0
while ! dc exec -T qwc-postgis pg_isready -U postgres >/dev/null 2>&1; do
  i=$((i + 1))
  if [ "$i" -gt "$MAX_WAIT_SEC" ]; then
    log "Postgres did not become ready in ${MAX_WAIT_SEC}s. Recent logs:"
    dc logs qwc-postgis --tail=80
    exit 1
  fi
  sleep 1
done

log "ready; server version:"
dc exec -T qwc-postgis psql -U postgres -d postgres -c "SHOW server_version;"
