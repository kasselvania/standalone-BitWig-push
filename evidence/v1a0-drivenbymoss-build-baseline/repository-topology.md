# Repository topology and source custody

## Date and machine state

- Evidence date: 2026-08-31 PDT.
- Machine state: accepted S0 Mac fixture; no DrivenByMoss source was edited.
- Central repository was inspected in its established checkout and changed only through a separate clean worktree.

## Central repository

| Item | Result |
| --- | --- |
| Established checkout | `$HOME/Documents/ChatGPT/BitWig Standalone Push/standalone-BitWig-push` |
| V1A-0 worktree | `$HOME/Documents/ChatGPT/BitWig Standalone Push/standalone-BitWig-push-v1a0` |
| Remote | `origin -> git@github.com:kasselvania/standalone-BitWig-push.git` |
| Accepted basis commit | `df7f2d93c87e1d2fe38c95f1e94be7c04ffa6692` |
| Accepted basis tree | `d7fd83283b6f1909f16e1950255fd1e0c570328d` |
| Evidence branch | `codex/v1a0-drivenbymoss-build-baseline` |

`git fetch origin --prune` and direct `rev-parse` readback showed that `origin/main` still matched both expected values. The existing checkout was not cleaned, stashed, reset, or repurposed.

## Implementation fork

The fork did not exist at the start of the slice. It was created with GitHub's fork mechanism rather than by copying source:

```text
gh repo fork git-moss/DrivenByMoss --clone=false
```

GitHub readback after creation:

| Item | Result |
| --- | --- |
| Fork URL | `https://github.com/kasselvania/DrivenByMoss` |
| GitHub fork relationship | `isFork: true` |
| Parent | `git-moss/DrivenByMoss` |
| Default branch | `master` (unchanged) |

No DrivenByMoss source was copied, vendored, or submoduled into the central repository.

## Local DrivenByMoss topology

| Item | Result |
| --- | --- |
| Fresh checkout | `$HOME/Documents/ChatGPT/BitWig Standalone Push/DrivenByMoss-v1a0` |
| Detached build worktree | `$HOME/Documents/ChatGPT/BitWig Standalone Push/DrivenByMoss-v1a0-build` |
| `origin` fetch/push | `git@github.com:kasselvania/DrivenByMoss.git` |
| `upstream` fetch/push | `https://github.com/git-moss/DrivenByMoss.git` |

The remote roles are deliberate: `origin` is the kasselvania implementation fork and `upstream` is git-moss.

Both remotes and all upstream tags were fetched. Direct source readback returned:

```text
git rev-parse 26.4.1^{commit}
fd03245ab38fa5149c45934051d937ee9fda6d08

git rev-parse 26.4.1^{tree}
edd2ad636b0aa1f39919f0ffd05c968015450075
```

## Stable fork branch

`pushwig/upstream-26.4.1` was created directly at the accepted commit and pushed without adding a commit.

Local and GitHub readback both returned:

| Ref | Commit | Tree |
| --- | --- | --- |
| `pushwig/upstream-26.4.1` | `fd03245ab38fa5149c45934051d937ee9fda6d08` | `edd2ad636b0aa1f39919f0ffd05c968015450075` |
| `origin/pushwig/upstream-26.4.1` | `fd03245ab38fa5149c45934051d937ee9fda6d08` | `edd2ad636b0aa1f39919f0ffd05c968015450075` |

GitHub reports the branch as unprotected. The fork default branch was not changed. No source pull request was created.

## Clean build source

The build worktree was detached at the accepted commit. Before running Maven:

```text
git diff --exit-code          # exit 0
git diff --cached --exit-code # exit 0
git status --short            # no output
```

The same commands returned the same clean result after the build. Generated `target/` content is ignored and did not alter the source tree.

## Tools and commands used

- `gh repo view`, `gh repo fork`, and `gh api`
- `git clone`, `git remote`, `git fetch --prune --tags`
- `git rev-parse`, `git branch`, `git push`, `git show-ref`
- `git diff --exit-code`, `git diff --cached --exit-code`, `git status --short`

## What this evidence proves

- `kasselvania/DrivenByMoss` is a true fork retaining upstream history.
- Remote ownership is not reversed.
- The stable fork branch is an exact, zero-divergence reference to accepted 26.4.1 source.
- The source built in this slice was clean and exactly pinned.
- The central slice was isolated from the maintainer's established checkout.

## What this evidence does not prove

- It does not claim that the fork's `master` branch is a Pushwig implementation branch.
- It does not introduce or review any DrivenByMoss source change.
- It does not prove build or hardware behavior; those results are retained separately.
