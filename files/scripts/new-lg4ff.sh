#!/usr/bin/env bash

set -euo pipefail

REPO_URL="https://github.com/berarma/new-lg4ff.git"
WORKDIR="$(mktemp -d)"

cleanup() {
  rm -rf "${WORKDIR}"
}
trap cleanup EXIT

# This runs in a container during image build, so avoid uname -r.
if [[ -d /usr/lib/modules ]]; then
  KVER="$(ls -1 /usr/lib/modules | sort -V | tail -n1)"
else
  echo "ERROR: /usr/lib/modules not found; cannot determine target kernel version" >&2
  exit 1
fi

dnf -y install \
  dkms \
  gcc \
  git \
  make \
  elfutils-libelf-devel \
  "kernel-devel-${KVER}" \
  kernel-core

cd "${WORKDIR}"
git clone --depth=1 "${REPO_URL}" new-lg4ff
cd new-lg4ff

VERSION="$(awk -F'"' '/^PACKAGE_VERSION=/{print $2}' dkms.conf)"
if [[ -z "${VERSION}" ]]; then
  echo "ERROR: could not determine new-lg4ff package version from dkms.conf" >&2
  exit 1
fi

SRC_DIR="/usr/src/new-lg4ff-${VERSION}"
rm -rf "${SRC_DIR}"
install -d "${SRC_DIR}"
cp -a . "${SRC_DIR}"

dkms add -m new-lg4ff -v "${VERSION}"
dkms build -m new-lg4ff -v "${VERSION}" -k "${KVER}"
dkms install -m new-lg4ff -v "${VERSION}" -k "${KVER}"

depmod -a "${KVER}"
