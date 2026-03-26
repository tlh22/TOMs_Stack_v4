#!/bin/sh
# Create empty subdirectories that a normal initdb would create, if they are missing.
# Use when Postgres logs: could not open directory "pg_*": No such file or directory
# (often after a partial copy, interrupted init, or manual cleanup).
#
# Run from DOCKER/qwc-mhtc with Docker available (stops qwc-postgis first).
#
# Usage:
#   ./scripts/repair-qwc-postgis-pgdata-subdirs.sh

set -eu

COMPOSE_DIR="${COMPOSE_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
DB_DIR="$COMPOSE_DIR/volumes/db"

dc() { docker compose -f "$COMPOSE_DIR/docker-compose.yml" "$@"; }

log() { echo "[repair-pgdata] $*"; }

if [ ! -d "$DB_DIR" ]; then
  log "missing $DB_DIR"
  exit 1
fi

log "stopping qwc-postgis (if running)"
dc stop qwc-postgis 2>/dev/null || true

for d in \
  pg_notify \
  pg_tblspc \
  pg_replslot \
  pg_stat_tmp \
  pg_stat \
  pg_commit_ts \
  pg_dynshmem \
  pg_serial \
  pg_snapshots \
  pg_twophase \
  pg_logical/snapshots \
  pg_logical/mappings \
  ; do
  if [ ! -d "$DB_DIR/$d" ]; then
    mkdir -p "$DB_DIR/$d"
    chmod 700 "$DB_DIR/$d"
    log "created $DB_DIR/$d"
  fi
done

log "done. Start with: docker compose up -d qwc-postgis"
