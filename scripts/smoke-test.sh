#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
PROJECT_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd -P)"
CHANGE="starter-smoke-test-$$"
CHANGE_DIR="$PROJECT_ROOT/openspec/changes/$CHANGE"

PASS_COUNT=0

pass() {
  PASS_COUNT=$((PASS_COUNT + 1))
  printf '[PASS] %s\n' "$*"
}

fail() {
  printf '[FAIL] %s\n' "$*" >&2
  exit 1
}

cleanup() {
  if [[ -d "$CHANGE_DIR" ]]; then
    rm -rf -- "$CHANGE_DIR"
  fi
}

json_assert() {
  local description="$1"
  local json="$2"
  local expression="$3"
  shift 3

  if printf '%s' "$json" | python3 -c '
import json
import sys

data = json.load(sys.stdin)
expression = sys.argv[1]
args = sys.argv[2:]

ok = eval(
    expression,
    {"__builtins__": {}},
    {
        "data": data,
        "args": args,
        "any": any,
        "all": all,
        "bool": bool,
        "len": len,
    },
)

raise SystemExit(0 if ok else 1)
' "$expression" "$@"
  then
    pass "$description"
  else
    fail "$description"
  fi
}

trap cleanup EXIT INT TERM

cd "$PROJECT_ROOT"

printf 'AI OpenSpec Starter Smoke Test\n'
printf 'Project: %s\n' "$PROJECT_ROOT"
printf 'Change : %s\n\n' "$CHANGE"

command -v openspec >/dev/null 2>&1 ||
  fail "openspec is not available in PATH"

command -v python3 >/dev/null 2>&1 ||
  fail "python3 is required"

[[ ! -e "$CHANGE_DIR" ]] ||
  fail "Temporary change already exists: $CHANGE"

# ------------------------------------------------------------
# 1. OpenSpec root
# ------------------------------------------------------------

LIST_JSON="$(openspec list --json)"

json_assert \
  "OpenSpec root matches this project" \
  "$LIST_JSON" \
  '(data.get("root") or {}).get("path") == args[0]' \
  "$PROJECT_ROOT"

# ------------------------------------------------------------
# 2. Create temporary change
# ------------------------------------------------------------

openspec new change "$CHANGE" >/dev/null

[[ -d "$CHANGE_DIR" ]] ||
  fail "OpenSpec did not create the temporary change"

pass "Temporary change created"

STATUS_JSON="$(openspec status --change "$CHANGE" --json)"

json_assert \
  "Schema is spec-driven" \
  "$STATUS_JSON" \
  'data.get("schemaName") == "spec-driven"'

json_assert \
  "Proposal starts ready" \
  "$STATUS_JSON" \
  'any(a.get("id") == "proposal" and a.get("status") == "ready" for a in data.get("artifacts", []))'

# ------------------------------------------------------------
# 3. Proposal rule injection
# ------------------------------------------------------------

PROPOSAL_JSON="$(openspec instructions proposal --change "$CHANGE" --json)"

json_assert \
  "Proposal receives project context" \
  "$PROPOSAL_JSON" \
  'bool(data.get("context"))'

json_assert \
  "Proposal receives proposal.md rule" \
  "$PROPOSAL_JSON" \
  '"Read and follow docs/rules/proposal.md." in data.get("rules", [])'

cat > "$CHANGE_DIR/proposal.md" <<'DOC'
# Proposal

## Why

Validate that the starter OpenSpec workflow and rule injection work end to end.

## What Changes

- Add a temporary smoke-test capability used only for validating the starter workflow.

## Capabilities

### New Capabilities

- `starter-smoke`: Temporary capability for exercising the starter workflow.

### Modified Capabilities

None.

## Impact

Only temporary smoke-test artifacts created for this validation.
DOC

pass "Proposal artifact created"

# ------------------------------------------------------------
# 4. Specs and Design
# ------------------------------------------------------------

STATUS_JSON="$(openspec status --change "$CHANGE" --json)"

json_assert \
  "Specs unlock after proposal" \
  "$STATUS_JSON" \
  'any(a.get("id") == "specs" and a.get("status") == "ready" for a in data.get("artifacts", []))'

json_assert \
  "Design unlocks after proposal" \
  "$STATUS_JSON" \
  'any(a.get("id") == "design" and a.get("status") == "ready" for a in data.get("artifacts", []))'

SPECS_JSON="$(openspec instructions specs --change "$CHANGE" --json)"

json_assert \
  "Specs receives specs.md rule" \
  "$SPECS_JSON" \
  '"Read and follow docs/rules/specs.md." in data.get("rules", [])'

DESIGN_JSON="$(openspec instructions design --change "$CHANGE" --json)"

json_assert \
  "Design receives design.md rule" \
  "$DESIGN_JSON" \
  '"Read and follow docs/rules/design.md." in data.get("rules", [])'

mkdir -p "$CHANGE_DIR/specs/starter-smoke"

cat > "$CHANGE_DIR/specs/starter-smoke/spec.md" <<'DOC'
# Spec Delta

## Purpose

Provides a temporary capability used to verify the starter OpenSpec workflow from planning through validation.

## ADDED Requirements

### Requirement: Smoke-test capability can be validated
The system SHALL provide a temporary smoke-test artifact that can be validated through the OpenSpec workflow.

#### Scenario: Validate smoke-test change
- **WHEN** the temporary smoke-test change is validated
- **THEN** OpenSpec accepts its specification structure
DOC

