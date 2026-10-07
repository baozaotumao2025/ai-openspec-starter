#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
STARTER_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd -P)"

DRY_RUN=0

usage() {
  cat <<'USAGE'
Usage:
  ./scripts/upgrade.sh [--dry-run] <target-project>

Examples:
  ./scripts/upgrade.sh --dry-run /path/to/my-project
  ./scripts/upgrade.sh /path/to/my-project

Run this script from the NEW starter source tree.

Safety:
  - Requires a previous install managed by AI OpenSpec Starter.
  - Verifies installed-file checksums before changing anything.
  - Stops if a managed file was modified or deleted locally.
  - Stops if a new starter file would overwrite an unknown target file.
  - Removes obsolete starter-managed files only when their old checksum matches.
  - Does NOT modify application source code.
  - Does NOT modify machine-level OpenSpec configuration.
USAGE
}

die() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
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

if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=1
  shift
fi

[[ $# -eq 1 ]] || {
  usage
  exit 2
}

TARGET_INPUT="$1"

[[ -d "$TARGET_INPUT" ]] ||
  die "Target project does not exist: $TARGET_INPUT"

TARGET_ROOT="$(cd -- "$TARGET_INPUT" && pwd -P)"

if [[ "$TARGET_ROOT" == "$STARTER_ROOT" ]]; then
  die "Refusing to upgrade the starter source tree into itself."
fi

META_DIR="$TARGET_ROOT/.ai-openspec-starter"
OLD_MANIFEST="$META_DIR/manifest.sha256"

[[ -d "$META_DIR" ]] ||
  die "Starter metadata was not found at $META_DIR. Install the starter first."

[[ -f "$OLD_MANIFEST" ]] ||
  die "Starter manifest is missing: $OLD_MANIFEST"

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
  die "Starter source is incomplete. Required path is missing: $CONTEXT_INDEX_REL"

TMP_NEW="$(mktemp)"
TMP_OLD="$(mktemp)"
TMP_CONFLICTS="$(mktemp)"
TMP_OBSOLETE="$(mktemp)"
TMP_ADDED="$(mktemp)"

cleanup_tmp() {
  rm -f \
    "$TMP_NEW" \
    "$TMP_OLD" \
    "$TMP_CONFLICTS" \
    "$TMP_OBSOLETE" \
    "$TMP_ADDED"
}

trap cleanup_tmp EXIT

collect_new_files() {
  local rel
  local src

  for rel in "${MANAGED_ROOTS[@]}"; do
    src="$STARTER_ROOT/$rel"

    if [[ -d "$src" ]]; then
      find "$src" -type f -print
    elif [[ -f "$src" ]]; then
      printf '%s\n' "$src"
    else
      die "Starter source is incomplete. Required path is missing: $rel"
    fi
  done |
    sed "s#^${STARTER_ROOT}/##" |
    LC_ALL=C sort -u
}

collect_new_files > "$TMP_NEW"

[[ -s "$TMP_NEW" ]] ||
  die "No managed files were found in the new starter."

cut -f2- "$OLD_MANIFEST" |
  awk -v context="$CONTEXT_INDEX_REL" '$0 != context' |
  LC_ALL=C sort -u > "$TMP_OLD"

# ------------------------------------------------------------
# 1. Verify every previously managed file is unchanged
# ------------------------------------------------------------

while IFS=$'\t' read -r recorded_hash rel; do
  [[ -n "${recorded_hash:-}" ]] || continue
  [[ -n "${rel:-}" ]] || continue

  # Compatibility with old installations that recorded index.yaml.
  [[ "$rel" == "$CONTEXT_INDEX_REL" ]] && continue

  target="$TARGET_ROOT/$rel"

  if [[ ! -f "$target" ]]; then
    printf '%s\t%s\n' "missing-managed-file" "$rel" >> "$TMP_CONFLICTS"
    continue
  fi

  current_hash="$(sha256_file "$target")"

  if [[ "$current_hash" != "$recorded_hash" ]]; then
    printf '%s\t%s\n' "locally-modified" "$rel" >> "$TMP_CONFLICTS"
  fi
done < "$OLD_MANIFEST"

# ------------------------------------------------------------
# 2. Detect files introduced by the new starter
# ------------------------------------------------------------

comm -13 "$TMP_OLD" "$TMP_NEW" > "$TMP_ADDED"

while IFS= read -r rel; do
  [[ -n "$rel" ]] || continue

  target="$TARGET_ROOT/$rel"

  if [[ -e "$target" || -L "$target" ]]; then
    printf '%s\t%s\n' "unknown-file-collision" "$rel" >> "$TMP_CONFLICTS"
  fi
done < "$TMP_ADDED"

# ------------------------------------------------------------
# 3. Detect files removed from the new starter
# ------------------------------------------------------------

comm -23 "$TMP_OLD" "$TMP_NEW" > "$TMP_OBSOLETE"

if [[ -s "$TMP_CONFLICTS" ]]; then
  printf '\nUpgrade stopped before changing any file.\n\n' >&2
  printf 'Conflicts:\n' >&2

  while IFS=$'\t' read -r reason rel; do
    case "$reason" in
      locally-modified)
        printf '  - LOCAL MODIFICATION: %s\n' "$rel" >&2
        ;;
      missing-managed-file)
        printf '  - MANAGED FILE MISSING: %s\n' "$rel" >&2
        ;;
      unknown-file-collision)
        printf '  - NEW FILE COLLIDES WITH EXISTING FILE: %s\n' "$rel" >&2
        ;;
      *)
        printf '  - %s: %s\n' "$reason" "$rel" >&2
        ;;
    esac
  done < "$TMP_CONFLICTS"

  cat >&2 <<'MSG'

