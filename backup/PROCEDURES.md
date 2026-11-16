# Procedures — how this Fedora 45 SwayFX desktop was built

Working record of every customisation made to the Fedora 45 Sway Spin install,
in the order it was done and with the exact commands that were used. It exists
because the session was rebuilt by hand many times: the Fedora overlay in
`fedora-overlay/` only covers part of it, and the rest lives in the live
`~/.config`, `~/.local/bin` and `~/.config/systemd/user` trees.

Everything below is reproduced from the live system on the capture date
(see `capture-date.txt`). Commands marked **[live]** are still in effect;
commands marked **[past]** are history and are already reflected in the files.

Host: ASUS TUF Gaming A15 FA506II, AMD Renoir iGPU driving the panel,
NVIDIA GTX 1650 Ti on PRIME render offload. Fedora 45 (Sway) x86_64,
kernel 7.3.3-300.fc45.x86_64.

---

## 0. Baseline: what Fedora gave us

Fedora 45 Sway Spin ships:

- `sway` (upstream 1.11/1.12) with `/etc/sway/config` and the
  `/usr/share/sway/config.d/*.conf` fragments,
- `sway-config-fedora` providing `/usr/bin/start-sway`, the
  `/usr/libexec/sway/layered-include` helper and the session entry,
- `sway-systemd` providing `sway-session.target`, the session script and the
  cgroup assignment helper,
- Waybar, Mako, swayidle, swaylock, swaybg, Fuzzel, kitty, LXQt PolicyKit agent,
- SDDM with the `03-sway-fedora` greeter theme.

The layered include in `~/.config/sway/config` is the pivot of the whole setup:

```
include '$(/usr/libexec/sway/layered-include "/usr/share/sway/config.d/*.conf" "/etc/sway/config.d/*.conf" "${XDG_CONFIG_HOME:-$HOME/.config}/sway/config.d/*.conf")'
```

Later directories win, so every personal change goes into
`~/.config/sway/config.d/`, never into `/etc/sway/`. Nothing under `/etc/sway`
was edited on this machine.

---

## 1. SwayFX instead of Sway

**Why.** SwayFX is a Sway fork with blur, shadows, rounded corners, animations
and a five-colour client syntax. The look of the old Ubuntu Sway Remix
depended on it, and the user explicitly wants SwayFX.

**How.**

```bash
dnf install swayfx            # from the swayfx COPR (owner: swayfx / Atmois)
```

`rpm -qf /usr/bin/sway` → `swayfx-0.6.1-1.fc45.x86_64`. The COPR package
*replaces* the Fedora `sway` binary, so `/usr/bin/sway`, `/usr/bin/swaybar`,
`/usr/bin/swaymsg` and `/usr/bin/swaynag` are all SwayFX builds. Nothing else
changed: `start-sway` still calls `/usr/bin/sway`, and the session entry, the
layered config and SDDM integration keep working.

**Proof.** `sway --version` → `swayfx version 0.6.1 (based on sway 1.12.0)`
and `swaymsg -t get_version` reports `"variant": "sway"` with
`"sway_original_version": "1.12.0"`.

**SwayFX-only syntax in use** (`~/.config/sway/config`):

```
client.focused          #368582 #368582 #ffffff #ffffff #368582
client.focused_inactive #1b1b1b #1b1b1b #bdc3c7 #41535b #1b1b1b
client.unfocused        #1b1b1b #2f2f2f #bdc3c7 #ffffff #1b1b1b
client.urgent           #da4453 #da4453 #2f2f2f #db7b55 #da4453
```

Five values (border, background, text, indicator, child border) is SwayFX
syntax and is **rejected by upstream Sway**. A restore to plain Sway has to
drop the fifth value.

**Also added for the compositor:** `default_border pixel 2`, `smart_borders on`,
`smart_gaps on`, `gaps inner 6`, `font pango:Inter 11`.

---

## 2. Output, refresh rate and VRR

**[live]**

```
output eDP-1 mode 1920x1080@144Hz
output eDP-1 scale 1
output eDP-1 adaptive_sync off
```

The internal panel is `eDP-1` at 1920x1080 and 144 Hz. Adaptive sync is
**off on purpose**: with VRR enabled, moving the pointer forces a repaint that
changes the panel refresh timing, which reads as a subtle full-screen flicker.
This was tested and rejected, so keep it off.

---

## 3. Wallpaper: swaybg → awww