cat > "$CHANGE_DIR/design.md" <<'DOC'
# Design

## Context

This change exists only to exercise the starter OpenSpec workflow.

## Goals / Non-Goals

**Goals:**
- Verify that planning artifacts can progress through the workflow.
- Keep smoke-test content isolated to this temporary change.

**Non-Goals:**
- No production implementation.
- No external dependencies.
- No persistent project behavior.

## Decisions

Use only temporary OpenSpec artifacts and avoid modifying project source code.

## Risks / Trade-offs

- Temporary artifacts could be mistaken for real project work → remove them after validation.
DOC

pass "Specs and Design artifacts created"

# ------------------------------------------------------------
# 5. Tasks
# ------------------------------------------------------------

STATUS_JSON="$(openspec status --change "$CHANGE" --json)"

json_assert \
  "Tasks unlock after Specs and Design" \
  "$STATUS_JSON" \
  'any(a.get("id") == "tasks" and a.get("status") == "ready" for a in data.get("artifacts", []))'

TASKS_JSON="$(openspec instructions tasks --change "$CHANGE" --json)"

json_assert \
  "Tasks receives tasks.md rule" \
  "$TASKS_JSON" \
  '"Read and follow docs/rules/tasks.md." in data.get("rules", [])'

cat > "$CHANGE_DIR/tasks.md" <<EOF_TASKS
# Tasks

## 1. Smoke Validation

- [ ] 1.1 Validate the temporary OpenSpec change with \`openspec validate $CHANGE --strict\` and verify the command succeeds without modifying production source code.
EOF_TASKS

pass "Tasks artifact created"

# ------------------------------------------------------------
# 6. Apply guidance
# ------------------------------------------------------------

APPLY_JSON="$(openspec instructions apply --change "$CHANGE" --json)"

json_assert \
  "Apply state is ready" \
  "$APPLY_JSON" \
  'data.get("state") == "ready"'

json_assert \
  "Apply sees one pending task" \
  "$APPLY_JSON" \
  'data.get("progress", {}).get("total") == 1 and data.get("progress", {}).get("remaining") == 1'

json_assert \
  "Apply receives apply.md guidance" \
  "$APPLY_JSON" \
  '"When implementing tasks, read and follow docs/rules/apply.md." in data.get("operationGuidance", [])'

# ------------------------------------------------------------
# 7. Strict validation
# ------------------------------------------------------------

openspec validate "$CHANGE" --strict >/dev/null

pass "Strict OpenSpec validation succeeds"

python3 - "$CHANGE_DIR/tasks.md" <<'PY'
from pathlib import Path
import sys

p = Path(sys.argv[1])
text = p.read_text()

old = "- [ ] 1.1"
new = "- [x] 1.1"

if old not in text:
    raise SystemExit("Smoke task checkbox not found")

p.write_text(text.replace(old, new, 1))
PY

pass "Smoke task marked complete"

APPLY_DONE_JSON="$(openspec instructions apply --change "$CHANGE" --json)"

json_assert \
  "Apply reaches all_done" \
  "$APPLY_DONE_JSON" \
  'data.get("state") == "all_done"'

json_assert \
  "Apply progress reaches 1/1" \
  "$APPLY_DONE_JSON" \
  'data.get("progress", {}).get("complete") == 1 and data.get("progress", {}).get("remaining") == 0'

# ------------------------------------------------------------
# 8. Archive guidance
# ------------------------------------------------------------

ARCHIVE_JSON="$(openspec instructions archive --change "$CHANGE" --json)"

json_assert \
  "Archive receives archive.md guidance" \
  "$ARCHIVE_JSON" \
  '"Read and follow docs/rules/archive.md before archiving a change." in data.get("operationGuidance", [])'

# ------------------------------------------------------------
# 9. Native Verify boundary
# ------------------------------------------------------------

VERIFY_FILE="$PROJECT_ROOT/.agents/skills/openspec-verify-change/SKILL.md"

[[ -f "$VERIFY_FILE" ]] ||
  fail "Generated native Verify workflow is missing"

grep -Fq 'openspec instructions apply' "$VERIFY_FILE" ||
  fail "Native Verify no longer uses apply instructions as expected"

pass "Native Verify uses apply instructions"

if grep -Fq 'docs/rules/verify.md' "$VERIFY_FILE"; then
  fail "Native Verify falsely references custom docs/rules/verify.md"
fi

pass "Native Verify does not claim custom verify.md injection"

if grep -Fq 'operationGuidance' "$VERIFY_FILE"; then
  fail "Native Verify unexpectedly consumes operationGuidance"
fi

pass "Native Verify does not consume operationGuidance"

# ------------------------------------------------------------
# 10. Cleanup
# ------------------------------------------------------------

cleanup
trap - EXIT INT TERM

[[ ! -e "$CHANGE_DIR" ]] ||
  fail "Temporary smoke-test change was not removed"

pass "Temporary change removed"

FINAL_LIST_JSON="$(openspec list --json)"

json_assert \
  "Temporary change is absent after cleanup" \
  "$FINAL_LIST_JSON" \
  'all(c.get("name") != args[0] for c in data.get("changes", []))' \
  "$CHANGE"

printf '\nSmoke test complete.\n'
printf 'PASS: %d\n' "$PASS_COUNT"
printf 'FAIL: 0\n'
