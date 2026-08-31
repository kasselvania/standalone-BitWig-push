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

The immutable basis branch must never receive project implementation merges.

Current accepted integration state:

```text
pushwig/main commit: 033ccef8c64f08e8d8d41fa90d48fa06b326a1a1
pushwig/main tree:   9aec7429ff093addee001a62a5a07309708fd592
```

That merge contains the exact reviewed V1A source head `6e1e4cbd2e725a7951e5b4dc1278fbb6e7b5d61c`.

Feature branches start from the current accepted `pushwig/main` head or from a newer basis accepted through a separate basis-upgrade decision. Do not silently rebase active work onto upstream `master` merely because upstream moved.

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
pushwig/v1b-static-synthetic-overlay
pushwig/v1c-external-frame-ingress
```

Do not use a long-lived feature branch for multiple roadmap claims.

Each implementation slice should normally produce:

1. one narrow source branch and PR in `kasselvania/DrivenByMoss`, targeting `pushwig/main`;
2. one narrow evidence PR in `kasselvania/standalone-BitWig-push`;
3. exact cross-references between both PRs and the active central issue.

The source PR and central evidence PR remain unmerged until technical-lead review of the exact heads.

## Accepted build baseline

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

A successful Maven exit remains necessary but never substitutes for artifact inspection, Bitwig loading, real-device acceptance, and rollback.

A locally built artifact is not expected to be byte-identical to the official distribution unless evidence demonstrates reproducibility. Differences in ZIP/JAR ordering, timestamps, line endings, dependency packaging, or build environment are not automatically defects. Source identity, bounded payload comparison, and behavioral parity are the relevant claims.

## Safe installation and rollback

The installed extension path proven by S0, V1A-0, and V1A is:

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

## Accepted V1A frame seam

V1A is merged and accepted.

Accepted path:

```text
complete semantic IBitmap
        -> PushFramePipeline.process
        -> exact same IBitmap reference
        -> unchanged PushUsbDisplay.send
```

Accepted source types:

```text
PushFramePipeline.java
PassThroughPushFramePipeline.java
Push2Display.java
```

V1A proved:

- one synchronous identity operation;
- no per-frame project allocation;
- no bitmap retention or pixel access;
- unchanged `PushUsbDisplay` source and bytecode;
- exact one-writer preservation;
- Java 21/Maven build success;
- all eleven real Push checks;
- no visible change;
- ordinary shutdown;
- exact official rollback.

Do not repeat V1A's identity proof in later slices except as regression evidence.

## V1B source-change discipline

V1B is the first visible-pixel experiment.

The project is testing in-place post-semantic drawing on the persistent bitmap. The test must remain bounded because a second `IBitmap.render` callback has not yet been proven to preserve existing pixels.

V1B must:

- branch from accepted `pushwig/main` at `033ccef8c64f08e8d8d41fa90d48fa06b326a1a1`;
- preserve pass-through behavior by default;
- use startup-scoped property `pushwig.syntheticOverlay=true` as the preferred diagnostic activation;
- read activation once at display construction;
- select one static synthetic-overlay pipeline when enabled;
- draw one fixed opaque two-color mark inside the declared rectangle;
- use one reusable renderer rather than allocate a renderer per frame;
- invoke one additional synchronous `IBitmap.render` callback per enabled send;
- return the same `IBitmap` reference;
- retain no bitmap/frame after the call;
- leave `PushUsbDisplay`, its endpoint, buffers, encoding, padding, XOR shaping, executor, and lifecycle unchanged;
- prove outside-region preservation and repeated-send stability;
- measure processing cost with temporary, uncommitted instrumentation;
- prove property-off startup, property-on startup, property-off recovery, real Push behavior, and exact official rollback.

Expected production delta:

```text
Push2Display.java
SyntheticOverlayPushFramePipeline.java
```

The accepted V1A interface and pass-through implementation should not require behavioral change.

V1B must not introduce:

- moving/animated pixels;
- runtime hot switching;
- damage restoration;
- a second output bitmap;
- raw pixel snapshots/copies in committed code;
- `PushDisplayTransport`;
- `PushConfiguration` or UI settings;
- queues, threads, executors, timers, IPC, sockets, shared memory;
- ScreenCaptureKit or platform types;
- external frames or visual-source contracts.

If the second render callback clears or unpredictably damages semantic pixels, stop and retain the failure. Do not widen the slice into transport encoding or raw-frame copying.

See [`V1B_SYNTHETIC_COMPOSITION.md`](V1B_SYNTHETIC_COMPOSITION.md).

## Later source-change discipline

V1C may introduce a platform-neutral immutable `VisualSourceFrame` ingress only after V1B proves the local composition primitive.

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

A controller-extension implementation PR is paired with a narrow central evidence PR. Generated extension binaries are not committed into either repository.

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
V1A    accepted
  identity PushFramePipeline merged and proven
        |
        v
V1B    active
  startup-scoped static synthetic mark + preservation proof
        |
        v
V1C
  external generated frame ingress
```

The sequence isolates each uncertainty domain: source custody, identity seam, direct composition, and external ingress.