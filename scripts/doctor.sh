#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd -P)"

PASS_COUNT=0
WARN_COUNT=0
FAIL_COUNT=0

pass() {
  PASS_COUNT=$((PASS_COUNT + 1))
  printf '[PASS] %s\n' "$*"
}

warn() {
  WARN_COUNT=$((WARN_COUNT + 1))
  printf '[WARN] %s\n' "$*"
}

fail() {
  FAIL_COUNT=$((FAIL_COUNT + 1))
  printf '[FAIL] %s\n' "$*"
}

section() {
  printf '\n== %s ==\n' "$*"
}

check_file() {
  local rel="$1"

  if [[ -f "$PROJECT_ROOT/$rel" ]]; then
    pass "$rel"
  else
    fail "Missing file: $rel"
  fi
}

count_files() {
  local dir="$1"
  local pattern="$2"

  if [[ ! -d "$dir" ]]; then
    printf '0\n'
    return
  fi

  find "$dir" -type f -name "$pattern" 2>/dev/null | wc -l | tr -d '[:space:]'
}

printf 'AI OpenSpec Starter Doctor\n'
printf 'Project: %s\n' "$PROJECT_ROOT"

section "Required commands"

if command -v git >/dev/null 2>&1; then
  pass "git: $(git --version 2>/dev/null || true)"
else
  warn "git is not available in PATH"
fi

if command -v openspec >/dev/null 2>&1; then
  OPEN_SPEC_VERSION="$(openspec --version 2>/dev/null || true)"

  if [[ -n "$OPEN_SPEC_VERSION" ]]; then
    pass "openspec: $OPEN_SPEC_VERSION"

    if [[ "$OPEN_SPEC_VERSION" == *"1.14.0"* ]]; then
      pass "OpenSpec version matches the validated baseline 1.14.0"
    else
      warn "Starter was validated against OpenSpec 1.14.0; current version is: $OPEN_SPEC_VERSION"
    fi
  else
    fail "openspec exists but its version could not be determined"
  fi
else
  fail "openspec is not available in PATH"
fi

section "Core files"

CORE_FILES=(
  "openspec/config.yaml"
  "docs/context/index.yaml"
  "docs/rules/global.md"
  "docs/rules/git-workflow.md"
  "docs/rules/engineering-workflow.md"
  "docs/rules/proposal.md"
  "docs/rules/specs.md"
  "docs/rules/design.md"
  "docs/rules/tasks.md"
  "docs/rules/apply.md"
  "docs/rules/verify.md"
  "docs/rules/archive.md"
  "docs/rules/testing.md"
  "docs/rules/code-quality.md"
  "docs/rules/database.md"
  "docs/rules/authorization.md"
  "docs/rules/external-dependency.md"
  "docs/rules/ui-frontend.md"
  "docs/rules/session-continuity.md"
)

for file in "${CORE_FILES[@]}"; do
  check_file "$file"
done

section "User documentation"

GUIDE_FILES=(
  "docs/ai-openspec/installation.md"
  "docs/ai-openspec/getting-started.md"
  "docs/ai-openspec/workflow-guide.md"
  "docs/ai-openspec/project-context.md"
  "docs/ai-openspec/architecture.md"
  "docs/ai-openspec/upgrade.md"
  "docs/ai-openspec/uninstall.md"
  "docs/ai-openspec/troubleshooting.md"
)

for file in "${GUIDE_FILES[@]}"; do
  check_file "$file"
done

section "Project context registry"

if [[ -f "$PROJECT_ROOT/docs/context/index.yaml" ]]; then
  if grep -Eq '^[[:space:]]*contexts:' "$PROJECT_ROOT/docs/context/index.yaml"; then
    pass "docs/context/index.yaml defines a contexts registry"
  else
    fail "docs/context/index.yaml does not define a top-level contexts registry"
  fi
fi

section "OpenSpec configuration"

if [[ -f "$PROJECT_ROOT/openspec/config.yaml" ]]; then
  if grep -Eq '^schema:[[:space:]]*spec-driven[[:space:]]*$' "$PROJECT_ROOT/openspec/config.yaml"; then
    pass "schema is spec-driven"
  else
    warn "openspec/config.yaml does not declare schema: spec-driven"
  fi

  if grep -Fq 'docs/rules/apply.md' "$PROJECT_ROOT/openspec/config.yaml"; then
    pass "Apply guidance is registered"
  else
    fail "Apply guidance does not reference docs/rules/apply.md"
  fi

  if grep -Fq 'docs/rules/archive.md' "$PROJECT_ROOT/openspec/config.yaml"; then
    pass "Archive guidance is registered"
  else
    fail "Archive guidance does not reference docs/rules/archive.md"
  fi

  if grep -Fq 'docs/rules/verify.md' "$PROJECT_ROOT/openspec/config.yaml"; then
    warn "openspec/config.yaml directly references docs/rules/verify.md; review this because OpenSpec 1.14.0 native Verify has no custom Verify guidance injection point"
  else
    pass "Native Verify is not falsely configured with custom verify.md injection"
  fi
