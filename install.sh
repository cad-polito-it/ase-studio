#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 Behnam Farnaghinejad <behnam.farnaghinejad@polito.it>
# SPDX-License-Identifier: GPL-2.0-only
set -euo pipefail

studio_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
host_root="$(cd "$studio_dir/.." && pwd)"
application_dir="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
desktop_file="$application_dir/it.polito.ASEStudio.desktop"

if ! python3 -c 'import gi; gi.require_version("Gtk", "3.0"); gi.require_version("WebKit2", "4.1")' 2>/dev/null; then
  echo "ASE Studio requires Python GTK and WebKitGTK bindings."
  echo "On Ubuntu/Debian, install: python3-gi gir1.2-gtk-3.0 gir1.2-webkit2-4.1"
  exit 1
fi

mkdir -p "$application_dir"
{
  echo "[Desktop Entry]"
  echo "Version=1.0"
  echo "Type=Application"
  echo "Name=ASE Studio"
  echo "Comment=RISC-V assembly and pipeline teaching studio"
  printf 'TryExec=%s\n' "$studio_dir/launch.sh"
  printf 'Exec=env "ASE_STUDIO_HOST_ROOT=%s" "%s"\n' "$host_root" "$studio_dir/launch.sh"
  printf 'Path=%s\n' "$host_root"
  printf 'Icon=%s\n' "$studio_dir/frontend/icon.png"
  echo "Terminal=false"
  echo "Categories=Education;"
  echo "StartupNotify=true"
  echo "StartupWMClass=ASEStudio"
} > "$desktop_file"
chmod 0644 "$desktop_file"

if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database "$application_dir" >/dev/null 2>&1 || true
fi

echo "ASE Studio was installed for the current user."
echo "Open it from the application menu or run: $host_root/ase-studio.sh"
