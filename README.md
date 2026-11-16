# Sway Fedora migration kit

A local, standalone record of the Sway look and user-level customizations from Ubuntu Sway Remix, with a Fedora 45 Sway overlay now applied. The Fedora overlay keeps Fedora's session and hardware defaults while carrying over the visual design and useful behavior.

At the time of the initial repository research on 2026-11-04, the official Sway Spin page still showed Fedora 44. Fedora 45 is now installed on the target system; the historical check is retained in `CONVERSATION_NOTES.md`.

## Contents

- `ubuntu-snapshot/` — selected user Sway/appearance config captured from `~/.config`; a source snapshot, **not** a drop-in Fedora config.
- `ubuntu-system-snapshot/` — relevant `/etc` and `/usr` package defaults, Remix scripts, palettes, wallpaper and the modified Sway launcher. These are reference files, not Fedora drop-ins.
- `personal-configs/` — source snapshots of Starship, Fish, Nushell, Neovim, and the Azote wallpaper helper. Histories, `fish_variables`, nested Git metadata and the Neovim README were excluded. The Fedora-adapted configs are in `fedora-overlay/`.
- `fedora-overlay/` — Fedora-native user config now applied on Fedora 45, with a user-level installer and small replacements for Ubuntu-only Waybar actions.
- `backup/` — **full backup of the live Fedora 45 SwayFX workstation** (configs, dotfiles, apps, package and service inventory, system files, archives) plus the written record of every customisation in `backup/PROCEDURES.md`, the app-to-config map in `backup/INVENTORY.md`, and the restore/port procedures in `backup/RESTORE.md`.
- `FEDORA_DEPENDENCIES.md` — initial Fedora 45 official-repository/COPR availability audit. Package availability should be checked again on the installed system with `dnf repoquery` before adding repositories or installing anything.
- `SYSTEM_AUDIT.md` — second-pass inventory of Ubuntu Sway system files and the one modified package-managed launcher.
- `MIGRATION_PLAN.md` — the staged porting plan and Ubuntu-specific assumptions to replace.
- `CONVERSATION_NOTES.md` — project context and decisions from the chat; credentials are intentionally omitted.

## Design snapshot

- Sway/GTK base: dark Yaru with a deep charcoal surface and muted teal accent.
- Waybar and Mako: compact dark surfaces, teal accents, Inter text.
- Ubuntu source icons: Papirus-Dark; cursor: Bibata-Modern-Ice. Fedora overlay uses Papirus-Dark and its packaged Adwaita cursor.
- Launcher: Fuzzel. The Ubuntu panel used nwg-drawer; the Fedora panel uses Fuzzel and a small Fuzzel quick-action menu.
- Terminal: Kitty is the Sway default. Kitty's own theme config is included as it exists locally.
- Personal shells/editors: Starship, Fish, Nushell and Neovim configs are included under `personal-configs/` and adapted for Fedora under `fedora-overlay/`. Shell history/state and Neovim's nested Git metadata are excluded.

## Fedora 45 setup

The target Fedora install has been inventoried and the overlay is active. Review `fedora-overlay/README.md` for what it applies and how to reapply it. Check package metadata with `dnf repoquery` before future additions. The overlay uses Fedora's own Sway layered config, session services and hardware settings; do not install Ubuntu system snapshots into Fedora.

The initial Fedora port is complete. The overlay and dependency notes record the current state for future repair or reinstall.

## Backup

`backup/` holds a complete capture of the running system, taken before the Ryoku install: every dotfile and `~/.config` tree, the user scripts, the Flatpak application data, the system files the desktop depends on, an inventory of all installed apps and packages, and tar.zst archives for the heavy binary trees (fonts, Neovim plugins and LSPs, browser profiles).

```bash
./backup/scripts/verify-backup.sh      # check every checksum
./backup/scripts/capture-backup.sh     # re-run the capture
./backup/scripts/restore-user-config.sh # dry run; --apply to restore
```

`backup/PROCEDURES.md` is the written record of how this desktop was built — the SwayFX swap, the awww wallpaper daemon, CopyQ with ydotool, the custom Sway Control Center, the GTK/Qt/Kvantum theme stack, the NVIDIA driver on this hybrid laptop and the dynamic island units. `backup/RESTORE.md` covers both restoring on Fedora and carrying the setup over to Ryoku on Hyprland or niri.

Credentials live in `backup/secrets/` with mode 600 and are excluded from git, as are the archives and the heavy binary trees.
