# Restore guide

Two paths are documented here:

- **Part A — restore this desktop on Fedora 45** (the exact system it was
  captured from).
- **Part B — carry the setup over to Ryoku** (Arch/CachyOS/Void/Fedora edition,
  Hyprland or niri), which is the intended target.

Everything referenced lives under `backup/` in this repository. The capture
date and host are in `backup/capture-date.txt` and `backup/capture-meta.txt`.

> **Before running the Ryoku installer:** Ryoku's own installer rewrites the
> desktop configuration in place and moves you off conflicting shells and
> daemons. Keep this repository (and a copy of `backup/` on external storage)
> somewhere safe before you start.
>
> This repository sits on `/home/asuna`, which is on the root partition — the
> same disk the Ryoku install rewrites. Copy
> `/home/asuna/backup-full-2026-11-17.tar.zst` to external storage first and
> verify it against `backup/archive-checksums.txt`.

---

## Part A — restore on Fedora 45

### A0. Verify the backup first

```bash
cd backup
sha256sum -c checksums.sha256          # plain files
# archives are listed at the end of the same file; check them with:
sha256sum -c <(grep 'archives/' checksums.sha256)
```

`./scripts/verify-backup.sh` does both and prints a summary.

### A1. Restore the user configuration

```bash
cd /home/asuna/sway-fedora-migration
./backup/scripts/restore-user-config.sh          # dry run
./backup/scripts/restore-user-config.sh --apply
```

What it copies back:

| From | To |
|---|---|
| `backup/home/config/` | `~/.config/` |
| `backup/home/dotfiles/` | `~/` (`.bashrc`, `.profile`, `.gitconfig`, `.gtkrc-2.0`, `.tmux`, …) |
| `backup/home/local/bin/` | `~/.local/bin/` (scripts only; the `mise` and `starship` binaries are reinstalled) |
| `backup/home/local/share/` | `~/.local/share/` |
| `backup/home/local/state/` | `~/.local/state/` |
| `backup/home/cargo/`, `home/rustup/` | `~/.cargo/`, `~/.rustup/` (config only) |
| `backup/home/Pictures/`, `home/Documents/` | `~/Pictures/`, `~/Documents/` |
| `backup/secrets/` | `~/.ssh/`, `~/.codex/auth.json`, `~/.config/opencode/` (mode 600) |

The heavy trees come from the archives:

```bash
tar --zstd -xf backup/archives/fonts.tar.zst                -C ~/.local/share
tar --zstd -xf backup/archives/nvim-plugins-and-mason.tar.zst -C ~/.local/share
tar --zstd -xf backup/archives/tmux-plugins.tar.zst          -C ~/.config/tmux
tar --zstd -xf backup/archives/mozilla-firefox-profile.tar.zst -C ~/.config/mozilla
tar --zstd -xf backup/archives/zen-browser-profile.tar.zst    -C ~/.var/app/app.zen_browser.zen
```

### A2. Reinstall the packages

```bash
sudo dnf install --repo terra awww awww-b
sudo dnf install swayfx kitty fish nushell copyq swappy fuzzel nwg-launchers \
                 calcurse htop pavucontrol wdisplays blink-cursor-themes \
                 bibata-cursor-themes papirus-icon-theme-dark material-icons-fonts \
                 jetbrains-mono-fonts ydotool grimshot wlr-randr \
                 NetworkManager-tui blueman xarchiver podman podman-compose \
                 rustup golang gcc clang zig ripgrep fd-find fzf bat zoxide gh
sudo dnf install akmod-nvidia xorg-x11-drv-nvidia     # proprietary driver
sudo dnf remove foot                                   # keep it out
```

The exact package list of the captured system is in
`inventory/rpm-packages-full.txt` (1880 packages) and
`inventory/dnf-history.txt` (every transaction, with its command line).

Flatpak:

```bash
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install flathub app.zen_browser.zen com.bitwig.BitwigStudio
```

### A3. Restore the system files

```bash
# SDDM greeter theme
sudo cp -a backup/system/usr/share/sddm/themes/ronin /usr/share/sddm/themes/
sudo cp -a backup/system/etc/sddm.conf.d/99-ronin-theme.conf /etc/sddm.conf.d/
sudo systemctl restart sddm

# NVIDIA module blacklist and modeset
sudo cp -a backup/system/etc/modprobe.d/blacklist-nouveau.conf /etc/modprobe.d/
sudo cp -a backup/system/etc/modprobe.d/nvidia-drm.conf      /etc/modprobe.d/
```

