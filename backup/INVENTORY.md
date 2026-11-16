# Inventory — apps, tools and where their settings live

Every application that was in use on this machine, with the exact path that
holds its settings. This is the lookup table for "what do I need to put back
on the new system", and it is the short version of `inventory/` (the raw
command output).

Legend for the backup column:

- `home/config/…` — in the backup as plain files, directly restorable
- `home/local/…` — in the backup as plain files
- `archives/…` — only inside a tar.zst archive, extract with
  `tar --zstd -xf archives/<name>.tar.zst -C <target>`
- `inventory/…` — only recorded as a list, reinstall from the package source

---

## Desktop shell and window management

| App | Version / source | Settings location | Backup |
|---|---|---|---|
| SwayFX | 0.6.1 (based on Sway 1.12.0), `swayfx` RPM from the swayfx COPR — provides `/usr/bin/sway`, `swaybar`, `swaymsg`, `swaynag` | `~/.config/sway/config`, `~/.config/sway/config.d/*.conf`, `~/.config/sway/environment` | `home/config/sway/` |
| Fedora Sway session | `sway-config-fedora` 0.4.3 (`/usr/bin/start-sway`, `layered-include`, `/usr/share/sway/config.d/`) | `/etc/sway/config`, `/etc/sway/config.d/`, `/etc/sway/environment` | `system/etc/sway/` |
| Sway session integration | `sway-systemd` 0.4.1 | `/etc/sway/config.d/10-systemd-session.conf`, `10-systemd-cgroups.conf` | `system/etc/sway/` |
| swayidle | 1.9.1 | Fedora defaults | `system/etc/sway/`, `system/usr/share/sway` |
| swaylock | 1.8.6 | `~/.config/swaylock/config` | `home/config/swaylock/` |
| swaybg | 1.2.2 — **installed but never started** (awww paints the wallpaper) | — | `system/etc/sway/` |
| Waybar | Fedora package, run as a systemd user service | `~/.config/waybar/config.jsonc`, `~/.config/waybar/style.css` | `home/config/waybar/` |
| Mako | 1.11.0, systemd user service | `~/.config/mako/config` | `home/config/mako/` |
| Fuzzel | 1.15.0 | `~/.config/fuzzel/fuzzel.ini` | `home/config/fuzzel/` |
| nwggrid | `nwg-launchers` 0.7.1 | `~/.config/nwg-launchers/nwggrid/style.css` | `home/config/nwg-launchers/` |
| Quickshell | 0.3.2 from the **Nix store** (not a package) | unit: `~/.config/systemd/user/quickshell.service` | `home/config/systemd/user/` |
| isled (dynamic island daemon) | custom Rust binary | unit: `~/.config/systemd/user/isled.service`, state `~/.local/state/isled` | `home/config/systemd/user/`, `home/local/state/` |
| Sway Control Center | **custom app**, `~/.local/bin/sway-control-center` (Python 3 + GTK 4) | `~/.config/sway-control-center/settings.json` | `home/local/bin/`, `home/config/sway-control-center/` |
| SDDM greeter | `sddm` + `sddm-wayland-sway`, theme `ronin` | `/etc/sddm.conf.d/99-ronin-theme.conf`, `/usr/share/sddm/themes/ronin/` | `system/etc/sddm.conf.d/`, `system/usr/share/sddm/themes/ronin/` |

## Terminal, shell, editor, prompt

