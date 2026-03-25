#!/bin/bash
# IMPORTANT: LF line endings only. Fix with: dos2unix start.sh

set -e

# ── ROOT PHASE ────────────────────────────────────────────────────────────────
# Container starts as root. We fix what we can on the mounted volume, then
# drop to qgisuser. Volume-mounted dirs that can't be fixed are redirected
# to /tmp in the qgisuser phase below -- so permissions NEVER block QGIS.
if [ "$(id -u)" = "0" ]; then
  echo "Running as root -- preparing dirs and dropping to qgisuser..."

  # Fix ownership only on the small set of specifically-mounted dirs.
  # We no longer mount the entire qgis_data tree (see docker-compose.yml)
  # so there is no large recursive chown -- this is fast and safe.
  for dir in \
      /home/qgisuser/qgis_data/profiles/default/python/plugins \
      /home/qgisuser/qgis_data/profiles/default/python/expressions \
      /home/qgisuser/qgis_data/profiles/default/QGIS \
      /home/qgisuser/log_files/toms \
      /home/qgisuser/projects; do
    mkdir -p "$dir"
    chown 1000:1000 "$dir"
    chmod 755 "$dir"
  done

  # Pre-create the auth db dir owned by qgisuser.
  # Lives in /tmp -- never mounted, always writable on all platforms.
  mkdir -p /tmp/qgis-auth-1000
  chown 1000:1000 /tmp/qgis-auth-1000
  chmod 700 /tmp/qgis-auth-1000

  echo "Done. Dropping to qgisuser..."
  exec gosu qgisuser "$0" "$@"
fi
# ── END ROOT PHASE -- everything below runs as qgisuser ──────────────────────

export HOME="/home/qgisuser"
export XDG_RUNTIME_DIR="/tmp/runtime-qgisuser"
mkdir -p "$XDG_RUNTIME_DIR" && chmod 700 "$XDG_RUNTIME_DIR"

# ── Redirect ALL QGIS writable dirs to /tmp ───────────────────────────────────
#
# This is the permanent fix for ALL permission errors on ALL platforms.
#
# The problem: QGIS needs to write to several subdirs inside the profile
# (processing, scripts, cache, auth db). On Windows, Docker Desktop mounts
# volumes as root-owned -- chmod from inside the container does not reliably
# fix this for all nested subdirs. Rather than fighting volume permissions,
# we redirect every writable dir QGIS needs to /tmp paths that are always
# owned by qgisuser.
#
# Dirs redirected:
#   QGIS_AUTH_DB_DIR_PATH  -> qgis-auth.db location  (fixes "private copy" error)
#   QGIS_CUSTOM_CONFIG_PATH stays on the volume for user data (projects, plugins)
#   but processing/scripts/cache are symlinked to /tmp so QGIS can always write

QGIS_TMP="/tmp/qgis-user-$(id -u)"
mkdir -p \
  "${QGIS_TMP}/auth" \
  "${QGIS_TMP}/processing" \
  "${QGIS_TMP}/scripts" \
  "${QGIS_TMP}/cache" \
  "${QGIS_TMP}/tmp"
chmod -R 700 "${QGIS_TMP}"

# Auth db -- redirect entirely to /tmp (fixes "cannot make private copy").
# We use the fixed path /tmp/qgis-auth-1000 which was pre-created and
# chowned to qgisuser in the root phase above.
# BOTH the env var AND --authdbdirectory CLI flag are set to guarantee
# QGIS picks it up regardless of init order.
QGIS_AUTH_DIR="/tmp/qgis-auth-1000"
export QGIS_AUTH_DB_DIR_PATH="$QGIS_AUTH_DIR"

# Processing scripts folder -- redirect to /tmp
export QGIS_PROCESSING_SCRIPTS_FOLDER="${QGIS_TMP}/scripts"

# QGIS custom config path stays on the volume for persistence
export QGIS_CUSTOM_CONFIG_PATH="/home/qgisuser/qgis_data"

# Symlink the dirs QGIS tries to create inside the profile to /tmp
# so even if the volume mount is root-owned, QGIS can always write to them.
# We do this for every dir that causes a PermissionError at QGIS startup.
PROFILE_DIR="/home/qgisuser/qgis_data/profiles/default"

for dir in processing scripts cache; do
  TARGET="${QGIS_TMP}/${dir}"
  LINK="${PROFILE_DIR}/${dir}"
  mkdir -p "$TARGET"
  # If the dir exists on the volume and is writable, leave it alone.
  # If it doesn't exist or is not writable, replace it with a symlink to /tmp.
  if [ -d "$LINK" ] && [ -w "$LINK" ]; then
    echo "Profile dir writable: ${LINK} -- using as-is."
  else
    rm -rf "$LINK" 2>/dev/null || true
    ln -sfn "$TARGET" "$LINK" 2>/dev/null || \
      echo "WARNING: Could not symlink ${LINK} -> ${TARGET}. QGIS may warn."
  fi
done

# TMPDIR for QGIS internal temp files
export TMPDIR="${QGIS_TMP}/tmp"

# Start a minimal dbus session to silence D-Bus notification warnings
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

  # The official qgis/qgis:final-* image already runs xvfb on :99.
  # For all other images we start our own Xvfb.
  if [ -f /tmp/.X99-lock ]; then
    echo "Xvfb already running on :99 (preinstalled base image) -- reusing it."
  else
    echo "======================================"
    echo "Starting virtual display (Xvfb)..."
    echo "======================================"
    rm -f /tmp/.X99-lock /tmp/.X11-unix/X99 2>/dev/null || true
    pkill -9 Xvfb 2>/dev/null || true
    sleep 1
    Xvfb :99 -screen 0 1920x1080x24 &
    sleep 2
  fi

  pkill -9 x11vnc 2>/dev/null || true
  sleep 1
  echo "Starting VNC server (x11vnc) on port 5900..."
  x11vnc -display :99 -nopw -listen 0.0.0.0 -rfbport 5900 -xkb -ncache 10 \
         -ncache_cr -forever -bg \
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
    echo "ERROR: noVNC web root not found. Check that novnc is installed."
    exit 1
  fi

  websockify --web="$NOVNC_PATH" 6080 localhost:5900 \
             --log-file=/home/qgisuser/log_files/websockify.log &
  sleep 2

  echo "======================================"
  echo "VNC is ready:"
  echo "  Browser (noVNC) : http://localhost:6080/vnc.html"
  echo "  Direct VNC      : localhost:5900"
  echo "======================================"
  export DISPLAY=:99

else
  echo "======================================"
  echo "VNC disabled. Using host DISPLAY=${DISPLAY}."
  echo "======================================"
fi

echo "Starting QGIS (${QGIS_BIN})..."

# Run QGIS -- not exec so we can clean up VNC on close
"$QGIS_BIN" --noversioncheck --authdbdirectory "$QGIS_AUTH_DIR" 2>&1 | tee /home/qgisuser/log_files/qgis.log
QGIS_EXIT=${PIPESTATUS[0]}

echo "QGIS exited with code ${QGIS_EXIT}. Shutting down..."
pkill -9 websockify 2>/dev/null || true
pkill -9 x11vnc    2>/dev/null || true

# Exit 0 -- normal close is not an error.
# restart: "no" in docker-compose.yml means container stays stopped.
exit 0