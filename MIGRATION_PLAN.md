# Migration plan

## Objective

Preserve the current desktop's look and useful Sway behavior as a portable user-level overlay for Fedora 45 Sway Spin. Do not transplant Ubuntu Sway's system config, packages, scripts, or welcome application.

## Stages completed on Fedora 45

1. Captured user config, selected Ubuntu system defaults/scripts/theme assets, package state and session choices.
2. Inspected Fedora's layered Sway config, session startup, hardware, packages and current output.
3. Checked the required commands in Fedora 45 repos; kept Fedora's tuned-ppd backend and skipped unavailable or stale optional sources.
4. Created and applied `fedora-overlay/`, preserving Fedora's system startup and hardware configuration.
5. Kept Kitty as terminal, removed Foot, and set Fish as the account login shell.
6. Applied the Sway appearance and adapted launcher, clipboard, screenshot and power actions to Fedora packages or small user scripts.
7. Applied the Starship, Fish, Nushell and Neovim user configs; guarded the unavailable Cargo environment file and kept machine-specific plugin/tool dependencies conditional where possible.

## Current visual and workflow choices

- Fedora Sway palette: charcoal `#1b1b1b` / `#2f2f2f`, teal `#317b79`, light text `#eff0f1`.
- Fedora GTK uses `Yaru-dark`, Papirus-Dark, Inter and Adwaita cursor. The teal Kvantum variant is included locally.
- Waybar, Mako, Fuzzel, Kitty, Swappy and swaylock have user-level styling. Fedora's default brightness/volume OSD and lock/idle services remain active.
- Kitty is the default terminal. The Sway variables include regular, working-directory and floating Kitty launches.
- The actual Fedora output is `eDP-1` at 1920x1080 and 144 Hz; adaptive sync is enabled in the overlay.

## Ubuntu-specific items replaced or intentionally omitted

- `~/.config/sway/config` includes `/usr/share/themes/yaru-sway/variables` and `/etc/sway/variables`; those paths do not describe Fedora's defaults.
- Waybar actions no longer call Ubuntu scripts under `/usr/share/sway/scripts`; screen recording/weather controls were omitted, and help/power/clipboard actions use local Fedora-safe scripts.
- Fedora's Sway idle, lock, brightness and media controls remain in place.
- Fuzzel handles app launching; CopyQ provides the dedicated clipboard history window in place of the Ubuntu nwg-clipman action.
- The Ubuntu Sway welcome app is explicitly out of scope.
- Foot was intentionally removed; do not reinstall it.
