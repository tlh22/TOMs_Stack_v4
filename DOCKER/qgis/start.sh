#!/bin/bash
# IMPORTANT: LF line endings only. Fix with: dos2unix start.sh

set -e

# ── ROOT PHASE ────────────────────────────────────────────────────────────────
# Container starts as root. We pre-create ALL /tmp dirs owned by qgisuser,
# fix ownership on mounted dirs, then drop to qgisuser via gosu.
if [ "$(id -u)" = "0" ]; then
  echo "=========================================="
  echo "ROOT PHASE: preparing dirs..."
  echo "=========================================="

  # Pre-create ALL /tmp working dirs owned by qgisuser BEFORE gosu drops.
  # These are never volume-mounted so they are always writable on all platforms.
  QGIS_TMP="/tmp/qgis-user-1000"
  for dir in \
      "${QGIS_TMP}/processing" \
      "${QGIS_TMP}/scripts" \
      "${QGIS_TMP}/cache" \
      "${QGIS_TMP}/tmp" \
      "${QGIS_TMP}/expressions" \
      "${QGIS_TMP}/auth" \
      /tmp/qgis-auth-1000 \
      /tmp/runtime-qgisuser; do
    mkdir -p "$dir"
    chown 1000:1000 "$dir"
    chmod 700 "$dir"
  done

  # Fix ownership on ALL dirs QGIS needs -- including volume-mounted ones.
  # mkdir -p is safe -- does nothing if dir already exists.
  # We do NOT mount expressions as a volume (see docker-compose.yml) so
  # it is safe to chown it here and symlink it in the user phase.
  for dir in \
      /home/qgisuser/qgis_data \
      /home/qgisuser/qgis_data/profiles \
      /home/qgisuser/qgis_data/profiles/default \
      /home/qgisuser/qgis_data/profiles/default/python \
      /home/qgisuser/qgis_data/profiles/default/python/plugins \
      /home/qgisuser/qgis_data/profiles/default/QGIS \
      /home/qgisuser/qgis_data/profiles/default/processing \
      /home/qgisuser/qgis_data/profiles/default/scripts \
      /home/qgisuser/qgis_data/profiles/default/cache \
      /home/qgisuser/log_files \
      /home/qgisuser/log_files/toms \
      /home/qgisuser/projects \
      /home/qgisuser/plugins; do
    mkdir -p "$dir"
    chown 1000:1000 "$dir"
    chmod 755 "$dir"
  done

  echo "ROOT PHASE done. Dropping to qgisuser..."
  echo "=========================================="
  exec gosu qgisuser "$0" "$@"
fi
# ── END ROOT PHASE -- everything below runs as qgisuser ──────────────────────

echo "=========================================="
echo "USER PHASE: configuring QGIS environment..."
echo "=========================================="

# ── Environment ───────────────────────────────────────────────────────────────
export HOME="/home/qgisuser"
export XDG_RUNTIME_DIR="/tmp/runtime-qgisuser"
export QGIS_CUSTOM_CONFIG_PATH="/home/qgisuser/qgis_data"
export QGIS_AUTH_DB_DIR_PATH="/tmp/qgis-auth-1000"

QGIS_TMP="/tmp/qgis-user-$(id -u)"
QGIS_AUTH_DIR="/tmp/qgis-auth-1000"
PROFILE_DIR="/home/qgisuser/qgis_data/profiles/default"
PYTHON_DIR="${PROFILE_DIR}/python"

export TMPDIR="${QGIS_TMP}/tmp"
export QGIS_PROCESSING_SCRIPTS_FOLDER="${QGIS_TMP}/scripts"

# Safety net -- ensure all /tmp dirs exist and are writable
# (in case root phase missed anything or id -u differs from 1000)
for dir in \
    "${QGIS_TMP}/processing" \
    "${QGIS_TMP}/scripts" \
    "${QGIS_TMP}/cache" \
    "${QGIS_TMP}/tmp" \
    "${QGIS_TMP}/expressions" \
    "${QGIS_TMP}/auth" \
    "$QGIS_AUTH_DIR" \
    "$XDG_RUNTIME_DIR"; do
  mkdir -p "$dir"
  chmod 700 "$dir"
done

# ── SYMLINKS: redirect ALL writable profile dirs to /tmp ──────────────────────
#
# WHY SYMLINKS:
# Docker creates volume-mounted dirs as root-owned at runtime on ALL platforms.
# chown in the root phase fixes top-level dirs but Docker can recreate them
# as root on next restart. The only 100% reliable fix across Windows, Mac,
# Linux and Google Cloud is to ALWAYS symlink these dirs to /tmp paths that
# we pre-created and own.
#
# IMPORTANT: expressions is NOT volume-mounted (see docker-compose.yml).
# This means rm -rf works on it -- no "Device or resource busy" error.
# processing/scripts/cache are also not volume-mounted for the same reason.
# Only plugins and QGIS settings are volume-mounted (they need to persist).

