#!/usr/bin/env bash
# Restore the user configuration captured in this backup onto the current home.
#
#   ./restore-user-config.sh            # dry run: prints what would happen
#   ./restore-user-config.sh --apply    # actually restore
#
# It never touches anything outside $HOME, never installs packages and never
# edits files in /etc. The heavy trees (fonts, Neovim plugins, browser
# profiles) live in backup/archives and are restored separately - see
# backup/RESTORE.md, section A1.

set -euo pipefail

BACKUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOME_DIR="${HOME:-/home/asuna}"
APPLY=0
[[ "${1:-}" == "--apply" ]] && APPLY=1

say() { printf '%s\n' "$*"; }

restore() {
    local src="$1" dst="$2" label="$3"
    if [[ ! -e "$src" ]]; then
        say "  missing source: $src"
        return 0
    fi
    if [[ $APPLY -eq 1 ]]; then
        mkdir -p "$dst"
        rsync -a --no-owner --no-group "$src"/ "$dst"/
        say "  restored $label -> $dst"
    else
        say "  would restore $label -> $dst"
    fi
}

say "backup:  $BACKUP_DIR"
say "target:  $HOME_DIR"
if [[ $APPLY -eq 0 ]]; then
    say "mode:    DRY RUN (pass --apply to write)"
else
    say "mode:    APPLY"
fi
say ""

say "[1/8] configuration tree"
restore "$BACKUP_DIR/home/config" "$HOME_DIR/.config" "~/.config"

say "[2/8] dotfiles"
for f in "$BACKUP_DIR"/home/dotfiles/.[!.]*; do
    [[ -e "$f" ]] || continue
    base="$(basename "$f")"
    case "$base" in
        .tmux)    restore "$f" "$HOME_DIR/.tmux" "~/.tmux" ;;
        .themes)  restore "$f" "$HOME_DIR/.themes" "~/.themes" ;;
        .local_share_zoxide) restore "$f" "$HOME_DIR/.local/share/zoxide" "~/.local/share/zoxide" ;;
        .config_kdeglobals) restore "$f" "$HOME_DIR/.config" "kdeglobals" ;;
        *)        restore "$f" "$HOME_DIR" "$base" ;;
    esac
done

say "[3/8] local scripts and data"
restore "$BACKUP_DIR/home/local/bin" "$HOME_DIR/.local/bin" "~/.local/bin"
restore "$BACKUP_DIR/home/local/share" "$HOME_DIR/.local/share" "~/.local/share"
restore "$BACKUP_DIR/home/local/state" "$HOME_DIR/.local/state" "~/.local/state"

say "[4/8] toolchains (config only)"
restore "$BACKUP_DIR/home/cargo" "$HOME_DIR/.cargo" "~/.cargo"
restore "$BACKUP_DIR/home/rustup" "$HOME_DIR/.rustup" "~/.rustup"

say "[5/8] user data"
restore "$BACKUP_DIR/home/Pictures" "$HOME_DIR/Pictures" "~/Pictures"
restore "$BACKUP_DIR/home/Documents" "$HOME_DIR/Documents" "~/Documents"
restore "$BACKUP_DIR/home/var-app" "$HOME_DIR/.var/app" "~/.var/app"

say "[6/8] app settings"
restore "$BACKUP_DIR/home/codex" "$HOME_DIR/.codex" "~/.codex"
restore "$BACKUP_DIR/home/npm" "$HOME_DIR/.npm" "~/.npm"

say "[7/8] secrets (mode 600)"
if [[ -d "$BACKUP_DIR/secrets" ]]; then
    if [[ $APPLY -eq 1 ]]; then
        mkdir -p "$HOME_DIR/.ssh"
        cp -a "$BACKUP_DIR/secrets/ssh/." "$HOME_DIR/.ssh/" 2>/dev/null || true
        chmod 700 "$HOME_DIR/.ssh"
        find "$HOME_DIR/.ssh" -type f -exec chmod 600 {} +
        [[ -f "$BACKUP_DIR/secrets/auth.json" ]] && cp -a "$BACKUP_DIR/secrets/auth.json" "$HOME_DIR/.codex/auth.json"
        [[ -f "$BACKUP_DIR/secrets/cli.json" ]] && cp -a "$BACKUP_DIR/secrets/cli.json" "$HOME_DIR/.config/opencode/cli.json"
        [[ -f "$BACKUP_DIR/secrets/service.json" ]] && cp -a "$BACKUP_DIR/secrets/service.json" "$HOME_DIR/.config/opencode/service.json"
        [[ -f "$BACKUP_DIR/secrets/gitconfig" ]] && cp -a "$BACKUP_DIR/secrets/gitconfig" "$HOME_DIR/.gitconfig"
        chmod 600 "$HOME_DIR/.codex/auth.json" "$HOME_DIR/.config/opencode/cli.json" 2>/dev/null || true
        say "  restored secrets"
    else
        say "  would restore ~/.ssh, ~/.codex/auth.json, ~/.config/opencode/*, ~/.gitconfig"
    fi
else
    say "  no secrets directory in this backup"
fi

say "[8/8] systemd user units"
restore "$BACKUP_DIR/home/config/systemd" "$HOME_DIR/.config/systemd" "~/.config/systemd"

say ""
if [[ $APPLY -eq 1 ]]; then
    say "done. now run:"
    say "  systemctl --user daemon-reload"
    say "  systemctl --user enable --now awww.service copyq.service xsettingsd.service"
    say "  swaymsg reload          # inside a Sway session"
else
    say "dry run finished. re-run with --apply to restore."
fi
