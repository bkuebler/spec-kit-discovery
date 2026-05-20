---
description: "Write an ADR locking the chosen approach; optionally promote rules to the constitution"
---

# Discovery: Decide (write an ADR)

## User Input

$ARGUMENTS

## Goal

Lock the chosen approach by writing an Architecture Decision Record. ADRs are the durable artifact of discovery — they're what you'll re-read in six months to remember *why* you chose what you chose.

Produces `03-adr-MMM-<slug>.md` in the current discovery directory, where `MMM` is the next ADR number within that directory (multiple ADRs per discovery are allowed). Optionally promotes rules to `.specify/memory/constitution.md`.

## Steps

1. **Locate the discovery directory** with the helper below. Must be on a `discovery/*` branch. `02-concept.md` should exist; if not, warn but allow proceeding (some decisions don't need a full concept doc).

2. **Determine the decision**:
   - If `$ARGUMENTS` describes the decision in prose: use it as the seed.
   - Else: read `02-concept.md`'s "Recommended direction" section and propose that as the decision; confirm with the user.
   - If the user wants a different decision than the concept recommended, accept it and note the divergence in the ADR's Context section.

3. **Generate a short decision slug** for the filename (e.g. `use-postgres-over-mongo`, 3-5 hyphenated words). Confirm with the user.

4. **Compute `MMM`** as max of existing `03-adr-*` filenames in the discovery directory, + 1, zero-padded to three digits. Start at `001`.

5. **Draft `03-adr-MMM-<slug>.md`** using the template below. Pre-fill from concept + arguments; mark unknowns with `[NEEDS CLARIFICATION: ...]`.

6. **Constitution promotion (opt-in).** After writing the ADR, ask the user **exactly once**:
   > *"Does this decision establish a **project-wide rule** that future features must respect? [y/N]"*

   - If **No** (default): skip promotion. Done.
   - If **Yes**:
     - Extract the rule(s) as 1-3 short bullets in imperative voice (e.g. "All persistent state must use Postgres; new services must not introduce other relational stores.").
     - Show the bullets to the user; accept edits.
     - Append (don't replace) to `.specify/memory/constitution.md` under a section heading `## Decisions promoted from ADRs` (create the section if absent). Each bullet ends with `(see <path-to-adr-file>)`.
     - If `.specify/memory/constitution.md` doesn't exist, tell the user and offer to create it with just this section.

7. **Report to the user**: ADR path, whether constitution was updated (and which file), suggested next command (`/speckit.discovery.decompose`).

## Helper

```bash
current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
if [[ ! "$current_branch" =~ ^discovery/[0-9]+- ]]; then
  echo "NOT_ON_DISCOVERY_BRANCH"
  exit 0
fi
suffix="${current_branch#discovery/}"
dir=".specify/discovery/$suffix"
echo "DISCOVERY_DIR=$dir"
echo "--- existing ADRs ---"
ls -1 "$dir"/03-adr-*.md 2>/dev/null || echo "(none)"
echo "--- constitution present ---"
test -f .specify/memory/constitution.md && echo yes || echo no
```

## Template: `03-adr-MMM-<slug>.md`

```markdown
# ADR MMM: <human-readable decision title>

**Status:** Accepted
**Date:** <YYYY-MM-DD>
**Discovery branch:** discovery/NNN-<discovery-slug>

## Context
<why we needed to decide, what was unclear, what constraints applied — 1-3 paragraphs>

## Decision
<the chosen approach, stated clearly and concretely — 1 paragraph>

## Alternatives considered
- **<Option B name>** — rejected because ...
- **<Option C name>** — rejected because ...

## Consequences
- **Positive:** ...
- **Negative / costs:** ...
- **Follow-up work:** ...

## Notes
<links, references, related ADRs>
```

## Constitution append format

If the user opts into promotion, append to `.specify/memory/constitution.md`:

```markdown
## Decisions promoted from ADRs

- <imperative rule sentence> (see .specify/discovery/NNN-<slug>/03-adr-MMM-<slug>.md)
- <next rule, if any> (see .specify/discovery/NNN-<slug>/03-adr-MMM-<slug>.md)
```

Only append the rule sentences. Do **not** copy the full ADR into the constitution — the back-link is enough.
