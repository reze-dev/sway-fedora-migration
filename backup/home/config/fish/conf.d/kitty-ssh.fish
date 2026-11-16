# Use Kitty's SSH kitten from Kitty terminals so the remote host gets the
# matching xterm-kitty terminfo entry. Outside Kitty, use the system ssh.
function ssh --description 'SSH with Kitty terminfo support when available'
    if test "$TERM" = xterm-kitty; and command -q kitty
        command kitty +kitten ssh $argv
    else
        command ssh $argv
    end
end
