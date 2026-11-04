# Ubuntu Sway system reference snapshot

These are package-provided Ubuntu Sway system files captured for reference while preparing the Fedora port. They are not Fedora configuration files and must not be copied into `/etc` on Fedora.

- `etc/sway/`: system Sway base config, modes, input/output defaults and session integration.
- `etc/skel/`: default files Ubuntu Sway seeds into a new home directory. The Ubuntu Sway Welcome autostart file, Foot config, Wofi config and binary dconf state are excluded.
- `usr/share/sway/scripts/`: Ubuntu-specific helpers referenced by the current Sway/Waybar configs.
- `usr/share/themes/` and `usr/share/Kvantum/`: the available Sway palettes and current Yaru Prussian Green Qt theme assets.
- `usr/share/wallpapers/`: the current Ubuntu Sway default wallpaper. Its package copyright notice is in `legal/`.
- `usr/bin/start-sway`: the local copy of the package-managed launcher. `dpkg -V` reports this file differs from the package checksum. It has GPU-specific environment handling and starts Sway through `ssh-agent`; its provenance was not established. The Fedora port should preserve the intent only after inspecting Fedora's launcher and GPU setup.
- `usr/lib/systemd/user/`: Ubuntu Sway session/restart service units.
- `etc/environment.d/` and `etc/xdg/`: Ubuntu-specific Qt/Wayland environment and desktop integration.

Package integrity inspection of the selected Ubuntu Sway packages reported only `/bin/start-sway` as changed. No package-managed files were edited during this repo work.
