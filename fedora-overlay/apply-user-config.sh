#!/usr/bin/env bash
set -euo pipefail
repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
cp -a "$repo_dir/fedora-overlay/.config/." "$HOME/.config/"
cp -a "$repo_dir/fedora-overlay/.local/." "$HOME/.local/"
install -m 755 "$repo_dir/fedora-overlay/.local/bin/azotebg" "$HOME/.azotebg"
mkdir -p "$HOME/Pictures/Wallpapers"
wallpaper="$HOME/.local/share/backgrounds/warty-final-ubuntusway.png"
if [[ -f "$wallpaper" && ! -e "$HOME/Pictures/Wallpapers/warty-final-ubuntusway.png" && ! -L "$HOME/Pictures/Wallpapers/warty-final-ubuntusway.png" ]]; then
    ln -s "$wallpaper" "$HOME/Pictures/Wallpapers/warty-final-ubuntusway.png"
fi
if python3 -c 'import azote' >/dev/null 2>&1; then
    python3 - "$HOME" <<'PYAZOTE'
import sys
from pathlib import Path
from azote import common
from azote.tools import Settings
home = Path(sys.argv[1])
common.data_home = str(home / ".local/share/azote")
common.sample_dir = str(home / "Pictures/Wallpapers")
common.azote_config_home = str(home / ".config/azote")
Path(common.data_home).mkdir(parents=True, exist_ok=True)
Path(common.azote_config_home).mkdir(parents=True, exist_ok=True)
settings = Settings()
settings.src_path = common.sample_dir
settings.save()
PYAZOTE
fi
mkdir -p "$HOME/.themes"
cp -a "$repo_dir/fedora-overlay/.themes/." "$HOME/.themes/"
for qt_version in qt5ct qt6ct; do
    qt_config="$HOME/.config/$qt_version/$qt_version.conf"
    sed -i "s|^color_scheme_path=.*|color_scheme_path=$HOME/.config/$qt_version/colors/Yaru-PrussianGreenDark.conf|; s|^custom_palette=.*|custom_palette=true|" "$qt_config"
done
if [[ -f "$HOME/.gtkrc-2.0.mine" ]]; then
    printf 'include "%s/.gtkrc-2.0.mine"\n' "$HOME" > "$HOME/.gtkrc-2.0"
else
    : > "$HOME/.gtkrc-2.0"
fi
cat >> "$HOME/.gtkrc-2.0" <<'GTKRC'
gtk-theme-name="Yaru-prussiangreen-dark"
gtk-icon-theme-name="Yaru-prussiangreen-dark"
gtk-font-name="Inter 11"
gtk-cursor-theme-name="Bibata-Modern-Ice"
gtk-cursor-theme-size=24
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle="hintslight"
gtk-xft-rgba="rgb"
GTKRC
for unit in app-nm-applet@autostart.service app-blueman@autostart.service; do
    if systemctl --user is-active --quiet "$unit"; then
        systemctl --user stop "$unit"
    fi
done
if command -v gsettings >/dev/null && gsettings list-schemas | grep -Fxq org.gnome.desktop.interface; then
    gsettings set org.gnome.desktop.interface gtk-theme 'Yaru-prussiangreen-dark'
    gsettings set org.gnome.desktop.interface icon-theme 'Yaru-prussiangreen-dark'
    gsettings set org.gnome.desktop.interface font-name 'Inter 11'
    gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Ice'
    gsettings set org.gnome.desktop.interface cursor-size 24
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    if gsettings list-keys org.gnome.desktop.interface | grep -Fxq accent-color; then
        gsettings set org.gnome.desktop.interface accent-color 'green'
    fi
fi
if [[ -x "$HOME/.local/bin/sway-control-center" && -f "$HOME/.config/sway-control-center/settings.json" ]]; then
    "$HOME/.local/bin/sway-control-center" --apply-state
fi
if [[ ! -f "$HOME/.config/sway-control-center/settings.json" ]] && command -v flatpak >/dev/null && [[ -r /usr/share/icons/Bibata-Modern-Ice/index.theme ]]; then
    flatpak override --user \
        --filesystem=/usr/share/icons/Bibata-Modern-Ice:ro \
        --env=XCURSOR_THEME=Bibata-Modern-Ice \
        --env=XCURSOR_SIZE=24
fi
systemctl --user daemon-reload
if systemctl --user is-active --quiet graphical-session.target; then
    systemctl --user disable --now cliphist.service 2>/dev/null || true
    systemctl --user enable --now copyq.service xsettingsd.service mako.service
else
    systemctl --user disable cliphist.service 2>/dev/null || true
    systemctl --user enable copyq.service xsettingsd.service mako.service
fi
if systemctl --user is-active --quiet xsettingsd.service; then
    systemctl --user restart xsettingsd.service
fi
if [[ -n "${SWAYSOCK:-}" ]]; then
    swaymsg reload
fi