**Why.** The upstream Remix painted the wallpaper with `swaybg` from a
`output * bg` line in the Sway config. Sway Control Center needs to change the
wallpaper at runtime, and `swaybg` can only do that by restarting.

**How.**

```bash
dnf install --repo terra awww awww-b      # awww = upstream swww, renamed
```

`awww` is an swww fork published on Codeberg and packaged in the Terra
repository. Terra was added as a system repo:

```bash
dnf install --nogpgcheck --disablerepo=updates \
    https://raw.githubusercontent.com/terralinux/terra-release/terra-stable.repo
```

**The three parts that must stay consistent:**

1. `~/.config/sway/config` has **no** `output * bg` line and starts with
   `swaybg_command -`, which disables Sway's built-in `swaybg` spawn. Only one
   process may ever paint the background layer.
2. `~/.config/systemd/user/awww.service` runs the daemon and calls the
   wallpaper script afterwards:

   ```ini
   [Unit]
   PartOf=graphical-session.target
   After=graphical-session.target
   Requisite=graphical-session.target

   [Service]
   Type=simple
   ExecStart=/usr/bin/awww-daemon
   ExecStartPost=%h/.local/bin/sway-set-wallpaper
   Restart=on-failure
   RestartSec=2

   [Install]
   WantedBy=graphical-session.target
   ```

3. `~/.local/bin/sway-set-wallpaper` reads the Sway Control Center state file
   `~/.config/sway-control-center/settings.json`, maps the scaling mode
   (fill/fit/stretch/center/tile) onto awww's resize strategies, waits for the
   daemon socket to answer `awww query`, then runs
   `awww img --resize <mode> --transition-type simple <image>`.

`swaybg` stays **installed**: it is a hard dependency of `sway-config-fedora`,
and removing it would cascade into removing `sway-config-fedora`,
`sway-systemd`, `sddm-wayland-sway` and `swayfx`, which would leave no way to
log in graphically. It is never started.

---

## 4. Waybar as a systemd user service

**Why.** Sway started its own bar (`90-bar.conf`), which produced duplicate
bars and made the bar die with the compositor.

**How.**

- `~/.config/sway/config.d/90-bar.conf` is intentionally empty — it overrides
  Fedora's `/usr/share/sway/config.d/90-bar.conf`, so Sway launches no bar.
- Waybar is started by Fedora's packaged unit
  `/usr/lib/systemd/user/waybar.service`, enabled into
  `~/.config/systemd/user/graphical-session.target.wants/waybar.service`.
- The bar config lives in `~/.config/waybar/config.jsonc` and
  `~/.config/waybar/style.css` with the charcoal/teal palette.

Waybar's `network` and `bluetooth` modules sit after the battery module, and
the duplicate NetworkManager/Blueman tray applets are hidden through
`~/.config/autostart/nm-applet.desktop` and `blueman.desktop` (both set to
`Hidden=true`).

The Waybar info button opens `~/.local/bin/sway-keybindings`, which prints the
live keybinding list through `swaymsg -t get_config` and pipes it into a
scrollable window.

---

## 5. Launcher: Fuzzel + nwggrid

- `set $menu fuzzel` in `~/.config/sway/config`. Super+D opens Fuzzel.
- Super+Shift+space and the Waybar rocket button open **nwggrid**
  (`~/.config/nwg-launchers/nwggrid/style.css`), a searchable app drawer.
- `~/.local/bin/sway-quick-menu` is a Fuzzel dmenu that offers quick actions:
  clipboard history, network, bluetooth, audio, calendar, process monitor and
  the power menu.
- `~/.local/bin/sway-power-menu` is a second Fuzzel dmenu with lock, suspend,
  log out, reboot and power off.

Both were installed with:

```bash
dnf install azote nwg-launchers      # azote was removed again later
dnf remove azote
```

Azote is no longer used; the wallpaper is managed by Sway Control Center.

---

## 6. Terminal: kitty, and Foot removed

```bash
dnf remove foot
dnf install kitty
```

`set $term kitty`. Kitty keeps its own upstream Rosé Pine theme
(`~/.config/kitty/current-theme.conf`, included from `~/.config/kitty/kitty.conf`).
The Sway Control Center deliberately does **not** touch Kitty's theme.

Extra terminal variables in `~/.config/sway/config`:

```
set $term_cwd   kitty --directory "$HOME"
set $term_float kitty --class floating_shell
set $calendar   $term_float calcurse
set $bluetooth  $term_float bluetoothctl
```

