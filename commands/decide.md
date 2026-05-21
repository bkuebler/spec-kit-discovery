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

1. **Locate the discovery directory** by running the helper below. If `ON_DISCOVERY_BRANCH=no`, stop. `02-concept.md` should exist in `DISCOVERY_DIR`; if not, warn but allow proceeding (some decisions don't need a full concept doc).

2. **Determine the decision**:
   - If `$ARGUMENTS` describes the decision in prose: use it as the seed.
   - Else: read `02-concept.md`'s "Recommended direction" section and propose that as the decision; confirm with the user.
   - If the user wants a different decision than the concept recommended, accept it and note the divergence in the ADR's Context section.

3. **Generate a short decision slug** for the filename (e.g. `use-postgres-over-mongo`, 3-5 hyphenated words). Confirm with the user.

4. **Compute `MMM`** as max of existing `03-adr-*` filenames in the discovery directory, + 1, zero-padded to three digits. Start at `001`.

5. **Draft `03-adr-MMM-<slug>.md`** using the template below. Pre-fill from concept + arguments; mark unknowns with `[NEEDS CLARIFICATION: ...]`. If `02-concept.md` contains a candidate-approaches table with effort/cost figures, carry the chosen option's row into the ADR's **Cost & effort** section verbatim, and carry each rejected option's effort/cost one-liner into **Alternatives considered**. If those figures are missing from the concept, mark them as clarifications — don't invent numbers in the ADR.

6. **Constitution promotion (opt-in).** After writing the ADR, ask the user **exactly once**:
   > *"Does this decision establish a **project-wide rule** that future features must respect? [y/N]"*

   - If **No** (default): skip promotion. Done.
   - If **Yes**:
     - Extract the rule(s) as 1-3 short bullets in imperative voice (e.g. "All persistent state must use Postgres; new services must not introduce other relational stores.").
     - Show the bullets to the user; accept edits.
     - Append (don't replace) to `.specify/memory/constitution.md` under a section heading `## Decisions promoted from ADRs` (create the section if absent). Each bullet ends with `(see <path-to-adr-file>)`.
     - If `.specify/memory/constitution.md` doesn't exist, tell the user and offer to create it with just this section.

7. **Report to the user**: ADR path, whether constitution was updated (and which file), and the count of `[NEEDS CLARIFICATION]` markers in the ADR (if any). Suggest `/speckit.discovery.clarify` if markers were introduced; otherwise suggest `/speckit.discovery.decompose` as the typical next step.

## Helper

```bash
bash .specify/extensions/discovery/scripts/bash/discovery-context.sh
```

If `ON_DISCOVERY_BRANCH=yes`, also gather ADR-specific state:

```bash
ls -1 "$DISCOVERY_DIR"/03-adr-*.md 2>/dev/null || echo "(no existing ADRs)"
test -f .specify/memory/constitution.md && echo "CONSTITUTION_PRESENT=yes" || echo "CONSTITUTION_PRESENT=no"
```

(Substitute the literal value of `DISCOVERY_DIR` from the first script's output.)

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

## Cost & effort
<Carry the chosen option's row from the concept's candidate-approaches table. If the concept didn't capture these, mark each line as [NEEDS CLARIFICATION: ...] rather than inventing numbers.>
- **Effort (build):** <S/M/L/XL or N-M person-weeks>
- **Build cost:** <€ range>
- **Run cost:** <€ / month or year>
- **Confidence:** <low / med / high>
- **Estimation assumptions:** <inline the key inputs the figures depend on (team size, blended rate, infra unit costs, time horizon), or reference `02-concept.md`'s Estimation assumptions section if unchanged>

## Alternatives considered
- **<Option B name>** — *effort: ..., build: €..., run: €.../mo* — rejected because ...
- **<Option C name>** — *effort: ..., build: €..., run: €.../mo* — rejected because ...

## Consequences
- **Positive:** ...
- **Negative / costs:** <non-monetary downsides — monetary costs go in Cost & effort above>
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
