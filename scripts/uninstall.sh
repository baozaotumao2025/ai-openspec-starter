#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd -P)"

YES=0

usage() {
  cat <<'USAGE'
Usage:
  ./scripts/uninstall.sh
  ./scripts/uninstall.sh --yes

Behavior:
  - Reads .ai-openspec-starter/manifest.sha256.
  - Verifies every managed file still matches the installed checksum.
  - Refuses to delete locally modified managed files.
  - Preview mode is the default.
  - --yes performs the deletion.
  - Does NOT delete application source code.
  - Does NOT modify Git history.
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

if [[ "${1:-}" == "--yes" ]]; then
  YES=1
  shift
fi

[[ $# -eq 0 ]] || {
  usage
  exit 2
}

META_DIR="$PROJECT_ROOT/.ai-openspec-starter"
MANIFEST="$META_DIR/manifest.sha256"
CONTEXT_INDEX_REL="docs/context/index.yaml"

[[ -d "$META_DIR" ]] ||
  die "Starter metadata was not found at $META_DIR"

[[ -f "$MANIFEST" ]] ||
  die "Starter manifest is missing: $MANIFEST"

TMP_CONFLICTS="$(mktemp)"
TMP_FILES="$(mktemp)"

cleanup_tmp() {
  rm -f "$TMP_CONFLICTS" "$TMP_FILES"
}

trap cleanup_tmp EXIT

cut -f2- "$MANIFEST" |
  awk -v context="$CONTEXT_INDEX_REL" '$0 != context' > "$TMP_FILES"

[[ -s "$TMP_FILES" ]] ||
  die "Starter manifest contains no managed files"

# ------------------------------------------------------------
# 1. Safety verification
# ------------------------------------------------------------

while IFS=$'\t' read -r recorded_hash rel; do
  [[ -n "${recorded_hash:-}" ]] || continue
  [[ -n "${rel:-}" ]] || continue

  # Project Context survives Starter uninstall, including older manifests.
  [[ "$rel" == "$CONTEXT_INDEX_REL" ]] && continue

  file="$PROJECT_ROOT/$rel"

  if [[ ! -f "$file" ]]; then
    printf '%s\t%s\n' "missing" "$rel" >> "$TMP_CONFLICTS"
    continue
  fi

  current_hash="$(sha256_file "$file")"

  if [[ "$current_hash" != "$recorded_hash" ]]; then
    printf '%s\t%s\n' "modified" "$rel" >> "$TMP_CONFLICTS"
  fi
done < "$MANIFEST"

if [[ -s "$TMP_CONFLICTS" ]]; then
  printf '\nUninstall stopped.\n\n' >&2
  printf 'Some starter-managed files no longer match the installation manifest:\n\n' >&2

  while IFS=$'\t' read -r reason rel; do
    case "$reason" in
      modified)
        printf '  - LOCALLY MODIFIED: %s\n' "$rel" >&2
        ;;
      missing)
        printf '  - MANAGED FILE MISSING: %s\n' "$rel" >&2
        ;;
      *)
        printf '  - %s: %s\n' "$reason" "$rel" >&2
        ;;
    esac
  done < "$TMP_CONFLICTS"

  cat >&2 <<'MSG'

No files were deleted.

Review these files manually before uninstalling.
This safety check prevents the starter from deleting work that may have
become project-specific after installation.
MSG

  exit 3
fi

# ------------------------------------------------------------
# 2. Preview
# ------------------------------------------------------------

info "AI OpenSpec Starter Uninstall"
info "Project: $PROJECT_ROOT"
info ""
info "The following starter-managed files are eligible for removal:"
info ""

sed 's/^/  - /' "$TMP_FILES"

info ""
info "Metadata directory:"
info "  - .ai-openspec-starter/"
info ""
info "The script will NOT modify:"
info "  - application source code not listed in the manifest"
info "  - Git history"
info "  - machine-level OpenSpec configuration"
info ""

if [[ "$YES" -ne 1 ]]; then
  info "Preview only. Nothing was deleted."
  info ""
  info "If this list is correct, run:"
  info "  ./scripts/uninstall.sh --yes"
  exit 0
fi

# ------------------------------------------------------------
# 3. Delete only verified managed files
# ------------------------------------------------------------

while IFS= read -r rel; do
  [[ -n "$rel" ]] || continue

  file="$PROJECT_ROOT/$rel"

  if [[ -f "$file" || -L "$file" ]]; then
    rm -f -- "$file"
    info "  removed $rel"
  fi
done < "$TMP_FILES"

# ------------------------------------------------------------
# 4. Remove empty directories created by the starter
# ------------------------------------------------------------

EMPTY_DIR_CANDIDATES=(
  "$PROJECT_ROOT/.agents/skills"
  "$PROJECT_ROOT/.agents"
  "$PROJECT_ROOT/.claude/commands/opsx"
  "$PROJECT_ROOT/.claude/commands"
  "$PROJECT_ROOT/.claude/skills"
  "$PROJECT_ROOT/.claude"
  "$PROJECT_ROOT/.cline/skills"
  "$PROJECT_ROOT/.cline"
  "$PROJECT_ROOT/.clinerules/workflows"
  "$PROJECT_ROOT/.clinerules"
  "$PROJECT_ROOT/.codegraph"
  "$PROJECT_ROOT/docs/ai-openspec"
  "$PROJECT_ROOT/docs/rules"
  "$PROJECT_ROOT/docs/context"
  "$PROJECT_ROOT/docs"
  "$PROJECT_ROOT/openspec/changes/archive"
  "$PROJECT_ROOT/openspec/changes"
  "$PROJECT_ROOT/openspec/specs"
  "$PROJECT_ROOT/openspec"
  "$PROJECT_ROOT/scripts"
)

for dir in "${EMPTY_DIR_CANDIDATES[@]}"; do
  if [[ -d "$dir" ]]; then
    rmdir -- "$dir" 2>/dev/null || true
  fi
done

rm -rf -- "$META_DIR"

info ""
info "AI OpenSpec Starter uninstall complete."
info ""
info "Review the project with:"
info "  git status --short"