`floating_shell` is what makes those helper windows float (the
`for_window [class="floating_shell"]` rule comes from the Fedora fragments
plus the local `70-settings.conf`).

---

## 7. Clipboard: cliphist → CopyQ

CopyQ gives a real clipboard history window and a themed tray icon.

```bash
dnf install copyq ydotool
```

- `~/.config/systemd/user/copyq.service` starts CopyQ inside the session and
  loads the theme right after start:

  ```ini
  [Service]
  Environment=YDOTOOL_SOCKET=/run/ydotoold.sock
  Environment=QT_QPA_PLATFORM=wayland
  Environment=QT_QPA_PLATFORMTHEME=qt6ct
  ExecStart=/usr/bin/copyq
  ExecStartPost=/usr/bin/copyq eval "loadTheme('%h/.config/copyq/themes/PrussianGreen.ini'); iconColor('#368582')"
  Restart=on-failure
  RestartSec=2
  ```

- `~/.config/copyq/copyq.conf` and `~/.config/copyq/copyq-commands.ini` hold
  the CopyQ settings and the Wayland paste command, which uses `ydotool`:
  CopyQ cannot paste into Wayland on its own, so the paste is emulated with
  `ydotool key --clearmodifiers ctrl+v` against the ydotool daemon socket.

- `sudo ./fedora-overlay/install-copyq-wayland.sh` configures the system
  ydotool daemon with a user-only socket (`/run/ydotoold.sock`), so only the
  logged-in user can reach it.

- The old `~/.config/systemd/user/cliphist.service` and the cliphist database
  are kept for upgraded systems, but CopyQ is what runs. The Waybar clipboard
  glyph was replaced by the CopyQ tray icon.

Super+Shift+v → `copyq toggle`.

---

## 8. Sway Control Center (custom application)

`~/.local/bin/sway-control-center` is a **custom Python 3 / GTK 4**
application (~37 KB) written for this setup. It is the single place where the
appearance is changed, and it writes to all of the backends at once.

What it writes:

| Target | File / command |
|---|---|
| GTK 3 | `~/.config/gtk-3.0/settings.ini` |
| GTK 4 | `~/.config/gtk-4.0/settings.ini` |
| GTK 2 | `~/.config/gtk-2.0/settings.ini` + `~/.gtkrc-2.0` |
| Qt 5 | `~/.config/qt5ct/qt5ct.conf` + `~/.config/qt5ct/colors/*.conf` |
| Qt 6 | `~/.config/qt6ct/qt6ct.conf` + `~/.config/qt6ct/colors/*.conf` |
| Kvantum | `~/.config/Kvantum/kvantum.kvconfig` |
| XSettings | `~/.config/xsettingsd/xsettingsd.conf` |
| Sway palette | `~/.config/sway/config` (`client.focused` … `client.urgent`) |
| Flatpak theme | `flatpak override --user --filesystem=…` + `flatpak override --user --env=…` |
| GNOME/desktop | `gsettings set org.gnome.desktop.interface …` |
| Wallpaper | `awww img …` and `~/.config/sway-control-center/settings.json` |
| Cursor | `swaymsg seat * xcursor_theme …` and `swaymsg reload` |

State file: `~/.config/sway-control-center/settings.json`.

Bindings:

- `Super+Shift+S` → settings panel (`~/.config/sway/config.d/70-settings.conf`)
- `Super+Shift+W` → appearance/wallpaper panel (`~/.config/sway/config`)

It also contains a **brightness slider** (reads and writes
`/sys/class/backlight/*/brightness` through `brightnessctl`), and it strips
the `output * bg` line from the Sway config before writing the palette, so the
single-wallpaper-process rule from step 3 is preserved.

---

## 9. Theme stack

| Layer | Choice | Where |
|---|---|---|
| GTK 3/4 | Yaru Prussian Green Dark | Fedora packages `yaru-gtk3-theme`, `yaru-gtk4-theme` |
| GTK 2 | shim matching the dark palette | `~/.config/gtk-2.0/settings.ini`, `~/.gtkrc-2.0` |
| Qt 5/6 | Kvantum `KvYaru-PrussianGreenDark` | local copy in `~/.config/Kvantum/` |
| Qt palettes | `Yaru-PrussianGreenDark.conf` | `~/.config/qt5ct/colors/`, `~/.config/qt6ct/colors/` |
| Icons | Papirus-Dark | `papirus-icon-theme-dark` |
| Cursor | Bibata Modern Ice | `bibata-cursor-themes` |
| Font | Inter (UI), JetBrainsMono Nerd Font (terminal/editor) | `~/.local/share/fonts/NerdFonts` |
| Terminal | Rosé Pine | `~/.config/kitty/current-theme.conf` |

