---
description: "Resolve [NEEDS CLARIFICATION] markers across discovery artifacts via Q&A"
---

# Discovery: Clarify

## User Input

$ARGUMENTS

## Goal

Walk every `[NEEDS CLARIFICATION: ...]` marker in the current discovery directory and resolve it interactively, replacing the marker with the user's answer.

## Steps

1. **Locate the discovery directory** with the helper below. Current branch must match `^discovery/[0-9]+-`. If not, stop and tell the user to start with `/speckit.discovery.problem`.

2. **Scan every file in the discovery directory** for `[NEEDS CLARIFICATION: ...]` markers. Build an ordered list of `(file, line, question)` tuples.

3. **If no markers are found**, tell the user there's nothing to clarify and suggest the next command (`/speckit.discovery.decide` if `02-concept.md` exists, else `/speckit.discovery.concept`). Stop.

4. **If `$ARGUMENTS` names a specific file** (e.g. `02-concept.md`) or a specific question fragment, narrow the list accordingly.

5. **For each marker, one at a time**:
   - Show the user: file name, surrounding section header, the question.
   - Ask the user for the answer.
   - Accept `skip` to leave the marker in place and move on.
   - Accept `stop` to halt and write progress.
   - Otherwise, replace the entire `[NEEDS CLARIFICATION: ...]` substring with the user's answer (preserving surrounding text and indentation).

6. **Write changes back to the files** as you go (do not batch — if the user stops mid-way, prior answers should already be saved).

7. **Report a summary**: how many markers resolved, how many remain, suggested next command.

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
echo "--- markers ---"
grep -RHn '\[NEEDS CLARIFICATION:' "$dir" 2>/dev/null || echo "(none)"
```

## Notes

- Treat markers as case-sensitive: only `[NEEDS CLARIFICATION: ...]` (not paraphrases).
- If a single line contains multiple markers, resolve them left-to-right as separate questions.
- Do not invent answers. If the user says "I don't know", leave the marker but optionally append `(asked: <date>)` after the question so it isn't re-asked immediately on the next run.
