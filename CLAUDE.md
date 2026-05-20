# CLAUDE.md — spec-kit-discovery

Context for AI assistants working on this repo. Keep this file factual; user-facing docs live in `README.md`.

## What this is

A [spec-kit](https://github.com/github/spec-kit) extension that adds a discovery phase **before** `/specify`. Five commands (`problem` → `concept` → `clarify` → `decide` → `decompose`) produce durable artifacts on isolated `discovery/NNN-<slug>` branches in the **consumer** project. This repo *is* the extension; it is not itself a spec-kit project.

## Locked design decisions (v0.1)

Don't re-litigate these without an explicit user ask:

1. **Scope = lean + ADR.** Five commands, not three, not six. `context` and `options` are folded into `concept.md` as sections, not standalone commands.
2. **Slug strategy = AI-generated, user-confirmed, numbered branch.** Branch name `discovery/NNN-<slug>`, dir `.specify/discovery/NNN-<slug>/`. `NNN` = max(local branches, remote branches, existing dirs) + 1, zero-padded.
3. **Interaction style = draft + clarify.** Each command drafts from prose (`$ARGUMENTS`) and marks gaps with `[NEEDS CLARIFICATION: <question>]` (spec-kit's existing convention). Empty args → pure template. `clarify` resolves markers interactively.
4. **Constitution integration = opt-in promotion.** `decide` asks once: "*Does this decision establish a project-wide rule?*" Yes → append 1-3 imperative bullets to `.specify/memory/constitution.md` under `## Decisions promoted from ADRs`, each with a back-link. Never append the full ADR.
5. **Handoff = discovery branch merges to main; `/specify` runs from main per slice.** Discovery branches are conceptually a design-doc stage, not feature branches.

## Repo layout

```
extension.yml           # manifest — 5 commands, no hooks in v0.1
commands/
  problem.md            # branch+dir creation, 01-problem.md
  concept.md            # 02-concept.md (options + recommendation)
  clarify.md            # walks [NEEDS CLARIFICATION] markers
  decide.md             # 03-adr-MMM-<slug>.md + opt-in promotion
  decompose.md          # 04-features.md with /specify-ready prose
README.md               # user-facing
CHANGELOG.md
LICENSE                 # MIT
.extensionignore        # excluded from `specify extension add` installs
```

Each `commands/*.md` file is an AI prompt with YAML frontmatter (`description`) and a markdown body containing natural-language steps, helper bash blocks, and a template for the artifact it produces.

## Extension system primer (what you need to know)

- **Spec for extensions**: `extensions/EXTENSION-DEVELOPMENT-GUIDE.md` and `EXTENSION-API-REFERENCE.md` in `github/spec-kit`. Read those before changing `extension.yml` schema.
- **Manifest constraints**:
  - `extension.id` must match `^[a-z0-9-]+$` — ours is `discovery`.
  - Command names must match `^speckit\.<ext-id>\.<cmd>$`.
  - `version` is strict SemVer (`1.0.0` not `1.0` or `v1.0.0`).
- **Available hook points** (for v0.2): `before_specify`/`after_specify`, plus `_plan`, `_tasks`, `_implement`, `_clarify`, `_constitution`, etc.
- **Script path rewriting**: scripts referenced as `../../scripts/bash/foo.sh` in extension source become `.specify/scripts/bash/foo.sh` after install. We don't ship scripts yet — all helpers are inlined in command markdown.
- **Local install for testing**: `specify extension add --dev /absolute/path/to/this/repo` from inside a spec-kit project. Commands land in `.claude/commands/speckit.discovery.*.md`.

## Conventions to preserve

- **Marker format**: `[NEEDS CLARIFICATION: <specific question>]` — case-sensitive, brackets included. Don't paraphrase. `clarify.md` greps for this exact substring.
- **Filenames in discovery dirs**: `01-problem.md`, `02-concept.md`, `03-adr-MMM-<slug>.md`, `04-features.md`. `MMM` is per-discovery (multiple ADRs allowed); `NNN` is per-project (one per discovery).
- **Bash helpers** in command bodies should be defensive (`2>/dev/null || true` where appropriate) — the consumer project's git state isn't ours to assume.
- **Idempotency**: `problem.md` reuses the current branch when invoked while already on a `discovery/*` branch. Other commands operate on whatever discovery branch is currently checked out.

## Known limitations / v0.2 backlog

In rough priority order:

1. **`before_specify` hook** + a small `speckit.discovery.check` command that warns when `/specify` runs without discovery artifacts. Omitted from v0.1 to keep the surface small.
2. **PowerShell helper parity** — currently bash-only. Spec-kit core ships `scripts/bash/` + `scripts/powershell/` siblings; add `.ps1` mirrors if/when a Windows user surfaces.
3. **Idempotency heuristic in `problem.md`** ("refinement vs new problem") is AI-judgement-based and fuzzy. May want an explicit `--new` / `--refine` flag.
4. **Constitution promotion has no dedup** — running `decide` on related ADRs can append similar rules. Document a review step or add fuzzy-match dedup.
5. **No tests yet.** The dev guide shows a pytest example using `specify_cli.extensions.ExtensionManifest`. Add a smoke test that loads `extension.yml` and asserts every `commands/*.md` referenced exists.
6. **Catalog submission** — see `extensions/EXTENSION-PUBLISHING-GUIDE.md` for the community-catalog flow when v0.1 is battle-tested.

## Testing changes locally

1. Pick or create a spec-kit-initialized consumer project.
2. From that project: `specify extension add --dev /Users/bkuebler/Repositories/github.com/bkuebler/spec-kit-discovery`
3. Verify: `specify extension list` shows `Discovery (pre-spec workflow) v0.1.0`.
4. Invoke commands with your AI agent (e.g. `/speckit.discovery.problem <prose>` in Claude Code).
5. Inspect `.specify/discovery/NNN-<slug>/` artifacts.
6. To re-test cleanly: `specify extension remove discovery`, then re-add.

After significant changes, bump `extension.version` and `CHANGELOG.md` together — they should never drift.

## Git conventions for this repo

- Email is set locally to `b.kuebler@kuebler-it.de` (overrides global). Don't change it.
- No remote configured. Don't push or add one without an explicit ask.
- No GPG signing configured globally; do NOT add `-c commit.gpgsign=false` to commits "just in case" — pass nothing.
- Commits should be descriptive but not novel-length; the README and CHANGELOG carry the prose.

## What's NOT this repo's concern

- Spec-kit core internals (`src/specify_cli/` upstream). We only consume the extension API surface.
- The consumer project's actual feature implementation. We only produce planning artifacts.
- Hooks (until v0.2).
