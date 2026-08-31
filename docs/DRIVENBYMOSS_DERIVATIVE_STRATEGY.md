# DrivenByMoss Derivative and Upstream Strategy

## Purpose

Track V needs a narrow DrivenByMoss derivative, but this repository should not absorb or rewrite the upstream project.

This document defines the repository, branch, build, install, and upstream-maintenance boundary before the first source modification.

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

`kasselvania/DrivenByMoss`, as a GitHub fork of `git-moss/DrivenByMoss`.

Owns:

- the minimal controller-extension source delta;
- buildable extension artifacts;
- unit or focused source tests added by this project;
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

The fork should retain a stable branch:

```text
pushwig/upstream-26.4.1
```

at that exact commit. This branch is immutable project basis, not a development branch.

Feature branches start from the accepted basis or from the newest separately accepted rebased basis. Do not silently rebase active work onto upstream `master` merely because upstream moved.

## Local remote topology

A development checkout should use:

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

## Branch conventions

Recommended stable branches:

```text
pushwig/upstream-26.4.1     # immutable accepted upstream basis
pushwig/main                # optional integration branch after first implementation acceptance
```

Recommended feature branches:

```text
pushwig/v1a-no-op-frame-pipeline
pushwig/v1b-synthetic-composition
pushwig/v1c-external-frame-ingress
```

Do not use a long-lived feature branch for multiple roadmap claims.

## Build baseline

Upstream 26.4.1 declares Java 21 and Maven 3.8.1 or newer. Its macOS release script uses a Temurin 21 JDK and runs:

```text
mvn clean install package -Dbitwig.extension.directory=target
```

V1A-0 must prove this or an exactly documented equivalent on the accepted Mac before source behavior changes.

A successful Maven exit is necessary but not sufficient. The artifact must be:

- hashed;
- inspected for version/manifest metadata;
- installed through a reversible process;
- loaded by Bitwig;
- exercised on the real Push fixture;
- removed or replaced by the exact official artifact during rollback.

A locally built artifact is not expected to be byte-identical to the official distribution unless evidence demonstrates reproducibility. Differences in ZIP/JAR ordering, timestamps, dependency packaging, or build environment are not automatically defects. Behavioral parity and source identity are the V1A-0 claims.

## Safe installation and rollback

The installed extension path proven by S0 is:

```text
$HOME/Documents/Bitwig Studio/Extensions/DrivenByMoss.bwextension
```

Before replacing it:

1. Stop Bitwig or use a proven safe extension-reload procedure.
2. Recompute the installed official artifact SHA-256.
3. Move the official file to a backup directory outside Bitwig's extension scan path.
4. Never overwrite the only copy of the official artifact.
5. Install exactly one `DrivenByMoss.bwextension` in the scan path.
6. Start/reload Bitwig and verify which artifact is active through retained version/hash/install-state evidence.
7. Execute the relevant real-device acceptance checklist.
8. At slice completion, restore the official artifact unless the maintainer explicitly authorizes leaving the derivative installed.
9. Recompute and verify the restored official SHA-256:

```text
98dc3195ad8d911526e18b1005f09f69a1aedcb965b080565474104654345c5a
```

Do not leave duplicate DrivenByMoss extension files in directories Bitwig scans.

## Source-change discipline

The first implementation delta is intentionally narrow.

For V1A:

- insert a synchronous identity frame-pipeline seam at the accepted `Push2Display.send(IBitmap)` boundary;
- preserve the same `IBitmap` object in the no-op path;
- retain exactly one USB transport owner;
- do not alter USB encoding, buffers, endpoint matching, or transfer scheduling;
- do not introduce capture, IPC, overlays, raw frame copies, new queues, or platform-specific types.

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

A controller-extension implementation PR should therefore be paired, when needed, with a narrow central evidence/status PR rather than committing generated extension binaries into either repository.

## Initial sequence

```text
S0
  official artifact + exact source + display seam proven
        |
        v
V1A-0
  fork + exact source build + temporary install + rollback proven
        |
        v
V1A
  identity PushFramePipeline implemented and measured
        |
        v
V1B
  synthetic project-owned pixels composed
```

This sequence isolates build/install failures from frame-pipeline failures and keeps the first behavioral source change small enough to review rigorously.
