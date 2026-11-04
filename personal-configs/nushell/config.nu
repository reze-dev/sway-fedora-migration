# ~/.config/nushell/config.nu
# Portable Nushell configuration for Fedora (Rosé Pine edition).

use std/util "path add"
use std/config *

# ── Rosé Pine Theme Palette ───────────────────────────────────────────────────
let rose_pine = {
    base: "#191724"
    surface: "#1f1d2e"
    overlay: "#26233a"
    muted: "#6e6a86"
    subtle: "#908caa"
    text: "#e0def4"
    love: "#eb6f92"
    gold: "#f6c177"
    rose: "#ebbcba"
    pine: "#31748f"
    foam: "#9ccfd8"
    iris: "#c4a7e7"
    highlight_low: "#21202e"
    highlight_med: "#403d52"
    highlight_high: "#524f67"
}

let rose_pine_theme = {
    separator: $rose_pine.overlay
    leading_trailing_space_bg: { attr: "n" }
    header: { fg: $rose_pine.foam, attr: "b" }
    empty: $rose_pine.pine
    bool: {|| if $in { $rose_pine.foam } else { $rose_pine.love } }
    int: $rose_pine.iris
    filesize: {|e|
        if $e == 0b {
            $rose_pine.muted
        } else if $e < 1mb {
            $rose_pine.foam
        } else {
            $rose_pine.love
        }
    }
    duration: $rose_pine.gold
    date: {||
        (date now) - $in | if $in < 1hr {
            $rose_pine.love
        } else if $in < 6hr {
            $rose_pine.gold
        } else if $in < 1day {
            $rose_pine.rose
        } else if $in < 1wk {
            $rose_pine.foam
        } else {
            $rose_pine.subtle
        }
    }
    range: $rose_pine.gold
    float: $rose_pine.iris
    string: $rose_pine.gold
    nothing: $rose_pine.muted
    binary: $rose_pine.rose
    cell-path: $rose_pine.subtle
    row_index: { fg: $rose_pine.muted, attr: "b" }
    record: $rose_pine.text
    list: $rose_pine.text
    block: $rose_pine.text
    hints: $rose_pine.muted
    search_result: { fg: $rose_pine.base, bg: $rose_pine.rose }

    # CLI syntax highlighting shapes
    shape_and: { fg: $rose_pine.iris, attr: "b" }
    shape_binary: { fg: $rose_pine.iris, attr: "b" }
    shape_block: { fg: $rose_pine.pine, attr: "b" }
    shape_bool: $rose_pine.foam
    shape_closure: { fg: $rose_pine.foam, attr: "b" }
    shape_custom: $rose_pine.rose
    shape_datetime: { fg: $rose_pine.foam, attr: "b" }
    shape_directory: $rose_pine.foam
    shape_external: $rose_pine.foam
    shape_external_resolved: { fg: $rose_pine.foam, attr: "b" }
    shape_externalarg: $rose_pine.rose
    shape_filepath: $rose_pine.foam
    shape_flag: { fg: $rose_pine.iris, attr: "b" }
    shape_float: { fg: $rose_pine.iris, attr: "b" }
    shape_garbage: { fg: $rose_pine.text, bg: $rose_pine.love, attr: "b" }
    shape_glob_interpolation: { fg: $rose_pine.foam, attr: "b" }
    shape_globpattern: { fg: $rose_pine.foam, attr: "b" }
    shape_int: { fg: $rose_pine.iris, attr: "b" }
    shape_internalcall: { fg: $rose_pine.rose, attr: "b" }
    shape_keyword: { fg: $rose_pine.pine, attr: "b" }
    shape_list: { fg: $rose_pine.foam, attr: "b" }
    shape_literal: $rose_pine.pine
    shape_match_pattern: $rose_pine.gold
    shape_matching_brackets: { attr: "u" }
    shape_nothing: $rose_pine.muted
    shape_operator: $rose_pine.gold
    shape_or: { fg: $rose_pine.iris, attr: "b" }
    shape_pipe: { fg: $rose_pine.iris, attr: "b" }
    shape_range: { fg: $rose_pine.gold, attr: "b" }
    shape_raw_string: { fg: $rose_pine.gold, attr: "b" }
    shape_record: { fg: $rose_pine.foam, attr: "b" }
    shape_redirection: { fg: $rose_pine.iris, attr: "b" }
    shape_signature: { fg: $rose_pine.foam, attr: "b" }
    shape_string: $rose_pine.gold
    shape_string_interpolation: { fg: $rose_pine.rose, attr: "b" }
    shape_table: { fg: $rose_pine.pine, attr: "b" }
    shape_variable: $rose_pine.rose
    shape_vardecl: { fg: $rose_pine.rose, attr: "u" }
}

# ── Core Shell & Environment ──────────────────────────────────────────────────
$env.config.show_banner = false
$env.config.color_config = $rose_pine_theme
$env.config.ls.use_ls_colors = true
$env.config.ls.clickable_links = true
$env.config.table.mode = "rounded"

$env.COLORTERM = "truecolor"
$env.DIRENV_LOG_FORMAT = ""
$env.GOPATH = ($nu.home-dir | path join "go")
$env.MANPAGER = "sh -c 'col -bx | bat -l man -p'"
$env.MANROFFOPT = "-c"
$env.BAT_THEME = "base16"

# ── PATH Configuration ────────────────────────────────────────────────────────
# `path add` prepends to $env.PATH; listed in reverse so `.local/bin` stays first.
path add ($nu.home-dir | path join ".config/emacs/bin")
path add ($nu.home-dir | path join ".cargo/bin")
path add ($nu.home-dir | path join ".local/share/coursier/bin")
path add ($nu.home-dir | path join "go/bin")
path add ($nu.home-dir | path join ".local/share/bin")
path add ($nu.home-dir | path join ".local/bin")

