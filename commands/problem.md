---
description: "Capture a problem brief and bootstrap a discovery branch"
---

# Discovery: Problem Brief

## User Input

$ARGUMENTS

## Goal

Capture the problem this work is meant to solve, **before** any `/specify`-level commitment. Produces `01-problem.md` on a fresh `discovery/NNN-<slug>` branch.

## Steps

1. **Inspect repo state** by running the helper bash block below. Read its output before proceeding.

2. **Refuse if `IN_GIT_REPO=no`** — tell the user this command requires a git repository and stop.

3. **Refuse if `WORKING_TREE_DIRTY=yes`.** Tell the user to commit or stash, then stop. Do not create branches, do not write files.

4. **Detect idempotent re-run.** If `ON_DISCOVERY_BRANCH=yes` AND the user's `$ARGUMENTS` (if any) looks like a refinement of the existing problem (not a wholly new problem), treat this as a re-draft:
   - Reuse `DISCOVERY_DIR` from the helper output.
   - Skip steps 5-8. Jump to step 9 and overwrite `01-problem.md`.

5. **Generate a slug** from `$ARGUMENTS`:
   - 3-5 words, lowercase, hyphenated, no stopwords, no punctuation.
   - Example: *"we need to replace the legacy auth middleware that stores session tokens insecurely"* -> `legacy-auth-replacement`.
   - If `$ARGUMENTS` is empty, ask the user for one sentence describing the problem and derive from that.

6. **Confirm the slug with the user.** Show it; accept an edit; do not silently proceed.

7. **Read `NEXT_NUMBER`** from the helper output — this is the zero-padded `NNN` to use for the new discovery. The script already computes max across local branches, remote branches, and existing dirs.

8. **Create the discovery branch.**
   - If `CURRENT_BRANCH` is `main` or `master`: switch silently.
   - If on any other branch: confirm with the user before switching away.
   - `git switch -c discovery/<NEXT_NUMBER>-<slug>` (or `git checkout -b ...`).

9. **Create / overwrite the artifact directory and file.**
   - `mkdir -p .specify/discovery/<NEXT_NUMBER>-<slug>/`
   - Write `01-problem.md` using the template below. Pre-fill from `$ARGUMENTS`. Every section the prose does not directly answer gets a `[NEEDS CLARIFICATION: <specific question>]` marker.
   - If `$ARGUMENTS` is empty, emit the pure template with every section marked.

10. **Report to the user**: branch name, artifact path, and the next command (`/speckit.discovery.concept`). Mention that `/speckit.discovery.clarify` can resolve `[NEEDS CLARIFICATION]` markers later.

## Helper

Run the shared context script and parse its `KEY=value` output. The script also emits three lists between `BEGIN_*` / `END_*` sentinels.

```bash
bash .specify/extensions/discovery/scripts/bash/discovery-context.sh
```

Relevant keys for this command: `IN_GIT_REPO`, `WORKING_TREE_DIRTY`, `CURRENT_BRANCH`, `ON_DISCOVERY_BRANCH`, `DISCOVERY_SUFFIX`, `DISCOVERY_DIR`, `NEXT_NUMBER`. The sentinel-delimited lists are informational — `NEXT_NUMBER` already incorporates them.

## Template: `01-problem.md`

```markdown
# Problem Brief: <human-readable title derived from slug>

**Status:** Discovery
**Branch:** discovery/NNN-<slug>
**Created:** <today's date YYYY-MM-DD>

## Problem statement
<one paragraph from $ARGUMENTS, or [NEEDS CLARIFICATION: what problem are we solving?]>

## Affected users / stakeholders
<who feels the pain — roles, teams, customer segments, or [NEEDS CLARIFICATION: who is affected and how?]>

## Evidence it matters
<incidents, metrics, requests, complaints, deadlines, or [NEEDS CLARIFICATION: what evidence justifies doing this now?]>

## Non-goals
<things explicitly NOT solved here, or [NEEDS CLARIFICATION: what is out of scope?]>

## Success signals
<observable indicators of success, or [NEEDS CLARIFICATION: how will we know it worked?]>

## Notes
<anything else worth capturing — links, prior attempts, related tickets>
```
