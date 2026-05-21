# spec-kit-discovery

A [spec-kit](https://github.com/github/spec-kit) extension that adds the **discovery phase** that happens *before* `/specify`.

Spec-kit's `/specify` assumes you already know *what* problem you're solving and roughly *how*. In real projects you usually don't — you need to think through the problem, weigh approaches, and lock a direction before writing a precise feature spec. This extension fills that gap with five commands that produce durable artifacts on an isolated `discovery/*` branch.

## How this fits into spec-kit's workflow

Spec-kit core gives you a per-feature pipeline: `/constitution` → `/specify` → `/clarify` → `/plan` → `/tasks` → `/implement`. This extension prepends a **discovery phase** that runs *once per body of work*, produces durable design artifacts, and feeds one or more feature slices into spec-kit's per-feature pipeline.

```
┌─ PROJECT SETUP (spec-kit core, once per project) ────────────────────────┐
│   /constitution                                                          │
│        │                                                                 │
└────────┼─────────────────────────────────────────────────────────────────┘
         │
         │   (optional: /speckit.discovery.decide can later
         │    promote rules into .specify/memory/constitution.md)
         ▼
┌─ DISCOVERY PHASE (this extension, once per body of work) ────────────────┐
│   on branch  discovery/NNN-<auto-slug>                                   │
│                                                                          │
│   /speckit.discovery.problem    <free-text problem description>          │
│        └→ 01-problem.md                                                  │
│   /speckit.discovery.concept                                             │
│        └→ 02-concept.md  (context, options, sketch, open questions)     │
│   /speckit.discovery.decide                                              │
│        └→ 03-adr-MMM-<slug>.md  (+ opt-in promotion to constitution)     │
│   /speckit.discovery.decompose                                           │
│        └→ 04-features.md  (one feature slice per /specify run)           │
│                                                                          │
│   /speckit.discovery.clarify    (iterative — run after any of the        │
│                                  commands above to resolve any           │
│                                  [NEEDS CLARIFICATION] markers           │
│                                  accumulated across the discovery dir)   │
│                                                                          │
│   merge  discovery/NNN-<slug>  →  main                                   │
└────────┬─────────────────────────────────────────────────────────────────┘
         │
         │   paste each feature slice's "Specify prose" block into /specify
         ▼
┌─ PER-FEATURE PIPELINE (spec-kit core, repeats per slice) ────────────────┐
│   /specify  <prose from 04-features.md>                                  │
│        └→ specs/NNN-<feature>/spec.md  (on a fresh feature branch)       │
│   /clarify                                                               │
│   /plan                                                                  │
│   /tasks                                                                 │
│   /implement                                                             │
└──────────────────────────────────────────────────────────────────────────┘
```

### Where it ties in

- **Constitution.** Spec-kit's `/constitution` sets project-wide rules once. Discovery's `/speckit.discovery.decide` can later *append* rules to `.specify/memory/constitution.md` when an ADR is judged to establish a project-wide constraint. The constitution then applies to every subsequent `/specify` / `/plan` / `/implement`.
- **Handoff to `/specify`.** `04-features.md` is the seam. Each slice contains a one-paragraph problem statement written in the imperative voice spec-kit's `/specify` expects — paste it in as the `/specify` argument from `main` (spec-kit will create its own `NNN-<feature>` branch).
- **One discovery, N features.** A single discovery typically produces multiple feature slices that each become independent `/specify` runs. Discovery branches live separately from feature branches.

### Ordering, currently

At the moment ordering is **manual / by convention** — nothing prevents you from running `/specify` without a discovery, or skipping `/decompose`. A `before_specify` hook that nudges you when discovery artifacts are missing is planned for v0.2 (see [Roadmap](#roadmap)).

## Install

### Recommended: from a tagged release

Pick the version you want from the [releases page](https://github.com/bkuebler/spec-kit-discovery/releases) and install the source archive directly:

```bash
specify extension add discovery \
  --from https://github.com/bkuebler/spec-kit-discovery/archive/refs/tags/v0.1.2.zip
```

Spec-kit will show a security warning (expected — the extension is not in your configured catalog) before installing.

### For development on the extension itself

Clone the repo and install with `--dev`, which is the install mode that supports a fast edit/reinstall loop:

```bash
git clone https://github.com/bkuebler/spec-kit-discovery.git
specify extension add --dev ./spec-kit-discovery
```

To pick up local edits, remove and re-add:

```bash
specify extension remove discovery && specify extension add --dev ./spec-kit-discovery
```

### From a catalog (not yet available)

A community-catalog submission is on the [roadmap](#roadmap). Once the entry lands, install simplifies to `specify extension add discovery`.

### Verify

```bash
specify extension list   # should show "Discovery (pre-spec workflow) vX.Y.Z"
```

## Conventions

- **Slug** is generated by the AI from the problem prose and confirmed by the user before any branch is created.
- **Branch name**: `discovery/NNN-<slug>` where `NNN` is the next number across local branches, remote branches, and existing `.specify/discovery/*` directories.
- **Artifact location**: `.specify/discovery/NNN-<slug>/` in the consumer project.
- **Subsequent commands** detect the current `discovery/*` branch and operate on its directory — no slug argument needed after `problem`.
- **Safety rails**: dirty working tree refused; switching off a non-`main`/non-`discovery` branch confirmed before creating a discovery branch.

## Interaction style

Each command takes optional prose input and **drafts** the artifact, marking uncertain sections with `[NEEDS CLARIFICATION: <question>]` (matching spec-kit's own convention). Run `/speckit.discovery.clarify` to resolve those interactively, or edit the file directly.

If you invoke a command with no arguments, it emits a pure template with placeholders.

## Constitution integration

`/speckit.discovery.decide` writes the ADR, then asks whether the decision establishes a project-wide rule. If yes, the agent extracts the rule(s) and appends them to `.specify/memory/constitution.md` under a `## Decisions promoted from ADRs` section, with a back-link to the ADR file. ADRs that are merely feature-scoped do not pollute the constitution.

## Roadmap

- **v0.1** (current): five core commands, manual ordering.
- **v0.2** (planned): `before_specify` hook + `speckit.discovery.check` command that warns when `/specify` runs without discovery artifacts; richer slug confirmation UI; powershell parity if needed.

## License

MIT — see [LICENSE](LICENSE).
