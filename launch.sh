#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 Behnam Farnaghinejad <behnam.farnaghinejad@polito.it>
# SPDX-License-Identifier: GPL-2.0-only
set -euo pipefail

studio_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
host_root="${ASE_STUDIO_HOST_ROOT:-$(cd "$studio_dir/.." && pwd)}"

usage() {
    cat <<'EOF'
Usage:
  ase-studio.sh [--server] [--host HOST] [--port PORT] [--open] [--help]

Modes:
  (default)            Start the native GTK GUI (needs a desktop session).
  --server             Start only the HTTP server, without opening the GUI window.
                       Connect with a browser at the printed URL.

Options:
  --host HOST          Interface to bind (default: 127.0.0.1, from ASE_STUDIO_HOST).
                       Use 0.0.0.0 to allow connections from other machines.
  --port PORT          Port to bind (default: 8765, from ASE_STUDIO_PORT).
                       Falls back to a free port if occupied.
  --open               Open the printed URL in the default browser (server mode).
  -h, --help           Show this help.

Examples:
  ./ase-studio.sh
  ./ase-studio.sh --server
  ./ase-studio.sh --server --port 8888 --open
  ./ase-studio.sh --server --host 0.0.0.0 --port 8765
EOF
}

mode="gui"
host="${ASE_STUDIO_HOST:-127.0.0.1}"
port="${ASE_STUDIO_PORT:-8765}"
open_browser=0

while [[ $# -gt 0 ]]; do
    case "$1" in
        --server)
            mode="server"
            shift
            ;;
        --host)
            [[ $# -ge 2 ]] || { echo "Option --host requires an argument." >&2; exit 1; }
            host="$2"
            shift 2
            ;;
        --host=*)
            host="${1#--host=}"
            shift
            ;;
        --port)
            [[ $# -ge 2 ]] || { echo "Option --port requires an argument." >&2; exit 1; }
            port="$2"
            shift 2
            ;;
        --port=*)
            port="${1#--port=}"
            shift
            ;;
        --open)
            open_browser=1
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            usage >&2
            exit 1
            ;;
    esac
done

if [[ -z "$host" ]]; then
    echo "Host cannot be empty." >&2
    exit 1
fi
if ! [[ "$port" =~ ^[0-9]+$ ]] || [[ "$port" -lt 1 ]] || [[ "$port" -gt 65535 ]]; then
    echo "Invalid port: $port (expected 1-65535)." >&2
    exit 1
fi

cd "$host_root"

if [[ "$mode" == "server" ]]; then
    args=(--host "$host" --port "$port")
    [[ "$open_browser" -eq 1 ]] && args+=(--open)
    exec python3 "$studio_dir/backend.py" "${args[@]}"
fi

if [[ "$open_browser" -eq 1 ]]; then
    echo "Note: --open is only used with --server; the GUI window opens on its own." >&2
fi
exec python3 "$studio_dir/native.py" --host "$host" --port "$port"
