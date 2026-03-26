#!/bin/sh
# Apply search views into the target DB used by qwc-fulltext-search-service.
# Use this when ./volumes/db-init/*.sql did not run (existing data directory),
# or after restoring/migrating a database.

set -eu

COMPOSE_DIR="${COMPOSE_DIR:-$(cd "$(dirname "$0")/.." && pwd)}"
DB_NAME="${DB_NAME:-threerivers}"
SQL_FILE="$COMPOSE_DIR/volumes/db-init/01_create_search_views.sql"

dc() { docker compose -f "$COMPOSE_DIR/docker-compose.yml" "$@"; }

if [ ! -f "$SQL_FILE" ]; then
  echo "[apply-search-views] missing SQL file: $SQL_FILE"
  exit 1
fi

echo "[apply-search-views] applying $SQL_FILE to database '$DB_NAME'"
dc exec -T qwc-postgis psql -U postgres -d "$DB_NAME" -v ON_ERROR_STOP=1 -f - <"$SQL_FILE"
echo "[apply-search-views] done"
