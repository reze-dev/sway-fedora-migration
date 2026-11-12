#!/usr/bin/env bash
# Build and install the swaybg-provider shim.
#
# swaybg is not installed, because the awww daemon paints the wallpaper
# instead. swaybg is a hard dependency of sway-config-fedora, which owns the
# SDDM session entry point (start-sway, sway.desktop), the layered-include
# helper that the Sway config includes, and the sway config.d fragments.
# Removing swaybg through dnf would therefore cascade into removing
# sway-config-fedora, sway-systemd, sddm, sddm-wayland-sway and swayfx,
# leaving no way to log in graphically.
#
# So swaybg is removed with "rpm -e --nodeps" instead, and this shim
# provides the "swaybg" capability so that the dependency is satisfied and
# "dnf check" stays clean. The shim ships no binary.
set -euo pipefail

if [[ ${EUID} -ne 0 ]]; then
    echo "Run this script with sudo." >&2
    exit 1
fi

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
spec_dir="$repo_dir/fedora-overlay/rpm/swaybg-provider"

if ! command -v rpmbuild >/dev/null; then
    echo "rpmbuild is required (dnf install rpm-build)." >&2
    exit 1
fi

build_dir=$(mktemp -d)
trap 'rm -rf "$build_dir"' EXIT

mkdir -p "$build_dir"/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
rpmbuild \
    --define "_topdir $build_dir" \
    --define "_sourcedir $spec_dir" \
    --define "_specdir $spec_dir" \
    -bb "$spec_dir/swaybg-provider.spec"

dnf install -y "$build_dir"/RPMS/noarch/swaybg-provider-*.noarch.rpm

echo "swaybg-provider is installed; dnf check should now be clean."