`/etc/sway/**` and `/etc/systemd/**` in the backup are **reference copies only**:
they are the Fedora packages' own files and must not be copied back.

### A4. Rebuild the initramfs and reload

```bash
~/.local/bin/sway-nvidia-initramfs        # after every kernel update
systemctl --user daemon-reload
systemctl --user enable --now awww.service copyq.service xsettingsd.service
swaymsg reload
```

### A5. Check the result

```bash
sway --version                 # must say swayfx
swaymsg -t get_outputs        # eDP-1 1920x1080@144Hz
systemctl --user list-units --type=service --state=running
```

---

## Part B — carry the setup over to Ryoku

Ryoku is a different animal: the desktop **is** the Ryoku shell (bar, launcher,
Hub, lockscreen, greeter), and the compositor underneath is Hyprland or niri.
Sway's config format does not exist there, so the Sway part has to be
translated, not copied.

### B0. What Ryoku does to the machine

- It installs `ryoku-keyring`, `ryoku-desktop` and `ryoku-desktop-hyprland`
  (or `-niri`), adds the signed `[ryoku]` repository, configures SDDM and
  selects the Ryoku greeter.
- It **backs up every config file it changes** and writes a `restore.sh` into
  that backup directory.
- It replaces conflicting shells and daemons — expect the Fish login shell and
  the custom user units to be reconsidered.
- On the **Fedora** edition it **leaves NVIDIA on nouveau**. The current setup
  uses the proprietary driver with `nouveau` blacklisted (see
  `PROCEDURES.md` §13). Pick one before the install:
  - keep the proprietary driver → verify that Ryoku's Hyprland/niri build works
    with it and that the panel still comes up on the iGPU;
  - switch to nouveau → drop `~/.local/bin/sway-nvidia-initramfs` and the
    `--unsupported-gpu` flag, they do not apply.
- On Arch/CachyOS, the NVIDIA path is the usual `nvidia-dkms` with
  `nvidia_drm.modeset=1` and early KMS; `sway-nvidia-initramfs` is
  dracut-specific and has no equivalent there (mkinitcpio handles it).

### B1. Order of operations

1. Finish and verify this backup. Copy `backup/` to external storage.
2. Run the Ryoku installer with `--dry-run` first and read the plan.
3. Run the real installer. It produces its own backup directory with
   `restore.sh` — keep it next to this repository.
4. Log into the Ryoku session and carry over the parts below.
5. Keep the old Fedora system reachable (separate partition or a snapshot) —
   the SwayFX desktop is still the reference implementation.

### B2. What transfers as-is

These are ordinary user files and are compositor-independent:

| Item | From | To |
|---|---|---|
| Shell | `~/.config/fish/`, `~/.config/nushell/` | same paths |
| Prompt | `~/.config/starship.toml` | same path |
| Editor | `~/.config/nvim/` (+ `lazy-lock.json`) | same path |
| Terminal | `~/.config/kitty/` | same path (Rosé Pine theme) |
| tmux | `~/.config/tmux/tmux.conf`, `~/.tmux/` | same paths |
| GTK/Qt/Kvantum/XSettings theme | `~/.config/gtk-2.0`, `gtk-3.0`, `gtk-4.0`, `qt5ct`, `qt6ct`, `Kvantum`, `xsettingsd` | same paths |
| Icons and cursor | `papirus-icon-theme-dark`, `bibata-cursor-themes` | reinstall the packages, then re-apply the flatpak overrides |
| Fonts | `archives/fonts.tar.zst` | `~/.local/share/fonts` |
| Wallpapers | `~/.local/share/backgrounds`, `~/Pictures/Wallpapers` | same paths |
| App data | Zen/Bitwig flatpak profiles, Firefox profile | same paths |
| Sway Control Center state | `~/.config/sway-control-center/settings.json` | same path (the app itself is Sway-specific) |

Flatpak theme overrides have to be re-applied on the new system:

```bash
flatpak override --user --filesystem=/usr/share/icons/Bibata-Modern-Ice:ro \
                        --filesystem=/usr/share/icons/Yaru-prussiangreen-dark:ro
flatpak override --user --env=XCURSOR_THEME=Bibata-Modern-Ice --env=XCURSOR_SIZE=24
```

### B3. What has to be translated

