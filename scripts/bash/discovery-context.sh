#!/usr/bin/env bash
# discovery-context.sh
#
# Emit a stable KEY=value block describing the state relevant to
# the spec-kit-discovery extension. Consumed by every discovery
# command markdown. Bash 3.2 compatible (macOS default).
#
# Keys emitted (always, even if empty):
#   CURRENT_BRANCH
#   ON_DISCOVERY_BRANCH        yes|no
#   WORKING_TREE_DIRTY         yes|no
#   IN_GIT_REPO                yes|no
#   DISCOVERY_SUFFIX           NNN-slug (empty if not on discovery branch)
#   DISCOVERY_DIR              .specify/discovery/<suffix> (empty if not on discovery branch)
#   NEXT_NUMBER                zero-padded NNN (max of branches+dirs, +1; "001" if none)
#
# Followed by three multi-line lists, each preceded by a sentinel
# line so the parser knows where they start/end:
#   BEGIN_EXISTING_BRANCHES_LOCAL  / END_EXISTING_BRANCHES_LOCAL
#   BEGIN_EXISTING_BRANCHES_REMOTE / END_EXISTING_BRANCHES_REMOTE
#   BEGIN_EXISTING_DIRS            / END_EXISTING_DIRS
#
# Exit code is always 0 unless git itself fails catastrophically.
# Absence of a git repo is reported via IN_GIT_REPO=no, not by exit.

set -u

# -- detect git repo --------------------------------------------------------
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  in_git=yes
else
  in_git=no
fi

# -- current branch ---------------------------------------------------------
if [ "$in_git" = "yes" ]; then
  current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || true)
else
  current_branch=""
fi

# -- on discovery branch? ---------------------------------------------------
on_discovery=no
discovery_suffix=""
discovery_dir=""
case "$current_branch" in
  discovery/[0-9]*-*)
    on_discovery=yes
    discovery_suffix="${current_branch#discovery/}"
    discovery_dir=".specify/discovery/$discovery_suffix"
    ;;
esac

# -- working tree dirty? ----------------------------------------------------
if [ "$in_git" = "yes" ] && [ -n "$(git status --porcelain 2>/dev/null)" ]; then
  dirty=yes
else
  dirty=no
fi

# -- gather existing branches and dirs --------------------------------------
existing_local=""
existing_remote=""
existing_dirs=""

if [ "$in_git" = "yes" ]; then
  existing_local=$(git for-each-ref --format='%(refname:short)' refs/heads/discovery/ 2>/dev/null || true)
  existing_remote=$(git for-each-ref --format='%(refname:short)' refs/remotes/origin/discovery/ 2>/dev/null || true)
fi

if [ -d .specify/discovery ]; then
  existing_dirs=$(find .specify/discovery -mindepth 1 -maxdepth 1 -type d -exec basename {} \; 2>/dev/null | LC_ALL=C sort || true)
fi

# -- compute NEXT_NUMBER ----------------------------------------------------
# Extract leading NNN from any of: local branches (discovery/NNN-...),
# remote branches (origin/discovery/NNN-...), discovery dirs (NNN-...).
extract_numbers() {
  # stdin: lines; stdout: numeric prefixes (no padding)
  sed -E -n 's|^(origin/)?discovery/([0-9]+)-.*$|\2|p; s|^([0-9]+)-.*$|\1|p'
}

max_num=$(
  {
    printf '%s\n' "$existing_local"
    printf '%s\n' "$existing_remote"
    printf '%s\n' "$existing_dirs"
  } | extract_numbers | LC_ALL=C sort -n | tail -n 1
)

if [ -z "$max_num" ]; then
  next_num="001"
else
  # zero-pad to 3 digits; if already >= 100 keep natural width
  next_raw=$((10#$max_num + 1))
  next_num=$(printf '%03d' "$next_raw")
fi

# -- emit -------------------------------------------------------------------
printf 'CURRENT_BRANCH=%s\n' "$current_branch"
printf 'ON_DISCOVERY_BRANCH=%s\n' "$on_discovery"
printf 'WORKING_TREE_DIRTY=%s\n' "$dirty"
printf 'IN_GIT_REPO=%s\n' "$in_git"
printf 'DISCOVERY_SUFFIX=%s\n' "$discovery_suffix"
printf 'DISCOVERY_DIR=%s\n' "$discovery_dir"
printf 'NEXT_NUMBER=%s\n' "$next_num"

printf 'BEGIN_EXISTING_BRANCHES_LOCAL\n'
[ -n "$existing_local" ] && printf '%s\n' "$existing_local"
printf 'END_EXISTING_BRANCHES_LOCAL\n'

printf 'BEGIN_EXISTING_BRANCHES_REMOTE\n'
[ -n "$existing_remote" ] && printf '%s\n' "$existing_remote"
printf 'END_EXISTING_BRANCHES_REMOTE\n'

printf 'BEGIN_EXISTING_DIRS\n'
[ -n "$existing_dirs" ] && printf '%s\n' "$existing_dirs"
printf 'END_EXISTING_DIRS\n'
