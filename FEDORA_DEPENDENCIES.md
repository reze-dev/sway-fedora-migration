# Fedora 45 dependency availability

Initial online audit performed 2026-11-04 against Fedora Packages and COPR. This maps the packages and commands referenced by the captured Sway/Waybar setup. It is a research snapshot, not an install script. Re-check on the installed Fedora system with `dnf repoquery --available`; the Spin may already provide packages and repository state can change.

## Confirmed in Fedora 45 official repositories

| Need / current command | Fedora package or result | Notes |
|---|---|---|
| Sway compositor | `sway` | Official Fedora 45 package; use the Spin's existing install. [Package](https://packages.fedoraproject.org/pkgs/sway/sway/) |
| Wallpaper backend | `swaybg` | Official Fedora 45 package; the Spin may already include it. [Package](https://packages.fedoraproject.org/pkgs/swaybg/swaybg/) |
| Clipboard bridge | `wl-clipboard` | Official Fedora 45 package (`wl-copy`, `wl-paste`). [Package](https://packages.fedoraproject.org/pkgs/wl-clipboard/wl-clipboard/) |
| JSON utility | `jq` | Official Fedora 45 package; used by current Sway/Waybar helpers. [Package](https://packages.fedoraproject.org/pkgs/jq/jq/) |
| Network TUI | `NetworkManager-tui` | Official Fedora 45 subpackage providing `nmtui`. [Package](https://packages.fedoraproject.org/pkgs/NetworkManager/NetworkManager-tui/) |
| File manager | `Thunar` | Official Fedora 45 package; check whether the Sway Spin already includes it. [Package](https://packages.fedoraproject.org/pkgs/Thunar/Thunar/) |
| Idle and screen lock | `swayidle`, `swaylock` | Official Fedora 45 builds. [swayidle](https://packages.fedoraproject.org/pkgs/swayidle/swayidle/), [swaylock](https://packages.fedoraproject.org/pkgs/swaylock/swaylock/) |
| Bar and notifications | `waybar`, `mako` | Official Fedora packages. [Waybar](https://packages.fedoraproject.org/pkgs/waybar/), [Mako](https://packages.fedoraproject.org/pkgs/mako/mako/) |
| App launcher | `fuzzel` | Official Fedora 45 package; can replace the current nwg drawer action. [Fuzzel](https://packages.fedoraproject.org/pkgs/fuzzel/fuzzel/) |
| Terminal and SSH terminfo | `kitty` | Official package; Fedora provides Kitty terminfo and Fish integration. [Kitty](https://packages.fedoraproject.org/pkgs/kitty/kitty/) |
| GTK theme | `yaru-theme` and GTK subpackages | Fedora 45 has Yaru GTK3/GTK4 and icon packages. The exact Ubuntu Remix variant `Yaru-prussiangreen-dark` is not confirmed. [Yaru](https://packages.fedoraproject.org/pkgs/yaru-theme/yaru-theme/) |
| Icons | `papirus-icon-theme`, `papirus-icon-theme-dark` | Official Fedora 45 packages. [Papirus](https://packages.fedoraproject.org/pkgs/papirus-icon-theme/papirus-icon-theme/) |
| UI font | `rsms-inter-fonts` | Official Fedora 45 package (RPM name for Inter). [Inter](https://packages.fedoraproject.org/pkgs/rsms-inter-fonts/rsms-inter-fonts/) |
| Terminal font | `jetbrains-mono-fonts` | Official Fedora 45 package. This is regular JetBrains Mono, not a verified patched Nerd Font. [JetBrains Mono](https://packages.fedoraproject.org/pkgs/jetbrains-mono-fonts/jetbrains-mono-fonts/) |
| Clipboard history | `cliphist` | Official Fedora 45 package. Replace current `nwg-clipman` menu action with a Fuzzel/cliphist action or a verified Fedora alternative. [cliphist](https://packages.fedoraproject.org/pkgs/cliphist/cliphist/) |
| Night color | `wlsunset` | Official Fedora 45 package. Replace Ubuntu-specific toggle scripts. [wlsunset](https://packages.fedoraproject.org/pkgs/wlsunset/wlsunset/) |
| Brightness | `brightnessctl` | Official Fedora 45 package. Keyboard-backlight paths/scripts still need to be adapted to the actual hardware. [brightnessctl](https://packages.fedoraproject.org/pkgs/brightnessctl/brightnessctl/) |
| Screenshots | `grim`, `slurp`, `swappy`, `grimshot` | Official Fedora 45 packages; `grimshot` is part of `sway-contrib`. [grim](https://packages.fedoraproject.org/pkgs/grim/grim/), [slurp](https://packages.fedoraproject.org/pkgs/slurp/slurp/), [swappy](https://packages.fedoraproject.org/pkgs/swappy/swappy/), [grimshot](https://packages.fedoraproject.org/pkgs/sway-contrib/grimshot/) |
| Media controls | `playerctl` | Official Fedora 45 package. [playerctl](https://packages.fedoraproject.org/pkgs/playerctl/playerctl/) |
| Audio mixer | `pavucontrol` | Official Fedora 45 package. Existing `pulsemixer` availability was not confirmed; use `pavucontrol` or PipeWire's `wpctl` if needed. [pavucontrol](https://packages.fedoraproject.org/pkgs/pavucontrol/pavucontrol/) |
| Power profiles | `power-profiles-daemon` | Official Fedora 45 package. Confirm that the Spin's installed backend matches Waybar's module. [Package](https://packages.fedoraproject.org/pkgs/power-profiles-daemon/power-profiles-daemon/) |
| Bluetooth | `bluez` (`bluetoothctl`) | Official Fedora 45 package. `bluetuith` availability was not confirmed; use `bluetoothctl` or the official [Blueman](https://packages.fedoraproject.org/pkgs/blueman/blueman/) GUI if wanted. [BlueZ](https://packages.fedoraproject.org/pkgs/bluez/bluez/) |
| Network menu | `NetworkManager-tui` | Official Fedora 45 subpackage providing `nmtui`. [Package](https://packages.fedoraproject.org/pkgs/NetworkManager/NetworkManager-tui/) |
| Polkit agent | `xfce-polkit` | Official Fedora 45 package; current Ubuntu Sway config already launches it. [Package](https://packages.fedoraproject.org/pkgs/xfce-polkit/xfce-polkit/) |
| Calendar and process actions | `calcurse`, `htop` | Official Fedora 45 packages. [calcurse](https://packages.fedoraproject.org/pkgs/calcurse/calcurse/), [htop](https://packages.fedoraproject.org/pkgs/htop/htop/) |

## COPR or other external source

| Need | Finding | Port decision |
|---|---|---|
| SwayOSD | A Fedora 45 build exists in COPR `erikreider/swayosd`; it is not an official Fedora package. [COPR build index](https://download.copr.fedorainfracloud.org/results/erikreider/swayosd/) | Recheck project owner, Fedora 45 build status, and trust before enabling. If unavailable, keep native volume/brightness key bindings or choose another maintained route. |
| Screen recording | Fedora's Sway SIG wishlist points to RPM Fusion for `wf-recorder`; it was not confirmed in the official Fedora repositories. [Fedora Sway SIG](https://fedoraproject.org/wiki/SIGs/Sway) | Optional feature. Install only if desired and after checking RPM Fusion availability; otherwise remove the recording indicator/action. |

## Not verified for Fedora 45; replace unless confirmed on-system

- `autotiling`, `swayr`, `swaykbdd`, `bluetuith`, and `pulsemixer`: no suitable Fedora 45 official package or maintained Fedora 45 COPR was verified in this audit. Prefer Sway built-in layout and keyboard features, `bluetoothctl`, and `pavucontrol`/`wpctl`; omit the extras if no maintained package is found.
- `fuzzel-emoji`: the Ubuntu system Sway mode references this command, but it is not installed on the current Ubuntu host. The Ubuntu package instead has a `wofi-emoji.desktop` launcher. Do not carry this binding over without a real Fedora command.
- `nwg-drawer`: Fedora package page showed builds through Fedora 44, but not Fedora 45 in this audit. Fuzzel can be the app menu.
- `nwg-look`, `nwg-displays`, `nwg-bar`, `nwg-wrapper`, `nwg-clipman`: no Fedora 45 official package or suitable maintained Fedora 45 COPR was verified. Community artifacts surfaced for some names but were not established as usable. Prefer direct theme settings, native Sway output configuration, Fuzzel/cliphist and small scripts.
- `azote`: exact Fedora 45 package/COPR availability was not verified. The static wallpaper can be configured directly with Fedora Sway’s existing wallpaper backend.
- `acpi`: current idle scripts use it to decide suspend behavior. Prefer Fedora's existing power services or rework the logic after inspecting the Spin and laptop hardware.
- The current Kitty font is `JetBrainsMono Nerd Font`; the Fedora `jetbrains-mono-fonts` package does not establish that exact patched face. Check Kitty's symbol fallback first.

## Ubuntu-only script references to port/remove

The snapshot's Sway/Waybar actions call scripts under `/usr/share/sway/scripts/` for locking, keyboard backlight, working-directory detection, recording, weather, help and sunset toggling. Those Ubuntu paths do not transfer. The Fedora session provides its own base config and scripts; keep Fedora's defaults and replace only the user-level actions that are needed.

Additional system helpers use `notify-send` (Fedora `libnotify`), `inotifywait` (Fedora `inotify-tools`), `rfkill`, `pkill`, `systemctl`, `swaymsg`, `swaynag`, `wl-paste`, `wl-copy`, `nmtui`, `playerctl`, `pavucontrol`, `jq`, and `wpctl`. Resolve exact Fedora ownership with `dnf repoquery --whatprovides` on the installed Spin instead of assuming Debian package names map directly. The current Nushell config also sources `~/.cargo/env.nu`, but that file is absent on this host; the repo does not fabricate it.

## Install policy

1. Inspect Fedora Spin's installed packages and default config first.
2. Check Fedora's official repositories for every needed command before considering third-party sources.
3. For each COPR, verify owner, Fedora 45 architecture/build status, recent activity and package contents. Do not enable an unverified repository.
4. Fedora's Sway Spin may ship Foot; the user explicitly chose Kitty and removed Foot on Ubuntu. Keep Kitty as the default and remove Foot from Fedora if it is installed.
5. No COPR has been enabled and no Fedora package has been installed from this Ubuntu machine.
