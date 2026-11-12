# Fedora 45 user overlay

This is the Fedora-native config currently applied on the Fedora Sway Spin. It keeps Fedora's Sway config and session integration, runs SwayFX in place of Fedora's Sway binary, then applies the Ubuntu setup's dark teal style.

## Included behavior

- Kitty is the default terminal; Foot was removed. Kitty uses the independent upstream Rosé Pine theme, which the Sway Control Center leaves untouched. The rocket button and Super+D open nwggrid, a searchable visual application grid; Fuzzel remains available for compact quick-action menus.
- Waybar runs as the Fedora systemd user service, independently of Sway’s bar command; a Sway config override disables compositor-managed bar launches to prevent duplicates. It starts once per graphical session. Waybar and Mako use the charcoal/teal palette. GTK apps use Yaru Prussian Green Dark, its matching Yaru icons, and Inter; GTK2 gets a matching dark palette shim. Qt5/6 use matching Kvantum and Qt color palettes.
- The Ubuntu Remix wallpaper is installed as a user-owned background. Sway Control Center includes a wallpaper picker and scaling selector; the selected image is restored on login. Wallpapers are painted by the `awww` daemon (upstream `swww`, renamed and moved to Codeberg) instead of `swaybg`. `awww` is packaged by the Terra repository, so it is installed with `dnf install --repo terra awww` rather than built from source. The `awww.service` user unit starts the daemon, and `~/.local/bin/sway-set-wallpaper` turns the saved Sway Control Center choice into an `awww img` call. Sway's own `output * bg` directive is absent and `swaybg_command -` disables Sway's built-in `swaybg` spawn, so only one process ever paints the background layer. Open the control center with Super+Shift+W. Sway keeps Fedora's 144 Hz output mode; adaptive sync (VRR) is disabled on `eDP-1`, because with VRR enabled a pointer repaint changes the panel refresh timing and shows up as a subtle full-screen flicker on cursor movement.
- Fedora's `tuned-ppd` remains the power-profile backend. Screenshot editing uses `grimshot` and Swappy; clipboard history uses CopyQ (the previous cliphist database is retained on upgraded systems).
- A user-level layered override disables Fedora's default Print bindings so the Swappy screenshot bindings load without overwrite warnings.
- Waybar's `network` and `bluetooth` modules sit after the battery module. Their duplicate NetworkManager and Blueman tray applets are hidden; the tray remains available for other apps.
- Waybar's info icon opens a searchable list of the active Sway keybindings.
- The Sway Control Center opens with `Super+Shift+S` or by searching “Sway Control Center” in Fuzzel. One appearance panel synchronizes GTK, Qt/Kvantum, XSettings, Sway, and Flatpak theme, icon, cursor, font, dark-mode, and accent settings. It leaves Kitty's Rosé Pine theme untouched. Display, sound, network, and Bluetooth controls are in the same window.
- SDDM uses the Ronin theme from the `ronin` branch of `mahaveergurjar/sddm`, with the matching `16.jpeg` wallpaper from the author's Hyprlock-Dots repository, a dynamic account greeting, and the SDDM Qt6 compatibility module. Run `sudo ./fedora-overlay/install-sddm-ronin.sh` to install or reapply it.
- Fuzzel quick actions provide network, Bluetooth, audio, calendar, process and power menus. nwggrid provides the app drawer. Fedora's existing LXQt PolicyKit agent, Waybar, idle/lock rules and Sway systemd integration remain in place.
- Fish, Nushell, Neovim and Starship configs are included. Fish is the account's login shell.

Fedora's Yaru GTK3, GTK4, and icon theme packages provide `Yaru-prussiangreen-dark`; a matching GTK3 Flatpak theme extension is installed from Flathub. The matching Kvantum theme is included locally. Bibata Modern Ice is selected for Sway, GTK, XSettings, Qt, and Flatpak apps. SDDM is the active and enabled login manager for the Sway session.

## Reapply

