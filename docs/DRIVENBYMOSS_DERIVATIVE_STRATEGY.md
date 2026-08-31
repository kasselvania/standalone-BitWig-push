# DrivenByMoss Derivative and Upstream Strategy

## Purpose

Track V needs a narrow DrivenByMoss derivative, but this repository should not absorb or rewrite the upstream project.

This document defines the repository, branch, build, install, evidence, review, and upstream-maintenance boundary for controller-extension source work.

## Repository roles

### Project authority repository

`kasselvania/standalone-BitWig-push`

Owns:

- product architecture;
- active-slice authority;
- cross-component contracts;
- evidence and acceptance results;
- visual-source, compositor, appliance, and hardware roadmaps;
- integration decisions that span more than DrivenByMoss.

It does **not** vendor the DrivenByMoss source tree.

### Controller-extension implementation repository

`kasselvania/DrivenByMoss`, a true GitHub fork of `git-moss/DrivenByMoss`.

Owns:

- the minimal controller-extension source delta;
- buildable extension artifacts;
- focused source tests or external verification harnesses where authorized;
- upstream synchronization and contribution-ready commits;
- LGPL-preserving source history and notices.

## Accepted upstream basis

S0 pinned the working installed extension to:

```text
Version: 26.4.1
Tag:     26.4.1
Commit:  fd03245ab38fa5149c45934051d937ee9fda6d08
Tree:    edd2ad636b0aa1f39919f0ffd05c968015450075
```

The fork retains two distinct branches:

```text
pushwig/upstream-26.4.1  # immutable accepted upstream basis
pushwig/main             # project integration branch
```

Both branches began at the exact accepted commit. The immutable basis branch must never receive project implementation merges. Feature pull requests target `pushwig/main`.

Feature branches start from the currently accepted `pushwig/main` head or from a newer basis accepted through a separate basis-upgrade decision. Do not silently rebase active work onto upstream `master` merely because upstream moved.

## Local remote topology

A development checkout uses:

```text
origin   git@github.com:kasselvania/DrivenByMoss.git
upstream https://github.com/git-moss/DrivenByMoss.git
```

Equivalent authenticated URLs are acceptable, but `origin` must be the project fork and `upstream` must be the authoritative upstream repository.

Before each slice, record:

```text
git remote -v
git fetch origin --prune
git fetch upstream --prune --tags
git rev-parse <basis>
git rev-parse <basis>^{tree}
git status --short
```

## Branch and pull-request conventions

Stable branches:

```text
pushwig/upstream-26.4.1
pushwig/main
```

Feature branches:

```text
pushwig/v1a-no-op-frame-pipeline
pushwig/v1b-synthetic-composition
pushwig/v1c-external-frame-ingress
```

Do not use a long-lived feature branch for multiple roadmap claims.

Each implementation slice should normally produce:

1. one narrow source branch and PR in `kasselvania/DrivenByMoss`, targeting `pushwig/main`;
2. one narrow evidence PR in `kasselvania/standalone-BitWig-push`;
3. exact cross-references between both PRs and the active central issue.

The source PR and central evidence PR remain unmerged until technical-lead review of the exact heads.

## Accepted V1A-0 build baseline

V1A-0 proved the exact unmodified 26.4.1 source on the accepted Mac.

Accepted toolchain:

```text
Java:  Homebrew OpenJDK 21.0.11
Maven: 3.9.16
```

The host default Java selection is not authoritative. DrivenByMoss builds must continue to select Java 21 explicitly:

```text
env \
  JAVA_HOME=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home \
  PATH=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin \
  mvn clean install package -Dbitwig.extension.directory=target
```

V1A-0 retained:

- a clean source build at the exact accepted commit/tree;
- local artifact SHA-256 `61ff21e5f21d96ee64bfe1b09c5971116f1f5075d5805bc015f0a168fe00b8f9`;
- bounded official-versus-local archive differences;
- sole-artifact temporary installation;
- eleven-row real Push behavioral parity;
- exact restoration of the official artifact.

A successful Maven exit remains necessary but never substitutes for artifact inspection, Bitwig loading, real-device acceptance, and rollback.