echo "Setting up symlinks for writable profile dirs..."

# Ensure parent dirs exist
mkdir -p "$PYTHON_DIR"
mkdir -p "$PROFILE_DIR"

# python/expressions -- QGIS writes __init__.py here at every startup.
# NOT volume-mounted so rm -rf is safe.
rm -rf  "${PYTHON_DIR}/expressions"
ln -sfn "${QGIS_TMP}/expressions" "${PYTHON_DIR}/expressions"
echo "  expressions -> ${QGIS_TMP}/expressions"

# processing, scripts, cache -- QGIS writes here during normal use.
# NOT volume-mounted so rm -rf is safe.
for dir in processing scripts cache; do
  rm -rf  "${PROFILE_DIR}/${dir}"
  ln -sfn "${QGIS_TMP}/${dir}" "${PROFILE_DIR}/${dir}"
  echo "  ${dir} -> ${QGIS_TMP}/${dir}"
done

echo "Symlinks done."

# ── D-Bus ─────────────────────────────────────────────────────────────────────
if command -v dbus-launch >/dev/null 2>&1; then
  eval "$(dbus-launch --sh-syntax)" 2>/dev/null || true
fi

# ── Verify QGIS binary ────────────────────────────────────────────────────────
QGIS_BIN="qgis"
if ! command -v "$QGIS_BIN" >/dev/null 2>&1; then
  echo "ERROR: QGIS binary '$QGIS_BIN' not found. Check the build log."
  exit 1
fi

# ── VNC setup ─────────────────────────────────────────────────────────────────
USE_VNC="${USE_VNC:-1}"
if [ "$USE_VNC" = "0" ] || [ "$USE_VNC" = "false" ] || [ "$USE_VNC" = "no" ]; then
  USE_VNC=0
else
  USE_VNC=1
fi

if [ "$USE_VNC" = "1" ]; then

  if [ -f /tmp/.X99-lock ]; then
    echo "Xvfb already running on :99 (preinstalled base image) -- reusing."
  else
    echo "=========================================="
    echo "Starting virtual display (Xvfb)..."
    echo "=========================================="
    rm -f /tmp/.X99-lock /tmp/.X11-unix/X99 2>/dev/null || true
    pkill -9 Xvfb 2>/dev/null || true
    sleep 1
    Xvfb :99 -screen 0 1920x1080x24 &
    sleep 2
  fi

  pkill -9 x11vnc 2>/dev/null || true
  sleep 1
  echo "Starting VNC server (x11vnc) on port 5900..."
  x11vnc -display :99 -nopw -listen 0.0.0.0 -rfbport 5900 -xkb \
         -ncache 10 -ncache_cr -forever -bg \
         -o /home/qgisuser/log_files/x11vnc.log
  sleep 2

  pkill -9 websockify 2>/dev/null || true
  sleep 1
  echo "Starting noVNC..."
  NOVNC_PATH=""
  for candidate in /usr/share/novnc /usr/share/noVNC /usr/share/novnc/; do
    if [ -d "$candidate" ]; then
      NOVNC_PATH="$candidate"
      break
    fi
  done
  if [ -z "$NOVNC_PATH" ]; then
    echo "ERROR: noVNC web root not found. Is novnc installed?"
    exit 1
  fi

  websockify --web="$NOVNC_PATH" 6080 localhost:5900 \
             --log-file=/home/qgisuser/log_files/websockify.log &
  sleep 2

  echo "=========================================="
  echo "VNC is ready:"
  echo "  Browser (noVNC) : http://localhost:6080/vnc.html"
  echo "  Direct VNC      : localhost:5900"
  echo "=========================================="
  export DISPLAY=:99

else
  echo "=========================================="
  echo "VNC disabled. Using host DISPLAY=${DISPLAY}."
  echo "=========================================="
fi

# ── Launch QGIS ───────────────────────────────────────────────────────────────
echo "=========================================="
echo "Starting QGIS..."
echo "  QGIS_CUSTOM_CONFIG_PATH : $QGIS_CUSTOM_CONFIG_PATH"
echo "  QGIS_AUTH_DB_DIR_PATH   : $QGIS_AUTH_DB_DIR_PATH"
echo "  DISPLAY                 : $DISPLAY"
echo "  XDG_RUNTIME_DIR         : $XDG_RUNTIME_DIR"
echo "=========================================="

# Not exec -- we need to run cleanup after QGIS closes
"$QGIS_BIN" --noversioncheck --authdbdirectory "$QGIS_AUTH_DIR" \
  2>&1 | tee /home/qgisuser/log_files/qgis.log
QGIS_EXIT=${PIPESTATUS[0]}

echo "QGIS exited with code ${QGIS_EXIT}. Shutting down..."
pkill -9 websockify 2>/dev/null || true
pkill -9 x11vnc    2>/dev/null || true

# Exit 0 -- normal QGIS close is not an error.
exit 0