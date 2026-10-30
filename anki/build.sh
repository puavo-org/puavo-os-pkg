#!/bin/sh

set -eux

mkdir -p build
cd build

anki_version='26.09.3'

if [ ! -d anki ]; then
  git clone --branch "$anki_version" --depth 1 --recurse-submodules \
    --shallow-submodules https://github.com/ankitects/anki.git
fi

cd anki

sudo apt update
sudo apt install -y ninja-build rustup

RELEASE=2 ./ninja wheels

sudo python3 -m venv --system-site-packages /opt/anki
sudo mkdir -p /opt/anki/icons /opt/anki/share/applications
sudo /opt/anki/bin/pip install out/wheels/*.whl
sudo install -o root -g root -m 644 qt/installer/app/resources/anki.png \
             /opt/anki/icons/anki.png
sudo install -o root -g root -m 644 \
  "./qt/installer/linux-template/{{ cookiecutter.format }}/{{ cookiecutter.app_name }}/anki.desktop" \
             /opt/anki/share/applications/anki.desktop
sudo tar -C / -zcf "/opt/anki-${anki_version}.tar.gz" opt/anki
