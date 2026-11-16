-- Ryoku / Hyprland: personal overrides
--
-- Drop-in for ~/.config/hypr/user.lua. Ryoku writes settings.lua and
-- rebinds.lua from the Hub; user.lua is the layer that survives every
-- `ryoku update`, so personal chords belong here.
--
-- Translated from the Sway/SwayFX setup that this backup captured. The Sway
-- source of every binding is named in the comment next to it.
--
-- NOT TESTED on Ryoku: this is a starting point, not a verified config.
-- Check the chords against the Hyprland version Ryoku ships.

local mod = "SUPER"

-- ---------------------------------------------------------------- terminals --
-- Sway: bindsym $mod+t exec $term
bind = bind(mod, "t", function() hyprctl dispatch exec "kitty" end)
-- Sway: bindsym $mod+Shift+Return exec kitty --directory "$HOME"
bind = bind(mod, "shift", "Return", function() hyprctl dispatch exec "kitty --directory $HOME" end)

-- ----------------------------------------------------------------- windows --
-- Sway: bindsym $mod+q kill
bind = bind(mod, "q", function() hyprctl dispatch killactive end)
-- Sway: bindsym $mod+f fullscreen
bind = bind(mod, "f", function() hyprctl dispatch fullscreen 0 end)
-- Sway: bindsym $mod+Shift+space floating toggle
bind = bind(mod, "shift", "space", function() hyprctl dispatch togglefloating end)
-- Sway: bindsym $mod+space focus mode_toggle
bind = bind(mod, "space", function() hyprctl dispatch movetoworkspace special:floating end)
-- Sway: bindsym $mod+b splith / bindsym $mod+v splitv
bind = bind(mod, "b", function() hyprctl dispatch splitw splitw end)
bind = bind(mod, "v", function() hyprctl dispatch splitw float end)
-- Sway: bindsym $mod+s layout stacking / $mod+w layout tabbed / $mod+e layout toggle split
bind = bind(mod, "s", function() hyprctl dispatch layout stacking end)
bind = bind(mod, "w", function() hyprctl dispatch layout tabbed end)
bind = bind(mod, "e", function() hyprctl dispatch layout toggle split end)
-- Sway: bindsym $mod+a focus parent
bind = bind(mod, "a", function() hyprctl dispatch focuswindow parent end)
-- Sway: bindsym $mod+r mode "resize" (h/j/k/l and the arrow keys)
bind = bind(mod, "r", function() hyprctl dispatch resizeactive 10 end)

-- focus and movement: Sway uses $mod+arrow for both, Shift for moving
bind = bind(mod, "left",  function() hyprctl dispatch movefocus l end)
bind = bind(mod, "right", function() hyprctl dispatch movefocus r end)
bind = bind(mod, "up",    function() hyprctl dispatch movefocus u end)
bind = bind(mod, "down",  function() hyprctl dispatch movefocus d end)
bind = bind(mod, "shift", "left",  function() hyprctl dispatch movewindow l end)
bind = bind(mod, "shift", "right", function() hyprctl dispatch movewindow r end)
bind = bind(mod, "shift", "up",    function() hyprctl dispatch movewindow u end)
bind = bind(mod, "shift", "down",  function() hyprctl dispatch movewindow d end)

-- Sway: scratchpad (move scratchpad / scratchpad show)
bind = bind(mod, "minus", function() hyprctl dispatch togglespecialworkspace minimised end)
bind = bind(mod, "shift", "minus", function() hyprctl dispatch movetoworkspace special:minimised end)

-- ------------------------------------------------------------- workspaces --
-- Sway: bindsym $mod+1..0 workspace number N, Shift+N move container to N
for i = 1, 9 do
    bind = bind(mod, tostring(i), function() hyprctl dispatch workspace i end)
    bind = bind(mod, "shift", tostring(i), function() hyprctl dispatch movetoworkspace i end)
end
bind = bind(mod, "0", function() hyprctl dispatch workspace 10 end)
bind = bind(mod, "shift", "0", function() hyprctl dispatch movetoworkspace 10 end)

-- ------------------------------------------------------------- screenshots --
-- Sway: bindsym Print / Alt+Print / Ctrl+Print -> grimshot | swappy
bind = bind("", "Print", function() hyprctl dispatch exec "grimshot save output - | swappy -f -" end)
bind = bind("", "alt", "Print", function() hyprctl dispatch exec "grimshot save active - | swappy -f -" end)
bind = bind("", "ctrl", "Print", function() hyprctl dispatch exec "grimshot save area - | swappy -f -" end)

-- ----------------------------------------------------------------- session --
-- Sway: bindsym $mod+Shift+c reload / $mod+Shift+e exit
bind = bind(mod, "shift", "c", function() hyprctl reload end)
bind = bind(mod, "shift", "e", function() hyprctl dispatch exec "hyprctl dispatch exit" end)
-- Sway: bindsym $mod+Shift+x -> sway-power-menu
-- Ryoku owns the session controls; keep the chord and point it at Ryoku's shell.
bind = bind(mod, "shift", "x", function() hyprctl dispatch exec "ryoku-shell power" end)

-- The Ryoku launcher, the Hub and the clipboard are Ryoku's own. The Sway
-- chords that opened Fuzzel, nwggrid, CopyQ and the Sway Control Center are
-- Super (launcher), Super+Comma (Hub) and Super+K (Keys) there.

-- ------------------------------------------------------------ window rules --
-- Sway: for_window [class="floating_shell"] floating enable
-- and the floating rules from ~/.config/sway/config.d/70-settings.conf
windowrule = rule matchclass "^floating_shell$" float true
windowrule = rule matchclass "^lxqt-policykit-agent$" float true
windowrule = rule matchclass "^wdisplays$" float true
windowrule = rule matchclass "^qt5ct$" float true
windowrule = rule matchclass "^qt6ct$" float true
windowrule = rule matchclass "^Lxappearance$" float true

-- ------------------------------------------------------------------ cursor --
-- Sway: seat * xcursor_theme Bibata-Modern-Ice 24
-- Ryoku drives the cursor through the Hub; the theme name is the same.
