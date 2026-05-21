---
description: "Slice the concept into feature briefs ready for /specify"
---

# Discovery: Decompose into features

## User Input

$ARGUMENTS

## Goal

Turn the architecture concept + ADR(s) into one or more **feature slices** — each sized for a single `/specify` run. Each slice becomes the prose input for spec-kit's `/specify` on a fresh feature branch (created off `main`, not off the discovery branch).

Produces `04-features.md` in the current discovery directory.

## Steps

1. **Locate the discovery directory** by running the helper below. If `ON_DISCOVERY_BRANCH=no`, stop. Use `DISCOVERY_DIR` for the rest of this command.

2. **Read prior artifacts in `DISCOVERY_DIR`**: `01-problem.md`, `02-concept.md`, and any `03-adr-*.md` files. If `02-concept.md` is missing, stop and tell the user to run `/speckit.discovery.concept` first.

3. **Identify feature slices.** Use these heuristics:
   - Each slice should be implementable in roughly one focused work session (hours, not weeks).
   - Slices should have clear dependency ordering — note which depend on which.
   - Don't split *too* finely — a slice that's just a config flag flip is not a feature.
   - If `$ARGUMENTS` gives hints (e.g. "split by service" or "frontend first"), honor them.
   - It is acceptable to produce a single slice if the work is genuinely one feature.

4. **Draft `04-features.md`** using the template below. For each slice, write a **one-paragraph problem statement in `/specify`-ready prose** — this is the text the user will paste into `/specify` later.

5. **Suggest the handoff sequence**: which slice to `/specify` first (typically the foundation / blocker), and in what order. The discovery branch should be merged to `main` first so concept + ADRs land in history before feature work begins.

6. **Report to the user**: artifact path, number of slices, recommended next steps:
   - Merge the discovery branch to `main` (e.g. via PR).
   - From `main`, run `/specify <prose>` for the first slice.

## Helper

```bash
bash .specify/extensions/discovery/scripts/bash/discovery-context.sh
```

If `ON_DISCOVERY_BRANCH=yes`, also list the existing artifacts:

```bash
ls -1 "$DISCOVERY_DIR" 2>/dev/null
```

(Substitute the literal value of `DISCOVERY_DIR` from the first script's output.)

## Template: `04-features.md`

```markdown
# Feature decomposition

**Status:** Discovery complete (pending handoff)
**Branch:** discovery/NNN-<slug>
**Created:** <YYYY-MM-DD>

## Overview
<2-3 sentence summary of the decomposition strategy>

## Recommended sequence
1. <slice id> — <why first>
2. <slice id> — <why next>
3. ...

## Slices

### F1: <feature name>
- **Depends on:** none | F2, F3
- **Rough size:** S | M | L
- **Specify prose** (paste into `/specify` after switching to `main` and creating a new branch):

  > <one-paragraph problem statement written in the imperative voice spec-kit's /specify expects. Mention the user, the desired behavior, and any constraints from the ADR(s).>

### F2: <feature name>
- **Depends on:** F1
- **Rough size:** S | M | L
- **Specify prose:**

  > ...

<repeat per slice>

## Handoff checklist
- [ ] Discovery branch merged to `main` (concept + ADRs live in history).
- [ ] `/specify` run for F1 from `main` (creates spec-kit's own feature branch).
- [ ] Subsequent slices follow once their dependencies merge.
```

## Notes

- If a slice's `/specify` prose still contains `[NEEDS CLARIFICATION]` markers, point this out in the report. Suggest running `/speckit.discovery.clarify` first or accepting that `/specify` will surface them via its own `/clarify` step.
- This command is **read-only with respect to git** — it does not switch branches, merge, or create the feature branches. The user controls the merge and the per-feature `/specify` invocations.
