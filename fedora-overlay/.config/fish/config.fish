# ~/.config/fish/config.fish
# Portable Fish configuration for Fedora.
# Theme and Fisher plugins are installed by install-fedora-fish.sh.

if status is-interactive
    # Keep startup quiet and terminal colors accurate.
    set -g fish_greeting
    set -gx COLORTERM truecolor
    set -gx TERMINAL kitty
    set -gx DIRENV_LOG_FORMAT ''
    set -gx GOPATH "$HOME/go"
    set -gx MANPAGER "sh -c 'col -bx | bat -l man -p'"
    set -gx MANROFFOPT -c
    set -gx BAT_THEME base16

    # User-installed tools and language toolchains.
    fish_add_path --global \
        "$HOME/.local/bin" \
        "$HOME/.local/share/bin" \
        "$HOME/go/bin" \
        "$HOME/.local/share/coursier/bin" \
        "$HOME/.config/emacs/bin"

    # ── Prompt ────────────────────────────────────────────────────────────────
    if type -q starship
        starship init fish | source
    end

    # Starship transient prompt support.
    function starship_transient_prompt_func
        if type -q starship
            starship module character
        end
    end

    # ── Smarter directory navigation ─────────────────────────────────────────
    if type -q zoxide
        zoxide init fish --cmd cd | source
    end

    # ── Per-directory environment variables ───────────────────────────────────
    if type -q direnv
        direnv hook fish | source
    end

    # ── Fuzzy finding ─────────────────────────────────────────────────────────
    set -gx FZF_DEFAULT_COMMAND 'fd --type f --strip-cwd-prefix --hidden --follow --exclude .git'
    set -gx FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
    set -gx FZF_CTRL_T_OPTS "--preview 'bat --color=always --style=numbers --line-range=:500 {}'"
    set -gx FZF_ALT_C_COMMAND 'fd --type d --hidden --follow --exclude .git'
    set -gx FZF_ALT_C_OPTS "--preview 'eza --tree --color=always --icons=always {} | head -200'"

    if type -q fzf
        fzf --fish | source
    end

    # Television is initialized after fzf so its Ctrl-T and Ctrl-R bindings take
    # precedence. Both tools remain available as standalone commands.
    if type -q tv
        tv init fish | source
    end

    # ── Aliases ──────────────────────────────────────────────────────────────
    if type -q eza
        alias ls='eza --icons=auto --group-directories-first'
        alias ll='eza --long --header --git --icons=auto --group-directories-first'
        alias la='eza --all --long --header --git --icons=auto --group-directories-first'
        alias lt='eza --tree --level=2 --icons=auto'
        alias lo='eza --long --octal-permissions --icons=auto'
        alias tree='eza --tree --icons=auto'
    end

    if type -q bat
        alias cat='bat --paging=never'
    end

    alias grep='rg'
    alias tmux='tmux -u'
    alias up='sudo dnf upgrade --refresh'
    alias g='git'

    if type -q btop
        alias top='btop'
    end
    if type -q duf
        alias df='duf'
    end
    if type -q dust
        alias du='dust'
    end

    # ── Small helper functions ────────────────────────────────────────────────
    function mkcd --description 'Create a directory and enter it'
        if test (count $argv) -ne 1
            echo 'Usage: mkcd DIRECTORY' >&2
            return 2
        end
        mkdir -p -- "$argv[1]"; and cd -- "$argv[1]"
    end

    function bak --description 'Copy files to a .bak sibling'
        if test (count $argv) -eq 0
            echo 'Usage: bak FILE...' >&2
            return 2
        end
        for file in $argv
            if not test -e "$file"
                echo "bak: no such file: $file" >&2
                return 1
            end
            cp -a -- "$file" "$file.bak"; or return $status
        end
    end

    # ── Abbreviations ─────────────────────────────────────────────────────────
    # Only add missing entries, so user-defined abbreviations are not clobbered.
    for pair in \
        'v nvim' \
        'vim nvim' \
        'gs git status -sb' \
        'ga git add' \
        'gc git commit -m' \
        'gp git push' \
        'gl git log --oneline --graph --decorate' \
        'gd git diff'
        set -l fields (string split ' ' -- "$pair")
        set -l name "$fields[1]"
        set -l expansion (string join ' ' -- $fields[2..-1])
        if not abbr --query "$name"
            abbr --add "$name" "$expansion"
        end
    end
end

# Optional user-installed tools.
fish_add_path "$HOME/.opencode/bin"
if test -x "$HOME/.local/bin/mise"
    "$HOME/.local/bin/mise" activate fish | source
end
