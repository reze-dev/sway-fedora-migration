# Ronin SDDM theme

Customized from the `ronin` branch of [mahaveergurjar/sddm](https://github.com/mahaveergurjar/sddm), upstream commit `c09a657`.

The theme uses the Ronin wallpaper `16.jpeg` from the author's [Hyprlock-Dots repository](https://github.com/mahaveergurjar/Hyprlock-Dots), shows the selected account name and initial, and identifies the system as Fedora Sway. Its Qt 5 graphical-effects import is changed to Qt 6's `Qt5Compat.GraphicalEffects` module. The bundled JetBrainsMono Nerd Font regular face and OFL license allow the SDDM service account to render the theme's icons.

Run `sudo ./fedora-overlay/install-sddm-ronin.sh` from the migration repository root to install the theme and set it as SDDM's current theme. This writes an `/etc/sddm.conf.d` override without replacing Fedora's session launcher. The theme appears the next time SDDM starts.
