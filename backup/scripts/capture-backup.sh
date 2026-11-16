#!/usr/bin/env bash
# Capture a complete, reproducible backup of this Fedora 45 SwayFX workstation.
#
# The script is idempotent: re-running it refreshes the tree in place. It never
# writes outside the repository, and it never touches the live system state.
#
# Usage:
#   ./backup/scripts/capture-backup.sh            # capture into ./backup
#   REPO_ROOT=/path/to/repo ./capture-backup.sh   # capture somewhere else
#
# What lands where:
#   backup/home/       user configs, dotfiles, scripts, app data
#   backup/system/     the system files this desktop actually depends on
#   backup/inventory/  package lists, service lists, hardware and session dumps
#   backup/archives/   tar.zst bundles for the heavy binary trees (gitignored)

set -euo pipefail

REPO_ROOT="${REPO_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
DEST="$REPO_ROOT/backup"
HOME_DIR="${HOME:-/home/asuna}"
STAMP="$(date +%Y-%m-%d_%H-%M-%S)"
LOG="$DEST/capture.log"
INV="$DEST/inventory"

log() { printf '%s %s\n' "$(date +%H:%M:%S)" "$*" | tee -a "$LOG"; }

# copy_tree <source> <destination> [extra rsync args...]
copy_tree() {
    local src="$1" dst="$2"
    shift 2
    if [[ ! -e "$src" ]]; then
        log "skip (missing): $src"
        return 0
    fi
    mkdir -p "$dst"
    if [[ -f "$src" ]]; then
        log "copy: $src -> $dst"
        cp -a "$src" "$dst/" 2>>"$LOG" || log "  warn: cannot copy $src"
        return 0
    fi
    log "copy: $src -> $dst"
    # .git internals are repository metadata of vendored trees (tmux plugin
    # clones, tuf-control); the plugin content is what the backup is for.
    rsync -a --no-owner --no-group --safe-links --exclude='.git/' "$@" "$src/" "$dst/" 2>>"$LOG" || \
        log "  warn: rsync reported errors for $src (see $LOG)"
}

# record <output-file> <command...>  - capture a command's output, never fail the run
record() {
    local out="$1"
    shift
    mkdir -p "$(dirname "$out")"
    {
        printf '# captured %s\n' "$(date -Is)"
        printf '# command: %s\n' "$*"
        "$@" 2>&1 || printf '(command failed, exit %s)\n' "$?"
    } > "$out"
}

# archive <name> <path...> - tar.zst a tree into backup/archives
archive() {
    local name="$1"
    shift
    mkdir -p "$DEST/archives"
    log "archive: $name"
    tar -C / --zstd -cf "$DEST/archives/$name.tar.zst" "$@" 2>>"$LOG"
}

mkdir -p "$DEST"/{home,system,inventory,archives}
: > "$LOG"

# Prune paths that are no longer part of the tree (kept out of git and/or
# archived separately), so a re-run never leaves stale copies behind.
rm -rf "$DEST/home/ssh" \
       "$DEST/home/opencode/bin" \
       "$DEST/home/config/mozilla/firefox" \
       "$DEST/home/config/opencode/cli.json" \
       "$DEST/home/config/opencode/service.json" \
       "$DEST/home/codex/auth.json" \
       "$DEST/home/codex/models_cache.json"

# Drop vendored git metadata from the backup: those trees are plugin clones,
# not configuration, and their .git directories are large and volatile.
find "$DEST/home" -type d -name '.git' -prune -print0 2>/dev/null \
    | while IFS= read -r -d '' d; do rm -rf "$d"; done

# Runtime sockets (CopyQ's IPC socket) are not configuration.
find "$DEST/home" -type s -delete 2>/dev/null

log "=== capture start: $(date -Is) ==="
log "repo: $REPO_ROOT"

################################################################################
# 0. Secrets: kept apart from the rest of the tree, mode 600, never in git
################################################################################
SEC="$DEST/secrets"
mkdir -p "$SEC"
chmod 700 "$SEC"
if [[ -d "$HOME_DIR/.ssh" ]]; then
    mkdir -p "$SEC/ssh"
    cp -a "$HOME_DIR/.ssh/." "$SEC/ssh/" 2>>"$LOG" || log "  warn: cannot copy .ssh"
    chmod 700 "$SEC/ssh"
    find "$SEC/ssh" -type f -exec chmod 600 {} +
fi
for f in "$HOME_DIR/.codex/auth.json" "$HOME_DIR/.config/opencode/cli.json" \
         "$HOME_DIR/.config/opencode/service.json" "$HOME_DIR/.gitconfig"; do
    [[ -e "$f" ]] && cp -a "$f" "$SEC/$(basename "$f")" 2>>"$LOG"
done
find "$SEC" -maxdepth 1 -type f -exec chmod 600 {} +