Palette: charcoal `#1b1b1b` / `#2f2f2f`, teal `#368582`, light text `#eff0f1`.

Flatpak apps get the same look through user overrides:

```
[Context]
filesystems=/usr/share/icons/Bibata-Modern-Ice:ro;/usr/share/icons/Yaru-prussiangreen-dark:ro;

[Environment]
XCURSOR_SIZE=24
XCURSOR_THEME=Bibata-Modern-Ice
```

plus the Flatpak runtime `org.gtk.Gtk3theme.Yaru-prussiangreen-dark`.

GNOME Tweaks and LXAppearance were removed
(`dnf remove gnome-tweaks lxappearance`); `qt5ct` and `qt6ct` stay installed
but hidden, because they are the theme backends the control center writes to.

`~/.config/xsettingsd/xsettingsd.conf` + `~/.config/systemd/user/xsettingsd.service`
make XSettings follow the same theme for X11-era widgets.

---

## 10. Cursor theme at the compositor level

`~/.config/sway/config.d/70-settings.conf`:

```
seat * xcursor_theme Bibata-Modern-Ice 24
exec_always env XCURSOR_THEME=Bibata-Modern-Ice XCURSOR_SIZE=24 dbus-update-activation-environment --systemd XCURSOR_THEME XCURSOR_SIZE
```

`~/.config/sway/environment` sets the same variables for the session, together
with the Qt platform variables:

```
QT_QPA_PLATFORM="wayland;xcb"
QT_QPA_PLATFORMTHEME=qt6ct
XCURSOR_THEME=Bibata-Modern-Ice
XCURSOR_SIZE=24
_JAVA_AWT_WM_NONREPARENTING=1
```

`~/.config/sway/environment` is read by `/usr/bin/start-sway` **before** the
compositor starts, so changes there need a new login; changes in
`config.d/70-settings.conf` are picked up by `swaymsg reload`.

---

## 11. Screenshot: grimshot + Swappy

```
bindsym Print       exec grimshot save output - | swappy -f -
bindsym Alt+Print   exec grimshot save active - | swappy -f -
bindsym Ctrl+Print  exec grimshot save area   - | swappy -f -
```

Fedora's own `60-bindings-screenshot.conf` defines Print bindings too, so
`~/.config/sway/config.d/60-bindings-screenshot.conf` is an **intentionally
empty** file: it exists only to shadow the vendor fragment (same filename,
later directory wins) and stop the duplicate-binding warnings.

`swappy` is configured in `~/.config/swappy/config`.

---

## 12. SDDM greeter: Ronin theme

```bash
sudo ./fedora-overlay/install-sddm-ronin.sh
```

- Theme files: `/usr/share/sddm/themes/ronin/` (from the `ronin` branch of
  `mahaveergurjar/sddm`, plus the matching wallpaper from the author's
  Hyprlock-Dots repository, a dynamic account greeting and the SDDM Qt6
  compatibility module).
- Enabled by `/etc/sddm.conf.d/99-ronin-theme.conf`:

  ```ini
  [Theme]
  Current=ronin
  ```

- SDDM is the active and enabled login manager for the Sway session.

The whole theme tree is copied into `backup/system/usr/share/sddm/themes/ronin`.

---

## 13. NVIDIA proprietary driver on a hybrid laptop

The machine is an ASUS TUF A15 FA506II: the internal panel is wired to the
AMD Renoir iGPU, the GTX 1650 Ti sits idle.

```bash
dnf install --nogpgcheck --repofrompath=rpmlfusionfree,https://mirrors.rpmfusion.org/free/fedora/45/anything/x86_64/ rpmlfusionfree-release
dnf install akmod-nvidia xorg-x11-drv-nvidia
```

- `nouveau` is blacklisted in `/etc/modprobe.d/blacklist-nouveau.conf`.
- `/etc/modprobe.d/nvidia-drm.conf` enables `nvidia_drm modeset=1`.
- RPM Fusion's `/usr/lib/dracut/dracut.conf.d/99-nvidia-dracut.conf` keeps the
  NVIDIA modules **out** of the ramdisk. That is wrong once nouveau is
  blacklisted, because the proprietary driver has to claim the device early.
  `~/.local/bin/sway-nvidia-initramfs` rebuilds the ramdisk with the modules
  included:

  ```bash
  dracut --force --kver <ver> --add-drivers "nvidia nvidia-modeset nvidia-drm nvidia-uvm"
  ```

  **Run it after every kernel update.**

