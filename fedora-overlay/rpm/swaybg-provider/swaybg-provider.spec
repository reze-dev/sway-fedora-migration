Name:           swaybg-provider
Version:        1
Release:        1%{?dist}
Summary:        Satisfies the swaybg dependency without shipping swaybg

License:        MIT
URL:            https://codeberg.org/LGFae/awww

# The awww daemon paints the wallpaper on the background layer, so swaybg is
# not needed at runtime. It cannot simply be uninstalled, though: swaybg is a
# hard dependency of sway-config-fedora, which owns the SDDM session entry
# point (start-sway, sway.desktop), the layered-include helper that the Sway
# config includes, and the sway config.d fragments. Removing swaybg through
# dnf would cascade into removing sway-config-fedora, sway-systemd, sddm,
# sddm-wayland-sway and swayfx, leaving no way to log in graphically.
#
# This package provides the "swaybg" capability so that the dependency is
# satisfied and "dnf check" stays clean, without shipping the swaybg binary.
# It stands in for the real package at the version that was removed, so it
# also satisfies a versioned requirement on that release.
#
# The awww package is available in the Terra repository.

Provides:       swaybg = 1.2.2-2.fc45
BuildArch:      noarch
Source0:        README.md

%description
Satisfies the swaybg dependency of sway-config-fedora without shipping
swaybg. The awww daemon (upstream swww, renamed and moved to Codeberg)
paints the wallpaper instead, so the swaybg binary is not used.

%prep
%build
%install
mkdir -p %{buildroot}%{_docdir}/%{name}
install -m 0644 %{SOURCE0} %{buildroot}%{_docdir}/%{name}/README.md

%files
%doc %{_docdir}/%{name}/README.md

%changelog
* Thu Nov 12 2026 asuna - 1-1
- Initial package