################################################################################
# 1. Home: dotfiles
################################################################################
log "--- home dotfiles ---"
DOTS="$DEST/home/dotfiles"
mkdir -p "$DOTS"
for f in .bashrc .bash_profile .bash_logout .bash_history .profile .zshenv .zprofile .zshrc \
         .gitconfig .gitignore .gitattributes .gtkrc-2.0 .gtkrc .inputrc .tmux.conf \
         .xinitrc .xprofile .Xresources .aliases .dircolors .selected_editor \
         .face .fonts.conf .npmrc .cargo/config.toml .condarc .nanorc .curlrc .wgetrc; do
    if [[ -e "$HOME_DIR/$f" ]]; then
        cp -a "$HOME_DIR/$f" "$DOTS/" 2>>"$LOG" || log "  warn: cannot copy $f"
    fi
done
# whole directories that are pure config
for d in .tmux .themes .config/kdeglobals .local/share/zoxide; do
    [[ -e "$HOME_DIR/$d" ]] && copy_tree "$HOME_DIR/$d" "$DOTS/$(echo "$d" | tr '/' '_')"
done
log "dotfiles copied: $(find "$DOTS" -type f | wc -l) files"

################################################################################
# 2. Home: ~/.config (the main dotfile tree)
################################################################################
log "--- ~/.config ---"
copy_tree "$HOME_DIR/.config" "$DEST/home/config" \
    --exclude='cache/' --exclude='Cache/' --exclude='GPUCache/' \
    --exclude='Code Cache/' --exclude='CachedData/' --exclude='cache2/' \
    --exclude='blob_storage/' --exclude='Crash Reports/' --exclude='*.log' \
    --exclude='mozilla/firefox/' --exclude='opencode/cli.json' \
    --exclude='opencode/service.json'
# The Firefox/Zen profile is archived separately in section 7.

################################################################################
# 3. Home: ~/.local (bin scripts, share data, state)
################################################################################
log "--- ~/.local ---"
copy_tree "$HOME_DIR/.local/bin" "$DEST/home/local/bin" \
    --exclude='mise' --exclude='starship' --exclude='__pycache__'
copy_tree "$HOME_DIR/.local/share" "$DEST/home/local/share" \
    --exclude='containers/' --exclude='nvim/' --exclude='fonts/' \
    --exclude='opencode/opencode.db*' --exclude='opencode/snapshot/' \
    --exclude='opencode/log/' --exclude='gvfs-metadata/'
copy_tree "$HOME_DIR/.local/state" "$DEST/home/local/state" \
    --exclude='dnf5.log*'

################################################################################
# 4. Home: toolchains, app data, ssh
################################################################################
log "--- toolchains and app data ---"
copy_tree "$HOME_DIR/.cargo" "$DEST/home/cargo" --exclude='registry/' --exclude='git/'
copy_tree "$HOME_DIR/.rustup" "$DEST/home/rustup" --exclude='toolchains/' --exclude='downloads/'
copy_tree "$HOME_DIR/.var/app" "$DEST/home/var-app" --exclude='cache/'
copy_tree "$HOME_DIR/.npm" "$DEST/home/npm" --exclude='_cacache/'
copy_tree "$HOME_DIR/.codex" "$DEST/home/codex" \
    --exclude='*.sqlite*' --exclude='logs_*/' --exclude='sessions/' --exclude='history.jsonl' \
    --exclude='packages/' --exclude='cache/' --exclude='tmp/' --exclude='.tmp/' \
    --exclude='auth.json' --exclude='models_cache.json'
copy_tree "$HOME_DIR/.opencode" "$DEST/home/opencode" --exclude='bin/'
record "$INV/opencode-runtime.txt" bash -c "'$HOME_DIR/.opencode/bin/opencode' --version 2>&1 | head -3; ls -1 '$HOME_DIR/.opencode/bin' 2>/dev/null"
copy_tree "$HOME_DIR/Pictures" "$DEST/home/Pictures"
copy_tree "$HOME_DIR/Documents" "$DEST/home/Documents"

################################################################################
# 5. System: the files this desktop depends on
################################################################################
log "--- system files ---"
for p in \
    etc/sway \
    etc/environment.d \
    etc/xdg/xdg-desktop-portal-wlr \
    etc/xdg/swayr \
    etc/xdg/xdg-ubuntusway \
    etc/systemd/user \
    etc/systemd/system \
    etc/modprobe.d \
    etc/dracut.conf.d \
    etc/sysctl.d \
    etc/sddm.conf.d \
    etc/sddm.conf \
    etc/default/grub \
    etc/fstab \
    etc/os-release \
    etc/hostname \
    etc/os-release \
    etc/environment \
    etc/pam.d/sddm \
    etc/udev/rules.d \
    etc/flatpak \
    ; do
    if [[ -e "/$p" ]]; then
        copy_tree "/$p" "$DEST/system/$p"
    else
        log "skip (missing): /$p"
    fi
