#!/bin/bash
# IMPORTANT: LF line endings only. Fix with: sed -i 's/\r//' start.sh

# ── ROOT PHASE ────────────────────────────────────────────────────────────────
if [ "$(id -u)" = "0" ]; then
  echo "=========================================="
  echo "ROOT PHASE: preparing dirs..."
  echo "=========================================="

  # IMPORTANT: Do NOT use ${UID} here -- it is a bash built-in that always
  # returns 0 for root. Use QGIS_RUN_UID passed from docker-compose.yml instead.
  RUN_UID="${QGIS_RUN_UID:-1000}"
  RUN_GID="${QGIS_RUN_GID:-1000}"

  echo "  Target uid=${RUN_UID} gid=${RUN_GID}"

  QGIS_TMP="/tmp/qgis-user-${RUN_UID}"
  QGIS_AUTH_DIR="/tmp/qgis-auth-${RUN_UID}"

  # Wipe and recreate ALL /tmp dirs as root so there are zero
  # stale ownership issues from any previous container run.
  rm -rf "$QGIS_TMP" "$QGIS_AUTH_DIR" /tmp/runtime-qgisuser 2>/dev/null || true

  for dir in \
      "${QGIS_TMP}/processing" \
      "${QGIS_TMP}/scripts" \
      "${QGIS_TMP}/cache" \
      "${QGIS_TMP}/tmp" \
      "${QGIS_TMP}/expressions" \
      "${QGIS_TMP}/auth" \
      "$QGIS_AUTH_DIR" \
      /tmp/runtime-qgisuser; do
    mkdir -p "$dir"
    chown "${RUN_UID}:${RUN_GID}" "$dir"
    chmod 700 "$dir"
  done

  # Fix ALL volume-mounted dirs.
  # 777 = everyone can read/write/execute.
  # Done as root inside container so no sudo needed on host.
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
    chown "${RUN_UID}:${RUN_GID}" "$dir"
    chmod 777 "$dir"
  done

  # Recursively fix plugins so all group members can add/remove plugins.
  chmod -R 777 /home/qgisuser/qgis_data/profiles/default/python/plugins \
    2>/dev/null || true
  chmod -R 777 /home/qgisuser/plugins \
    2>/dev/null || true

  # setgid so new files created inside plugins inherit the group.
  find /home/qgisuser/qgis_data/profiles/default/python/plugins \
    -type d -exec chmod g+s {} \; 2>/dev/null || true
  find /home/qgisuser/plugins \
    -type d -exec chmod g+s {} \; 2>/dev/null || true

  echo "ROOT PHASE done. Dropping to uid=${RUN_UID} gid=${RUN_GID}..."
  echo "=========================================="
  exec gosu qgisuser "$0" "$@"
fi

# ── END ROOT PHASE -- everything below runs as qgisuser ──────────────────────

echo "=========================================="
echo "USER PHASE: configuring QGIS environment..."
echo "  Running as uid=$(id -u) gid=$(id -g)"
echo "=========================================="

# ── Environment ───────────────────────────────────────────────────────────────
export HOME="/home/qgisuser"
export XDG_RUNTIME_DIR="/tmp/runtime-qgisuser"
export QGIS_CUSTOM_CONFIG_PATH="/home/qgisuser/qgis_data"

QGIS_TMP="/tmp/qgis-user-$(id -u)"
QGIS_AUTH_DIR="/tmp/qgis-auth-$(id -u)"

export QGIS_AUTH_DB_DIR_PATH="$QGIS_AUTH_DIR"
export TMPDIR="${QGIS_TMP}/tmp"
export QGIS_PROCESSING_SCRIPTS_FOLDER="${QGIS_TMP}/scripts"

PROFILE_DIR="/home/qgisuser/qgis_data/profiles/default"
PYTHON_DIR="${PROFILE_DIR}/python"

# ── Verify /tmp dirs -- NO chmod here, root phase handled it ─────────────────
echo "Verifying /tmp dirs..."
for dir in \
    "${QGIS_TMP}/processing" \
    "${QGIS_TMP}/scripts" \
    "${QGIS_TMP}/cache" \
    "${QGIS_TMP}/tmp" \
    "${QGIS_TMP}/expressions" \
    "${QGIS_TMP}/auth" \
    "$QGIS_AUTH_DIR" \
    "$XDG_RUNTIME_DIR"; do
  if [ -w "$dir" ]; then
    echo "  OK: $dir"
  else
    echo "  WARNING: $dir not writable -- QGIS may have issues"
  fi
done

# ── SYMLINKS ──────────────────────────────────────────────────────────────────
echo "Setting up symlinks..."

mkdir -p "$PYTHON_DIR" 2>/dev/null || true
mkdir -p "$PROFILE_DIR" 2>/dev/null || true

# python/expressions -- QGIS writes __init__.py here at every startup.
rm -rf  "${PYTHON_DIR}/expressions"
ln -sfn "${QGIS_TMP}/expressions" "${PYTHON_DIR}/expressions"
echo "  expressions -> ${QGIS_TMP}/expressions"

# processing, scripts, cache
for dir in processing scripts cache; do
  rm -rf  "${PROFILE_DIR}/${dir}"
  ln -sfn "${QGIS_TMP}/${dir}" "${PROFILE_DIR}/${dir}"
  echo "  ${dir} -> ${QGIS_TMP}/${dir}"
done

echo "Symlinks done."
echo "=========================================="

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

"$QGIS_BIN" --noversioncheck --authdbdirectory "$QGIS_AUTH_DIR" \
  2>&1 | tee /home/qgisuser/log_files/qgis.log
QGIS_EXIT=${PIPESTATUS[0]}

echo "QGIS exited with code ${QGIS_EXIT}. Shutting down..."
pkill -9 websockify 2>/dev/null || true
pkill -9 x11vnc    2>/dev/null || true
exit 0