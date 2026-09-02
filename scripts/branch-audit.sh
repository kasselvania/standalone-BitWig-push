#!/usr/bin/env bash
# Read-only Git/worktree inventory for Pushwig repositories.
set -euo pipefail

if [[ $# -eq 0 ]]; then
  repos=(".")
else
  repos=("$@")
fi

for repo in "${repos[@]}"; do
  echo
  echo "================================================================"
  echo "REPOSITORY: $repo"
  echo "================================================================"

  git -C "$repo" rev-parse --show-toplevel
  echo
  echo "-- current status --"
  git -C "$repo" status --short

  echo
  echo "-- worktrees --"
  git -C "$repo" worktree list --porcelain

  echo
  echo "-- local branches --"
  git -C "$repo" branch -vv

  echo
  echo "-- remote branches --"
  git -C "$repo" branch -r

  echo
  echo "-- worktree status detail --"
  while IFS= read -r path; do
    [[ -n "$path" ]] || continue
    echo
    echo "WORKTREE: $path"
    git -C "$path" status --short
    echo "HEAD: $(git -C "$path" rev-parse HEAD)"
    echo "TREE: $(git -C "$path" rev-parse 'HEAD^{tree}')"
    echo "BRANCH: $(git -C "$path" branch --show-current || true)"
  done < <(git -C "$repo" worktree list --porcelain | awk '/^worktree / {print substr($0,10)}')

  if command -v gh >/dev/null 2>&1; then
    echo
    echo "-- pull requests (gh) --"
    (
      cd "$(git -C "$repo" rev-parse --show-toplevel)"
      gh pr list --state all --limit 200 \
        --json number,state,isDraft,headRefName,baseRefName,mergedAt,url 2>/dev/null || true
    )
  else
    echo
    echo "-- pull requests --"
    echo "gh CLI not installed; skipped PR lookup"
  fi

done

echo
echo "READ-ONLY AUDIT COMPLETE"
echo "No branches or worktrees were deleted or modified."
