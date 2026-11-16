# Backup — Fedora 45 SwayFX workstation

Complete capture of this machine: user configuration, dotfiles, app settings,
installed apps, system files and the written record of every customisation.

Captured: see `capture-date.txt` / `capture-meta.txt`.
Host: ASUS TUF Gaming A15 FA506II — Fedora 45 (Sway) x86_64, SwayFX 0.6.1.

> **Copy this somewhere else before you install Ryoku.**
> The repository and the single-file archive both live on `/home/asuna`, which
> is on the root partition (`nvme0n1p6`) — the same disk a Ryoku install
> rewrites. Move `backup-full-2026-11-17.tar.zst` to external storage or a
> second machine, and check it with `backup/archive-checksums.txt` when it
> arrives.

| Document | What it is |
|---|---|
| `README.md` | this file — layout, how to verify, how to restore |
| `PROCEDURES.md` | **the written record**: every customisation, the command used to make it, and why |
| `INVENTORY.md` | every app and tool in use, with the path that holds its settings |
| `RESTORE.md` | restore on Fedora, and the port plan for Ryoku (Hyprland / niri) |
| `ryoku-port/` | the keybindings translated into `hypr/user.lua` and `niri/user.kdl` |

---

## Layout

```
backup/
├── README.md              this file
├── PROCEDURES.md          how the desktop was built, step by step
├── INVENTORY.md           apps → config paths
├── RESTORE.md             restore + port procedures
├── MANIFEST.txt           every backed up file with its size
├── checksums.sha256       SHA-256 of every file and every archive
├── capture-date.txt       when the capture ran
├── capture-meta.txt       host, OS, kernel, compositor version
├── capture.log            what the capture script did
│
├── home/                  the user tree, as plain files
│   ├── dotfiles/          ~/.bashrc, ~/.profile, ~/.gitconfig, ~/.tmux, ~/.themes …
│   ├── config/            ~/.config (the whole tree, caches pruned)
│   ├── local/             ~/.local/bin, ~/.local/share, ~/.local/state
│   ├── cargo/, rustup/    toolchain configuration
│   ├── codex/, npm/       CLI tool settings
│   ├── var-app/           Flatpak application data (Zen, Bitwig)
│   ├── Pictures/, Documents/
│   └── opencode/
│
├── system/                the system files this desktop depends on
│   ├── etc/sway/          Fedora's Sway config and fragments (reference)
│   ├── etc/modprobe.d/    nouveau blacklist, nvidia-drm modeset
│   ├── etc/systemd/       system units
│   ├── etc/sddm.conf.d/   greeter theme selection
│   ├── etc/default/grub, etc/fstab, etc/udev/rules.d
│   ├── boot/              kernel command line, grubby state
│   └── usr/share/sddm/themes/ronin/   the installed greeter theme
│
├── inventory/             the "what is installed" record
│   ├── rpm-packages-full.txt      all 1880 RPMs
│   ├── dnf-user-installed.txt      what was installed on purpose
│   ├── dnf-history.txt            every transaction with its command line
│   ├── flatpak-apps.txt, flatpak-sbom.txt, flatpak-overrides.txt
│   ├── systemd-user-*.txt         every user unit and its state
│   ├── sway-config-effective.txt  the live runtime configuration
│   ├── sway-outputs.txt, sway-inputs.txt
│   ├── hardware-*.txt, kernel-*.txt
│   └── cargo/rustup/go/nix/podman/mise/npm lists
│
├── archives/              tar.zst bundles for the heavy binary trees
│   ├── fonts.tar.zst              ~/.local/share/fonts (Nerd Fonts)
│   ├── nvim-plugins-and-mason.tar.zst   lazy.nvim plugins + mason LSPs
│   ├── tmux-plugins.tar.zst       TPM plugin clones
│   ├── mozilla-firefox-profile.tar.zst
│   ├── mozilla-extensions.tar.zst
│   └── zen-browser-profile.tar.zst
│
├── ryoku-port/            the Sway keybindings translated for Ryoku
│   ├── hypr/user.lua          ~/.config/hypr/user.lua
│   ├── niri/user.kdl          ~/.config/niri/user.kdl
│   └── README.md             the translation table and what was left out
│
├── secrets/               credentials — mode 600, excluded from git
│   ├── ssh/                      private key + known_hosts
│   ├── auth.json                 Codex credentials
│   ├── cli.json, service.json    OpenCode credentials
│   └── gitconfig
│
└── scripts/
    ├── capture-backup.sh          re-runs the whole capture
    ├── restore-user-config.sh     puts the user tree back (dry run by default)
    └── verify-backup.sh           checks every checksum
```

---

## Verifying the backup

```bash
./backup/scripts/verify-backup.sh
```

```
== plain files ==
OK: 2175 files match
== archives ==
OK   archives/fonts.tar.zst (127M)
...
BACKUP OK
```

Exit code 0 means the backup is intact. The same check by hand:

```bash
cd backup
sha256sum -c checksums.sha256
```

### Single-file portable copy

The whole repository was also packed into one file, so the backup can be moved
to another machine or an external disk in one go:

```bash
/home/asuna/backup-full-2026-11-17.tar.zst        # 804 MB
sha256sum -c backup/archive-checksums.txt          # recorded checksum
tar --zstd -xf backup-full-2026-11-17.tar.zst -C /path/to/target
```

`./scripts/make-portable-archive.sh` recreates it.

---

## Re-capturing

```bash
./backup/scripts/capture-backup.sh
```

The script is idempotent and never writes outside this repository. It copies
the live trees, dumps the package and service state, rebuilds the archives and
regenerates `MANIFEST.txt` and `checksums.sha256`. It is safe to run while the
session is live.

---

## Restoring

See `RESTORE.md`. Short version:

```bash
./backup/scripts/restore-user-config.sh --apply     # user tree
sudo ./fedora-overlay/install-sddm-ronin.sh          # greeter theme
```

The heavy trees come from the archives:

```bash
tar --zstd -xf backup/archives/fonts.tar.zst -C ~/.local/share
tar --zstd -xf backup/archives/nvim-plugins-and-mason.tar.zst -C ~/.local/share
```

---

## What was deliberately left out

| Left out | Why |
|---|---|
| `~/.cache` | caches, regenerated on demand |
| `~/.local/share/containers` (3.5 GB) | Podman images; the list is in `inventory/podman-images.txt` |
| `~/.opencode/bin` (240 MB) | the OpenCode runtime binary; the version is in `inventory/opencode-runtime.txt` |
| `~/.local/bin/mise` and `starship` binaries | upstream release binaries, reinstallable; the configs are backed up |
| `~/.cargo/registry`, `~/.rustup/toolchains` | caches and toolchains; the toolchain list is in `inventory/` |
| `.git` directories inside vendored trees | repository metadata, not configuration |
| `~/Projects/*` | left in place; `Nethergate/.env` and `secrets/` hold live credentials |
| `~/Projects/dynamic-island` | **the source tree was already missing** from the machine when the backup ran; the systemd units that reference it are backed up |
| browser caches | profiles are backed up, caches are not |

## Security note

`backup/secrets/` holds the SSH private key and the CLI credentials. It is
mode 600 and it is **excluded from git**. Before moving the backup to another
machine, encrypt it:

```bash
cd backup
tar -cf - secrets | gpg --symmetric --cipher-algo AES256 -o secrets.tar.gpg
```

and delete `secrets/` from the unencrypted copy.
