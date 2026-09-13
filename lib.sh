#!/usr/bin/env bash
set -euo pipefail

ap_language() {
  local lang="${AP_LANGUAGE:-}"
  if [ -z "$lang" ] && [ -f platform.toml ]; then
    lang=$(sed -n 's/^language = "\(.*\)"/\1/p' platform.toml | head -1)
  fi
  printf '%s' "$lang"
}

ap_type() {
  local type_="${AP_TYPE:-}"
  if [ -z "$type_" ] && [ -f platform.toml ]; then
    type_=$(sed -n 's/^type = "\(.*\)"/\1/p' platform.toml | head -1)
  fi
  printf '%s' "$type_"
}
