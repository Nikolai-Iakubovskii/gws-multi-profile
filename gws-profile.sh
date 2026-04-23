#!/usr/bin/env bash
set -euo pipefail

show_help() {
  cat <<'EOF'
Run the official Google Workspace CLI (`gws`) inside an isolated profile.

Usage:
  ./gws-profile.sh <profile> <gws args...>

Examples:
  ./gws-profile.sh work auth status
  ./gws-profile.sh personal auth login -s gmail,drive,sheets
  ./gws-profile.sh client-a gmail users messages list --params '{"userId":"me","maxResults":1}' --format json

Environment:
  GWS_BIN           Path to the gws binary. Default: gws from PATH
  GWS_PROFILES_DIR  Base directory for profile configs. Default: $HOME/.config

What it does:
  - creates: $GWS_PROFILES_DIR/gws-<profile>
  - exports: GOOGLE_WORKSPACE_CLI_CONFIG_DIR=<that dir>
  - execs:   gws <args...>
EOF
}

if [[ $# -lt 2 ]]; then
  show_help
  exit 1
fi

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  show_help
  exit 0
fi

profile="$1"
shift

gws_bin="${GWS_BIN:-gws}"
profiles_dir="${GWS_PROFILES_DIR:-$HOME/.config}"
config_dir="${profiles_dir}/gws-${profile}"

mkdir -p "${config_dir}"

if ! command -v "${gws_bin}" >/dev/null 2>&1; then
  echo "gws binary not found: ${gws_bin}" >&2
  echo "Install @googleworkspace/cli or set GWS_BIN." >&2
  exit 1
fi

export GOOGLE_WORKSPACE_CLI_CONFIG_DIR="${config_dir}"
exec "${gws_bin}" "$@"