done
# kernel command line and boot loader state
record "$DEST/system/boot/proc-cmdline.txt" cat /proc/cmdline
record "$DEST/system/boot/grubby-info.txt" grubby --info=ALL
record "$DEST/system/boot/ls-initramfs.txt" ls -l /boot
mkdir -p "$DEST/system/boot"
cp /proc/cmdline "$DEST/system/boot/proc-cmdline.txt" 2>/dev/null || true
grubby --info=ALL > "$DEST/system/boot/grubby-info.txt" 2>&1 || true
# SDDM theme that was installed into the system tree
[[ -d /usr/share/sddm/themes/ronin ]] && copy_tree /usr/share/sddm/themes/ronin "$DEST/system/usr/share/sddm/themes/ronin"
[[ -d /usr/share/sddm/themes/03-sway-fedora ]] && copy_tree /usr/share/sddm/themes/03-sway-fedora "$DEST/system/usr/share/sddm/themes/03-sway-fedora"

# The Sway package fragments: the default bindings and rules that the user
# config shadows, plus the launcher and the layered-include helper.
[[ -d /usr/share/sway ]] && copy_tree /usr/share/sway "$DEST/system/usr/share/sway" --exclude='live/'
[[ -d /usr/libexec/sway ]] && copy_tree /usr/libexec/sway "$DEST/system/usr/libexec/sway"
[[ -f /usr/bin/start-sway ]] && copy_tree /usr/bin/start-sway "$DEST/system/usr/bin"

################################################################################
# 6. Inventory: packages, apps, services, session state
################################################################################
log "--- inventory ---"

record "$INV/rpm-packages-full.txt"        rpm -qa
record "$INV/rpm-packages-user-facing.txt"  bash -c "rpm -qa --qf '%{NAME}\t%{VERSION}-%{RELEASE}\n' | sort"
record "$INV/rpm-owners-files.txt"         bash -c "rpm -qf /usr/bin/sway /usr/bin/swaymsg /usr/bin/waybar /usr/bin/kitty 2>/dev/null | sort -u"
record "$INV/dnf-repos.txt"                dnf repolist --enabled
record "$INV/dnf-history.txt"              dnf history list
record "$INV/dnf-history-info.txt"         dnf history info last
record "$INV/dnf-user-installed.txt"       dnf repoquery --userinstalled --qf '%{NAME}\t%{VERSION}-%{RELEASE}\t%{REPONAME}\n'

record "$INV/flatpak-apps.txt"             flatpak list --app --columns=application,name,version,branch,origin,installation
record "$INV/flatpak-runtimes.txt"         flatpak list --runtime --columns=application,version,branch
record "$INV/flatpak-remotes.txt"          flatpak remotes --show-details
record "$INV/flatpak-overrides.txt"        flatpak override --user --show
record "$INV/flatpak-sbom.txt"             flatpak list --app --columns=application --show-metadata

record "$INV/cargo-installed.txt"          bash -c "ls -1 ~/.cargo/bin 2>/dev/null"
record "$INV/rustup-toolchains.txt"        rustup toolchain list
record "$INV/rustup-components.txt"        rustup component list --installed
record "$INV/go-version.txt"               go version
record "$INV/go-packages.txt"              bash -c "ls -1 ~/go/bin 2>/dev/null || true"
record "$INV/npm-global.txt"               npm ls -g --depth=0
record "$INV/python-pip.txt"               bash -c "python3 -m pip list 2>&1 || echo 'pip not installed'"
record "$INV/mise-tools.txt"               bash -c "mise ls 2>&1 || true"
record "$INV/nix-profile.txt"              bash -c "nix profile list 2>&1 || true"
record "$INV/nix-store-references.txt"     bash -c "ls -1 /nix/store 2>/dev/null | grep -Ev '\.(drv|patch)$' | wc -l; ls -1 /nix/store | grep -E 'quickshell|mesa-|libglvnd' | head -50"
record "$INV/podman-images.txt"            bash -c "podman images --format '{{.Repository}}:{{.Tag}} {{.Size}}' 2>&1 || true"
record "$INV/podman-ps.txt"                bash -c "podman ps -a --format '{{.Names}} {{.Image}} {{.Status}}' 2>&1 || true"

record "$INV/systemd-user-units.txt"       bash -c "systemctl --user list-unit-files --all"
record "$INV/systemd-user-enabled.txt"     bash -c "systemctl --user list-unit-files --state=enabled"
record "$INV/systemd-user-running.txt"     bash -c "systemctl --user list-units --type=service --state=running"
record "$INV/systemd-system-services.txt"  bash -c "systemctl list-units --type=service --state=running"
record "$INV/systemd-timers.txt"           bash -c "systemctl list-timers --all"