- The proprietary driver makes Sway print "Proprietary GPU drivers are not
  supported by sway" on startup. `~/.config/sway/environment` passes
  `--unsupported-gpu` through `SWAY_EXTRA_ARGS`, which suppresses the notice
  only — it does not change the renderer.
- `~/.local/bin/sway-prime-run <command>` pushes a single command onto the
  discrete GPU through PRIME render offload:

  ```bash
  export __NV_PRIME_RENDER_OFFLOAD=1
  export __GLX_VENDOR_LIBRARY_NAME=nvidia
  export __EGL_VENDOR_LIBRARY_FILES=/usr/share/glvnd/egl_vendor.d/10_nvidia.json
  ```

The panel stays on the iGPU; only explicitly launched programs use the dGPU.

---

## 14. Shells, prompt and editor

```bash
dnf install fish nushell
chsh -s /usr/bin/fish          # the account login shell is /usr/bin/fish
```

| Tool | Config | Notes |
|---|---|---|
| Fish | `~/.config/fish/config.fish`, `~/.config/fish/conf.d/kitty-ssh.fish` | `fish_variables` is state, not config |
| Nushell | `~/.config/nushell/config.nu` | sources `~/.cargo/env.nu`, which now exists |
| Starship | `~/.config/starship.toml` | binary installed to `~/.local/bin/starship` (upstream release, 1.27.0) |
| Neovim | `~/.config/nvim/` | lazy.nvim + 51 plugins, lock file `lazy-lock.json` |
| Kitty | `~/.config/kitty/` | terminal + Rosé Pine theme |
| tmux | `~/.config/tmux/tmux.conf`, `~/.tmux/` | TPM plugin tree in `~/.config/tmux/plugins` |

Starship is **not** in the Fedora 45 repos and the COPR build was outdated, so
the upstream release binary was installed into `~/.local/bin`. The same is true
of JetBrainsMono Nerd Font 3.5.1, which was installed into
`~/.local/share/fonts/NerdFonts`.

Neovim language servers are managed by mason and installed into
`~/.local/share/nvim/mason`: basedpyright, css-lsp, docker-compose-language-service,
dockerfile-language-server, gopls, html-lsp, json-lsp, lua-language-server,
taplo, terraform-ls, typescript-language-server, yaml-language-server, zls.

---

## 15. Dynamic Island (custom Quickshell UI)

A custom "Dynamic Island" was built for this session: a Rust daemon `isled`
plus a Quickshell UI.

- `~/.config/systemd/user/isled.service` runs
  `/home/asuna/Projects/dynamic-island/core/target/debug/isled`.
- `~/.config/systemd/user/quickshell.service` runs the Nix-packaged
  `quickshell-0.3.2` against `/home/asuna/Projects/dynamic-island/ui`.

Both units import `WAYLAND_DISPLAY`, `XDG_RUNTIME_DIR`, `XDG_SESSION_TYPE`,
`NIRI_SOCKET`, `HYPRLAND_INSTANCE_SIGNATURE` and `DBUS_SESSION_BUS_ADDRESS`,
because the adapter has to know which compositor it is talking to — it is
already written for Hyprland and niri, not only for Sway.

The Quickshell unit also carries a Nix-on-Fedora workaround: the Nix build
ships its own `libEGL` but no Mesa vendor stack, so bare launches fail with
"EGL not available". The unit therefore sets:

```
Environment=LD_LIBRARY_PATH=/nix/store/<mesa>/lib:/nix/store/<libglvnd>/lib
Environment=__GLVND_LIBRARY_PATH=/nix/store/<mesa>/lib/libEGL_mesa.so
Environment=__GLX_VENDOR_LIBRARY_NAME=mesa
```

**Current state:** the `~/Projects/dynamic-island` source tree is **not
present** on the machine any more, so both units will fail to start. The unit
files are still captured in `backup/home/config/systemd/user/`. The state
directory `~/.local/state/isled` survives.

---

## 16. Other custom services and helpers

