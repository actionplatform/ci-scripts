#!/usr/bin/env bash
# CI: validate a pull request against git-flow. AP_HEAD, AP_BASE, optional AP_HAS_DEVELOP / AP_DEFAULT_BRANCH.
set -euo pipefail
. "$(dirname "$0")/gitflow.sh"

head="${AP_HEAD:?set AP_HEAD (source branch)}"
base="${AP_BASE:?set AP_BASE (target branch)}"

case "$head" in
  dependabot/*)
    echo "git-flow skipped: $head is Dependabot's, whose branch names cannot follow <kind>/<code>"
    exit 0 ;;
esac

if [ -z "${AP_HAS_DEVELOP:-}" ]; then
  if git ls-remote --heads origin develop 2>/dev/null | grep -q develop; then AP_HAS_DEVELOP=true; else AP_HAS_DEVELOP=false; fi
  export AP_HAS_DEVELOP
fi

gitflow_branch "$head"
gitflow_target "$head" "$base"
echo "git-flow ok: $head → $base"
