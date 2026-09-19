#!/usr/bin/env bash
# Build and publish a library for the registry the platform named. The platform
# dispatches the publish workflow on the release tag with AP_VERSION and
# AP_REGISTRY (the scope: pypi, testpypi, npm, npm-next…); the pipeline holds
# the credentials.
set -euo pipefail
. "$(dirname "$0")/lib.sh"

lang=$(ap_language)
version="${AP_VERSION:?AP_VERSION is the release to publish}"
registry="${AP_REGISTRY:-}"

if [ -f LAST_VERSION ] && [ "$(tr -d '[:space:]' < LAST_VERSION)" != "$version" ]; then
  echo "error: LAST_VERSION is $(cat LAST_VERSION), not $version — publish runs on the release tag" >&2
  exit 1
fi

run() { echo "+ $*"; "$@"; }

case "$lang" in
  python)
    run poetry build
    if [ -n "${PYPI_TOKEN:-}" ]; then
      case "$registry" in
        testpypi) url="https://test.pypi.org/legacy/" ;;
        *)        url="https://upload.pypi.org/legacy/" ;;
      esac
      run poetry config repositories.ap-target "$url"
      poetry publish -r ap-target -u __token__ -p "$PYPI_TOKEN" --no-interaction
    else
      echo "dist/ built for $version; no PYPI_TOKEN — the pipeline uploads it (trusted publishing)"
    fi
    ;;
  node)
    if grep -q '"build"' package.json; then run npm run build; fi
    case "$registry" in
      npm|"") tag="latest" ;;
      npm-*)  tag="${registry#npm-}" ;;
      *)      tag="$registry" ;;
    esac
    run npm publish --provenance --access public --tag "$tag"
    ;;
  rust)
    run cargo publish --locked
    ;;
  ruby)
    run gem build
    run gem push ./*-"$version".gem
    ;;
  java)
    run mvn -B -q -DskipTests deploy
    ;;
  go)
    module=$(go list -m)
    echo "go: the tag is the release; asking the module proxy for $module@v$version"
    curl -fsS "https://proxy.golang.org/${module}/@v/v${version}.info" || echo "the proxy will pick the tag up on first request"
    ;;
  php)
    echo "php: the tag is the release; Packagist reads it from the repository"
    ;;
  *)
    echo "error: no publish step for language ${lang:-none}" >&2
    exit 1
    ;;
esac
