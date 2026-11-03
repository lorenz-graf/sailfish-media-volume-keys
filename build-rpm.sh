#!/bin/sh
# Builds build/sailfish-media-volume-keys-<version>-<release>.noarch.rpm
# Needs rpmbuild (Arch: pacman -S rpm-tools). Sailfish has rpm 4.16, so the package is
# written in rpm v4 format with a gzip payload (rpm 6 defaults to v6 + zstd), and the
# directory macros are set to Sailfish's values, since the build host's can differ.
set -eu
cd "$(dirname "$0")"

VERSION=1.0

TOP=$(pwd)/build
rm -rf "$TOP" && mkdir -p "$TOP/SOURCES"
cp settings/* LICENSE "$TOP/SOURCES/"

rpmbuild -bb --quiet \
    --define "_topdir $TOP" \
    --define "mvk_version $VERSION" \
    --define "_binary_payload w9.gzdio" \
    --define "_rpmformat 4" \
    --define "_prefix /usr" --define "_datadir /usr/share" \
    rpm/sailfish-media-volume-keys.spec
mv "$TOP"/RPMS/noarch/*.rpm "$TOP/"
echo "built: $(ls "$TOP"/*.rpm)"