fi

section "OpenSpec root"

if command -v openspec >/dev/null 2>&1; then
  LIST_JSON=""
  LIST_RC=0

  LIST_JSON="$(cd "$PROJECT_ROOT" && openspec list --json 2>&1)" || LIST_RC=$?

  if [[ "$LIST_RC" -eq 0 ]]; then
    pass "openspec list --json succeeded"

    if [[ "$LIST_JSON" == *"\"root\""* ]]; then
      pass "OpenSpec reports a project root"
    else
      fail "OpenSpec output does not contain a root object"
    fi

    if command -v python3 >/dev/null 2>&1; then
      DETECTED_ROOT="$(
        printf '%s' "$LIST_JSON" |
          python3 -c '
import json, sys
try:
    data = json.load(sys.stdin)
    root = data.get("root") or {}
    print(root.get("path") or "")
except Exception:
    print("")
'
      )"

      if [[ -z "$DETECTED_ROOT" ]]; then
        fail "Could not parse OpenSpec root.path"
      elif [[ "$DETECTED_ROOT" == "$PROJECT_ROOT" ]]; then
        pass "OpenSpec root matches this project"
      else
        fail "OpenSpec root mismatch: $DETECTED_ROOT"
      fi
    else
      warn "python3 is unavailable; exact OpenSpec root path was not parsed"
    fi
  else
    fail "openspec list --json failed"
    printf '%s\n' "$LIST_JSON" | sed 's/^/       /'
  fi
fi

section "Generated workflow integrations"

# Check the canonical generated paths instead of deriving names:
# several OpenSpec workflows intentionally do not use the "-change" suffix.
AGENT_EXPECTED=(
  ".agents/skills/openspec-apply-change/SKILL.md"
  ".agents/skills/openspec-archive-change/SKILL.md"
  ".agents/skills/openspec-continue-change/SKILL.md"
  ".agents/skills/openspec-explore/SKILL.md"
  ".agents/skills/openspec-new-change/SKILL.md"
  ".agents/skills/openspec-propose/SKILL.md"
  ".agents/skills/openspec-sync-specs/SKILL.md"
  ".agents/skills/openspec-update-change/SKILL.md"
  ".agents/skills/openspec-verify-change/SKILL.md"
)

CLAUDE_SKILL_EXPECTED=(
  ".claude/skills/openspec-apply-change/SKILL.md"
  ".claude/skills/openspec-archive-change/SKILL.md"
  ".claude/skills/openspec-continue-change/SKILL.md"
  ".claude/skills/openspec-explore/SKILL.md"
  ".claude/skills/openspec-new-change/SKILL.md"
  ".claude/skills/openspec-propose/SKILL.md"
  ".claude/skills/openspec-sync-specs/SKILL.md"
  ".claude/skills/openspec-update-change/SKILL.md"
  ".claude/skills/openspec-verify-change/SKILL.md"
)

CLINE_SKILL_EXPECTED=(
  ".cline/skills/openspec-apply-change/SKILL.md"
  ".cline/skills/openspec-archive-change/SKILL.md"
  ".cline/skills/openspec-continue-change/SKILL.md"
  ".cline/skills/openspec-explore/SKILL.md"
  ".cline/skills/openspec-new-change/SKILL.md"
  ".cline/skills/openspec-propose/SKILL.md"
  ".cline/skills/openspec-sync-specs/SKILL.md"
  ".cline/skills/openspec-update-change/SKILL.md"
  ".cline/skills/openspec-verify-change/SKILL.md"
)

CLAUDE_COMMAND_EXPECTED=(
  ".claude/commands/opsx/apply.md"
  ".claude/commands/opsx/archive.md"
  ".claude/commands/opsx/continue.md"
  ".claude/commands/opsx/explore.md"
  ".claude/commands/opsx/new.md"
  ".claude/commands/opsx/propose.md"
  ".claude/commands/opsx/sync.md"
  ".claude/commands/opsx/update.md"
  ".claude/commands/opsx/verify.md"
)

