---
description: "Slice the concept into feature briefs ready for /specify; optionally promote ADRs and generate a management summary"
---

# Discovery: Decompose into features

## User Input

$ARGUMENTS

## Goal

Turn the architecture concept + ADR(s) into one or more **feature slices** — each sized for a single `/specify` run. Each slice becomes the prose input for spec-kit's `/specify` on a fresh feature branch (created off `main`, not off the discovery branch).

Also wraps up discovery by optionally:
- promoting ADRs to `docs/adr/` (durable, non-spec-kit-aware view), and
- generating a management summary that synthesizes problem + options + decision + costs + plan into one shareable document.

Produces `04-features.md` (always) and `05-management-summary.md` (opt-in) in the current discovery directory.

## Steps

1. **Locate the discovery directory** by running the helper below. If `ON_DISCOVERY_BRANCH=no`, stop. Use `DISCOVERY_DIR` for the rest of this command.

2. **Read prior artifacts in `DISCOVERY_DIR`**: `01-problem.md`, `02-concept.md`, and any `03-adr-*.md` files. If `02-concept.md` is missing, stop and tell the user to run `/speckit.discovery.concept` first.

3. **Identify feature slices.** Use these heuristics:
   - Each slice should be implementable in roughly one focused work session (hours, not weeks).
   - Slices should have clear dependency ordering — note which depend on which.
   - Don't split *too* finely — a slice that's just a config flag flip is not a feature.
   - If `$ARGUMENTS` gives hints (e.g. "split by service" or "frontend first"), honor them.
   - It is acceptable to produce a single slice if the work is genuinely one feature.

4. **Draft `04-features.md`** using the template below. For each slice, write a **one-paragraph problem statement in `/specify`-ready prose** — this is the text the user will paste into `/specify` later. Fill the **Cost rollup** section by restating the chosen-option totals from the ADR(s) and splitting them across slices as effort shares (percentages), not re-estimated dollar figures. The slice shares must sum to 100%.

5. **Suggest the handoff sequence**: which slice to `/specify` first (typically the foundation / blocker), and in what order. The discovery branch should be merged to `main` first so concept + ADRs land in history before feature work begins.

6. **Offer ADR promotion to `docs/adr/`.** Ask the user **exactly once**:
   > *"Promote ADR(s) to `docs/adr/`? This copies them into the project's durable design-record directory with a project-wide number, leaving the discovery originals untouched. [y/N]"*

   - If **No** (default): skip.
   - If **Yes**:
     - List each `03-adr-MMM-<slug>.md` in `DISCOVERY_DIR`.
     - Compute the next project-wide ADR number `NNNN` = max numeric prefix of existing `docs/adr/*.md` files + 1, zero-padded to four digits. Start at `0001` if `docs/adr/` is empty or doesn't exist.
     - For each discovery ADR (in `MMM` order), copy to `docs/adr/NNNN-<slug>.md`, incrementing `NNNN` per file.
     - On copy, rewrite the first heading line from `# ADR MMM: <title>` to `# ADR NNNN: <title>` so the title matches the new filename, and append a footer line:
       ```
       ---
       > Promoted from `.specify/discovery/NNN-<discovery-slug>/03-adr-MMM-<slug>.md`.
       ```
     - Create `docs/adr/` if it doesn't exist.
     - Report each promoted path.

7. **Offer management summary generation.** Ask the user **exactly once**:
   > *"Generate a management summary (problem, options, decision, costs, plan in one shareable doc)? [y/N]"*

   - If **No** (default): skip both this step and step 8.
   - If **Yes**: draft `05-management-summary.md` in `DISCOVERY_DIR` using the template below. **Synthesize only — do not re-analyze or re-estimate.** Every figure must come from `02-concept.md` or `03-adr-*.md`; if a source field is missing or marked `[NEEDS CLARIFICATION]`, preserve the marker verbatim in the summary so it's obvious the figure isn't real.

8. **Offer summary promotion to `docs/management-summaries/`.** Only ask if step 7 produced a summary:
   > *"Also copy the summary to `docs/management-summaries/` so it can be shared outside the repo? [y/N]"*

   - If **No** (default): skip.
   - If **Yes**: copy `05-management-summary.md` to `docs/management-summaries/NNN-<discovery-slug>.md` (creating the directory if absent). The `NNN` here is the discovery number, not the ADR number — one summary per discovery. Report the path.

9. **Report to the user**:
   - `04-features.md` path and slice count.
   - Promoted ADR paths, if any.
   - Management summary path(s), if any.
   - Recommended next steps:
     - Merge the discovery branch to `main` (e.g. via PR). The `docs/adr/` and `docs/management-summaries/` copies, if any, ride along in the same merge.
     - From `main`, run `/specify <prose>` for the first slice.

## Helper

```bash
bash .specify/extensions/discovery/scripts/bash/discovery-context.sh
```

If `ON_DISCOVERY_BRANCH=yes`, also gather decompose-specific state:

