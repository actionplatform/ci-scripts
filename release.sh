#!/usr/bin/env bash
# Write LAST_VERSION and version constants from a tag, commit back to the default branch.
#   AP_TAG=v1.2.3 AP_FILES="pyproject.toml pkg/__init__.py" AP_BRANCH=main scripts/release.sh
set -euo pipefail

tag="${AP_TAG:?set AP_TAG (vX.Y.Z)}"
version="${tag#v}"
branch="${AP_BRANCH:-main}"

echo "$version" > LAST_VERSION
for f in ${AP_FILES:-}; do
  [ -f "$f" ] || continue
  sed -i.bak -E "s/^(version *= *)\"[^\"]*\"/\1\"$version\"/" "$f"
  sed -i.bak -E "s/^(__version__ *= *)\"[^\"]*\"/\1\"$version\"/" "$f"
  sed -i.bak -E "s/(VERSION *= *)\"[^\"]*\"/\1\"$version\"/" "$f"
  sed -i.bak -E "s/(VERSION *= *)'[^']*'/\1'$version'/" "$f"
  sed -i.bak -E "s/(\"version\": *)\"[^\"]*\"/\1\"$version\"/" "$f"
  rm -f "$f.bak"
done

git config user.name "${AP_GIT_USER:-ci-bot}"
git config user.email "${AP_GIT_EMAIL:-ci-bot@users.noreply.github.com}"
git add LAST_VERSION ${AP_FILES:-}
git commit -m "chore(release): $version" || { echo "nothing to commit"; exit 0; }
git push origin "HEAD:$branch"
echo "version=$version"
