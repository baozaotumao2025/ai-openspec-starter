#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
STARTER_ROOT="$(cd -- "$SCRIPT_DIR/.." && pwd -P)"

usage() {
  cat <<'USAGE'
Usage:
  ./scripts/init.sh <existing-git-project>
  ./scripts/init.sh --new <new-project-path>

The existing-project mode installs into the Git repository root.
The --new mode creates a directory and Git repository first.
Both modes run doctor.sh after installation.
USAGE
}

die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

MODE="existing"
if [[ "${1:-}" == "--new" ]]; then
  MODE="new"
  shift
fi
[[ $# -eq 1 ]] || { usage >&2; exit 2; }

TARGET_INPUT="$1"
command -v git >/dev/null 2>&1 || die "Git is required. Install Git and try again."

if [[ "$MODE" == "new" ]]; then
  [[ ! -e "$TARGET_INPUT" && ! -L "$TARGET_INPUT" ]] ||
    die "New project path already exists: $TARGET_INPUT"
  mkdir -p -- "$TARGET_INPUT"
  TARGET_ROOT="$(cd -- "$TARGET_INPUT" && pwd -P)"
  git -C "$TARGET_ROOT" init || die "Git initialization failed in $TARGET_ROOT"
else
  [[ -d "$TARGET_INPUT" ]] || die "Project directory does not exist: $TARGET_INPUT"
  TARGET_ROOT="$(cd -- "$TARGET_INPUT" && pwd -P)"
  GIT_ROOT="$(git -C "$TARGET_ROOT" rev-parse --show-toplevel 2>/dev/null)" ||
    die "Target is not a Git repository. Use --new for a new project."
  [[ "$GIT_ROOT" == "$TARGET_ROOT" ]] ||
    die "Target must be the Git repository root: $GIT_ROOT"
fi

[[ "$TARGET_ROOT" != "$STARTER_ROOT" ]] || die "Cannot initialize the Starter itself."

"$SCRIPT_DIR/install.sh" "$TARGET_ROOT"

printf '\nRunning project diagnosis...\n'
if "$TARGET_ROOT/scripts/doctor.sh"; then
  printf '\nProject initialized: %s\n' "$TARGET_ROOT"
else
  printf '\nStarter files are installed, but diagnosis reported failures. Fix them before starting a Change.\n' >&2
  exit 1
fi

printf '\nNext steps:\n'
printf '  1. Record verified project facts in docs/context/ and docs/context/index.yaml.\n'
printf '  2. Start a change: cd "%s" && openspec new change <change-name>\n' "$TARGET_ROOT"
printf '  3. Read docs/ai-openspec/getting-started.md for the workflow.\n'
