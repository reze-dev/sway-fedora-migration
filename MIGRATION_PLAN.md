# Migration plan

## Objective

Preserve the current desktop's look and useful Sway behavior as a portable user-level overlay for Fedora 45 Sway Spin. Do not transplant Ubuntu Sway's system config, packages, scripts, or welcome application.

## Stages

1. Capture user config, selected Ubuntu system defaults/scripts/theme assets, package state and session choices. The repo now has both the user snapshot and a separate system reference snapshot.
2. On Fedora, inspect the actual Spin defaults, output/input configuration, session startup and existing user config.
3. Check each required dependency against Fedora 45 enabled repositories. Use a COPR only when no suitable official package exists, and record its owner and Fedora 45 build status. Prefer a Fedora package or a small local script over an unmaintained COPR.
4. Create a Fedora-native user config overlay. Preserve Fedora's system startup and hardware configuration.
5. Keep Kitty as the terminal; if Fedora Spin installs Foot, remove it and update all terminal variables to Kitty.
6. Apply and reload the Sway config in stages, resolving Fedora-specific command/package differences before enabling each feature.
7. Review `personal-configs/` on Fedora before applying it. Preserve existing Fedora shell/editor settings where needed, and adapt machine-specific paths, plugins and terminal integration.

## Current visual and workflow choices

- Current Yaru Sway palette: charcoal `#1b1b1b` / `#2f2f2f`, teal `#317b79`, light text `#eff0f1`.
- GTK theme currently `Yaru-prussiangreen-dark`; Papirus-Dark icons, Inter UI font, Bibata-Modern-Ice cursor. Fedora availability/theme names must be checked.
- Waybar, Mako, Fuzzel, SwayOSD and swaylock have user-level styling.
- Kitty is the default terminal. The Sway variables include regular, working-directory and floating Kitty launches.
- Existing display config has a machine-specific eDP-1 mode of 1920x1080 at 144 Hz. Inspect Fedora's actual output before carrying it over.

## Ubuntu-specific items to port or replace

- `~/.config/sway/config` includes `/usr/share/themes/yaru-sway/variables` and `/etc/sway/variables`; those paths do not describe Fedora's defaults.
- Waybar actions call Ubuntu scripts under `/usr/share/sway/scripts`, including screen recording and weather/help functions. Preserve the visual styles; port or replace the actions.
- Sway idle config calls Ubuntu lock/backlight scripts and `acpi`; replace with Fedora Spin equivalents after inventory.
- Ubuntu's nwg app suite has mixed Fedora availability. Check dependencies before retaining the drawer, bar, display editor, look editor, wrapper and clipman. Fuzzel and cliphist can cover core launcher and clipboard use if an nwg component is absent.
- The Ubuntu Sway welcome app is explicitly out of scope.
- Foot was intentionally removed; do not reinstall it.
