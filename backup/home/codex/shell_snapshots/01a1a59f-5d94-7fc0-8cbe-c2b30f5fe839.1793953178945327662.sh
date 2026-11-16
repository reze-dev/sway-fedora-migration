# Snapshot file
# Unset all aliases to avoid conflicts with functions
unalias -a 2>/dev/null || true
shopt -u array_expand_once
shopt -u assoc_expand_once
shopt -u autocd
shopt -u bash_source_fullpath
shopt -u cdable_vars
shopt -u cdspell
shopt -u checkhash
shopt -u checkjobs
shopt -s checkwinsize
shopt -s cmdhist
shopt -u compat31
shopt -u compat32
shopt -u compat40
shopt -u compat41
shopt -u compat42
shopt -u compat43
shopt -u compat44
shopt -s complete_fullquote
shopt -u direxpand
shopt -u dirspell
shopt -u dotglob
shopt -u execfail
shopt -u expand_aliases
shopt -u extdebug
shopt -u extglob
shopt -s extquote
shopt -u failglob
shopt -s force_fignore
shopt -s globasciiranges
shopt -s globskipdots
shopt -u globstar
shopt -u gnu_errfmt
shopt -u histappend
shopt -u histreedit
shopt -u histverify
shopt -s hostcomplete
shopt -u huponexit
shopt -u inherit_errexit
shopt -s interactive_comments
shopt -u lastpipe
shopt -u lithist
shopt -u localvar_inherit
shopt -u localvar_unset
shopt -s login_shell
shopt -u mailwarn
shopt -u no_empty_cmd_completion
shopt -u nocaseglob
shopt -u nocasematch
shopt -u noexpand_translation
shopt -u nullglob
shopt -s patsub_replacement
shopt -s progcomp
shopt -u progcomp_alias
shopt -s promptvars
shopt -u restricted_shell
shopt -u shift_verbose
shopt -s sourcepath
shopt -u syslog_history
shopt -u varredir_close
shopt -u xpg_echo
# Functions
__systemd_osc_context_common () 
{ 
    if [ -f /etc/machine-id ]; then
        printf ";machineid=%.36s" "$(< /etc/machine-id)";
    fi;
    __systemd_osc_context_escape ";user=%.255s" "$USER";
    __systemd_osc_context_escape ";hostname=%.255s" "$HOSTNAME";
    printf ";bootid=%.36s;pid=%.20s" "$(< /proc/sys/kernel/random/boot_id)" "$$";
    __systemd_osc_context_escape ";cwd=%.255s" "$PWD"
}
__systemd_osc_context_escape () 
{ 
    local systemd_format="$1";
    local systemd_value="$2";
    systemd_value="${systemd_value//\\/\\x5c}";
    systemd_value="${systemd_value//;/\\x3b}";
    systemd_value="${systemd_value//[[:cntrl:]]/⍰}";
    printf "$systemd_format" "$systemd_value"
}
__systemd_osc_context_precmdline () 
{ 
    local systemd_exitstatus="$?" systemd_signal;
    if [ -n "${systemd_osc_context_cmd_id:-}" ]; then
        if [ "$systemd_exitstatus" -gt 128 ] && systemd_signal=$(kill -l "$systemd_exitstatus" 2>&-); then
            printf "\033]3008;end=%.64s;exit=failure;status=%d;signal=SIG%s\033\\" "$systemd_osc_context_cmd_id" "$systemd_exitstatus" "$systemd_signal";
        else
            if [ "$systemd_exitstatus" -ne 0 ]; then
                printf "\033]3008;end=%.64s;exit=failure;status=%d\033\\" "$systemd_osc_context_cmd_id" "$systemd_exitstatus";
            else
                printf "\033]3008;end=%.64s;exit=success\033\\" "$systemd_osc_context_cmd_id";
            fi;
        fi;
    fi;
    if [ -z "${systemd_osc_context_shell_id:-}" ]; then
        read -r systemd_osc_context_shell_id < /proc/sys/kernel/random/uuid;
    fi;
    printf "\033]3008;start=%.64s;type=shell%s\033\\" "$systemd_osc_context_shell_id" "$(__systemd_osc_context_common)";
    read -r systemd_osc_context_cmd_id < /proc/sys/kernel/random/uuid
}
__systemd_osc_context_ps0 () 
{ 
    [ -n "${systemd_osc_context_cmd_id:-}" ] || return;
    printf "\033]3008;start=%.64s;type=command%s\033\\" "$systemd_osc_context_cmd_id" "$(__systemd_osc_context_common)"
}
gawklibpath_append () 
{ 
    [ -z "$AWKLIBPATH" ] && AWKLIBPATH=`gawk 'BEGIN {print ENVIRON["AWKLIBPATH"]}'`;
    export AWKLIBPATH="$AWKLIBPATH:$*"
}
gawklibpath_default () 
{ 
    unset AWKLIBPATH;
    export AWKLIBPATH=`gawk 'BEGIN {print ENVIRON["AWKLIBPATH"]}'`
}
gawklibpath_prepend () 
{ 
    [ -z "$AWKLIBPATH" ] && AWKLIBPATH=`gawk 'BEGIN {print ENVIRON["AWKLIBPATH"]}'`;
    export AWKLIBPATH="$*:$AWKLIBPATH"
}
gawkpath_append () 
{ 
    [ -z "$AWKPATH" ] && AWKPATH=`gawk 'BEGIN {print ENVIRON["AWKPATH"]}'`;
    export AWKPATH="$AWKPATH:$*"
}
gawkpath_default () 
{ 
    unset AWKPATH;
    export AWKPATH=`gawk 'BEGIN {print ENVIRON["AWKPATH"]}'`
}
gawkpath_prepend () 
{ 
    [ -z "$AWKPATH" ] && AWKPATH=`gawk 'BEGIN {print ENVIRON["AWKPATH"]}'`;
    export AWKPATH="$*:$AWKPATH"
}

