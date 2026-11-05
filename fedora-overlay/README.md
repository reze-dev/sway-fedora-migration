# Fedora 45 user overlay

This is the Fedora-native config currently applied on the Fedora Sway Spin. It keeps Fedora's Sway base config and session integration, then replaces the user-facing appearance and actions with the Ubuntu setup's dark teal style.

## Included behavior

- Kitty is the default terminal; Foot was removed. Fuzzel is the launcher.
- Waybar and Mako use the charcoal/teal palette, with Yaru-dark, Papirus-Dark and Inter for GTK apps.
- The Ubuntu Remix wallpaper is installed as a user-owned background. Sway keeps Fedora's 144 Hz output mode and enables adaptive sync on `eDP-1`.
- Fedora's `tuned-ppd` remains the power-profile backend. Screenshot editing uses `grimshot` and Swappy; clipboard history uses cliphist.
- A user-level layered override disables Fedora's default Print bindings so the Swappy screenshot bindings load without overwrite warnings.
- Fuzzel quick actions provide network, Bluetooth, audio, calendar, process and power menus. Fedora's existing LXQt PolicyKit agent, Waybar, idle/lock rules and Sway systemd integration remain in place.
- Fish, Nushell, Neovim and Starship configs are included. Fish is the account's login shell.

The exact Ubuntu `Yaru-prussiangreen-dark` GTK theme and Bibata cursor were not available in the enabled Fedora 45 repositories. GTK uses Fedora's `Yaru-dark` and Adwaita cursor; the matching Kvantum teal theme is included locally.

## Reapply

Run `./fedora-overlay/apply-user-config.sh` from the repository root. It copies the user config and wallpaper/scripts, reloads user systemd unit metadata, enables the clipboard history, XSettings and Mako services, sets GTK4 theme preferences when the GNOME interface schema is installed, and reloads Sway when run inside the session.

`fedora45-packages.txt` records packages added for this overlay, the relevant packages already present in the Sway Spin, and intentionally omitted alternatives.

The script does not install packages or replace Fedora system files. On this Fedora install, its dependencies are already installed. The QT platform environment values in `~/.config/sway/environment` take full effect after the next Sway login.

Starship 1.27.0 and JetBrainsMono Nerd Font 3.5.1 are upstream user-level installs, not bundled binaries. The Fedora 45 repo does not package Starship, and the available COPR build was outdated. The files in this overlay expect `starship` in `~/.local/bin` and the font family `JetBrainsMono Nerd Font`.
