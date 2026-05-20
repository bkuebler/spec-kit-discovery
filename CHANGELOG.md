# Changelog

All notable changes to this extension are documented here. Format roughly follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/); versions follow [SemVer](https://semver.org/).

## [0.1.0] - Unreleased

### Added
- Five discovery commands: `speckit.discovery.problem`, `concept`, `clarify`, `decide`, `decompose`.
- AI-generated slugs with user confirmation; numbered `discovery/NNN-<slug>` branches.
- Idempotent re-runs of `problem` while already on a `discovery/*` branch.
- ADR generation with opt-in promotion of rules to `.specify/memory/constitution.md`.
- `[NEEDS CLARIFICATION]` marker convention compatible with spec-kit core.

### Known limitations
- No `before_specify` hook yet — workflow ordering is by convention. Planned for v0.2.
- Bash-only helpers; PowerShell parity not yet implemented.
