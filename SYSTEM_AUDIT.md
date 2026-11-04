# Second-pass system audit

Audit date: 2026-11-04. This is a targeted audit of Sway Remix-owned system locations, not a recursive copy of `/usr`. Relevant files are preserved under `ubuntu-system-snapshot/` for reference.

## Files and behavior found

- `/etc/sway/`: generic Sway config plus Remix variables, input/output settings, keybinding modes, application defaults and session integration. The current user's `~/.config/sway/config` includes the Remix theme variables and system variables, and user overrides set Fuzzel and Kitty.
- `/etc/environment.d/90ubuntu-sway.conf`: forces Qt Wayland preference, `qt6ct`, EFL Wayland and an AWT workaround. These are Ubuntu session environment defaults; review against Fedora's session before porting.
- `/etc/skel/`: the Ubuntu Sway package seeds appearance, Sway, Waybar, Mako and utility configs for new users. The repo contains the selected templates, excluding the Welcome autostart, Foot config, Wofi config and binary dconf state.
- `/etc/xdg/xdg-ubuntusway/`: Thunar, libfm and MIME defaults. `/etc/xdg/xdg-desktop-portal-wlr/` and `/etc/xdg/swayr/` also contain system defaults.
- `/usr/share/sway/scripts/`: Remix scripts for lock, screenshots, recording, workspace naming, keyboard backlight, wallpaper color temperature, help, weather and working-directory detection. Current Sway/Waybar configs invoke several of these by absolute Ubuntu-specific path.
- `/usr/share/themes/`: the installed Remix offers Yaru Sway, Breeze Sway and Matcha Dark Sway palettes. The selected palette is Yaru Sway. `/usr/share/Kvantum/KvYaru-PrussianGreenDark/` supplies the matching Qt theme.
- `/usr/share/wallpapers/warty-final-ubuntusway.png`: current default wallpaper, selected by the user helper `~/.azotebg` and `/etc/sway/outputs/default-screen.conf`.
- `/usr/lib/systemd/user/`: Ubuntu Sway includes restart/session units for Sway idle, SwayOSD and Waybar.
- `/usr/share/wayland-sessions/ubuntusway.desktop`: Ubuntu Sway session entry.

## Modified package-managed system file

`dpkg -V` across `ubuntu-sway-default-settings`, `ubuntu-sway-themes`, `ubuntu-sway-wallpapers`, `ubuntu-sway-artwork`, `sway`, `sway-systemd` and `sway-input-config` reported only `/bin/start-sway` as different. The cached `ubuntu-sway-default-settings` package was available for a direct comparison. Its sole code change is the NVIDIA detection condition:

- package version: use the NVIDIA renderer only when NVIDIA is present and both AMDGPU and Intel i915 are absent;
- installed version: use the NVIDIA renderer whenever the NVIDIA module is present.

The rest of the launcher sets Wayland session variables, includes GPU workaround variables, imports `/etc/environment.d` and user `environment.d`, starts Sway under `ssh-agent`, and logs through `systemd-cat`. The condition change appears to cover hybrid NVIDIA systems too, but its reason/provenance is unknown. It is copied at `ubuntu-system-snapshot/usr/bin/start-sway`; do not install it on Fedora. Inspect Fedora's own NVIDIA and session launch path first.

## Porting implications

- Fedora's Sway config and session scripts are not Ubuntu's. Use this system snapshot to discover behavior, then recreate only the desired user-level features.
- The display mode in `ubuntu-snapshot/sway/outputs` is device-specific: `eDP-1`, 1920x1080 at 144 Hz, adaptive sync enabled. Query actual Fedora outputs before applying it.
- The Warty wallpaper is GPL-2-or-later according to its package copyright file, included under `ubuntu-system-snapshot/legal/`. It can be retained as a local asset, though it carries Ubuntu branding.
- `/etc/sway/modes/default.conf` binds `Alt+Shift+e` to `fuzzel-emoji`; that executable is absent on this Ubuntu host. The package instead has a `wofi-emoji.desktop` launcher. Treat this as a dangling binding and do not port it unchanged.
- `~/.config/nushell/config.nu` sources `~/.cargo/env.nu`, but that file is absent. It is not included in the repo.
- Kitty's `kitty.conf` includes `current-theme.conf`; the Rosé Pine palette is active and both files are included in the snapshots.
- No system file was edited while creating this repository. The system snapshot is archival reference only.
