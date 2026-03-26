#!/bin/sh
set -eu

TENANT="${1:-all}"
CORE="${SOLR_CORE:-gdi}"
SOLR_BASE_URL="${SOLR_BASE_URL:-http://localhost:8983/solr/${CORE}}"
MAX_WAIT_SECONDS="${MAX_WAIT_SECONDS:-300}"
SLEEP_SECONDS="${SLEEP_SECONDS:-2}"

log() { echo "[$(date -u +"%Y-%m-%dT%H:%M:%SZ")] $*"; }
fail() { log "ERROR: $*"; exit 1; }

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

run_import() {
  handler="$1"
  url="${SOLR_BASE_URL}/${handler}"

  http_code="$(curl -s -o /tmp/solr_handler_check.out -w "%{http_code}" "${url}?command=status&wt=json" || true)"
  if [ "$http_code" != "200" ]; then
    log "Skipping ${handler}: handler endpoint not available (HTTP ${http_code})."
    return 0
  fi

  log "Triggering full-import for '${handler}'..."
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

log "Waiting for Solr readiness..."
wait_http_ok "${SOLR_BASE_URL}/select?q=*:*&rows=0&wt=json" || fail "Solr core is not ready."

run_tenant_imports "${TENANT}"
log "Done."
