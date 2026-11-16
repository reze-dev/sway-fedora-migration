# Conversation notes

## User intent

Initially, the user wanted to move from Ubuntu Sway Remix to Fedora 45 Sway Spin while keeping the desktop's aesthetics in a standalone repo. That Fedora install is now complete and the first user-level overlay has been applied. The repo documents customizations and package availability. The Ubuntu Sway welcome app is excluded.

## Decisions captured

- Keep the current Ubuntu system untouched during preparation; the user will install Fedora separately.
- Snapshot selected user-level Sway and appearance configuration as source material, not as a blind Fedora overwrite.
- Copy the user's Starship, Fish, Nushell and Neovim configuration into the repo after scanning it; exclude shell history/state and nested Neovim Git metadata.
- Kitty is the chosen/default Sway terminal. Foot was removed and must stay out of the Fedora dependency set.
- A small Fish function routes SSH from Kitty through `kitty +kitten ssh`, allowing remote Kitty terminfo; it is included separately.
- Exclude credentials and other private state from this repository. The sudo credential mentioned in chat is intentionally not recorded.

## Work performed on the Ubuntu setup before this repository

- Installed Fuzzel, Inter and Papirus-Dark; removed Wofi and pointed Sway's launcher variable at Fuzzel.
- Styled Waybar and Mako with the dark Yaru/teal palette.
- Set GTK icon/font preferences and matched Foot's old local config to Kitty's terminal palette before Foot was later purged.
- Purged Foot, set Kitty as the Sway terminal and system terminal alternative, and added a Kitty-aware SSH helper in `~/.config/fish/conf.d/kitty-ssh.fish`.

The original Fish config and selected Nushell/Neovim config are included in `personal-configs/`; see its README for exclusions and review notes.

## Fedora image availability check

Historical check: Fedora Linux 45 was announced on 2026-11-03, but the official Sway Spin download page still listed Fedora Sway Spin 44 when checked on 2026-11-04. The user subsequently installed Fedora 45 Sway, which is confirmed by `/etc/os-release` on the target host.

## Second-pass system audit and personal configs

- Captured selected `/etc/sway`, Ubuntu environment/xdg defaults, `/usr/share/sway/scripts`, Sway palette variables, Kvantum assets, systemd user units, session entry, wallpaper and the `/etc/skel` templates. The Welcome autostart, Foot/Wofi templates and binary dconf state were excluded.
- `dpkg -V` found only `/bin/start-sway` modified among the audited Sway packages. Direct comparison to the cached package showed that its NVIDIA branch condition was broadened to trigger whenever the NVIDIA module exists. The reason is unknown; preserve as evidence, not as a Fedora config.
- Added Starship, Fish, Nushell and Neovim runtime configs plus the Azote helper. Excluded histories, Fish variables, nested Neovim `.git` metadata, and Neovim documentation. A credential-pattern scan found no likely non-placeholder credential assignments.

- The system audit found an Ubuntu keybind to `fuzzel-emoji` (not installed) and a Nushell reference to missing `~/.cargo/env.nu`. The Fedora overlay drops the dangling binding and guards the optional Cargo file.

## Fedora 45 application

- The user installed Fedora 45 Sway and asked to carry over the same behavior. The active system was inventoried before changes; Fedora's Sway session, GPU setup, policy agent and idle/lock integration were preserved.
- Applied the repo's Fedora overlay: Kitty replaces Foot as the Sway terminal, Fuzzel replaces the launcher, dark Yaru/Papirus/Inter styling is in place, and the captured Ubuntu wallpaper is used. Waybar and Mako use the dark teal palette. Fedora's built-in output mode remains 1920x1080 at 144 Hz; adaptive sync is enabled.
- Added Fuzzel-based quick and power menus plus a CopyQ clipboard window; CopyQ and xsettingsd are user services attached to `graphical-session.target`. Fedora's tuned-ppd is used for power profiles rather than installing a conflicting second daemon. The existing Fedora LXQt PolicyKit agent remains the only agent.
- Installed official Fedora packages for the selected terminal, launcher, notification daemon, themes/icons/fonts, clipboard, shell/editor, Qt theming, screenshot edit, TUI helpers and NetworkManager TUI. Removed Foot and changed the account login shell to Fish.
- Fedora 45 has no official Starship package. The available atim COPR build was outdated, so the COPR was removed; Starship 1.27.0 and JetBrainsMono Nerd Font 3.5.1 were installed per-user from upstream release assets after checking their published SHA-256 digests.
- QT platform environment settings are recorded in `~/.config/sway/environment`; they take full effect on the next Sway login. Existing user windows were left open.

