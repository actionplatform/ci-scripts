#!/usr/bin/env bash
# Fail when a commit in the range does not follow Conventional Commits 1.0.0.
#   AP_BASE=<sha|ref> AP_TYPES="feat|fix|..." scripts/conventional-commit.sh
set -euo pipefail

base="${AP_BASE:?set AP_BASE (base ref or sha)}"
types="${AP_TYPES:-feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert}"
pattern="^(${types})(\([a-z0-9._/-]+\))?!?: .+"
bad=0

while IFS= read -r line; do
  [ -z "$line" ] && continue
  printf '%s' "$line" | grep -Eq '^Merge ' && continue
  if ! printf '%s' "$line" | grep -Eq "$pattern"; then
    echo "::error::not a conventional commit: $line" >&2
    bad=1
  fi
done < <(git log --format=%s "${base}..HEAD")

exit $bad
