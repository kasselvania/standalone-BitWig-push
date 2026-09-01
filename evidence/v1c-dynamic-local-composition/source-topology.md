# V1C source topology

## Date, machine state, and authority

- Evidence date: 2026-09-01 PDT.
- Machine state: accepted macOS arm64 fixture; source and evidence were isolated from unrelated work.
- Actual central basis/tree: `4265dc7b6f1cabf2dcbad1b827d002bd9062cf4f` / `2af6b4757e5906ce74a3b52c5ee82323f5e32406`.
- DrivenByMoss basis/tree: `1ae0b74f383314d170a5960ca763bdf9c319e787` / `a81e5c4330b31f36845c25e98e322990d62f0c67`.
- Source PR/head/tree: [kasselvania/DrivenByMoss#3](https://github.com/kasselvania/DrivenByMoss/pull/3), `4b3326eddcf2d890de3baa10b93f6e80842d41e1`, tree `d03a372e2efcf41b22cef46501e08efbfb0c0036`.

## Repository custody

DrivenByMoss worktree:

```text
$HOME/Documents/ChatGPT/BitWig Standalone Push/DrivenByMoss-v1c
```

Remotes:

```text
origin   git@github.com:kasselvania/DrivenByMoss.git
upstream https://github.com/git-moss/DrivenByMoss.git
```

Branches and immutable authority:

```text
integration: pushwig/main
feature:     pushwig/v1c-dynamic-local-composition
immutable:   pushwig/upstream-26.4.1
```

The immutable upstream branch remained at commit `fd03245ab38fa5149c45934051d937ee9fda6d08`, tree `edd2ad636b0aa1f39919f0ffd05c968015450075`. The feature branch has exactly one commit over `pushwig/main`:

```text
4b3326ed V1C: implement dynamic local Push composition
```

Its parent is exactly `1ae0b74f383314d170a5960ca763bdf9c319e787`.

## Exact production envelope

```text
src/main/java/de/mossgrabers/framework/controller/display/AbstractGraphicDisplay.java
src/main/java/de/mossgrabers/controller/ableton/push/controller/Push2Display.java
src/main/java/de/mossgrabers/controller/ableton/push/controller/DynamicLocalPushFramePipeline.java
```

No other production path changed. In particular, `PushUsbDisplay.java`, `PushFramePipeline.java`, `PassThroughPushFramePipeline.java`, `SyntheticOverlayPushFramePipeline.java`, `pom.xml`, IDs, versioning, USB selection, endpoint ownership, conversion, padding, XOR shaping, transfer scheduling, and shutdown transport were not modified.

Pre-edit and final checks included:

```text
git status --short
git diff --exit-code
git diff --cached --exit-code
git rev-parse HEAD
git rev-parse HEAD^{tree}
git diff --check
git diff --name-only 1ae0b74f..HEAD
git log --oneline 1ae0b74f..HEAD
```

The exact source file SHA-256 values before commit were:

```text
AbstractGraphicDisplay.java          5e77f86a2c23517be64b368d97e9b53d3f05f7f5effd53542b20b10690ec8bf6
Push2Display.java                    232f234005bfb00013cf8d4c8528ac7ed8734668de6771046c9a4aa8400882a0
DynamicLocalPushFramePipeline.java   cd877186d28667df3a0ca718d7f09119e2c6abc9aa18fb6e1a9f93126bb8cc3e
```

The staged implementation patch SHA-256 was `2076243bc69e2134a1a1c9a1c00c3f56847f3afd73c44e785d604edc6587a4de`.

## Pull request readback

```text
URL:       https://github.com/kasselvania/DrivenByMoss/pull/3
state:     OPEN
draft:     false
base:      pushwig/main
head:      pushwig/v1c-dynamic-local-composition
head OID:  4b3326eddcf2d890de3baa10b93f6e80842d41e1
merge readback at creation: CLEAN
```

No source PR targets the immutable upstream-basis branch, and no source PR was merged.

## Commands and tools

Tools included `git worktree list`, `git fetch --prune`, `git rev-parse`, `git status`, `git diff`, `git log`, `git push`, `shasum -a 256`, source searches with `rg`, and `gh pr create/view`.

## What this proves

- Source custody is exact, reviewable, and limited to the authorized three-path envelope.
- The feature is one commit directly above the accepted integration basis.
- The fork remotes retain their required roles and the immutable upstream basis was not targeted.
- The ordinary non-draft source PR exists at the exact tested head.

## What this does not prove

- Git topology alone does not prove bytecode behavior, bitmap restoration, timing, real hardware behavior, or rollback; those are retained in the other evidence documents.