No files were changed.

Review the conflicts explicitly.
Do not use an automatic force overwrite when you do not know why the
target differs from the installed manifest.
MSG

  exit 3
fi

OLD_VERSION="unknown"

if [[ -f "$META_DIR/version" ]]; then
  OLD_VERSION="$(tr -d '[:space:]' < "$META_DIR/version")"
fi

info "AI OpenSpec Starter Upgrade"
info "Source version : $VERSION"
info "Target version : $OLD_VERSION"
info "Source         : $STARTER_ROOT"
info "Target         : $TARGET_ROOT"
info ""

if [[ "$DRY_RUN" -eq 1 ]]; then
  info "DRY RUN — no files will be changed."
  info ""
fi

if [[ -s "$TMP_ADDED" ]]; then
  info "New managed files:"
  sed 's/^/  + /' "$TMP_ADDED"
else
  info "New managed files: none"
fi

info ""

if [[ -s "$TMP_OBSOLETE" ]]; then
  info "Obsolete managed files:"
  sed 's/^/  - /' "$TMP_OBSOLETE"
else
  info "Obsolete managed files: none"
fi

info ""

if [[ "$DRY_RUN" -eq 1 ]]; then
  info "Managed files that remain present would be refreshed from the new starter."
  info ""
  info "Dry run complete. No files were changed."
  exit 0
fi

# ------------------------------------------------------------
# 4. Remove obsolete starter-managed files
# ------------------------------------------------------------

while IFS= read -r rel; do
  [[ -n "$rel" ]] || continue

  target="$TARGET_ROOT/$rel"

  if [[ -f "$target" || -L "$target" ]]; then
    rm -f -- "$target"
    info "  removed   $rel"
  fi
done < "$TMP_OBSOLETE"

# ------------------------------------------------------------
# 5. Copy the current starter-managed file set
# ------------------------------------------------------------

while IFS= read -r rel; do
  [[ -n "$rel" ]] || continue

  src="$STARTER_ROOT/$rel"
  target="$TARGET_ROOT/$rel"

  mkdir -p "$(dirname -- "$target")"
  cp -p -- "$src" "$target"

  info "  refreshed $rel"
done < "$TMP_NEW"

# Context registry belongs to the target project.
# Never overwrite its registrations during Starter upgrades.
CONTEXT_INDEX_TARGET="$TARGET_ROOT/$CONTEXT_INDEX_REL"

if [[ -f "$CONTEXT_INDEX_TARGET" ]]; then
  info "  preserved $CONTEXT_INDEX_REL (project-owned)"
elif [[ -e "$CONTEXT_INDEX_TARGET" || -L "$CONTEXT_INDEX_TARGET" ]]; then
  die "Context registry path exists but is not a regular file: $CONTEXT_INDEX_REL"
else
  mkdir -p "$(dirname -- "$CONTEXT_INDEX_TARGET")"
  cp -p -- "$CONTEXT_INDEX_SOURCE" "$CONTEXT_INDEX_TARGET"
  info "  seeded    $CONTEXT_INDEX_REL (project-owned)"
fi

# ------------------------------------------------------------
# 6. Rebuild manifest
# ------------------------------------------------------------

NEW_MANIFEST="$META_DIR/manifest.sha256.new"
: > "$NEW_MANIFEST"

while IFS= read -r rel; do
  [[ -n "$rel" ]] || continue

  hash="$(sha256_file "$TARGET_ROOT/$rel")"
  printf '%s\t%s\n' "$hash" "$rel" >> "$NEW_MANIFEST"
done < "$TMP_NEW"

mv -- "$NEW_MANIFEST" "$OLD_MANIFEST"
printf '%s\n' "$VERSION" > "$META_DIR/version"

cat > "$META_DIR/README.txt" <<'META'
This directory is managed by AI OpenSpec Starter.

manifest.sha256
  Records the checksum of every file installed by the starter.

version
  Records the installed starter version.

The manifest is used by upgrade.sh and uninstall.sh to detect local
modifications before changing or deleting starter-managed files.

Do not delete this directory manually if you want those safety checks.
META

info ""
info "Upgrade complete."
info ""
info "Important:"
info "  - Machine-level OpenSpec configuration was not modified."
info "  - Generated integration files came from this starter source tree."
info "  - The starter intentionally does not distribute the Onboard workflow."
info ""
info "Recommended checks:"
info "  cd \"$TARGET_ROOT\""
info "  ./scripts/doctor.sh"
info "  ./scripts/smoke-test.sh"
