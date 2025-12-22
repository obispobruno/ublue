#!/usr/bin/env bash

set -euo pipefail

REPO_URL="https://github.com/Fred78290/nct6687d"
WORKDIR="$(mktemp -d)"

cleanup() {
  rm -rf "${WORKDIR}"
}
trap cleanup EXIT

# IMPORTANT:
# - This script runs during the image build, inside a container.
# - `uname -r` would report the GitHub runner kernel, not the kernel shipped in the image.
#   So we derive the target kernel version from the image's /usr/lib/modules instead.
if [[ -d /usr/lib/modules ]]; then
  KVER="$(ls -1 /usr/lib/modules | sort -V | tail -n1)"
else
  echo "ERROR: /usr/lib/modules not found; cannot determine target kernel version" >&2
  exit 1
fi

dnf -y install \
  gcc \
  git \
  kmod \
  make \
  elfutils-libelf-devel \
  "kernel-devel-${KVER}" \
  kernel-core

cd "${WORKDIR}"
git clone --depth=1 "${REPO_URL}" nct6687d
cd nct6687d

# Build against the kernel shipped in the image (KVER), not the build host kernel.
make -C "/usr/lib/modules/${KVER}/build" M="$PWD" modules

KO_SRC="$(find . -maxdepth 2 -type f -name '*.ko' | head -n1 || true)"
if [[ -z "${KO_SRC}" ]]; then
  echo "ERROR: build succeeded but no .ko file was produced" >&2
  exit 1
fi

KO_DEST="/usr/lib/modules/${KVER}/extra/$(basename "${KO_SRC}")"
install -D -m 0644 "${KO_SRC}" "${KO_DEST}"

depmod -a "${KVER}"

# Ensure the module is loaded on boot (Fedora uses systemd-modules-load, not /etc/modules).
MODNAME="$(modinfo -F name "${KO_DEST}" 2>/dev/null || true)"
if [[ -n "${MODNAME}" ]]; then
  install -D -m 0644 /dev/stdin "/usr/lib/modules-load.d/${MODNAME}.conf" <<<"${MODNAME}"
fi
