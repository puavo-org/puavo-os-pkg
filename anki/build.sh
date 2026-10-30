#!/bin/sh

set -eu

mkdir -p build
cd build

anki_version='26.09.3'
anki_tarball="anki-${anki_version}.tar.gz"

if [ ! -e "$anki_tarball" ]; then
  wget -O "$anki_tarball" \
   "https://github.com/ankitects/anki/archive/refs/tags/${anki_version}.tar.gz"
fi
actual_checksum=$(sha256sum "$anki_tarball" | awk '{ print $1 }')
expected_checksum='311dcb406606dccaa0f9f94a5870099a777690e1a056feefe3d75a4bbe4e1416'

if [ "$actual_checksum" != "$expected_checksum" ]; then
  echo "expected ${expected_checksum} but got ${actual_checksum}"
  exit 1
fi

tar -zxf "$anki_tarball"
cd "anki-${anki_version}"

sudo apt update
sudo apt install -y ninja-build rustup

RELEASE=1 ./tools/build
