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

1. **Locate the discovery context** with the helper below. The current branch must match `^discovery/[0-9]+-`. If not, stop and tell the user to run `/speckit.discovery.problem` first.

2. **Read `01-problem.md`** to ground the concept in the captured problem. If it does not exist, stop and tell the user to run `/speckit.discovery.problem`.

3. **Draft `02-concept.md`** using the template below.
   - Use `$ARGUMENTS` as guidance / hints if provided.
   - Where the problem brief or arguments give clear signal, write the section.
   - Where they don't, write `[NEEDS CLARIFICATION: <specific question>]`.
   - For **candidate approaches**: propose 2-3 distinct options. Do not collapse them prematurely. For each, fill cost / risk / reversibility honestly; mark unknowns.
   - For **recommended direction**: state which option you'd pursue and why, in 2-3 sentences. If you can't pick honestly, say so and mark `[NEEDS CLARIFICATION: which option fits best?]`.

4. **Report to the user**: artifact path, count of clarification markers, and next-step options:
   - `/speckit.discovery.clarify` to resolve markers, or
   - `/speckit.discovery.decide` to lock the recommended approach into an ADR.

## Helper

```bash
current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
echo "CURRENT_BRANCH=$current_branch"
if [[ "$current_branch" =~ ^discovery/[0-9]+- ]]; then
  suffix="${current_branch#discovery/}"
  echo "DISCOVERY_DIR=.specify/discovery/$suffix"
  ls -la ".specify/discovery/$suffix" 2>/dev/null || echo "(directory not found)"
fi
```

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

## Candidate approaches

### Option A: <name>
- **Summary:** ...
- **Cost:** ...
- **Risk:** ...
- **Reversibility:** ...

### Option B: <name>
- **Summary:** ...
- **Cost:** ...
- **Risk:** ...
- **Reversibility:** ...

### Option C: <name> (optional)
- **Summary:** ...
- **Cost:** ...
- **Risk:** ...
- **Reversibility:** ...

## Recommended direction
<which option and why, 2-3 sentences, or [NEEDS CLARIFICATION: which fits best?]>

## Architecture sketch
<ASCII / mermaid / prose description of major components and flows>

## Open questions
- [NEEDS CLARIFICATION: ...]
- ...

## Out of scope for this discovery
<things we'll defer to later discoveries or feature specs>
```
