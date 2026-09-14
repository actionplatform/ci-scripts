#!/usr/bin/env bash
# Install dependencies for the project language. The toolchain itself comes from
# the CI image (GitLab/Bitbucket/Jenkins) or from setup-* actions (GitHub).
set -euo pipefail
. "$(dirname "$0")/lib.sh"

lang=$(ap_language)
install="${AP_INSTALL:-true}"
echo "language=${lang:-none} install=$install"
[ "$install" = "true" ] || exit 0
[ -n "$lang" ] || { echo "no language in platform.toml: nothing to install"; exit 0; }

case "$lang" in
  python)
    command -v poetry >/dev/null || pip install "poetry>=1.8.0" poetry-plugin-export
    poetry install --with dev,code-quality 2>/dev/null || poetry install
    ;;
  go)   go mod download ;;
  node) if [ -f package-lock.json ]; then npm ci; else npm install; fi ;;
  php)  composer install --no-interaction --prefer-dist ;;
  java) mvn -B -q dependency:resolve ;;
  rust) cargo fetch ;;
  ruby) bundle install --jobs 4 ;;
  *)    echo "error: unknown language $lang" >&2; exit 1 ;;
esac
