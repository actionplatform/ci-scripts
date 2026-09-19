# ci-scripts

The one implementation of Action Platform CI steps. Bash, no dependencies beyond the language toolchain. Consumed by [ci-github](https://github.com/actionplatform/ci-github), [ci-gitlab](https://github.com/actionplatform/ci-gitlab) and [ci-jenkins](https://github.com/actionplatform/ci-jenkins).

| Script | Does | Env |
|--------|------|-----|
| `setup.sh` | install dependencies for the language | `AP_LANGUAGE` (default: `platform.toml`), `AP_INSTALL` |
| `check.sh` | lint + format + tests (`docs` type: `mkdocs build --strict`; python adds mypy when `.code_quality/mypy.ini` exists) | `AP_LANGUAGE`, `AP_TYPE`, `AP_CHECK` (override) |
| `release.sh` | `LAST_VERSION` + version constants from a tag, commit back | `AP_TAG`, `AP_FILES`, `AP_BRANCH`, `AP_GIT_USER`, `AP_GIT_EMAIL` |
| `conventional-commit.sh` | Conventional Commits 1.0.0 on `AP_BASE..HEAD` | `AP_BASE`, `AP_TYPES` |
| `gitflow.sh` | rules: `branch`, `commit-msg`, `target`, `protect` — also sourced by the git hooks | `AP_KINDS`, `AP_TYPES`, `AP_PROTECTED` |
| `gitflow-pr.sh` | CI: head branch name + merge target | `AP_HEAD`, `AP_BASE`, `AP_HAS_DEVELOP`, `AP_DEFAULT_BRANCH` |
| `hooks/` | `pre-commit`, `commit-msg`, `pre-push` — bundled in the `action-platform` CLI, installed into `.git/hooks` by `action-platform install` | — |
| `lib.sh` | `ap_language`, `ap_type` — read `platform.toml` | — |

```bash
curl -fsSL https://raw.githubusercontent.com/actionplatform/ci-scripts/v1/check.sh | bash
```

Tag `vX.Y.Z`; `v1` floats to the latest.