# setopts 3
set -o braceexpand
set -o hashall
set -o interactive-comments

# aliases 10
alias egrep='grep -E --color=auto'
alias fgrep='grep -F --color=auto'
alias grep='grep --color=auto'
alias which='(alias; declare -f) | /usr/bin/which --tty-only --read-alias --read-functions --show-tilde --show-dot'
alias xzegrep='xzegrep --color=auto'
alias xzfgrep='xzfgrep --color=auto'
alias xzgrep='xzgrep --color=auto'
alias zegrep='zegrep --color=auto'
alias zfgrep='zfgrep --color=auto'
alias zgrep='zgrep --color=auto'

# exports (native declarations)
declare -x BAT_THEME="base16"
declare -x COLORTERM="truecolor"
declare -x DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/1000/bus"
declare -x DEBUGINFOD_IMA_CERT_PATH="/etc/keys/ima:"
declare -x DEBUGINFOD_URLS="ima:enforcing https://debuginfod.fedoraproject.org/ ima:ignore "
declare -x DESKTOP_SESSION="sway"
declare -x DESKTOP_STARTUP_ID="e1c22a7c08d1bad820ec5af8cebbb9ed"
declare -x DIRENV_LOG_FORMAT=""
declare -x DISPLAY=":0"
declare -x EDITOR="/usr/bin/nano"
declare -x FZF_ALT_C_COMMAND="fd --type d --hidden --follow --exclude .git"
declare -x FZF_ALT_C_OPTS="--preview 'eza --tree --color=always --icons=always {} | head -200'"
declare -x FZF_CTRL_T_COMMAND="fd --type f --strip-cwd-prefix --hidden --follow --exclude .git"
declare -x FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers --line-range=:500 {}'"
declare -x FZF_DEFAULT_COMMAND="fd --type f --strip-cwd-prefix --hidden --follow --exclude .git"
declare -x GOPATH="/home/asuna/go"
declare -x HISTCONTROL="ignoredups"
declare -x HISTSIZE="1000"
declare -x HOME="/home/asuna"
declare -x HOSTNAME="fedora"
declare -x I3SOCK="/run/user/1000/sway-ipc.1000.1319.sock"
declare -x JOURNAL_STREAM="10:11933"
declare -x KITTY_INSTALLATION_DIR="/usr/lib64/kitty"
declare -x KITTY_PID="4119"
declare -x KITTY_PUBLIC_KEY="1:M{2j!X+9REPl56{*08x{o3fx(1~Sj@=2#94zn9cD"
declare -x KITTY_WINDOW_ID="1"
declare -x LANG="en_IN.UTF-8"
declare -x LESSOPEN="||/usr/bin/lesspipe.sh %s"
declare -x LOGNAME="asuna"
declare -x LS_COLORS=""
declare -x MAIL="/var/spool/mail/asuna"
declare -x MANPAGER="sh -c 'col -bx | bat -l man -p'"
declare -x MANROFFOPT="-c"
declare -x PATH="/home/asuna/.local/bin:/home/asuna/bin:/home/asuna/.codex/tmp/arg0-linux/codex-arg0oJNTA5:/home/asuna/.codex/packages/app-server-daemon/releases/0.166.0-x86_64-unknown-linux-musl/codex-path:/home/asuna/.codex/tmp/arg0-linux/codex-arg0EAvTiX:/home/asuna/.codex/packages/standalone/releases/0.166.0-x86_64-unknown-linux-musl/codex-path:/home/asuna/.local/bin:/home/asuna/.cargo/bin:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin"
declare -x QT_QPA_PLATFORM="wayland;xcb"
declare -x QT_QPA_PLATFORMTHEME="qt6ct"
declare -x SHELL="/usr/bin/fish"
declare -x SHLVL="3"
declare -x STARSHIP_SESSION_KEY="3106613464224013"
declare -x STARSHIP_SHELL="fish"
declare -x SWAYSOCK="/run/user/1000/sway-ipc.1000.1319.sock"
declare -x TERM="xterm-kitty"
declare -x TERMINAL="kitty"
declare -x TERMINFO="/usr/lib64/kitty/terminfo"
declare -x USER="asuna"
declare -x WAYLAND_DISPLAY="wayland-1"
declare -x XCURSOR_SIZE="24"
declare -x XCURSOR_THEME="Bibata-Modern-Ice"
declare -x XDG_CURRENT_DESKTOP="sway"
declare -x XDG_DATA_DIRS="/home/asuna/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share:/usr/local/share:/usr/share"
declare -x XDG_RUNTIME_DIR="/run/user/1000"
declare -x XDG_SEAT="seat0"
declare -x XDG_SEAT_PATH="/org/freedesktop/DisplayManager/Seat0"
declare -x XDG_SESSION_CLASS="user"
declare -x XDG_SESSION_DESKTOP="sway"
declare -x XDG_SESSION_ID="2"
declare -x XDG_SESSION_PATH="/org/freedesktop/DisplayManager/Session1"
declare -x XDG_SESSION_TYPE="wayland"
declare -x XDG_VTNR="2"
declare -x _JAVA_AWT_WM_NONREPARENTING="1"