record "$INV/gsettings-list.txt"           bash -c "gsettings list-recursively 2>&1 || true"
record "$INV/dconf-dump.txt"               bash -c "dconf dump / 2>&1 || true"
record "$INV/xdg-user-dirs.txt"            bash -c "cat ~/.config/user-dirs.dirs 2>/dev/null"
record "$INV/xsettingsd-conf.txt"          bash -c "cat ~/.config/xsettingsd/xsettingsd.conf 2>/dev/null"

record "$INV/desktop-entries-user.txt"     bash -c "ls -1 ~/.local/share/applications 2>/dev/null"
record "$INV/desktop-entries-system.txt"   bash -c "ls -1 /usr/share/applications 2>/dev/null | head -400"
record "$INV/gtk-theme.ini"                bash -c "cat ~/.config/gtk-3.0/settings.ini 2>/dev/null"
record "$INV/fonts-user.txt"               bash -c "fc-list : user 2>/dev/null | sort | head -200"
record "$INV/fonts-all-families.txt"        bash -c "fc-list : family 2>/dev/null | tr ',' '\n' | sort -u | head -200"

record "$INV/hardware-lspci.txt"           lspci -nnk
record "$INV/hardware-lsusb.txt"           lsusb
record "$INV/hardware-lscpu.txt"           lscpu
record "$INV/hardware-free.txt"            free -h
record "$INV/kernel-modules-blacklist.txt" bash -c "grep -R . /etc/modprobe.d/ 2>/dev/null"
record "$INV/kernel-installed.txt"         bash -c "rpm -qa 'kernel*' | sort"
record "$INV/kernel-current.txt"           uname -a

record "$INV/sway-version.txt"             sway --version
record "$INV/sway-version-json.txt"        swaymsg -t get_version
record "$INV/sway-config-effective.txt"    swaymsg -t get_config
record "$INV/sway-outputs.txt"             swaymsg -t get_outputs
record "$INV/sway-inputs.txt"              swaymsg -t get_inputs
record "$INV/sway-tree.txt"                swaymsg -t get_tree

record "$INV/environment.txt"              bash -c "env | sort"
record "$INV/passwd-user.txt"              bash -c "getent passwd $(id -u)"
record "$INV/groups-user.txt"              bash -c "id"

################################################################################
# 7. Archives for the heavy binary trees
################################################################################
log "--- archives ---"
[[ -d "$HOME_DIR/.local/share/fonts" ]] && archive fonts "$HOME_DIR/.local/share/fonts"
[[ -d "$HOME_DIR/.local/share/nvim" ]] && archive nvim-plugins-and-mason "$HOME_DIR/.local/share/nvim"
[[ -d "$HOME_DIR/.config/tmux/plugins" ]] && archive tmux-plugins "$HOME_DIR/.config/tmux/plugins"
[[ -d "$HOME_DIR/.config/mozilla/firefox" ]] && archive mozilla-firefox-profile "$HOME_DIR/.config/mozilla/firefox"
[[ -d "$HOME_DIR/.config/mozilla/extensions" ]] && archive mozilla-extensions "$HOME_DIR/.config/mozilla/extensions"
[[ -d "$HOME_DIR/.var/app/app.zen_browser.zen/.zen" ]] && archive zen-browser-profile "$HOME_DIR/.var/app/app.zen_browser.zen/.zen"

################################################################################
# 8. Manifest and checksums
################################################################################
log "--- manifest ---"
date -Is > "$DEST/capture-date.txt"
printf 'host=%s\nos=%s\nkernel=%s\nsway=%s\n' \
    "$(hostname)" "$(. /etc/os-release; echo "$PRETTY_NAME")" "$(uname -r)" \
    "$(sway --version 2>&1 | head -1)" > "$DEST/capture-meta.txt"
( cd "$DEST" && find . -type f -not -path './archives/*' -not -name 'checksums.sha256' \
    -not -name 'capture.log' -not -name 'archive-checksums.txt' -printf '%10s  %p\n' | sort -k2 > MANIFEST.txt )
( cd "$DEST" && find . -type f -not -path './archives/*' -not -name 'checksums.sha256' \
    -not -name 'capture.log' -not -name 'archive-checksums.txt' -print0 | sort -z | xargs -0 sha256sum > checksums.sha256 )
( cd "$DEST" && for f in archives/*.tar.zst; do
    [[ -e "$f" ]] || continue
    sha256sum "$f" >> checksums.sha256
done )

log "files: $(find "$DEST" -type f | wc -l)"
log "size:  $(du -sh "$DEST" | cut -f1)"
log "=== capture done: $(date -Is) ==="
