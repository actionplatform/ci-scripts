#!/usr/bin/env bash
set -euo pipefail

ap_language() {
  local lang="${AP_LANGUAGE:-}"
  if [ -z "$lang" ] && [ -f platform.toml ]; then
    lang=$(sed -n 's/^language = "\(.*\)"/\1/p' platform.toml | head -1)
  fi
  [ -n "$lang" ] || { echo "error: language not given (AP_LANGUAGE) and platform.toml has none" >&2; exit 1; }
  printf '%s' "$lang"
}

ap_type() {
  local type_="${AP_TYPE:-}"
  if [ -z "$type_" ] && [ -f platform.toml ]; then
    type_=$(sed -n 's/^type = "\(.*\)"/\1/p' platform.toml | head -1)
  fi
  printf '%s' "$type_"
}