# ── Fuzzy Finding Environment (with Rosé Pine colors) ─────────────────────────
$env.FZF_DEFAULT_OPTS = "--color=fg:#908caa,bg:#191724,hl:#ebbcba --color=fg+:#e0def4,bg+:#26233a,hl+:#ebbcba --color=border:#403d52,header:#31748f,gutter:#191724 --color=spinner:#f6c177,info:#9ccfd8 --color=pointer:#c4a7e7,marker:#eb6f92,prompt:#908caa"
$env.FZF_DEFAULT_COMMAND = "fd --type f --strip-cwd-prefix --hidden --follow --exclude .git"
$env.FZF_CTRL_T_COMMAND = $env.FZF_DEFAULT_COMMAND
$env.FZF_CTRL_T_OPTS = "--preview 'bat --color=always --style=numbers --line-range=:500 {}'"
$env.FZF_ALT_C_COMMAND = "fd --type d --hidden --follow --exclude .git"
$env.FZF_ALT_C_OPTS = "--preview 'fd --max-depth 2 --color=always . {} | head -200'"

# ── Tool Integrations (Autoloaded & Cached) ───────────────────────────────────
# Generates init scripts into `vendor/autoload/` only if missing.
# Run `regen-integrations -f` manually after upgrading starship, zoxide, fzf, or tv.
def regen-integrations [
    --force (-f) # Overwrite existing autoload scripts
] {
    let autoload_dir = ($nu.data-dir | path join "vendor/autoload")
    mkdir $autoload_dir

    let tools = [
        {
            bin: "starship"
            file: "00-starship.nu"
            cmd: { ^starship init nu }
        }
        {
            bin: "zoxide"
            file: "10-zoxide.nu"
            cmd: { ^zoxide init nushell --cmd cd }
        }
        {
            bin: "fzf"
            file: "20-fzf.nu"
            cmd: {
                # Patch fzf's completer wrapper for Nushell 0.116+ (`|spans|` -> `|place|`)
                ^fzf --nushell
                | str replace "let fzf_wrapper_completer = {|spans|" "let fzf_wrapper_completer = {|place|\n      let spans = $place.command"
            }
        }
        {
            bin: "tv"
            file: "30-tv.nu"
            cmd: { ^tv init nu }
        }
    ]

    for tool in $tools {
        let target = ($autoload_dir | path join $tool.file)
        if ($force or not ($target | path exists)) and (which $tool.bin | is-not-empty) {
            do $tool.cmd | save -f $target
        }
    }
}

regen-integrations

# Starship transient prompt support
$env.TRANSIENT_PROMPT_COMMAND = {||
    if (which starship | is-not-empty) {
        ^starship module character
    } else {
        ""
    }
}

# ── Direnv Hook (Per-directory environment variables) ─────────────────────────
$env.config.hooks.env_change.PWD = (
    $env.config.hooks.env_change.PWD? | default [] | append {||
        if (which direnv | is-empty) {
            return
        }
        ^direnv export json
        | from json
        | default {}
        | update cells --columns [PATH] {
            do (env-conversions).path.from_string $in
        }
        | load-env
    }
)

# ── Native Directory Listings ─────────────────────────────────────────────────
alias la = ls -a
alias lla = ls -la

def ll [
    --all (-a)        # Show hidden files
    ...pattern: glob  # Files or directories to list
] {
    let targets = if ($pattern | is-empty) { [.] } else { $pattern }
    if $all {
        ls -la ...$targets
    } else {
        ls -l ...$targets
    }
    | select name type mode user group size modified
    | sort-by type name -i
}

# ── External Tool Aliases ─────────────────────────────────────────────────────
alias nu-du = du

alias cat = ^bat --paging=never
alias grep = ^rg
alias tmux = ^tmux -u
alias up = ^sudo dnf upgrade --refresh
alias g = ^git

alias top = ^btop
alias df = ^duf
alias du = ^dust

# ── Small Helper Functions ────────────────────────────────────────────────────
def --env mkcd [
    dir: path # Directory to create and enter
] {
    mkdir $dir
    cd $dir
}

def bak [
    ...files: path # Files to back up
] {
    if ($files | is-empty) {
        error make { msg: "Usage: bak FILE..." }
    }
    for file in $files {
        if not ($file | path exists) {
            error make { msg: $"bak: no such file: ($file)" }
        }
        ^cp -a -- $file $"($file).bak"
    }
}

# ── Abbreviations ─────────────────────────────────────────────────────────────
alias v = ^nvim
alias vim = ^nvim
alias gs = ^git status -sb
alias ga = ^git add
alias gc = ^git commit -m
alias gp = ^git push
alias gl = ^git log --oneline --graph --decorate
alias gd = ^git diff

$env.config.menus ++= [
    {
        name: abbr_menu
        only_buffer_difference: false
        marker: "👀 "
        type: { layout: columnar, columns: 1, col_width: 20, col_padding: 2 }
        style: {
            text: $rose_pine.foam
            selected_text: { fg: $rose_pine.base, bg: $rose_pine.rose, attr: "b" }
            description_text: $rose_pine.gold
        }
        source: {|buffer, position|
            scope aliases
            | where name == $buffer
            | each {|elt| { value: $elt.expansion } }
        }
    }
]

$env.config.keybindings ++= [
    {
        name: abbr
        modifier: control
        keycode: space
        mode: [emacs, vi_normal, vi_insert]
        event: [
            { send: menu, name: abbr_menu }
            { edit: insertchar, value: " " }
        ]
    }
]
source "~/.cargo/env.nu"
