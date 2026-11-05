# Fedora 45 user overlay

This is the Fedora-native config currently applied on the Fedora Sway Spin. It keeps Fedora's Sway base config and session integration, then replaces the user-facing appearance and actions with the Ubuntu setup's dark teal style.

## Included behavior

- Kitty is the default terminal; Foot was removed. Fuzzel is the launcher.
- Waybar and Mako use the charcoal/teal palette. GTK apps use Yaru Prussian Green Dark, its matching Yaru icons, and Inter; GTK2 gets a matching dark palette shim. Qt5/6 use matching Kvantum and Qt color palettes.
- The Ubuntu Remix wallpaper is installed as a user-owned background. Sway keeps Fedora's 144 Hz output mode and enables adaptive sync on `eDP-1`.
- Fedora's `tuned-ppd` remains the power-profile backend. Screenshot editing uses `grimshot` and Swappy; clipboard history uses cliphist.
- A user-level layered override disables Fedora's default Print bindings so the Swappy screenshot bindings load without overwrite warnings.
- Waybar's `network` and `bluetooth` modules sit after the battery module. Their duplicate NetworkManager and Blueman tray applets are hidden; the tray remains available for other apps.
- The Sway Control Center opens with `Super+Shift+S` or by searching “Sway Control Center” in Fuzzel. One appearance panel synchronizes GTK, Qt/Kvantum, XSettings, Sway, and Flatpak theme, icon, cursor, font, dark-mode, and accent settings. Display, sound, network, and Bluetooth controls are in the same window.
- Fuzzel quick actions provide network, Bluetooth, audio, calendar, process and power menus. Fedora's existing LXQt PolicyKit agent, Waybar, idle/lock rules and Sway systemd integration remain in place.
- Fish, Nushell, Neovim and Starship configs are included. Fish is the account's login shell.

Fedora's Yaru GTK3, GTK4, and icon theme packages provide `Yaru-prussiangreen-dark`; a matching GTK3 Flatpak theme extension is installed from Flathub. The matching Kvantum theme is included locally. Bibata Modern Ice is selected for Sway, GTK, XSettings, Qt, and Flatpak apps. SDDM is the active and enabled login manager for the Sway session.

## Reapply

Run `./fedora-overlay/apply-user-config.sh` from the repository root. It copies the user config and wallpaper/scripts, synchronizes GTK2/3/4, Qt, GNOME and XSettings theme preferences, restores any saved Sway Control Center choices, reloads user systemd unit metadata, enables the clipboard history, XSettings and Mako services, and reloads Sway when run inside the session. Fedora's `lxappearance` and `wdisplays` packages are needed for GTK and display settings; they are hidden as standalone launchers in favor of the Control Center.

`fedora45-packages.txt` records packages added for this overlay, the relevant packages already present in the Sway Spin, and intentionally omitted alternatives.

The script does not install packages or replace Fedora system files. On this Fedora install, its dependencies are already installed. The QT platform environment values in `~/.config/sway/environment` take full effect after the next Sway login.

Starship 1.27.0 and JetBrainsMono Nerd Font 3.5.1 are upstream user-level installs, not bundled binaries. The Fedora 45 repo does not package Starship, and the available COPR build was outdated. The files in this overlay expect `starship` in `~/.local/bin` and the font family `JetBrainsMono Nerd Font`.
