# Multi-version QGIS image for TOMs.
#
# This Dockerfile has NO hardcoded version numbers.
# All routing is driven by variables in .env:
#
#   QGIS_VERSION    version string (image tag / container name only)
#   BASE_IMAGE      docker base image (debian:* or ubuntu:* or qgis/qgis:*)
#   QGIS_REPO_TYPE  builtin | backports | qgis-org | qgis-nightly | preinstalled
#   QGIS_SUITE      debian/ubuntu suite name (bookworm, jammy, focal, trixie...)
#   QGIS_QT         5 or 6
#
# Windows + Mac/Linux compatibility:
#   The container starts as ROOT. start.sh detects this, fixes permissions
#   on mounted dirs, then re-execs itself as qgisuser via gosu.
#   No separate entrypoint.sh needed -- start.sh handles both roles.
#
# Supported versions (verified):
#
#   QGIS    BASE_IMAGE                    QGIS_REPO_TYPE   QGIS_SUITE
#   ------  ----------------------------  ---------------  ----------
#   3.22    debian:bookworm-slim          builtin          bookworm
#   3.28    qgis/qgis:final-3_28_13       preinstalled     focal
#   3.34    debian:bookworm-slim          backports        bookworm
#   3.40    debian:bookworm-slim          backports        bookworm
#   3.44    debian:bookworm-slim          qgis-org         bookworm
#   4.x     debian:trixie-slim            qgis-nightly     trixie

ARG BASE_IMAGE=debian:bookworm-slim
FROM ${BASE_IMAGE}

ARG QGIS_VERSION=3.44
ARG QGIS_REPO_TYPE=qgis-org
ARG QGIS_SUITE=bookworm
ARG QGIS_QT=5
ARG USER_ID=1000
ARG GROUP_ID=1000

ENV DEBIAN_FRONTEND=noninteractive

# Force IPv4 for apt
RUN echo 'Acquire::ForceIPv4 "true";' > /etc/apt/apt.conf.d/99force-ipv4