| App | Version / source | Settings location | Backup |
|---|---|---|---|
| kitty | 0.48.2 | `~/.config/kitty/kitty.conf`, `~/.config/kitty/current-theme.conf` (Rosé Pine) | `home/config/kitty/` |
| Fish | 4.6.0 — **login shell** (`/usr/bin/fish`) | `~/.config/fish/config.fish`, `~/.config/fish/conf.d/kitty-ssh.fish` | `home/config/fish/` |
| Nushell | 0.99.1 | `~/.config/nushell/config.nu` | `home/config/nushell/` |
| Starship | 1.27.0, upstream binary in `~/.local/bin` | `~/.config/starship.toml` | `home/config/starship.toml` |
| Neovim | 0.12.6 + lazy.nvim, 51 plugins | `~/.config/nvim/` (config), `~/.local/share/nvim/lazy` (plugins), `~/.local/share/nvim/mason` (LSPs) | `home/config/nvim/`, `archives/nvim-plugins-and-mason.tar.zst` |
| tmux | with TPM | `~/.config/tmux/tmux.conf`, `~/.tmux/` | `home/config/tmux/`, `home/dotfiles/.tmux/` |
| tmux plugins | TPM clones | `~/.config/tmux/plugins` | `archives/tmux-plugins.tar.zst` |
| zoxide | 0.9.x | `~/.local/share/zoxide` | `home/dotfiles/.local_share_zoxide/` |
| bash | 5.3.15 | `~/.bashrc`, `~/.bash_profile`, `~/.bash_logout` | `home/dotfiles/` |

## Applications

| App | Version / source | Settings location | Backup |
|---|---|---|---|
| Zen Browser | 1.24.2b, **Flatpak** (`flathub`) | `~/.var/app/app.zen_browser.zen/.zen` | `archives/zen-browser-profile.tar.zst`, `home/var-app/` |
| Firefox profile (native) | profile data kept | `~/.config/mozilla/firefox` | `archives/mozilla-firefox-profile.tar.zst` |
| Bitwig Studio | 6.1.7, **Flatpak** (`flathub`) | `~/.var/app/com.bitwig.BitwigStudio` | `home/var-app/` |
| CopyQ | 17.0.0 — clipboard history | `~/.config/copyq/copyq.conf`, `copyq-commands.ini`, `themes/PrussianGreen.ini` | `home/config/copyq/` |
| cliphist | 0.7.0 — superseded by CopyQ, still installed | — | `inventory/` |
| Swappy | screenshot editor | `~/.config/swappy/config` | `home/config/swappy/` |
| Nautilus | 51.1 | `~/.config/nautilus/` | `home/config/nautilus/` |
| Epiphany | 51.2 | `~/.config/epiphany/` | `home/config/epiphany/` |
| Thunar | (leftover from the LXQt session) | `~/.config/Thunar/` | `home/config/Thunar/` |
| xarchiver | — | `~/.config/xarchiver/` | `home/config/xarchiver/` |
| blueman | 2.4.6 | tray applet autostart is hidden | `home/config/autostart/` |
| nm-applet | NetworkManager tray — hidden | `~/.config/autostart/nm-applet.desktop` | `home/config/autostart/` |
| NetworkManager-tui | 1.58.1 | — | `inventory/` |
| pavucontrol | — | `~/.config/pavucontrol.ini` | `home/config/pavucontrol.ini` |
| calcurse | 4.8.2 | `~/.config/calcurse/` | `home/config/calcurse/` |
| htop | 3.5.3 | `~/.config/htop/` | `home/config/htop/` |
| wdisplays | — | — | `inventory/` |
| asusctl | 6.5.0 — laptop fan/lighting control | `~/.config/rog/` | `home/config/rog/` |
| TUF Control | third-party updater, `~/.local/bin/tuf-control` | `~/.local/share/tuf-control/` | `home/local/share/tuf-control/` |
| ydotool | Wayland paste emulation for CopyQ | — | `inventory/` |
| grimshot / grim / slurp | Fedora screenshot helpers | — | `inventory/` |
| Ghostscript | 10.07.1 (+ fontutils, printing) | — | `inventory/` |
| openconnect | VPN client | — | `inventory/` |
| zenity | dialog helper | — | `inventory/` |

## Appearance

