---
description: "Draft an architecture concept: context, options, sketch, open questions"
---

# Discovery: Architecture Concept

## User Input

$ARGUMENTS

## Goal

Turn the problem brief into a working architecture concept. Folds in context, constraints, candidate approaches, and a recommended direction — but does not yet commit (that happens in `/speckit.discovery.decide`).

Produces `02-concept.md` in the current discovery directory.

## Steps

1. **Locate the discovery context** by running the helper below. If `ON_DISCOVERY_BRANCH=no`, stop and tell the user to run `/speckit.discovery.problem` first. Otherwise use `DISCOVERY_DIR` as the working directory for the rest of this command.

2. **Read `$DISCOVERY_DIR/01-problem.md`** to ground the concept in the captured problem. If it does not exist, stop and tell the user to run `/speckit.discovery.problem`.

3. **Draft `02-concept.md`** using the template below.
   - Use `$ARGUMENTS` as guidance / hints if provided.
   - Where the problem brief or arguments give clear signal, write the section.
   - Where they don't, write `[NEEDS CLARIFICATION: <specific question>]`.
   - For **candidate approaches**: propose 2-3 distinct options. Do not collapse them prematurely. For each, fill effort / build cost / run cost / risk / reversibility honestly; mark unknowns. Effort is a T-shirt size (S/M/L/XL) or person-week range; costs are ranges, not point estimates. State confidence (low/medium/high) — rough is fine, false precision is not.
   - For **estimation assumptions**: capture the inputs your effort/cost figures depend on (team size, blended rate, infra unit costs, capacity available). If unknown, mark `[NEEDS CLARIFICATION: ...]` — these drive the numbers, so missing inputs mean the numbers are placeholders.
   - For **recommended direction**: state which option you'd pursue and why, in 2-3 sentences, explicitly weighing the effort/cost trade. If you can't pick honestly, say so and mark `[NEEDS CLARIFICATION: which option fits best?]`.

4. **Report to the user**: artifact path, count of clarification markers, and next-step options:
   - `/speckit.discovery.clarify` to resolve markers, or
   - `/speckit.discovery.decide` to lock the recommended approach into an ADR.

## Helper

```bash
bash .specify/extensions/discovery/scripts/bash/discovery-context.sh
```

Relevant keys: `ON_DISCOVERY_BRANCH`, `DISCOVERY_DIR`. If `ON_DISCOVERY_BRANCH=no`, stop and tell the user to run `/speckit.discovery.problem` first.

## Template: `02-concept.md`

```markdown
# Architecture Concept: <title>

**Status:** Discovery
**Branch:** discovery/NNN-<slug>
**Updated:** <today's date YYYY-MM-DD>

## Context
<systems touched, current state, why now, or [NEEDS CLARIFICATION: ...]>

## Constraints
- **Compliance / regulatory:** ...
- **Performance / scale:** ...
- **Budget / timeline:** ...
- **Team skills:** ...
- **Existing stack alignment:** ...
<replace any that are unknown with [NEEDS CLARIFICATION: ...]>

## Estimation assumptions
<Inputs the effort/cost figures below depend on. Mark unknowns with [NEEDS CLARIFICATION: ...].>
- **Team / capacity:** <e.g. 2 engineers, ~60% allocation>
- **Blended rate:** <e.g. €800/day, or "internal — no chargeback">
- **Infra unit costs:** <e.g. cloud provider, license tier, per-seat SaaS pricing>
- **Time horizon for run cost:** <e.g. annualized, first 12 months>
- **Other:** <anything else the numbers hinge on>

## Candidate approaches

| | Option A | Option B | Option C *(optional)* |
|---|---|---|---|
| **Name** | ... | ... | ... |
| **Effort (build)** | S/M/L/XL or N-M person-weeks | ... | ... |
| **Build cost** | € range | ... | ... |
| **Run cost** | € / month or year | ... | ... |
| **Risk** | low / med / high — one-line why | ... | ... |
| **Reversibility** | easy / hard / one-way | ... | ... |
| **Confidence** | low / med / high | ... | ... |

### Option A: <name>
- **Summary:** ...
- **Notes on estimate:** <what drives the effort/cost, what could blow it up>

### Option B: <name>
- **Summary:** ...
- **Notes on estimate:** ...

### Option C: <name> (optional)
- **Summary:** ...
- **Notes on estimate:** ...

## Recommended direction
<which option and why, 2-3 sentences. Explicitly weigh effort/cost against risk and reversibility — the cheapest option is not always the right one. Or [NEEDS CLARIFICATION: which fits best?]>

## Architecture sketch
<ASCII / mermaid / prose description of major components and flows>

## Open questions
- [NEEDS CLARIFICATION: ...]
- ...

## Out of scope for this discovery
<things we'll defer to later discoveries or feature specs>
```
