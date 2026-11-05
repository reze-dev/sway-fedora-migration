#!/usr/bin/env bash
set -euo pipefail
if [[ ${EUID} -eq 0 ]]; then
    echo 'Run this script as your desktop user, without sudo.' >&2
    exit 1
fi
uid=$(id -u)
gid=$(id -g)
sudo install -d /etc/systemd/system/ydotool.service.d
printf '%s\n' \
  '[Service]' \
  'ExecStart=' \
  "/usr/bin/ydotoold --socket-path=/run/ydotoold.sock --socket-perm=0600 --socket-own=${uid}:${gid}" \
  | sudo tee /etc/systemd/system/ydotool.service.d/override.conf >/dev/null
sudo systemctl daemon-reload
sudo systemctl enable --now ydotool.service