```bash
ls -1 "$DISCOVERY_DIR" 2>/dev/null
ls -1 "$DISCOVERY_DIR"/03-adr-*.md 2>/dev/null || echo "(no ADRs in discovery)"
ls -1 docs/adr/*.md 2>/dev/null || echo "(docs/adr/ empty or absent)"
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

## Cost rollup
<Single source of truth: the chosen option's figures from the ADR(s). Do not re-estimate here. If multiple ADRs exist, sum or list per ADR as appropriate.>
- **Total build cost:** <€ range from ADR>
- **Total build effort:** <S/M/L/XL or N-M person-weeks from ADR>
- **Run cost:** <€ / month or year from ADR>
- **Confidence:** <from ADR>
- **Source ADR(s):** `03-adr-MMM-<slug>.md`<, ...>

### Effort share by slice
| Slice | Effort share | Cumulative | Notes |
|---|---|---|---|
| F1 | ~XX% | XX% | <one line> |
| F2 | ~XX% | XX% | ... |
| ... | ... | 100% | |

### Descope scenarios
<Optional. Useful if management asked "what if we ship less?" One row per realistic stopping point.>
- **F1 only:** delivers <value>; ~XX% of total build cost; defers <what>.
- **F1+F2 only:** delivers <value>; ~XX% of total build cost; defers <what>.

## Recommended sequence
1. <slice id> — <why first>
2. <slice id> — <why next>
3. ...

## Slices

### F1: <feature name>
- **Depends on:** none | F2, F3
- **Rough size:** S | M | L
- **Effort share:** ~XX% of total build effort
- **Specify prose** (paste into `/specify` after switching to `main` and creating a new branch):

  > <one-paragraph problem statement written in the imperative voice spec-kit's /specify expects. Mention the user, the desired behavior, and any constraints from the ADR(s).>

### F2: <feature name>
- **Depends on:** F1
- **Rough size:** S | M | L
- **Effort share:** ~XX%
- **Specify prose:**

  > ...

<repeat per slice>

## Handoff checklist
- [ ] Discovery branch merged to `main` (concept + ADRs land in history; promoted ADRs / summary ride along).
- [ ] `/specify` run for F1 from `main` (creates spec-kit's own feature branch).
- [ ] Subsequent slices follow once their dependencies merge.
```

## Template: `05-management-summary.md`

```markdown
# Management summary: <discovery title>

**Status:** Discovery complete
**Date:** <YYYY-MM-DD>
**Discovery branch:** discovery/NNN-<slug>
**Promoted ADR(s):** `docs/adr/NNNN-<slug>.md`<, ...> *(or "not promoted" if step 6 was declined)*

## TL;DR
<3-5 sentences: what problem we're solving, what we decided, total cost/effort, expected outcome.>

## The problem
<2-3 paragraphs lifted/condensed from `01-problem.md`. Plain language — no internal jargon.>

## Options considered
<Carry the candidate-approaches table from `02-concept.md` verbatim. Do not re-estimate.>

| | Option A | Option B | Option C |
|---|---|---|---|
| Name | ... | ... | ... |
| Effort (build) | ... | ... | ... |
| Build cost | ... | ... | ... |
| Run cost | ... | ... | ... |
| Risk | ... | ... | ... |
| Reversibility | ... | ... | ... |
| Confidence | ... | ... | ... |

## Decision
<1-2 paragraphs lifted from the ADR's Decision section, plus a one-sentence rationale lifted from "Recommended direction" in the concept or the ADR's Context. Cite the ADR path.>

## Cost & effort (chosen option)
<Verbatim from the ADR's Cost & effort section.>
- **Effort (build):** ...
- **Build cost:** ...
- **Run cost:** ...
- **Confidence:** ...
- **Estimation assumptions:** ...

## Implementation plan
<Lift the Recommended sequence + Effort share table from `04-features.md`.>

### Phasing
1. <Slice F1> — ~XX% of build cost — <one-line outcome>
2. <Slice F2> — ~XX% — ...
3. ...

### Descope scenarios *(if any)*
- **Minimum viable:** <which slices, what % of cost, what we get>
- **Recommended scope:** <which slices, what % of cost, what we get>

## Risks and caveats
<Lift from the ADR's Consequences > Negative bullet and the concept's risk column for the chosen option. Plain language.>

- ...
- ...

## Open questions
<Any [NEEDS CLARIFICATION: ...] markers present in source docs at time of summary. Don't paper over them — preserve verbatim so the reader knows what isn't pinned down yet.>

## Source documents
- Problem brief: `.specify/discovery/NNN-<slug>/01-problem.md`
- Architecture concept: `.specify/discovery/NNN-<slug>/02-concept.md`
- ADR(s): `.specify/discovery/NNN-<slug>/03-adr-*.md` *(promoted to `docs/adr/` if applicable)*
- Feature decomposition: `.specify/discovery/NNN-<slug>/04-features.md`
```

## Notes

- If a slice's `/specify` prose still contains `[NEEDS CLARIFICATION]` markers, point this out in the report. Suggest running `/speckit.discovery.clarify` first or accepting that `/specify` will surface them via its own `/clarify` step.
- ADR promotion to `docs/adr/` is a **copy**, not a move. The originals in `.specify/discovery/` remain the working record; `docs/adr/` is the durable, non-spec-kit-aware view. If a discovery ADR is later amended, the user is responsible for re-running this command (or hand-editing the promoted copy).
- The management summary is **synthesis only**. Every figure in it must trace back to `02-concept.md` or `03-adr-*.md`. If you're tempted to add analysis that isn't already in those documents, that analysis belongs in the source documents first — go back and edit them.
- This command is **read-only with respect to git** — it does not switch branches, merge, or create the feature branches. The user controls the merge and the per-feature `/specify` invocations.
