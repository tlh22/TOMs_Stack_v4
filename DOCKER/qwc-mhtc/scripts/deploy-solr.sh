#!/bin/sh
set -eu

TENANT="${1:-all}"
CORE="${SOLR_CORE:-gdi}"
SOLR_HOST_URL="${SOLR_HOST_URL:-http://localhost:8983/solr}"
COMPOSE_DIR="${COMPOSE_DIR:-.}"
MAX_WAIT_SECONDS="${MAX_WAIT_SECONDS:-300}"
SLEEP_SECONDS="${SLEEP_SECONDS:-2}"
DEPLOY_MODE="${DEPLOY_MODE:-full}"

log() { echo "[$(date -u +"%Y-%m-%dT%H:%M:%SZ")] $*"; }
fail() { log "ERROR: $*"; exit 1; }
dc() { docker compose -f "$COMPOSE_DIR/docker-compose.yml" "$@"; }

wait_http_ok() {
  url="$1"
  elapsed=0
  while [ "$elapsed" -lt "$MAX_WAIT_SECONDS" ]; do
    if curl -fsS "$url" >/dev/null 2>&1; then
      return 0
    fi
    sleep "$SLEEP_SECONDS"
    elapsed=$((elapsed + SLEEP_SECONDS))
  done
  return 1
}

extract_stat() {
  key="$1"
  body="$2"
  printf "%s" "$body" | tr -d '\n' | sed -n "s/.*\"${key}\":\"\\([^\"]*\\)\".*/\\1/p"
}

show_core_status() {
  log "Current core status:"
  curl -fsS "${SOLR_HOST_URL}/admin/cores?action=STATUS&wt=json" || fail "Unable to get core status."
  echo
}

sync_solr_configs() {
  log "Syncing Solr config XMLs into active core conf..."
  dc exec -T qwc-solr sh -lc "cp -f /gdi_conf/conf/*.xml /var/solr/data/${CORE}/conf/" || fail "Config sync failed."
}

reload_core() {
  log "Reloading core '${CORE}'..."
  curl -fsS "${SOLR_HOST_URL}/admin/cores?action=RELOAD&core=${CORE}&wt=json" >/dev/null || fail "Core reload failed."
}

run_import() {
  handler="$1"
  url="${SOLR_HOST_URL}/${CORE}/${handler}"

  http_code="$(curl -s -o /tmp/solr_handler_check.out -w "%{http_code}" "${url}?command=status&wt=json" || true)"
  if [ "$http_code" != "200" ]; then
    log "Skipping ${handler}: handler endpoint not available (HTTP ${http_code})."
    return 0
  fi

  log "Triggering full-import for '${handler}' (clean=false)..."
  curl -fsS "${url}?command=full-import&clean=false&commit=true&wt=json" >/dev/null || fail "Trigger failed: ${handler}"

  elapsed=0
  while [ "$elapsed" -lt "$MAX_WAIT_SECONDS" ]; do
    status_resp="$(curl -fsS "${url}?command=status&wt=json")" || fail "Status failed: ${handler}"
    status="$(printf "%s" "$status_resp" | tr -d '\n' | sed -n 's/.*"status":"\([^"]*\)".*/\1/p')"
    completed_msg="$(printf "%s" "$status_resp" | tr -d '\n' | sed -n 's/.*"Indexing completed\([^"]*\)".*/Indexing completed\1/p')"
    failed_msg="$(printf "%s" "$status_resp" | tr -d '\n' | sed -n 's/.*"Full Import failed":"\([^"]*\)".*/\1/p')"
    docs_processed="$(extract_stat "Total Documents Processed" "$status_resp")"
    docs_skipped="$(extract_stat "Total Documents Skipped" "$status_resp")"

    if [ -n "$failed_msg" ]; then
      fail "Import failed for ${handler} at ${failed_msg}"
    fi

    if [ "$status" = "idle" ] && [ -n "$completed_msg" ]; then
      log "Completed ${handler}: ${completed_msg}"
      [ -n "${docs_processed}" ] && log "Stats ${handler}: processed=${docs_processed} skipped=${docs_skipped:-0}"
      return 0
    fi

    sleep "$SLEEP_SECONDS"
    elapsed=$((elapsed + SLEEP_SECONDS))
  done

  fail "Timed out waiting for completion: ${handler}"
}

run_tenant_imports() {
  case "$1" in
    trdc)
      run_import "trdc_postcode"
      run_import "trdc_road_name"
      ;;
    mhtc)
      run_import "mhtc_road_name"
      ;;
    all)
      run_import "trdc_postcode"
      run_import "trdc_road_name"
      run_import "mhtc_road_name"
      ;;
    *)
      run_import "${1}_postcode"
      run_import "${1}_road_name"
      ;;
  esac
}

verify_docs() {
  log "Verifying indexed document count..."
  all_docs="$(curl -fsS "${SOLR_HOST_URL}/${CORE}/select?q=*:*&rows=0&wt=json" || true)"
  num_docs="$(printf "%s" "$all_docs" | tr -d '\n' | sed -n 's/.*"numFound":\([0-9][0-9]*\).*/\1/p')"
  log "Core '${CORE}' numDocs=${num_docs:-unknown}"
}

log "Starting safe Solr deploy workflow (tenant=${TENANT}, core=${CORE})."
if [ "$DEPLOY_MODE" = "full" ]; then
  log "Ensuring qwc-postgis and qwc-solr are up..."
  dc up -d qwc-postgis qwc-solr >/dev/null
else
  log "DEPLOY_MODE=${DEPLOY_MODE}: API-only reindex."
fi

log "Waiting for Solr HTTP readiness..."
wait_http_ok "${SOLR_HOST_URL}/admin/info/system?wt=json" || fail "Solr is not ready."
show_core_status

if [ "$DEPLOY_MODE" = "full" ]; then
  sync_solr_configs
  reload_core
fi

run_tenant_imports "${TENANT}"
verify_docs

log "Done. Safe deploy workflow completed."
if [ "$DEPLOY_MODE" = "full" ]; then
  log "If permission issues occur:"
  log "  sudo chown -R 8983:8983 ${COMPOSE_DIR}/volumes/solr/data"
fi
