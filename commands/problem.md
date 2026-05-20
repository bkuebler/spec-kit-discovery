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

2. **Refuse if working tree is dirty.** Tell the user to commit or stash, then stop. Do not create branches, do not write files.

3. **Detect idempotent re-run.** If the current branch matches `^discovery/[0-9]+-` AND the user's `$ARGUMENTS` (if any) looks like a refinement of the existing problem (not a wholly new problem), treat this as a re-draft:
   - Reuse the current branch and its `.specify/discovery/<branch-suffix>/` directory.
   - Skip steps 4-7. Jump to step 8 and overwrite `01-problem.md`.

4. **Generate a slug** from `$ARGUMENTS`:
   - 3-5 words, lowercase, hyphenated, no stopwords, no punctuation.
   - Example: *"we need to replace the legacy auth middleware that stores session tokens insecurely"* -> `legacy-auth-replacement`.
   - If `$ARGUMENTS` is empty, ask the user for one sentence describing the problem and derive from that.

5. **Confirm the slug with the user.** Show it; accept an edit; do not silently proceed.

6. **Compute `NNN`** as max(local `discovery/*` branches, remote `discovery/*` branches, existing `.specify/discovery/*/` directory names) + 1, zero-padded to three digits. Start at `001`.

7. **Create the discovery branch.**
   - If currently on `main`/`master`: switch silently.
   - If on any other branch: confirm with the user before switching away.
   - `git switch -c discovery/NNN-<slug>` (or `git checkout -b ...`).

8. **Create / overwrite the artifact directory and file.**
   - `mkdir -p .specify/discovery/NNN-<slug>/`
   - Write `01-problem.md` using the template below. Pre-fill from `$ARGUMENTS`. Every section the prose does not directly answer gets a `[NEEDS CLARIFICATION: <specific question>]` marker.
   - If `$ARGUMENTS` is empty, emit the pure template with every section marked.

9. **Report to the user**: branch name, artifact path, and the next command (`/speckit.discovery.concept`). Mention that `/speckit.discovery.clarify` can resolve `[NEEDS CLARIFICATION]` markers later.

## Helper

```bash
git_status=$(git status --porcelain 2>/dev/null)
current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
echo "WORKING_TREE_DIRTY=$([ -n "$git_status" ] && echo yes || echo no)"
echo "CURRENT_BRANCH=$current_branch"
echo "--- existing local discovery branches ---"
git branch --list 'discovery/*' --format='%(refname:short)' 2>/dev/null || true
echo "--- existing remote discovery branches ---"
git branch -r --list 'origin/discovery/*' --format='%(refname:short)' 2>/dev/null || true
echo "--- existing discovery dirs ---"
ls -d .specify/discovery/*/ 2>/dev/null | xargs -n1 basename 2>/dev/null || true
```

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
