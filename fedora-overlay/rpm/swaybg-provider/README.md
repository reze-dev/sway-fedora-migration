swaybg-provider
================

This package exists only to satisfy the `swaybg` dependency of
`sway-config-fedora`. It ships no binary and no functionality.

Why
---

The `awww` daemon (upstream `swww`, renamed and moved to Codeberg) paints the
wallpaper on the background layer, so the `swaybg` binary is not used. The
Sway config sets `swaybg_command -`, which stops Sway from spawning its own
built-in `swaybg`, and the `output * bg` directive is absent entirely.

`swaybg` cannot simply be uninstalled with dnf, because it is a hard
dependency of `sway-config-fedora`. That package owns the SDDM session entry
point (`/usr/bin/start-sway`, `sway.desktop`), the `layered-include` helper
that the Sway config includes, and the `sway/config.d` fragments. Removing
`swaybg` through dnf therefore cascades into removing `sway-config-fedora`,
`sway-systemd`, `sddm`, `sddm-wayland-sway` and `swayfx`, which would leave no
way to log in graphically.

So `swaybg` is removed with `rpm -e --nodeps swaybg` and excluded in
`/etc/dnf/dnf.conf` so that a later transaction does not pull it back in.
This package provides the `swaybg` capability so that the dependency is
satisfied and `dnf check` stays clean.

The `awww` package itself comes from the Terra repository:

    dnf install --repo terra awww