A locally built artifact is not expected to be byte-identical to the official distribution unless evidence demonstrates reproducibility. Differences in ZIP/JAR ordering, timestamps, line endings, dependency packaging, or build environment are not automatically defects. Source identity, bounded payload comparison, and behavioral parity are the relevant claims.

## Safe installation and rollback

The installed extension path proven by S0 and V1A-0 is:

```text
$HOME/Documents/Bitwig Studio/Extensions/DrivenByMoss.bwextension
```

Before replacing it:

1. Stop Bitwig or use a separately proven safe extension-reload procedure.
2. Recompute the installed official artifact SHA-256.
3. Move the official file to a backup directory outside Bitwig's extension scan path.
4. Never overwrite the only copy of the official artifact.
5. Install exactly one `DrivenByMoss.bwextension` in the scan path.
6. Start/reload Bitwig and prove which artifact is active through retained hash/install-state evidence plus real behavior.
7. Execute the slice-specific real-device acceptance checklist.
8. At slice completion, restore the official artifact unless the maintainer explicitly authorizes leaving a derivative installed.
9. Recompute and verify the restored official SHA-256:

```text
98dc3195ad8d911526e18b1005f09f69a1aedcb965b080565474104654345c5a
```

10. Confirm exactly one DrivenByMoss extension remains in every scanned directory.

## V1A source-change discipline

V1A is the first functional source change and is intentionally narrower than the complete future compositor architecture.

V1A must:

- insert a synchronous identity frame-pipeline seam at the accepted `Push2Display.send(IBitmap)` boundary;
- preserve the same `IBitmap` object reference in the production no-op path;
- keep the existing shutdown/null guard;
- call the pipeline once and the existing USB display once per eligible send;
- retain exactly one USB transport owner;
- leave `PushUsbDisplay` source, encoding, buffers, endpoint matching, signal shaping, executor, and transfer scheduling unchanged;
- avoid per-frame allocation, bitmap retention, pixel copies, queues, threads, timers, IPC, and platform-specific types.

Expected source envelope:

```text
Push2Display.java
PushFramePipeline.java
PassThroughPushFramePipeline.java
```

Do not introduce a `PushDisplayTransport` abstraction in V1A. Transport extraction can be considered only when a later claim actually needs it.

The first proof should use source/bytecode and same-toolchain base/head artifact comparison rather than permanent per-frame debug instrumentation. A temporary external identity harness is acceptable when it does not modify the project POM or production source.

Later source changes must remain separable so that useful generic improvements can be proposed upstream without requiring adoption of the entire appliance project.

## Upstream synchronization

Upstream may advance while the project works from 26.4.1.

Use an explicit synchronization process:

1. Inspect upstream release notes and relevant diffs.
2. Identify changes touching the Push display, bitmap abstraction, controller setup, USB transport, or Bitwig API version.
3. Create a dedicated basis-upgrade issue.
4. Re-run the accepted build and real-device baseline on the proposed new upstream commit.
5. Rebase or replay the project delta in a reviewable PR.
6. Update the central repository's pinned basis only after acceptance.

Do not let the fork drift indefinitely without recording its upstream relationship. Do not let automatic dependency tools rewrite the accepted basis without review.

## Licensing and redistribution

DrivenByMoss retains its upstream LGPL license and copyright notices.

The fork must:

- preserve upstream license files and source notices;
- make modified source available under compatible terms;
- identify project-authored changes clearly;
- avoid implying endorsement by the upstream author;
- avoid redistributing Bitwig, Ableton, or other proprietary binaries/assets.

The central repository's MIT license applies only to original code and documentation not derived from differently licensed upstream code.

## Evidence boundary

Build and implementation evidence belongs in the central repository because it supports cross-repository project claims.

Source changes belong in the DrivenByMoss fork.

A controller-extension implementation PR is paired, when needed, with a narrow central evidence PR. Generated extension binaries are not committed into either repository.

## Initial sequence

```text
S0     accepted
  official artifact + exact source + display seam proven
        |
        v
V1A-0  accepted
  fork + exact source build + temporary install + rollback proven
        |
        v
V1A    active
  identity PushFramePipeline implemented and proven
        |
        v
V1B
  synthetic project-owned pixels composed
```

This sequence isolates build/install failures from frame-pipeline failures and keeps the first behavioral source change small enough to review rigorously.
