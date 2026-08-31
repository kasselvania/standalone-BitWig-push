# V1B source topology

## Date and machine state

- Evidence date: 2026-08-31 PDT.
- Machine state: accepted macOS 26.4.1 arm64 fixture; Bitwig Studio was kept outside source mutation and builds.
- Central basis: `a13faef08ac8bb75a9e32f7ff7d4bc07fcd41c6e`, tree `c06009f822fee7bf36096739e7be6589f0b9ae34`.
- Source basis: `033ccef8c64f08e8d8d41fa90d48fa06b326a1a1`, tree `9aec7429ff093addee001a62a5a07309708fd592`.
- Source PR/head/tree: [kasselvania/DrivenByMoss#2](https://github.com/kasselvania/DrivenByMoss/pull/2), `a2e0341b7bccfa4e6b13614f4adffc2235f785f4`, tree `a81e5c4330b31f36845c25e98e322990d62f0c67`.

## Repository roles and exact result

Source worktree:

```text
$HOME/Documents/ChatGPT/BitWig Standalone Push/DrivenByMoss-v1b
```

Remotes:

```text
origin   git@github.com:kasselvania/DrivenByMoss.git
upstream https://github.com/git-moss/DrivenByMoss.git
```

Verified pre-work references:

| Reference | Commit | Tree |
| --- | --- | --- |
| `origin/pushwig/main` | `033ccef8c64f08e8d8d41fa90d48fa06b326a1a1` | `9aec7429ff093addee001a62a5a07309708fd592` |
| `origin/pushwig/upstream-26.4.1` | `fd03245ab38fa5149c45934051d937ee9fda6d08` | `edd2ad636b0aa1f39919f0ffd05c968015450075` |

Feature topology:

```text
branch: pushwig/v1b-static-synthetic-overlay
parent: 033ccef8c64f08e8d8d41fa90d48fa06b326a1a1
head:   a2e0341b7bccfa4e6b13614f4adffc2235f785f4
tree:   a81e5c4330b31f36845c25e98e322990d62f0c67
commit count over parent: 1
commit message: V1B: add static synthetic Push overlay
```

Exact changed paths:

```text
src/main/java/de/mossgrabers/controller/ableton/push/controller/Push2Display.java
src/main/java/de/mossgrabers/controller/ableton/push/controller/SyntheticOverlayPushFramePipeline.java
```

`PushFramePipeline.java`, `PassThroughPushFramePipeline.java`, `PushUsbDisplay.java`, `pom.xml`, identifiers, version, MIDI discovery, USB matching, encoder, padding, XOR shaping, and transfer scheduling are unchanged. The immutable upstream-basis branch was neither modified nor targeted.

## Commands and tools

Representative commands:

```text
git fetch origin --prune
git fetch upstream --prune --tags
git rev-parse origin/pushwig/main
git rev-parse origin/pushwig/main^{tree}
git rev-parse origin/pushwig/upstream-26.4.1
git rev-parse origin/pushwig/upstream-26.4.1^{tree}
git status --short
git diff --exit-code
git diff --cached --exit-code
git diff --check
git diff --name-only 033ccef8c64f08e8d8d41fa90d48fa06b326a1a1..a2e0341b7bccfa4e6b13614f4adffc2235f785f4
git log --oneline 033ccef8c64f08e8d8d41fa90d48fa06b326a1a1..a2e0341b7bccfa4e6b13614f4adffc2235f785f4
```

The prohibited-dependency search found only inherited shutdown `Executor`/`Thread` context in `Push2Display`; the new pipeline type contains none of the searched queue, executor, timer, buffer, encode, USB, socket, capture, or platform dependencies.

## What this proves

- The fork roles, integration authority, immutable upstream basis, feature parent, one-commit rule, and two-path envelope are exact.
- No unrelated source, build configuration, transport source, or authority repository file entered the source PR.
- The implementation head is independently reviewable before the central evidence commit.

## What this does not prove

- Git topology alone does not prove the Java build, bytecode behavior, pixels, timing, real controller behavior, or rollback; those are retained separately.
- This does not make a Push 2 hardware claim or an upstream acceptance claim.