| Sway / SwayFX | Ryoku + Hyprland | Ryoku + niri |
|---|---|---|
| `~/.config/sway/config` keybinds | `~/.config/hypr/user.lua` (Lua) | `~/.config/niri/user.kdl` (KDL) |
| `~/.config/sway/config.d/70-settings.conf` (cursor, control-centre binding, floating rules) | `hypr/user.lua` | `niri/user.kdl` |
| `output eDP-1 mode 1920x1080@144Hz` | `hypr/monitors.lua` (machine-owned seed) | `niri/monitors.kdl` + `monitors_user.kdl` |
| `adaptive_sync off` | monitor seed `vrr = 0` | niri has no VRR switch by default — check the panel behaviour |
| SwayFX 5-colour `client.*` palette | Hyprland `col.activeborder` / `col.inactiveborder` (Ryoku's `paletteBorder` keeps the border tied to the wallpaper) | niri border colours via the Ryoku palette |
| `smart_borders` / `smart_gaps` / `gaps inner 6` | Hyprland `gaps`/`smart_gaps` | niri `gaps` / `struts` |
| Waybar (this setup) | Ryoku's own bars: Orpheus, QS Bar, Sumi, Kairos, Shima, Python, Nomarchy | same |
| Fuzzel + nwggrid launcher | Ryoku's launcher (Super, then type) | same |
| awww wallpaper daemon | Ryoku shell wallpaper (hyprpaper / swww) | same |
| CopyQ clipboard history | Ryoku's own clipboard handling, or keep CopyQ | same |
| swaylock | qylock (Ryoku) | qylock (Ryoku) |
| `swayidle` | hypridle (Ryoku) | hypridle (Ryoku) |
| `grimshot`/`swappy` screenshot | Ryoku screenshot action; Swappy still usable | same |
| `~/.local/bin/sway-*` helper scripts | rewrite against `hyprctl` / `niri msg` | rewrite against `niri msg` |
| `sway-control-center` (GTK4 app) | Ryoku Hub replaces it | Ryoku Hub replaces it |
| `~/.config/systemd/user/*.service` | Ryoku provisions its own user services | same |

Ryoku's rule is that personal overrides live in `user.lua` / `user.kdl` — the
Hub writes the generated `settings.lua`/`rebinds.lua` and `settings.kdl`/
`rebinds.kdl`, and `user.*` is the layer that survives every `ryoku update`.
Anything the Ryoku Hub can express should be set in the Hub; anything it
cannot should go into `user.lua`/`user.kdl`.

### B4. The dynamic island

`isled.service` and `quickshell.service` already import `NIRI_SOCKET` and
`HYPRLAND_INSTANCE_SIGNATURE`, so the adapter was written with Hyprland and
niri in mind. On Ryoku:

- the Quickshell unit must point at the rebuilt binary — the Nix store path
  (`/nix/store/…quickshell-0.3.2`) does not exist on a Ryoku system, so use
  Ryoku's own Quickshell or install it from the distribution;
- the `LD_LIBRARY_PATH` / `__GLVND_LIBRARY_PATH` workaround in the unit is
  only needed for the Nix build on Fedora — remove it on Ryoku, or keep it if
  the Nix package is reused;
- the `~/Projects/dynamic-island` source tree is **missing** from the capture,
  so the units cannot start until the project is restored from its own
  repository.

### B5. Suggested order of work on the Ryoku machine

1. Log in, run `ryoku doctor`, pick the bar style and the interface scale.
2. Copy the portable user files (B2) into place.
3. Reinstall the flatpaks and the theme/font packages, re-apply the flatpak
   overrides.
4. Translate the keybinds into `user.lua` / `user.kdl`, starting from the
   table in B3 — the exact chords are in
   `inventory/sway-config-effective.txt`, which is the *effective* runtime
   configuration of the captured session.
5. Set the monitor to 1920x1080@144 Hz and turn VRR off.
6. Rebuild the dynamic island against the new compositor.
7. Keep the Fedora system bootable until the Ryoku session feels right.

---

## Part C — Files that map to what

| Need | File |
|---|---|
| Which packages were installed | `inventory/rpm-packages-full.txt`, `inventory/dnf-user-installed.txt` |
| Which flatpaks | `inventory/flatpak-apps.txt`, `inventory/flatpak-sbom.txt` |
| The live keybinding set | `inventory/sway-config-effective.txt` |
| The live output and input state | `inventory/sway-outputs.txt`, `inventory/sway-inputs.txt` |
| The compositor version | `inventory/sway-version.txt` |
| The user services | `inventory/systemd-user-units.txt`, `home/config/systemd/user/` |
| The theme settings as they were | `home/config/gtk-3.0/settings.ini`, `home/config/qt6ct/`, `home/config/Kvantum/` |
| The wallpaper choice | `home/config/sway-control-center/settings.json` |
| What was customised and how | `PROCEDURES.md` |
| Where every app keeps its settings | `INVENTORY.md` |
