#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
STARTER_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd -P)"

usage() {
  cat <<'USAGE'
Usage:
  ./scripts/install.sh <target-project>

Example:
  ./scripts/install.sh /path/to/my-project
  ./scripts/install.sh .

Behavior:
  - Installs AI OpenSpec Starter files into an existing project.
  - Does NOT overwrite existing managed files.
  - Does NOT modify machine-level OpenSpec configuration.
  - Does NOT modify application source code.
  - Records installed files in .ai-openspec-starter/manifest.sha256.

If files conflict, installation stops before copying anything.
USAGE
}

die() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

warn() {
  printf 'WARNING: %s\n' "$*" >&2
}

info() {
  printf '%s\n' "$*"
}

sha256_file() {
  local file="$1"

  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$file" | awk '{print $1}'
  elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$file" | awk '{print $1}'
  else
    die "sha256sum or shasum is required."
  fi
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

[[ $# -eq 1 ]] || {
  usage
  exit 2
}

TARGET_INPUT="$1"
[[ -d "$TARGET_INPUT" ]] || die "Target project does not exist: $TARGET_INPUT"

TARGET_ROOT="$(cd -- "$TARGET_INPUT" && pwd -P)"

if [[ "$TARGET_ROOT" == "$STARTER_ROOT" ]]; then
  die "Refusing to install the starter into itself."
fi

META_DIR="$TARGET_ROOT/.ai-openspec-starter"

if [[ -e "$META_DIR" ]]; then
  die "Starter metadata already exists at $META_DIR. Use the upgrade workflow instead."
fi

if ! command -v git >/dev/null 2>&1; then
  warn "Git is not installed or not available in PATH."
fi

if ! command -v openspec >/dev/null 2>&1; then
  warn "OpenSpec CLI is not available in PATH. Files can still be installed, but the project cannot use OpenSpec until it is installed."
fi

VERSION="dev"
if [[ -f "$STARTER_ROOT/VERSION" ]]; then
  VERSION="$(tr -d '[:space:]' < "$STARTER_ROOT/VERSION")"
fi

MANAGED_ROOTS=(
  ".agents"
  ".claude"
  ".cline"
  ".clinerules"
  ".codegraph"
  "docs/rules"
  "docs/ai-openspec"
  "openspec/config.yaml"
  "openspec/changes/archive/.gitkeep"
  "openspec/specs/.gitkeep"
  "scripts/install.sh"
  "scripts/init.sh"
  "scripts/upgrade.sh"
  "scripts/uninstall.sh"
  "scripts/doctor.sh"
  "scripts/smoke-test.sh"
)

CONTEXT_INDEX_REL="docs/context/index.yaml"
CONTEXT_INDEX_SOURCE="$STARTER_ROOT/$CONTEXT_INDEX_REL"

[[ -f "$CONTEXT_INDEX_SOURCE" ]] ||
  die "Starter is incomplete. Required path is missing: $CONTEXT_INDEX_REL"

TMP_FILES="$(mktemp)"
TMP_CONFLICTS="$(mktemp)"
trap 'rm -f "$TMP_FILES" "$TMP_CONFLICTS"' EXIT

collect_managed_files() {
  local rel
  local src

  for rel in "${MANAGED_ROOTS[@]}"; do
    src="$STARTER_ROOT/$rel"

    if [[ -d "$src" ]]; then
      find "$src" -type f -print
    elif [[ -f "$src" ]]; then
      printf '%s\n' "$src"
    else
      die "Starter is incomplete. Required path is missing: $rel"
    fi
  done |
    sed "s#^${STARTER_ROOT}/##" |
    LC_ALL=C sort -u
}

collect_managed_files > "$TMP_FILES"

[[ -s "$TMP_FILES" ]] || die "No managed starter files were found."

# Preflight first: installation must be all-or-nothing with respect to
# pre-existing managed files.
while IFS= read -r rel; do
  [[ -n "$rel" ]] || continue

  dest="$TARGET_ROOT/$rel"

  if [[ -e "$dest" || -L "$dest" ]]; then
    printf '%s\n' "$rel" >> "$TMP_CONFLICTS"
  fi
done < "$TMP_FILES"

CONTEXT_INDEX_TARGET="$TARGET_ROOT/$CONTEXT_INDEX_REL"

if [[ -e "$CONTEXT_INDEX_TARGET" || -L "$CONTEXT_INDEX_TARGET" ]]; then
  [[ -f "$CONTEXT_INDEX_TARGET" ]] ||
    die "Context registry path exists but is not a regular file: $CONTEXT_INDEX_REL"
fi

if [[ -s "$TMP_CONFLICTS" ]]; then
  printf '\nInstallation stopped. Existing files would be overwritten:\n\n' >&2
  sed 's/^/  - /' "$TMP_CONFLICTS" >&2
  printf '\nNo starter files were copied.\n' >&2
  printf 'Resolve these conflicts explicitly, then run install.sh again.\n' >&2
  exit 3
fi

info "Installing AI OpenSpec Starter"
info "Source : $STARTER_ROOT"
info "Target : $TARGET_ROOT"
info "Version: $VERSION"
info ""

while IFS= read -r rel; do
  [[ -n "$rel" ]] || continue

  src="$STARTER_ROOT/$rel"
  dest="$TARGET_ROOT/$rel"

  mkdir -p "$(dirname -- "$dest")"
  cp -p -- "$src" "$dest"

  info "  installed $rel"
done < "$TMP_FILES"

# Project Context is project-owned, not Starter-owned.
# Seed the registry only when the target does not already have one.
if [[ -f "$CONTEXT_INDEX_TARGET" ]]; then
  info "  preserved $CONTEXT_INDEX_REL (project-owned)"
else
  mkdir -p "$(dirname -- "$CONTEXT_INDEX_TARGET")"
  cp -p -- "$CONTEXT_INDEX_SOURCE" "$CONTEXT_INDEX_TARGET"
  info "  seeded    $CONTEXT_INDEX_REL (project-owned)"
fi

mkdir -p "$META_DIR"

MANIFEST="$META_DIR/manifest.sha256"
: > "$MANIFEST"

while IFS= read -r rel; do
  [[ -n "$rel" ]] || continue
  hash="$(sha256_file "$TARGET_ROOT/$rel")"
  printf '%s\t%s\n' "$hash" "$rel" >> "$MANIFEST"
done < "$TMP_FILES"

printf '%s\n' "$VERSION" > "$META_DIR/version"

cat > "$META_DIR/README.txt" <<'META'
This directory is managed by AI OpenSpec Starter.

manifest.sha256
  Records the checksum of every file installed by the starter.

version
  Records the installed starter version.

Do not delete this directory manually if you want upgrade.sh and
uninstall.sh to safely detect locally modified managed files.
META

info ""
info "Installation complete."
info ""
info "Next:"
info "  cd \"$TARGET_ROOT\""
info "  ./scripts/doctor.sh"
info ""
info "The installer did not modify machine-level OpenSpec configuration."