| Unit / script | Purpose |
|---|---|
| `~/.config/systemd/user/awww.service` | wallpaper daemon (step 3) |
| `~/.config/systemd/user/copyq.service` | clipboard manager (step 7) |
| `~/.config/systemd/user/xsettingsd.service` | XSettings theme bridge |
| `~/.config/systemd/user/mako.service` | notifications (Fedora package unit) |
| `~/.config/systemd/user/waybar.service` | bar (Fedora package unit) |
| `~/.config/systemd/user/isled.service` | dynamic island daemon |
| `~/.config/systemd/user/quickshell.service` | dynamic island UI |
| `~/.local/bin/sway-set-wallpaper` | apply saved wallpaper (step 3) |
| `~/.local/bin/sway-control-center` | appearance + system panel (step 8) |
| `~/.local/bin/sway-keybindings` | show live keybindings |
| `~/.local/bin/sway-quick-menu` | Fuzzel quick actions |
| `~/.local/bin/sway-power-menu` | Fuzzel power menu |
| `~/.local/bin/sway-clipboard-menu` | `copyq toggle` |
| `~/.local/bin/sway-settings` | alias for the control center |
| `~/.local/bin/sway-prime-run` | PRIME render offload (step 13) |
| `~/.local/bin/sway-nvidia-initramfs` | ramdisk rebuild (step 13) |
| `~/.local/bin/tuf-control` | TUF Control (third-party updater) |

`~/.config/autostart/` holds `blueman.desktop` and `nm-applet.desktop`, both
with `Hidden=true`, to suppress the duplicate tray applets.

---

## 17. Apps and tooling installed

Flatpak (system installation, `flathub` remote):

- `app.zen_browser.zen` — Zen Browser 1.24.2b (profile in
  `~/.var/app/app.zen_browser.zen/.zen`)
- `com.bitwig.BitwigStudio` — Bitwig Studio 6.1.7

RPM: the full list is in `backup/inventory/rpm-packages-full.txt`
(1882 packages). The user-facing ones that were installed on purpose:

awww, asusctl, bat, bibata-cursor-themes, blueman, brightnessctl, calcurse,
cliphist, copyq, fd-find, fzf, gh, ghostscript (+ fontutils/printing tools),
grimshot, htop, jq, kitty, kvantum-qt5, kvantum-data, lxqt-policykit, mako,
nautilus, neovim, NetworkManager-tui, nushell, nwg-launchers, nwg-wrapper,
openconnect, papirus-icon-theme, papirus-icon-theme-dark, pavucontrol, podman,
podman-compose, ripgrep, rustup, golang, zig, gcc, clang, swayfx, swayidle,
swaylock, swappy, wdisplays, xarchiver, ydotool, zoxide, zenity,
material-icons-fonts, jetbrains-mono-fonts, yaru-gtk3-theme, yaru-gtk4-theme,
sway-config-fedora, sway-systemd, sddm-wayland-sway, sddm.

Quickshell is not an RPM: it comes from the Nix store
(`/nix/store/p4fqvcdsgq2rds0f1k3gwqp7k50vfz8r-quickshell-0.3.2`).

Toolchains: `rustup` (stable), Go 1.27.4, gcc/clang 23, zig, podman +
podman-compose, `mise` (`~/.local/bin/mise`, 170 MB), `starship` 1.27.0,
`opencode` and `codex` CLIs, `tuf-control`.

---

## 18. Re-applying everything

On Fedora, the overlay still covers the appearance layer:

```bash
./fedora-overlay/apply-user-config.sh
```

It copies the user config and wallpaper/scripts, synchronises GTK2/3/4, Qt,
GNOME and XSettings theme preferences, restores saved Sway Control Center
choices, reloads the user systemd unit metadata, enables the clipboard,
XSettings, Mako and Waybar services and reloads Sway when run inside the
session. It does not install packages and does not replace system files.

The full restore procedure, including the parts the overlay does not cover
(swayfx itself, awww, the SDDM theme, the NVIDIA driver and the dynamic
island units), is in `backup/RESTORE.md`.

---

## 19. What is **not** covered by the overlay

For reference, these live only in the backup tree:

- the SwayFX replacement of the Sway binary,
- the `~/.config/sway/environment` file and the `--unsupported-gpu` flag,
- the `~/.config/sway/config.d/` overrides (screenshot shadowing, cursor theme,
  control-center binding, floating rules, empty bar fragment),
- `~/.config/systemd/user/{awww,copyq,xsettingsd,isled,quickshell}.service`,
- the brightness slider in the control center,
- the dynamic island units,
- the flatpak user overrides,
- the per-user Qt5ct/Qt6ct palettes actually written by the control center.
