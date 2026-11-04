# Sway Fedora migration kit

A local, standalone record of the Sway look and user-level customizations currently used on Ubuntu Sway Remix, prepared for a Fedora 45 Sway Spin install. The goal is to carry over the visual design and useful behavior without copying Ubuntu's system defaults wholesale.

Fedora 45 was announced on 2026-11-03, but on 2026-11-04 the official Sway Spin download page still showed Fedora 44. Fedora calls the edition the **Sway Spin**. Before installing, confirm the Fedora 45 Sway Spin ISO is published; otherwise decide whether to wait or use another Fedora 45 install and add Sway.

## Contents

- `ubuntu-snapshot/` — selected user Sway/appearance config captured from `~/.config`; a source snapshot, **not** a drop-in Fedora config.
- `ubuntu-system-snapshot/` — relevant `/etc` and `/usr` package defaults, Remix scripts, palettes, wallpaper and the modified Sway launcher. These are reference files, not Fedora drop-ins.
- `personal-configs/` — Starship, Fish, Nushell, Neovim, and the Azote wallpaper helper. Histories, `fish_variables`, nested Git metadata and the Neovim README were excluded.
- `FEDORA_DEPENDENCIES.md` — initial Fedora 45 official-repository/COPR availability audit. Package availability should be checked again on the installed system with `dnf repoquery` before adding repositories or installing anything.
- `SYSTEM_AUDIT.md` — second-pass inventory of Ubuntu Sway system files and the one modified package-managed launcher.
- `MIGRATION_PLAN.md` — the staged porting plan and Ubuntu-specific assumptions to replace.
- `CONVERSATION_NOTES.md` — project context and decisions from the chat; credentials are intentionally omitted.

## Design snapshot

- Sway/GTK base: dark Yaru with a deep charcoal surface and muted teal accent.
- Waybar and Mako: compact dark surfaces, teal accents, Inter text.
- Icons: Papirus-Dark; cursor: Bibata-Modern-Ice.
- Launcher: Fuzzel. Panel application drawer currently uses nwg-drawer on Ubuntu.
- Terminal: Kitty is the Sway default. Kitty's own theme config is included as it exists locally.
- Personal shells/editors: Starship, the existing Fish and Nushell configs, and Neovim runtime files are copied under `personal-configs/`. Shell history/state and Neovim's nested Git metadata are excluded. Review machine-specific paths and plugins before applying them on Fedora.

## Safe migration approach

After Fedora is installed, first inventory its Sway Spin defaults and hardware-related settings. Query package names and versions from enabled Fedora 45 repositories; check COPR only for packages missing from Fedora proper. Then install the required dependencies, adapt scripts and service paths, and apply the user-level configuration in stages. Do not overwrite Fedora's Sway base config or hardware settings with the Ubuntu snapshot.

The user plans to install Fedora before the actual port. This repository records the design and package research so that work can resume after that installation.