# Bootstrap tools
# gosu cleanly drops root to qgisuser inside start.sh at runtime
# software-properties-common is Ubuntu-only, not available on Debian
RUN apt-get update && apt-get install -y --no-install-recommends \
      gnupg wget ca-certificates gosu \
    && case "${QGIS_SUITE}" in \
         focal|jammy|mantic|noble|oracular|plucky) \
           apt-get install -y --no-install-recommends software-properties-common ;; \
       esac \
    && rm -rf /var/lib/apt/lists/*

# QGIS apt repo setup
RUN set -e; \
    case "${QGIS_SUITE}" in \
      focal|jammy|mantic|noble|oracular|plucky) OS_TYPE="ubuntu" ;; \
      *) OS_TYPE="debian" ;; \
    esac; \
    \
    case "${QGIS_REPO_TYPE}" in \
    \
      preinstalled) \
        echo "QGIS ${QGIS_VERSION}: preinstalled in base image -- skipping repo setup."; \
        ;; \
    \
      builtin) \
        echo "QGIS ${QGIS_VERSION}: using ${QGIS_SUITE} built-in repo."; \
        ;; \
    \
      backports) \
        echo "QGIS ${QGIS_VERSION}: enabling ${QGIS_SUITE}-backports."; \
        echo "deb http://deb.debian.org/debian ${QGIS_SUITE}-backports main" \
          > /etc/apt/sources.list.d/${QGIS_SUITE}-backports.list; \
        ;; \
    \
      qgis-org) \
        echo "QGIS ${QGIS_VERSION}: adding qgis.org/${OS_TYPE} ${QGIS_SUITE}."; \
        mkdir -m755 -p /etc/apt/keyrings /etc/apt/sources.list.d; \
        wget -q -O /etc/apt/keyrings/qgis-archive-keyring.gpg \
          https://download.qgis.org/downloads/qgis-archive-keyring.gpg; \
        echo "deb [signed-by=/etc/apt/keyrings/qgis-archive-keyring.gpg] https://qgis.org/${OS_TYPE} ${QGIS_SUITE} main" \
          > /etc/apt/sources.list.d/qgis.list; \
        ;; \
    \
      qgis-nightly) \
        echo "QGIS ${QGIS_VERSION}: adding qgis.org/debian-nightly-release ${QGIS_SUITE}."; \
        mkdir -m755 -p /etc/apt/keyrings /etc/apt/sources.list.d; \
        wget -q -O /etc/apt/keyrings/qgis-archive-keyring.gpg \
          https://download.qgis.org/downloads/qgis-archive-keyring.gpg; \
        echo "deb [signed-by=/etc/apt/keyrings/qgis-archive-keyring.gpg] https://qgis.org/debian-nightly-release ${QGIS_SUITE} main" \
          > /etc/apt/sources.list.d/qgis.list; \
        ;; \
    \
      *) \
        echo "ERROR: Unknown QGIS_REPO_TYPE '${QGIS_REPO_TYPE}'."; \
        echo "Valid: builtin | backports | qgis-org | qgis-nightly | preinstalled"; \
        exit 1; \
        ;; \
    esac

# Install QGIS + dependencies
RUN set -e; \
    \
    if [ "${QGIS_QT}" = "6" ]; then \
      QT_PKGS=" \
        libqt6gui6 \
        libqt6widgets6 \
        libqt6svg6 \
        libasound2t64 \
        libxcb-cursor0 \
        libxcb-xinerama0 \
        libxcb-xfixes0 \
        libdrm2 \
        libgbm1 \
      "; \
      QT_EXTRA=" \
        qml6-module-qtquick-controls \
        qml6-module-qtquick-layouts \
        qml6-module-qtquick-effects \
      "; \
    else \
      QT_PKGS=" \
        libqt5gui5 \
        libqt5widgets5 \
        libqt5svg5 \
        libasound2 \
        libxcb-icccm4 \
        libxcb-image0 \
        libxcb-keysyms1 \
        libxcb-render-util0 \
      "; \
      QT_EXTRA=""; \
    fi && \
    \
    VNC_PKGS=" \
      x11vnc \
      novnc \
      websockify \
      xterm \
      dbus-x11 \
      libpulse0 \
      libgl1 \
      libglx-mesa0 \
      libegl1 \
      mesa-utils \
      libnss3 \
      libxkbcommon-x11-0 \
      postgresql-client \
    " && \
    \
    apt-get update && \
    \
    case "${QGIS_REPO_TYPE}" in \
    \
      preinstalled) \
        apt-get install -y --no-install-recommends \
          $VNC_PKGS $QT_PKGS; \
        ;; \
    \
      backports) \
        apt-get install -y --no-install-recommends \
          -t ${QGIS_SUITE}-backports qgis python3-qgis && \
        apt-get install -y --no-install-recommends \
          xvfb $VNC_PKGS $QT_PKGS $QT_EXTRA; \
        ;; \
    \
      *) \
        apt-get install -y --no-install-recommends \
          qgis python3-qgis xvfb \
          $VNC_PKGS $QT_PKGS $QT_EXTRA; \
        ;; \
    esac && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Create qgisuser
RUN groupadd -g ${GROUP_ID} qgisgroup 2>/dev/null || true && \
    useradd -m -u ${USER_ID} -g ${GROUP_ID} -s /bin/bash qgisuser 2>/dev/null || true

# Create base directories and set ownership.
# Only the dirs that are NOT volume-mounted need to be created here.
# Volume-mounted dirs are handled at runtime by start.sh after mounts settle.
RUN mkdir -p \
      /home/qgisuser/qgis_data/profiles/default/python/plugins \
      /home/qgisuser/qgis_data/profiles/default/python/expressions \
      /home/qgisuser/qgis_data/profiles/default/QGIS \
      /home/qgisuser/projects \
      /home/qgisuser/log_files \
      /home/qgisuser/log_files/toms && \
    chown -R qgisuser:qgisgroup /home/qgisuser && \
    mkdir -p /tmp/.X11-unix && chmod 1777 /tmp/.X11-unix

# Copy only start.sh -- it serves as both entrypoint (root phase) and
# main script (qgisuser phase). No separate entrypoint.sh needed.
COPY start.sh /start.sh
RUN chmod 755 /start.sh

# Run as root so start.sh can fix permissions before dropping to qgisuser
USER root

ENV DISPLAY=:99
ENV HOME=/home/qgisuser
ENV QT_X11_NO_MITSHM=1
ENV LIBGL_ALWAYS_SOFTWARE=1
ENV QGIS_CUSTOM_CONFIG_PATH=/home/qgisuser/qgis_data
WORKDIR /home/qgisuser
ENTRYPOINT ["/start.sh"]