# V1A source topology

## Date and machine state

- Evidence date: 2026-08-31 PDT.
- Machine state: accepted macOS 26.4.1 arm64 fixture; source work occurred in isolated clean worktrees while the ordinary DrivenByMoss checkout remained untouched.
- Central basis: `a36779d4c04a11d6c6e9ce0d48c34ea3b813a0cc`, tree `bc4634da23f794f2afd39c63fab9eb5cf44524c1`.
- DrivenByMoss basis: `fd03245ab38fa5149c45934051d937ee9fda6d08`, tree `edd2ad636b0aa1f39919f0ffd05c968015450075`.
- Source PR/head/tree: [kasselvania/DrivenByMoss#1](https://github.com/kasselvania/DrivenByMoss/pull/1), `6e1e4cbd2e725a7951e5b4dc1278fbb6e7b5d61c`, `9aec7429ff093addee001a62a5a07309708fd592`.

## Repository custody

Sanitized source worktree: `$HOME/Documents/ChatGPT/BitWig Standalone Push/DrivenByMoss-v1a`.

```text
origin   git@github.com:kasselvania/DrivenByMoss.git
upstream https://github.com/git-moss/DrivenByMoss.git
```

Before branching, both `origin/pushwig/main` and immutable `origin/pushwig/upstream-26.4.1` resolved to the accepted commit and tree. The feature branch was created directly from `origin/pushwig/main`; the immutable basis branch was neither targeted nor changed.

The central evidence worktree is `$HOME/Documents/ChatGPT/BitWig Standalone Push/standalone-BitWig-push-v1a`, branch `codex/v1a-no-op-frame-pipeline-evidence`, created directly from the accepted central basis.

## Commands and exact results

```text
git fetch origin --prune
git fetch upstream --prune --tags
git rev-parse origin/pushwig/main
git rev-parse origin/pushwig/main^{tree}
git rev-parse origin/pushwig/upstream-26.4.1
git rev-parse origin/pushwig/upstream-26.4.1^{tree}
```

All commit queries returned `fd03245ab38fa5149c45934051d937ee9fda6d08`; all tree queries returned `edd2ad636b0aa1f39919f0ffd05c968015450075`.

Pre-edit checks returned an empty `git status --short`, exit 0 from both unstaged and staged diff checks, and the accepted HEAD/tree. The source commit is:

```text
commit  6e1e4cbd2e725a7951e5b4dc1278fbb6e7b5d61c
parent  fd03245ab38fa5149c45934051d937ee9fda6d08
tree    9aec7429ff093addee001a62a5a07309708fd592
message V1A: insert identity Push frame pipeline
```

`git rev-list --count fd03245ab38fa5149c45934051d937ee9fda6d08..HEAD` returned `1`.

## Exact changed paths

```text
src/main/java/de/mossgrabers/controller/ableton/push/controller/PassThroughPushFramePipeline.java
src/main/java/de/mossgrabers/controller/ableton/push/controller/Push2Display.java
src/main/java/de/mossgrabers/controller/ableton/push/controller/PushFramePipeline.java
```

The commit has 70 insertions and 4 deletions. The new/modified files retain the upstream LGPL notice and identify the project-authored V1A change. There is no `PushUsbDisplay.java`, `pom.xml`, test, resource, ID, discovery, version, or transport source change.

## Pull-request readback

GitHub readback reported:

- URL: <https://github.com/kasselvania/DrivenByMoss/pull/1>
- state: open;
- draft: false;
- base: `pushwig/main`;
- head branch: `pushwig/v1a-no-op-frame-pipeline`;
- head OID: `6e1e4cbd2e725a7951e5b4dc1278fbb6e7b5d61c`;
- commit count: one;
- changed file count: three, exactly the paths above.

The PR is intentionally unmerged.

## What this proves

- V1A is a one-commit derivative change on the exact accepted integration basis.
- The immutable upstream-basis branch remains outside the implementation topology.
- Source review is bounded to the authorized three production files and retains LGPL provenance.

## What this does not prove

- Repository topology does not prove runtime loading, physical behavior, transport timing, or rollback.
- The shared Push 2/Push 3 class path does not establish a Push 2 hardware claim.
