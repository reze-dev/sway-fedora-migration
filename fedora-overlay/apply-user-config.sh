#!/usr/bin/env bash
set -euo pipefail
repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
cp -a "$repo_dir/fedora-overlay/.config/." "$HOME/.config/"
cp -a "$repo_dir/fedora-overlay/.local/." "$HOME/.local/"
for unit in app-nm-applet@autostart.service app-blueman@autostart.service; do
    if systemctl --user is-active --quiet "$unit"; then
        systemctl --user stop "$unit"
    fi
done
if command -v gsettings >/dev/null && gsettings list-schemas | grep -Fxq org.gnome.desktop.interface; then
    gsettings set org.gnome.desktop.interface gtk-theme 'Yaru-dark'
    gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'
    gsettings set org.gnome.desktop.interface font-name 'Inter 11'
    gsettings set org.gnome.desktop.interface cursor-theme 'Adwaita'
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
fi
systemctl --user daemon-reload
if systemctl --user is-active --quiet graphical-session.target; then
    systemctl --user enable --now cliphist.service xsettingsd.service mako.service
else
    systemctl --user enable cliphist.service xsettingsd.service mako.service
fi
if [[ -n "${SWAYSOCK:-}" ]]; then
    swaymsg reload
fi
