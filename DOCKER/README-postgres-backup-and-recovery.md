# PostgreSQL Backup, Restore, and Recovery (Docker)

This guide documents the commands used in this workspace for:

- Regular backups
- Restore
- PG14 -> PG16 migration for `qwc-mhtc`
- Data-directory repair when startup fails due to missing `pg_*` folders

---

## 1) Services and Paths

- `DOCKER/postgis` service name: `postgis` (host port `5435`)
- `DOCKER/qwc-mhtc` service name: `qwc-postgis` (host port `5439`)

Main scripts:

- `DOCKER/qwc-mhtc/scripts/migrate-qwc-postgis-pg14-to-16.sh`
- `DOCKER/qwc-mhtc/scripts/repair-qwc-postgis-pgdata-subdirs.sh`
- `DOCKER/qwc-mhtc/scripts/wait-qwc-postgis-and-show-version.sh`

---

## 2) Backup Commands

### A. Full cluster backup (`pg_dumpall`) - postgis

```bash
cd /Users/macbookpro/Documents/TOMs_Stack_v4/DOCKER/postgis
mkdir -p backups
PGPASSWORD=postgis docker compose exec -T postgis pg_dumpall -U postgres > backups/postgis-$(date +%F-%H%M%S)-all.sql
```

### B. Full cluster backup (`pg_dumpall`) - qwc-mhtc

```bash
cd /Users/macbookpro/Documents/TOMs_Stack_v4/DOCKER/qwc-mhtc
mkdir -p backups
PGPASSWORD=postgis docker compose exec -T qwc-postgis pg_dumpall -U postgres > backups/qwc-postgis-$(date +%F-%H%M%S)-all.sql
```

### C. Single database backup (`pg_dump`) example

```bash
cd /Users/macbookpro/Documents/TOMs_Stack_v4/DOCKER/postgis
mkdir -p backups
PGPASSWORD=postgis docker compose exec -T postgis pg_dump -U postgres -d TOMs_Test > backups/TOMs_Test-$(date +%F-%H%M%S).sql
```

---

## 3) Restore Commands

### A. Restore full cluster (`pg_dumpall` file)

```bash
cd /Users/macbookpro/Documents/TOMs_Stack_v4/DOCKER/qwc-mhtc
PGPASSWORD=postgis docker compose exec -T qwc-postgis psql -U postgres -f - < backups/qwc-postgis-YYYY-MM-DD-HHMMSS-all.sql
```

### B. Restore one database dump

```bash
cd /Users/macbookpro/Documents/TOMs_Stack_v4/DOCKER/postgis
PGPASSWORD=postgis docker compose exec -T postgis psql -U postgres -d TOMs_Test -f - < backups/TOMs_Test-YYYY-MM-DD-HHMMSS.sql
```

---

## 4) PG14 -> PG16 Migration (qwc-mhtc)

Use this only if data directory is PG14 and image is PG16.

```bash
cd /Users/macbookpro/Documents/TOMs_Stack_v4/DOCKER/qwc-mhtc
./scripts/migrate-qwc-postgis-pg14-to-16.sh
```

With explicit password (if not default):

```bash
cd /Users/macbookpro/Documents/TOMs_Stack_v4/DOCKER/qwc-mhtc
POSTGRES_PASSWORD='postgis' ./scripts/migrate-qwc-postgis-pg14-to-16.sh
```

What it does:

1. Starts temporary PG14 container against old volume
2. Dumps with `pg_dumpall`
3. Moves old data dir to timestamp backup
4. Starts PG16 container with fresh data dir
5. Restores dump into PG16

---

## 5) Recovery for Missing `pg_*` Directories (qwc-mhtc)

If logs show errors like:

- `could not open directory "pg_tblspc"`
- `could not open directory "pg_replslot"`
- `could not open directory "pg_logical/snapshots"`

Run:

```bash
cd /Users/macbookpro/Documents/TOMs_Stack_v4/DOCKER/qwc-mhtc
./scripts/repair-qwc-postgis-pgdata-subdirs.sh
docker compose up -d qwc-postgis
```

Then verify readiness and version:

```bash
cd /Users/macbookpro/Documents/TOMs_Stack_v4/DOCKER/qwc-mhtc
REPAIR=1 ./scripts/wait-qwc-postgis-and-show-version.sh
```

---

## 6) Verify Databases Exist

`postgis` stack:

```bash
cd /Users/macbookpro/Documents/TOMs_Stack_v4/DOCKER/postgis
PGPASSWORD=postgis docker compose exec -T postgis psql -U postgres -d postgres -c "SELECT datname FROM pg_database ORDER BY 1;"
```

`qwc-mhtc` stack:

```bash
cd /Users/macbookpro/Documents/TOMs_Stack_v4/DOCKER/qwc-mhtc
PGPASSWORD=postgis docker compose exec -T qwc-postgis psql -U postgres -d postgres -c "SELECT datname FROM pg_database ORDER BY 1;"
```

---

## 7) Apply `db-init` SQL to Existing Database

`docker-entrypoint-initdb.d` runs only on first cluster initialization.
If the data directory already exists, SQL files in `./volumes/db-init` are not re-run.

For the TRDC search view fix:

```bash
cd /Users/macbookpro/Documents/TOMs_Stack_v4/DOCKER/qwc-mhtc
./scripts/apply-search-views.sh
```

Optional (different DB):

```bash
cd /Users/macbookpro/Documents/TOMs_Stack_v4/DOCKER/qwc-mhtc
DB_NAME=threerivers ./scripts/apply-search-views.sh
```

---

## 8) Build Export Compatibility Views (TRDC)

If QGIS project expects `export` layers (`Bays`, `Signs`, `Sign_point`, `RestrictionPolygons`, `CPZs`, `Lines`)
but only `toms.*` tables exist, apply compatibility views:

```bash
cd /Users/macbookpro/Documents/TOMs_Stack_v4/DOCKER/qwc-mhtc
./scripts/apply-export-compat-views.sh
```

Optional (different DB):

```bash
cd /Users/macbookpro/Documents/TOMs_Stack_v4/DOCKER/qwc-mhtc
DB_NAME=threerivers ./scripts/apply-export-compat-views.sh
```

Then restart QGIS server:

```bash
cd /Users/macbookpro/Documents/TOMs_Stack_v4/DOCKER/qwc-mhtc
docker compose restart qwc-qgis-server
```

---

## 9) Notes

- If init scripts under `docker-entrypoint-initdb.d` fail with `Permission denied`, make them executable:

```bash
chmod +x DOCKER/postgis/toms_test_db_init_scripts/*.sh
```

- `docker compose up` in foreground can be suspended accidentally (`Ctrl+Z`). Use detached mode for normal operation:

```bash
docker compose up -d
```
