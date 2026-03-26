#!/bin/sh
# Apply export compatibility views into DB used by TRDC QGIS project.
# Use when export.* relations are missing after restore/migration.

set -eu

COMPOSE_DIR="${COMPOSE_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
DB_NAME="${DB_NAME:-threerivers}"
SQL_FILE="$COMPOSE_DIR/volumes/db-init/02_create_export_compat_views.sql"

dc() { docker compose -f "$COMPOSE_DIR/docker-compose.yml" "$@"; }

if [ ! -f "$SQL_FILE" ]; then
  echo "[apply-export-compat-views] missing SQL file: $SQL_FILE"
  exit 1
fi

echo "[apply-export-compat-views] applying $SQL_FILE to database '$DB_NAME'"
dc exec -T qwc-postgis psql -U postgres -d "$DB_NAME" -v ON_ERROR_STOP=1 -f - <"$SQL_FILE"
echo "[apply-export-compat-views] done"
