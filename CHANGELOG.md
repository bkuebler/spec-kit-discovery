# Changelog

All notable changes to this extension are documented here. Format roughly follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versions follow [SemVer](https://semver.org/).

## [Unreleased]

## [0.1.3] - 2026-05-21

### Changed
- Manifest `description` tightened to fit the publishing-guide ≤100-char guideline so the entry renders cleanly in `specify extension search`.
- Manifest `homepage` field added (recommended by the publishing guide for catalog discoverability).

## [0.1.2] - 2026-05-21

### Changed
- README expanded to show how the discovery phase fits into spec-kit's full workflow: project setup (`/constitution`) → discovery (this extension) → per-feature pipeline (`/specify` → `/clarify` → `/plan` → `/tasks` → `/implement`). Constitution promotion and the `04-features.md → /specify` handoff are now called out as named seams.
- `/speckit.discovery.clarify` reframed as **iterative** across all discovery phases, not a single step between `concept` and `decide`. README diagram updated to reflect real usage; clarify's no-markers branch no longer prescribes a fixed "next command" (was: *decide if concept exists, else concept* — too workflow-y).
- `/speckit.discovery.decide` completion report now counts `[NEEDS CLARIFICATION]` markers in the new ADR and conditionally suggests `/clarify` before `/decompose` when markers were introduced.

## [0.1.1] - 2026-05-21

### Added
- Shared state script `scripts/bash/discovery-context.sh` — single point of state introspection (branch, dirty status, discovery directory, next number, existing branches/dirs). All commands consume its `KEY=value` output. Bash 3.2 compatible. The output protocol is documented as a versioned contract in `CLAUDE.md`.
- `IN_GIT_REPO=no` guard in `problem.md` — refuses cleanly when invoked outside a git repository.

### Changed
- All five commands refactored to call the shared script instead of inlining their own state-gathering bash. Step language updated to reference the emitted keys (`ON_DISCOVERY_BRANCH`, `DISCOVERY_DIR`, `NEXT_NUMBER`, etc.).
- Install path for the shared script in consumer projects: `.specify/extensions/discovery/scripts/bash/discovery-context.sh` (matches the convention spec-kit core's `extensions/git` uses).

### Fixed
- Bash helper guard in `clarify.md`, `decide.md`, `decompose.md` no longer uses `[[ ! "$var" =~ ... ]]`, which broke when the shell escaped `!` to `\!` (a defense against bash history expansion). Replaced with `case "$var" in <glob>) ;; *) ... ;; esac`, which is bash 3.2 compatible and sidesteps both pitfalls.

## [0.1.0] - 2026-05-20

### Added
- Initial extension scaffold.
- Five discovery commands: `speckit.discovery.problem`, `concept`, `clarify`, `decide`, `decompose`.
- AI-generated slugs with user confirmation; numbered `discovery/NNN-<slug>` branches.
- Idempotent re-runs of `problem` while already on a `discovery/*` branch.
- ADR generation with opt-in promotion of rules to `.specify/memory/constitution.md`.
- `[NEEDS CLARIFICATION]` marker convention compatible with spec-kit core.

### Known limitations
- No `before_specify` hook yet — workflow ordering is by convention. Planned for v0.2.
- Bash-only helpers; PowerShell parity not yet implemented.

[Unreleased]: https://github.com/bkuebler/spec-kit-discovery/compare/v0.1.3...HEAD
[0.1.3]: https://github.com/bkuebler/spec-kit-discovery/compare/v0.1.2...v0.1.3
[0.1.2]: https://github.com/bkuebler/spec-kit-discovery/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/bkuebler/spec-kit-discovery/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/bkuebler/spec-kit-discovery/releases/tag/v0.1.0