Run `./fedora-overlay/apply-user-config.sh` from the repository root. It copies the user config and wallpaper/scripts, synchronizes GTK2/3/4, Qt, GNOME and XSettings theme preferences, restores any saved Sway Control Center choices, reloads user systemd unit metadata, enables the clipboard history, XSettings, Mako and Waybar services, and reloads Sway when run inside the session. The appearance controls live in Sway Control Center. GNOME Tweaks and LXAppearance have been removed; Qt5ct and Qt6ct remain installed as hidden Qt theme backends, and wdisplays remains available for display layout. Apply the SDDM greeter theme separately with `sudo ./fedora-overlay/install-sddm-ronin.sh`; it takes effect at the next SDDM start.

`fedora45-packages.txt` records packages added for this overlay, the relevant packages already present in the Sway Spin, and intentionally omitted alternatives.

The script does not install packages or replace Fedora system files. On this Fedora install, its dependencies are already installed. The QT platform environment values in `~/.config/sway/environment` take full effect after the next Sway login.

Starship 1.27.0 and JetBrainsMono Nerd Font 3.5.1 are upstream user-level installs, not bundled binaries. The Fedora 45 repo does not package Starship, and the available COPR build was outdated. The files in this overlay expect `starship` in `~/.local/bin` and the font family `JetBrainsMono Nerd Font`.

- CopyQ uses the Prussian Green theme override in `~/.config/copyq/themes/PrussianGreen.ini`; its tray icon replaces the old custom Waybar clipboard glyph. The official Wayland Support command uses `ydotool` for activation pasting. Run `install-copyq-wayland.sh` once to configure the system daemon with a user-only socket.

The nwggrid styling is in `~/.config/nwg-launchers/nwggrid/style.css`; it follows the Prussian Green palette. Add images to `~/Pictures/Wallpapers`, open Sway Control Center with Super+Shift+W, choose an image and scaling mode, then Apply. Sway Control Center hands the image to the `awww` daemon and stores the choice for the next login.

## Removing swaybg

`swaybg` is not installed. It is a hard dependency of `sway-config-fedora`, which owns the SDDM session entry point (`/usr/bin/start-sway`, `sway.desktop`), the `layered-include` helper that the Sway config includes, and the `sway/config.d` fragments. A plain `dnf remove swaybg` therefore cascades into removing `sway-config-fedora`, `sway-systemd`, `sddm`, `sddm-wayland-sway` and `swayfx`, which would leave no way to log in graphically.

The package is removed with `rpm -e --nodeps swaybg` instead, and `exclude=swaybg` is set in `/etc/dnf/dnf.conf` so that a later transaction does not pull it back in and undo the removal. `dnf check` reports one expected problem: `sway-config-fedora` is missing its `swaybg` requirement.

## Discrete NVIDIA GPU

The ASUS TUF Gaming A15 FA506II is a hybrid laptop: the internal panel is wired to the AMD Renoir iGPU, and the NVIDIA GTX 1650 Ti is a discrete GPU that sits idle. The proprietary NVIDIA 615 driver is installed from RPM Fusion (`akmod-nvidia-615.78.08`, `xorg-x11-drv-nvidia-615.78.08` and friends) and replaces `nouveau`, which is blacklisted in `/etc/modprobe.d/blacklist-nouveau.conf`. `/etc/modprobe.d/nvidia-drm.conf` enables `nvidia_drm modeset=1`.

RPM Fusion's `99-nvidia-dracut.conf` keeps the NVIDIA modules out of the ramdisk so that kernel updates do not need a ramdisk rebuild. That is wrong once `nouveau` is blacklisted, because the proprietary driver has to claim the device early. `~/.local/bin/sway-nvidia-initramfs` rebuilds the ramdisk with `--add-drivers "nvidia nvidia-modeset nvidia-drm nvidia-uvm"`; run it after a kernel update.

The panel stays on the iGPU, which is what actually drives it. `~/.local/bin/sway-prime-run` pushes a single command onto the dGPU through PRIME render offload, for example `sway-prime-run steam`.