CLINERULE_EXPECTED=(
  ".clinerules/workflows/opsx-apply.md"
  ".clinerules/workflows/opsx-archive.md"
  ".clinerules/workflows/opsx-continue.md"
  ".clinerules/workflows/opsx-explore.md"
  ".clinerules/workflows/opsx-new.md"
  ".clinerules/workflows/opsx-propose.md"
  ".clinerules/workflows/opsx-sync.md"
  ".clinerules/workflows/opsx-update.md"
  ".clinerules/workflows/opsx-verify.md"
)

# The generic loop above intentionally does not determine canonical generated
# names. Check the actual expected OpenSpec 1.14.0 paths here.
for file in \
  "${AGENT_EXPECTED[@]}" \
  "${CLAUDE_SKILL_EXPECTED[@]}" \
  "${CLINE_SKILL_EXPECTED[@]}" \
  "${CLAUDE_COMMAND_EXPECTED[@]}" \
  "${CLINERULE_EXPECTED[@]}"
do
  if [[ ! -f "$PROJECT_ROOT/$file" ]]; then
    fail "Missing generated integration: $file"
  fi
done

AGENT_COUNT="$(count_files "$PROJECT_ROOT/.agents/skills" "SKILL.md")"
CLAUDE_SKILL_COUNT="$(count_files "$PROJECT_ROOT/.claude/skills" "SKILL.md")"
CLAUDE_COMMAND_COUNT="$(count_files "$PROJECT_ROOT/.claude/commands/opsx" "*.md")"
CLINE_SKILL_COUNT="$(count_files "$PROJECT_ROOT/.cline/skills" "SKILL.md")"
CLINERULE_COUNT="$(count_files "$PROJECT_ROOT/.clinerules/workflows" "opsx-*.md")"

for entry in \
  "agents:$AGENT_COUNT" \
  "claude-skills:$CLAUDE_SKILL_COUNT" \
  "claude-commands:$CLAUDE_COMMAND_COUNT" \
  "cline-skills:$CLINE_SKILL_COUNT" \
  "clinerules:$CLINERULE_COUNT"
do
  name="${entry%%:*}"
  count="${entry##*:}"

  if [[ "$count" -eq 9 ]]; then
    pass "$name exposes 9 workflows"
  else
    fail "$name exposes $count workflows; expected 9"
  fi
done

if find \
  "$PROJECT_ROOT/.agents" \
  "$PROJECT_ROOT/.claude" \
  "$PROJECT_ROOT/.cline" \
  "$PROJECT_ROOT/.clinerules" \
  -iname '*onboard*' \
  -print -quit 2>/dev/null |
  grep -q .
then
  fail "Onboard workflow residue detected"
else
  pass "Onboard workflow is not distributed"
fi

section "Verify boundary"

VERIFY_FILE="$PROJECT_ROOT/.agents/skills/openspec-verify-change/SKILL.md"

if [[ -f "$VERIFY_FILE" ]]; then
  if grep -Fq 'openspec instructions apply' "$VERIFY_FILE"; then
    pass "Native Verify uses OpenSpec apply instructions for planning context"
  else
    warn "Native Verify implementation differs from the validated OpenSpec 1.14.0 baseline"
  fi

  if grep -Fq 'docs/rules/verify.md' "$VERIFY_FILE"; then
    fail "Generated native Verify directly references custom docs/rules/verify.md"
  else
    pass "Generated native Verify does not claim custom verify.md injection"
  fi
fi

section "Starter scripts"

SCRIPT_FILES=(
  "scripts/install.sh"
  "scripts/init.sh"
  "scripts/upgrade.sh"
  "scripts/uninstall.sh"
  "scripts/doctor.sh"
  "scripts/smoke-test.sh"
)

for file in "${SCRIPT_FILES[@]}"; do
  check_file "$file"

  if [[ -f "$PROJECT_ROOT/$file" ]]; then
    if [[ -x "$PROJECT_ROOT/$file" ]]; then
      pass "$file is executable"
    else
      fail "$file is not executable"
    fi
  fi
done

section "Summary"

printf 'PASS: %d\n' "$PASS_COUNT"
printf 'WARN: %d\n' "$WARN_COUNT"
printf 'FAIL: %d\n' "$FAIL_COUNT"

if [[ "$FAIL_COUNT" -gt 0 ]]; then
  printf '\nDoctor found blocking problems.\n'
  exit 1
fi

if [[ "$WARN_COUNT" -gt 0 ]]; then
  printf '\nDoctor completed with warnings.\n'
else
  printf '\nDoctor completed successfully.\n'
fi
