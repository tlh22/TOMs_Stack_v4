#!/bin/sh
# One-time: PG 14 on-disk cluster under volumes/db -> PG 16 (compose image) via pg_dumpall / restore.
# Run from repo host with Docker available. Stops qwc-postgis, dumps with a temporary PG14 container,
# moves the old data dir aside, then starts the stack service and restores into the new cluster.
#
# Usage (from DOCKER/qwc-mhtc):
#   ./scripts/migrate-qwc-postgis-pg14-to-16.sh
#
# First run downloads ~400MB+ of image layers; "Downloading" lines are normal until "Pull complete".
#
# Env:
#   POSTGRES_PASSWORD  default postgis (must match docker-compose qwc-postgis)
#   COMPOSE_DIR        default: directory containing this script's parent (qwc-mhtc)
#   MAX_WAIT_SEC       default 600 — seconds to wait for postgres to accept connections after start

set -eu

COMPOSE_DIR="${COMPOSE_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$COMPOSE_DIR"
DB_DIR="$COMPOSE_DIR/volumes/db"
DUMP="$COMPOSE_DIR/volumes/pg14_dumpall.sql"
PW="${POSTGRES_PASSWORD:-postgis}"
NAME="qwc-mhtc-pg14-dump-$$"
MAX_WAIT_SEC="${MAX_WAIT_SEC:-600}"

dc() { docker compose -f "$COMPOSE_DIR/docker-compose.yml" "$@"; }

log() { echo "[migrate] $*"; }

wait_ready() {
  cmd=$1
  i=0
  while ! eval "$cmd" >/dev/null 2>&1; do
    i=$((i + 1))
    if [ "$i" -gt "$MAX_WAIT_SEC" ]; then
      return 1
    fi
    sleep 1
  done
  return 0
}

if [ ! -d "$DB_DIR" ]; then
  log "missing $DB_DIR"
  exit 1
fi

PG_MAJOR=""
if [ -f "$DB_DIR/PG_VERSION" ]; then
  PG_MAJOR=$(tr -d '\r\n' <"$DB_DIR/PG_VERSION")
elif [ -f "$DB_DIR/docker/PG_VERSION" ]; then
  PG_MAJOR=$(tr -d '\r\n' <"$DB_DIR/docker/PG_VERSION")
fi

# Data dir already matches the PG16 image: do not run a PG14 container (it will fail with "incompatible").
case "$PG_MAJOR" in
16|17|18)
  log "PG_VERSION in $DB_DIR is $PG_MAJOR — data is already a PostgreSQL 16-class cluster."
  log "Nothing to migrate from 14. Empty dirs like pg_notify are normal."
  log "If qwc-postgis exits with missing pg_tblspc/pg_replslot/pg_notify, run:"
  log "  ./scripts/repair-qwc-postgis-pgdata-subdirs.sh"
  log "Start the DB with: docker compose up -d qwc-postgis"
  log "Then: docker compose exec qwc-postgis psql -U postgres -d postgres -c \"SHOW server_version;\""
  exit 0
  ;;
"") log "could not read PG_VERSION under $DB_DIR — is this a valid Postgres data directory?"; exit 1 ;;
esac

# Only PG 14 on-disk data needs the temporary PG14 dump step.
if [ "$PG_MAJOR" != "14" ]; then
  log "PG_VERSION is $PG_MAJOR (not 14). This script only upgrades from 14 -> 16 via dump/restore."
  log "For 15 -> 16, dump with sourcepole/qwc-base-db:15 against the same volume, then restore into a fresh PG16 dir (same steps as this script but use :15 for the dump container)."
  exit 1
fi

# Partial/corrupt data dirs may miss subdirs initdb normally creates.
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
    log "creating missing $DB_DIR/$d"
    mkdir -p "$DB_DIR/$d"
    chmod 700 "$DB_DIR/$d"
  fi
done

if ! docker info >/dev/null 2>&1; then
  log "Docker does not appear to be running"
  exit 1
fi

log "pulling sourcepole/qwc-base-db:14 (one-time; wait until all layers show Pull complete)"
docker pull sourcepole/qwc-base-db:14

log "pulling qwc-postgis image from compose (Postgres 16)"
dc pull qwc-postgis

log "stopping qwc-postgis (if running)"
dc stop qwc-postgis 2>/dev/null || true

log "starting temporary Postgres 14 to read existing data"
docker rm -f "$NAME" 2>/dev/null || true
docker run -d --name "$NAME" \
  -e POSTGRES_PASSWORD="$PW" \
  -v "$DB_DIR:/var/lib/postgresql/docker" \
  sourcepole/qwc-base-db:14

if ! wait_ready "docker exec \"$NAME\" pg_isready -U postgres"; then
  log "Postgres 14 did not become ready within ${MAX_WAIT_SEC}s; logs:"
  docker logs "$NAME" 2>&1 | tail -80
  docker rm -f "$NAME"
  exit 1
fi

log "writing $DUMP"
docker exec -e PGPASSWORD="$PW" "$NAME" pg_dumpall -U postgres >"$DUMP"
docker rm -f "$NAME"

# Basic dump sanity check (pg_dumpall output varies slightly between versions).
if [ ! -s "$DUMP" ] || ! (grep -q "database cluster dump" "$DUMP" 2>/dev/null || grep -q "CREATE DATABASE" "$DUMP" 2>/dev/null); then
  log "dump file looks wrong or empty: $DUMP"
  log "check Postgres 14 logs above; old data dir was not moved"
  exit 1
fi

BACKUP="$COMPOSE_DIR/volumes/db.pg14.backup.$(date -u +%Y%m%dT%H%M%SZ)"
log "moving old data dir to $BACKUP"
mv "$DB_DIR" "$BACKUP"
mkdir -p "$DB_DIR"

log "starting qwc-postgis (Postgres 16)"
dc up -d qwc-postgis

if ! wait_ready "dc exec -T qwc-postgis pg_isready -U postgres"; then
  log "Postgres 16 did not become ready within ${MAX_WAIT_SEC}s"
  dc logs qwc-postgis 2>&1 | tail -80
  exit 1
fi

log "restoring dump into PG16 (this may take a while)"
# Plain pg_dumpall may emit CREATE ROLE for accounts that already exist after initdb; psql continues by default.
dc exec -T -e PGPASSWORD="$PW" qwc-postgis psql -U postgres -f - <"$DUMP"

log "done. Old cluster: $BACKUP  Dump (optional to keep): $DUMP"
