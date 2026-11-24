#!/usr/bin/env bash
# Lint, format check and tests for the project language.
set -euo pipefail
. "$(dirname "$0")/lib.sh"

lang=$(ap_language)
type_=$(ap_type)

mkdocs=false
[ "$type_" = "docs" ] && [ -f mkdocs.yml ] && mkdocs=true

if [ -z "${AP_CHECK:-}" ] && [ -z "$lang" ] && [ "$mkdocs" = false ]; then
  echo "no language in platform.toml and no mkdocs.yml: nothing to check"
  exit 0
fi

if [ -n "${AP_CHECK:-}" ]; then
  cmds=("$AP_CHECK")
elif [ "$mkdocs" = true ]; then
  cmds=('poetry run mkdocs build --strict')
else
case "$lang" in
  python)
    cmds=('poetry run ruff check .' 'poetry run ruff format --check .')
    [ -f .code_quality/mypy.ini ] && cmds+=('poetry run mypy --config-file .code_quality/mypy.ini .')
    cmds+=('poetry run pytest')
    ;;
  go)     cmds=('go vet ./...' 'test -z "$(gofmt -l .)"' 'go test ./...') ;;
  node)   cmds=('npm run lint' 'npm test') ;;
  php)    cmds=('composer lint' 'composer analyse' 'composer test') ;;
  java)   cmds=('mvn -B verify') ;;
  rust)   cmds=('cargo fmt --check' 'cargo clippy -- -D warnings' 'cargo test') ;;
  ruby)   cmds=('bundle exec rubocop' 'bundle exec rspec') ;;
  *)      echo "error: no checks for language $lang" >&2; exit 1 ;;
esac
fi

for cmd in "${cmds[@]}"; do
  echo "+ $cmd"
  bash -c "$cmd"
done
