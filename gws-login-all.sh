#!/usr/bin/env bash
set -euo pipefail

show_help() {
  cat <<'EOF'
Start multiple `gws auth login` flows in parallel.

Usage:
  ./gws-login-all.sh <profile> [profile...]

Examples:
  ./gws-login-all.sh work personal
  GWS_LOGIN_SCOPES="gmail,drive,sheets" ./gws-login-all.sh work personal client-a
  GWS_DEFAULT_PROFILES="work personal client-a" ./gws-login-all.sh

Environment:
  GWS_LOGIN_SCOPES    Comma-separated scopes. Default: gmail,drive,sheets
  GWS_DEFAULT_PROFILES
                      Space-separated profiles used when no args are passed
  GWS_LOGIN_LOG_DIR   Explicit log root. Default: $HOME/.cache/gws-logins/<timestamp>
  GWS_BIN             Path to the gws binary
  GWS_PROFILES_DIR    Base directory for profile configs
EOF
}

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  show_help
  exit 0
fi

script_dir="$(cd "$(dirname "$0")" && pwd)"
scopes="${GWS_LOGIN_SCOPES:-gmail,drive,sheets}"

profiles=("$@")
if [[ ${#profiles[@]} -eq 0 ]]; then
  if [[ -n "${GWS_DEFAULT_PROFILES:-}" ]]; then
    # shellcheck disable=SC2206
    profiles=(${GWS_DEFAULT_PROFILES})
  else
    show_help
    exit 1
  fi
fi

log_root="${GWS_LOGIN_LOG_DIR:-$HOME/.cache/gws-logins/$(date +%Y%m%d-%H%M%S)}"
mkdir -p "${log_root}"

echo "Starting parallel gws logins"
echo "Scopes: ${scopes}"
echo "Logs:   ${log_root}"

for profile in "${profiles[@]}"; do
  log_file="${log_root}/${profile}.log"
  nohup "${script_dir}/gws-profile.sh" "${profile}" auth login -s "${scopes}" >"${log_file}" 2>&1 &
  pid=$!
  echo "${profile}: pid=${pid} log=${log_file}"
done

sleep 2

for profile in "${profiles[@]}"; do
  log_file="${log_root}/${profile}.log"
  echo
  echo "== ${profile} =="
  sed -n '1,12p' "${log_file}" || true
done

echo
echo "After browser login, verify each profile:"
for profile in "${profiles[@]}"; do
  echo "  ./gws-profile.sh ${profile} auth status"
done
