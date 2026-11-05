#!/usr/bin/env bash
set -euo pipefail

if [[ ${EUID} -ne 0 ]]; then
    echo "Run this script with sudo." >&2
    exit 1
fi

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
source_dir="$repo_dir/fedora-overlay/sddm/ronin"
theme_dir=/usr/share/sddm/themes/ronin
font_dir=/usr/share/fonts/ronin-sddm

if ! rpm -q qt6-qt5compat >/dev/null; then
    echo "Install qt6-qt5compat first (dnf install qt6-qt5compat)." >&2
    exit 1
fi

install -d "$theme_dir" "$font_dir" /etc/sddm.conf.d
cp -a "$source_dir/." "$theme_dir/"
install -m 0644 "$source_dir/fonts/JetBrainsMonoNerdFont-Regular.ttf" "$font_dir/"
install -m 0644 "$source_dir/fonts/OFL.txt" "$font_dir/"
fc-cache -f "$font_dir"

cat > /etc/sddm.conf.d/99-ronin-theme.conf <<'SDDMCONF'
[Theme]
Current=ronin
SDDMCONF

echo "Ronin is selected for the next SDDM start."
