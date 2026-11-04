# Conversation notes

## User intent

The user wants to replace the current Ubuntu Sway Remix base with Fedora 45 Sway Spin later, while retaining the desktop's aesthetics as a standalone repo. Once Fedora is installed, they want the same design applied there. The repository should document customizations and check required packages in Fedora repositories or COPR before installation. The Ubuntu Sway welcome app is excluded.

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

Fedora Linux 45 was announced on 2026-11-03, but the official Sway Spin download page still listed Fedora Sway Spin 44 when checked on 2026-11-04. Confirm the official Fedora 45 Sway Spin image is published before installing.

## Second-pass system audit and personal configs

- Captured selected `/etc/sway`, Ubuntu environment/xdg defaults, `/usr/share/sway/scripts`, Sway palette variables, Kvantum assets, systemd user units, session entry, wallpaper and the `/etc/skel` templates. The Welcome autostart, Foot/Wofi templates and binary dconf state were excluded.
- `dpkg -V` found only `/bin/start-sway` modified among the audited Sway packages. Direct comparison to the cached package showed that its NVIDIA branch condition was broadened to trigger whenever the NVIDIA module exists. The reason is unknown; preserve as evidence, not as a Fedora config.
- Added Starship, Fish, Nushell and Neovim runtime configs plus the Azote helper. Excluded histories, Fish variables, nested Neovim `.git` metadata, and Neovim documentation. A credential-pattern scan found no likely non-placeholder credential assignments.

- The system audit also found a dangling system keybind to `fuzzel-emoji` (not installed) and a Nushell config reference to a missing `~/.cargo/env.nu`; both are documented for review on Fedora.
