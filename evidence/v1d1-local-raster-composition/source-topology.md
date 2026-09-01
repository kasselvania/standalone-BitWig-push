# V1D-1 source topology

## Date, machine state, and authority

- Evidence date: 2026-09-01 PDT.
- Machine state: accepted local Mac fixture; Bitwig was closed for repository/build custody checks.
- Central basis/tree: `c94d1b74d702e696d6cc4cc89625f1a2f7a95530` / `8539026fc9476bbf2df34b310190a57906113b90`.
- DrivenByMoss basis/tree: `852b520933eed87fbe496a04b5c18819a10b3564` / `d03a372e2efcf41b22cef46501e08efbfb0c0036`.
- Source PR/head/tree: [kasselvania/DrivenByMoss#4](https://github.com/kasselvania/DrivenByMoss/pull/4), `3c3ca02ff81ab5ce110ae3d714e20b5fca05a03f`, tree `c4e42825d069421a44b3241349de9a7c6453a3ad`.

## Repository and branch custody

Sanitized worktrees and remotes:

```text
central: $HOME/Documents/ChatGPT/BitWig Standalone Push/standalone-BitWig-push-v1d1
branch:  codex/v1d1-local-raster-composition-evidence
origin:  git@github.com:kasselvania/standalone-BitWig-push.git

source:   $HOME/Documents/ChatGPT/BitWig Standalone Push/DrivenByMoss-v1d1
branch:   pushwig/v1d1-local-raster-composition
origin:   git@github.com:kasselvania/DrivenByMoss.git
upstream: https://github.com/git-moss/DrivenByMoss.git
```

The source branch contains exactly one implementation commit:

```text
commit:  3c3ca02ff81ab5ce110ae3d714e20b5fca05a03f
parent:  852b520933eed87fbe496a04b5c18819a10b3564
tree:    c4e42825d069421a44b3241349de9a7c6453a3ad
subject: V1D-1: implement local raster composition
```

The source PR is OPEN, non-draft, unmerged, targets `pushwig/main`, and its remote head is exactly the commit above. The immutable upstream-basis branch was not modified or targeted. No temporary observation branch was pushed and no second source PR exists.

## Exact production envelope

The source commit changes exactly five paths:

1. `src/main/java/de/mossgrabers/bitwig/framework/graphics/BitmapImpl.java`
2. `src/main/java/de/mossgrabers/controller/ableton/push/controller/DynamicLocalRasterPushFramePipeline.java`
3. `src/main/java/de/mossgrabers/controller/ableton/push/controller/Push2Display.java`
4. `src/main/java/de/mossgrabers/framework/graphics/IRasterWritableBitmap.java`
5. `src/main/java/de/mossgrabers/framework/graphics/RasterPixelFormat.java`

### Exact proposed-head source object hashes

The following are the Git blob object IDs for the exact file bytes in source head `3c3ca02ff81ab5ce110ae3d714e20b5fca05a03f`. A Git blob ID is the SHA-1 of the canonical `blob <byte-length>\0<content>` object, so these values independently bind every final production source and both host-neutral interface files to the reviewed tree:

```text
BitmapImpl.java
cafd0454dfa4c1bc5200130bc360386df9637abd

Push2Display.java
ff6871c1116e0917f857c176202ade8cf8ffcef0

DynamicLocalRasterPushFramePipeline.java
9f0cadd4969204b2b0a434a370183446434002d1

IRasterWritableBitmap.java
6607481bf8afab540d603928a28f289b215a103e

RasterPixelFormat.java
71518c0b2541248d048fbea07e1d3d5d1f88c078
```

These are source-content object hashes, distinct from the compiled-class SHA-256 values retained in `build-artifact-comparison.md` and from temporary observation-source hashes.

`git show --stat` reports 444 insertions and 6 deletions. `PushUsbDisplay.java`, `AbstractGraphicDisplay.java`, POM files, extension/version/ID definitions, and accepted V1A/V1B/V1C source files are outside the source diff.

The required dependency search found only:

- `ByteBuffer` in `BitmapImpl`, the authorized Bitwig backend adapter; one destination view is obtained at construction and cached;
- the pre-existing `encode` implementation in `BitmapImpl`;
- the pre-existing shutdown-only executor in unchanged `Push2Display` context.

It found no new thread, executor, scheduler, timer, queue, future, USB type, capture type, socket, file channel, mapped buffer, enum-values array, duplicate/slice/array view, or prohibited dependency in the new raster pipeline or host-neutral contract.

## Temporary research custody

The observation worktree was derived from the exact source head and was never committed or pushed. Its complete temporary patch SHA-256 was `f3292a792fe7eb465549d3156b8890983a6349e98934e74cbe6834a2b6c0ccf0`. After the live observation, the four tracked files were restored and the untracked observer removed. Readback showed the observation and production worktrees both clean at:

```text
HEAD: 3c3ca02ff81ab5ce110ae3d714e20b5fca05a03f
tree: c4e42825d069421a44b3241349de9a7c6453a3ad
```

Generated extensions and temporary harness/observer code are not part of either repository commit.

## Commands and tools

Commands included `git fetch`, `git rev-parse`, `git log`, `git status --short`, `git diff --exit-code`, `git diff --cached --exit-code`, `git diff --check`, `git show --stat`, `git diff-tree --name-only`, `git remote -v`, scoped `rg`, `git push`, and `gh pr view`. Exact Git blob IDs were read back from the proposed source head for all five production files.

## What this proves

- The implementation is a one-commit child of the accepted integration basis.
- The source PR and remote branch point to the exact reviewed head/tree.
- The production change stays inside the authorized five-path envelope.
- Every final production source file is independently content-bound by an exact Git blob hash.
- Temporary observation work was removed and never entered source history.

## What this does not prove

- It does not merge or authorize merging the source PR.
- It does not claim the temporary observer as production code.
- Repository topology and source hashes alone do not prove pixel correctness or real-hardware behavior; those are retained separately.