| Component | Choice | Settings location | Backup |
|---|---|---|---|
| GTK 3 | Yaru Prussian Green Dark | `~/.config/gtk-3.0/settings.ini` | `home/config/gtk-3.0/` |
| GTK 4 | Yaru Prussian Green Dark | `~/.config/gtk-4.0/settings.ini` | `home/config/gtk-4.0/` |
| GTK 2 | dark shim | `~/.config/gtk-2.0/settings.ini`, `~/.gtkrc-2.0` | `home/config/gtk-2.0/`, `home/dotfiles/` |
| Qt 5 / Qt 6 | qt5ct / qt6ct palettes | `~/.config/qt5ct/`, `~/.config/qt6ct/` | `home/config/qt5ct/`, `home/config/qt6ct/` |
| Kvantum | KvYaru-PrussianGreenDark (local copy) | `~/.config/Kvantum/` | `home/config/Kvantum/` |
| XSettings | xsettingsd | `~/.config/xsettingsd/xsettingsd.conf` | `home/config/xsettingsd/` |
| Icons | Papirus-Dark | system theme | `inventory/` |
| Cursor | Bibata Modern Ice | `~/.config/sway/config.d/70-settings.conf`, `~/.config/sway/environment`, flatpak overrides | `home/config/`, `inventory/flatpak-overrides.txt` |
| Fonts | Inter, JetBrainsMono Nerd Font | `~/.local/share/fonts/NerdFonts` | `archives/fonts.tar.zst` |
| Wallpaper | Ubuntu Remix “warty” + user picks in `~/Pictures/Wallpapers` | `~/.local/share/backgrounds/`, `~/.config/sway-control-center/settings.json` | `home/local/share/backgrounds/`, `home/Pictures/` |

## Toolchains and developer tooling

| Tool | Version | Notes | Backup |
|---|---|---|---|
| rustup | stable-x86_64-unknown-linux-gnu | `~/.cargo/bin` has rustc, cargo, clippy, rustfmt, rust-analyzer | `inventory/rustup-toolchains.txt`, `home/cargo/` |
| Go | 1.27.4 | `~/go/pkg` module cache | `inventory/go-version.txt` |
| gcc / clang | 23 | `clang-tools-extra` | `inventory/` |
| zig | — | | `inventory/` |
| podman + podman-compose | — | containers: `~/.local/share/containers` (3.5 GB, not archived) | `inventory/podman-images.txt` |
| mise | `~/.local/bin/mise` (170 MB binary, not archived) | no tools configured | `inventory/mise-tools.txt` |
| gh | 2.97.0 | GitHub CLI | `inventory/` |
| git | 2.56.1 | `~/.gitconfig` | `backup/secrets/gitconfig` |
| ripgrep, fd, fzf, bat, zoxide | — | shell tooling | `inventory/` |
| neovim LSPs | mason | basedpyright, gopls, zls, lua-language-server, taplo, terraform-ls, typescript-language-server, yaml-language-server, json-lsp, css-lsp, html-lsp, dockerfile-language-server, docker-compose-language-service | `archives/nvim-plugins-and-mason.tar.zst` |
| opencode | `~/.opencode/bin` (240 MB runtime, not archived) | config in `~/.config/opencode/` | `inventory/opencode-runtime.txt` |
| codex | `~/.codex/` | config, plugins, skills | `home/codex/` |
| nix | 7.3 GB store, quickshell + mesa + libglvnd | per-user profile is empty | `inventory/nix-store-references.txt` |

## Projects on the machine

| Project | Path | Notes |
|---|---|---|
| Nethergate | `~/Projects/Nethergate` | Docker/podman stack, `.env` + `secrets/` present |
| warpgate | `~/Projects/warpgate` | data only |
| Budgeting-app | `~/Projects/Budgeting-app` | |
| transformer-in-go | `~/Projects/transformer-in-go` | |
| dynamic-island | `~/Projects/dynamic-island` | **source tree no longer on disk**; the systemd units still point at it |

Projects are left in place; only their configuration is listed here. The
`Nethergate/.env` and `secrets/` contain credentials and are deliberately not
copied into the backup tree — they stay in the project directory.