- CopyQ now uses a custom dark Prussian Green theme with Inter and teal `#368582` selection, and its tray icon replaces the former custom Waybar clipboard glyph. The official CopyQ Wayland Support command is installed; `ydotoold` uses an asuna-only socket, and Kitty maps Shift+Insert to clipboard paste.

- The Fedora 45 app drawer and wallpaper workflow were completed: official Fedora packages `nwg-launchers` and `azote` are installed. Waybar’s rocket and Super+D open the Prussian Green styled nwggrid; Super+Shift+W opens Azote. The current Warty wallpaper is preserved in `~/Pictures/Wallpapers` and restored by `~/.azotebg`.

- Waybar now runs through Fedora’s `waybar.service`; a user Sway `config.d/90-bar.conf` override suppresses the packaged `swaybar_command waybar` stanza. This makes systemd the single process owner and prevents a second Sway-managed bar.

- Azote was removed at the user’s request. The unified Sway Control Center now has a GTK image picker and scaling selector; it updates Sway’s `output * bg` setting for application and login restore. Super+Shift+W opens the control center. `awww` (formerly `swww`) was considered but is not in the enabled Fedora 45 repositories.

## Later changes on Fedora 45

- The Terra repository was added and `awww` was installed from it, replacing the `swaybg` wallpaper process. `swaybg_command -` and the removal of the `output * bg` line guarantee a single wallpaper process; `~/.config/systemd/user/awww.service` and `~/.local/bin/sway-set-wallpaper` restore the Control Center’s choice at login.
- The Sway binary was replaced by **SwayFX 0.6.1** from the swayfx COPR. `/usr/bin/sway`, `swaybar`, `swaymsg` and `swaynag` are all SwayFX builds, and the client palette uses the SwayFX five-colour syntax.
- The SDDM greeter was switched to the **Ronin** theme, installed under `/usr/share/sddm/themes/ronin` and selected by `/etc/sddm.conf.d/99-ronin-theme.conf`.
- The **NVIDIA proprietary driver** (RPM Fusion `akmod-nvidia`) replaced nouveau; nouveau is blacklisted and `nvidia_drm.modeset=1` is set. `~/.local/bin/sway-nvidia-initramfs` rebuilds the initramfs with the NVIDIA modules, because RPM Fusion’s dracut snippet keeps them out. `~/.config/sway/environment` passes `--unsupported-gpu` to suppress the “proprietary GPU not supported” notice. `~/.local/bin/sway-prime-run` runs a single program on the discrete GPU.
- Adaptive sync was **disabled** on `eDP-1`: with VRR on, pointer movement changes the panel refresh timing and reads as a full-screen flicker.
- A brightness slider was added to the Sway Control Center.
- A custom **Dynamic Island** (Rust daemon `isled` + Quickshell UI) was added as `isled.service` and `quickshell.service`. Both units import `NIRI_SOCKET` and `HYPRLAND_INSTANCE_SIGNATURE`, because the adapter was written for Hyprland and niri as well. The Quickshell unit carries a Nix-on-Fedora `libEGL`/glvnd workaround. The `~/Projects/dynamic-island` source tree is no longer on the machine, so both units currently fail to start.

## Ryoku preparation and the full backup

- The user is installing **Ryoku** on this machine. Ryoku is a hand-built desktop (Arch, CachyOS, Void and Fedora editions; Hyprland, niri and Wayfire compositors) whose installer rewrites the desktop configuration in place, so the existing setup had to be captured first.
- `backup/` holds the complete capture: the user tree, the system files the desktop depends on, an inventory of every installed app and package, tar.zst archives for the heavy binary trees, and the written record of every customisation in `backup/PROCEDURES.md`.
- `backup/INVENTORY.md` maps every app to the path that holds its settings. `backup/RESTORE.md` covers restoring on Fedora and the translation of the Sway setup into Ryoku’s `user.lua` / `user.kdl` override files.
- Credentials (SSH key, Codex and OpenCode credentials) are stored in `backup/secrets/` with mode 600 and are excluded from git, as are the archives and the heavy binary trees.
- The Ryoku installer’s own backup and its `restore.sh` should be kept next to this repository, so the SwayFX desktop remains recoverable.
