# DrivenByMoss Derivative and Upstream Strategy

## Purpose

Track V needs a narrow DrivenByMoss derivative, but the central project repository must not absorb or rewrite the upstream source tree.

This document defines repository roles, accepted branches, build/install discipline, evidence boundaries, production source topology, and upstream synchronization.

## Repository roles

### Project authority repository

`kasselvania/standalone-BitWig-push`

Owns:

- product architecture;
- active-slice authority;
- cross-component contracts;
- accepted source bases;
- retained evidence and technical decisions;
- visual-source, compositor, appliance, and hardware roadmaps.

It does not vendor DrivenByMoss source or generated extension binaries.

### Controller-extension implementation repository

`kasselvania/DrivenByMoss`, a true GitHub fork of `git-moss/DrivenByMoss`.

Owns:

- the minimal controller-extension source delta;
- buildable derivative source;
- focused source tests or external verification harnesses where authorized;
- upstream synchronization and contribution-ready commits;
- LGPL-preserving history and notices.

## Upstream basis and branches

Accepted upstream basis:

```text
Version: 26.4.1
Tag:     26.4.1
Commit:  fd03245ab38fa5149c45934051d937ee9fda6d08
Tree:    edd2ad636b0aa1f39919f0ffd05c968015450075
```

Stable fork branches:

```text
pushwig/upstream-26.4.1  # immutable accepted upstream basis
pushwig/main             # accepted project integration branch
```

The immutable branch never receives project implementation merges.

Current accepted integration state:

```text
branch: pushwig/main
commit: 1ae0b74f383314d170a5960ca763bdf9c319e787
tree:   a81e5c4330b31f36845c25e98e322990d62f0c67
```

That merge contains:

- accepted V1A source head `6e1e4cbd2e725a7951e5b4dc1278fbb6e7b5d61c`;
- accepted V1B source head `a2e0341b7bccfa4e6b13614f4adffc2235f785f4`.

Feature branches begin from the exact currently accepted `pushwig/main` unless a separate basis-upgrade decision says otherwise.

## Local remote topology

A development checkout uses:

```text
origin   git@github.com:kasselvania/DrivenByMoss.git
upstream https://github.com/git-moss/DrivenByMoss.git
```

Before each source slice, record:

```text
git remote -v
git fetch origin --prune
git fetch upstream --prune --tags
git rev-parse <basis>
git rev-parse <basis>^{tree}
git status --short
```

Do not silently move an active slice to upstream `master` or fork `master`.

## Branch and pull-request conventions

Production feature examples:

```text
pushwig/v1a-no-op-frame-pipeline
pushwig/v1b-static-synthetic-overlay
pushwig/v1c-dynamic-local-composition
pushwig/v1d-external-frame-ingress
```

A production implementation slice normally produces:

1. one narrow source branch and PR in `kasselvania/DrivenByMoss`, targeting `pushwig/main`;
2. one narrow evidence PR in `kasselvania/standalone-BitWig-push`;
3. exact cross-references between both PRs and the active central issue.

Both exact heads remain unmerged until technical-lead review.

## Research-slice exception

V1C-0 was an architecture-selection slice rather than a production implementation slice.

It used temporary local worktrees, a local research commit, harnesses, and uncommitted instrumentation without opening a source PR.

Accepted central evidence retained:

- exact accepted basis;
- candidate/patch/harness hashes;
- changed-path summaries;
- build and artifact hashes;
- pixel correctness and performance;
- real-fixture and rollback evidence;
- one precise production decision.

That decision selected retained current semantic redraw. The local research commit is evidence, not an accepted source branch. V1C must not cherry-pick it wholesale.

## Accepted build baseline

DrivenByMoss builds use:

```text
Java:  Homebrew OpenJDK 21.0.11
Maven: 3.9.16
```

The host default Java selection is not authoritative.

Use:

```text
env \
  JAVA_HOME=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home \
  PATH=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin \
  mvn clean install package -Dbitwig.extension.directory=target
```

A successful Maven exit is necessary but does not replace artifact inspection, exact source custody, real-device acceptance, or rollback.

Generated `.bwextension` files are not committed.

## Safe installation and rollback

Accepted installed path:

```text
$HOME/Documents/Bitwig Studio/Extensions/DrivenByMoss.bwextension
```

Accepted official SHA-256:

```text
98dc3195ad8d911526e18b1005f09f69a1aedcb965b080565474104654345c5a
```

Before replacing it:

1. stop Bitwig normally and verify relevant processes ended;
2. recompute the installed official hash;
3. move the official file intact outside all extension scan paths;
4. verify the backup hash;
5. install exactly one tested derivative artifact at the canonical filename;
6. verify its exact hash and sole-scanned state;
7. run the slice-specific real-fixture acceptance;
8. quit normally;
9. move the derivative outside the scan path;
10. restore the untouched official file;
11. reverify the exact official hash and sole-scanned state;
12. relaunch sufficiently to prove official loadability.

Never overwrite the only official copy. Never leave duplicate scanned DrivenByMoss artifacts.

## Accepted source path

### V1A identity seam

```text
complete semantic IBitmap
        -> PushFramePipeline.process
        -> same IBitmap
        -> unchanged PushUsbDisplay
```

### V1B static diagnostic composition

Default:

```text
PassThroughPushFramePipeline.INSTANCE
```

Startup diagnostic:

```text
pushwig.syntheticOverlay=true
        -> SyntheticOverlayPushFramePipeline.INSTANCE
        -> one fixed bounded render callback
        -> same IBitmap
```

V1B proved zero outside-region mismatches and bounded cost for a static mark.

### V1C-0 selected restoration model

```text
newest copied ModelInfo
        -> retain before render decision
        -> complete semantic redraw for dynamic-local mode
        -> current valid local visual or no visual
        -> same persistent IBitmap
        -> unchanged PushUsbDisplay
```

The previous composed output is never restoration authority.

## V1C production source discipline

V1C begins directly from accepted `pushwig/main`.

Expected source envelope:

```text
src/main/java/de/mossgrabers/framework/controller/display/AbstractGraphicDisplay.java
src/main/java/de/mossgrabers/controller/ableton/push/controller/Push2Display.java
src/main/java/de/mossgrabers/controller/ableton/push/controller/DynamicLocalPushFramePipeline.java
```

The production source must:

- retain the newest copied `ModelInfo` before the render decision;
- add one protected default-false redraw hook;
- preserve ordinary dirty rendering;
- request forced redraw only for selected dynamic-local Push mode;
- preserve pass-through and V1B static selection;
- use one package-private per-display dynamic pipeline;
- cover movement, overlap, resizing, replacement, none, stale, and invalid states;
- return the same bitmap;
- retain no historical frame or bitmap;
- preserve one USB writer;
- measure exact performance and allocations;
- prove overlay-only and notification lifecycle correctness.

The local V1C-0 research commit may be inspected but must not be promoted as production merely by cherry-picking or renaming.

## Property selection

Startup properties are read once:

```text
pushwig.syntheticOverlay
pushwig.dynamicLocalVisual
```

Precedence:

```text
dynamic local > static synthetic > pass-through
```

Exactly one pipeline is selected.

No user-facing setting is added in V1C.

## External-frame boundary

External-frame IPC is V1D, after V1C is accepted.

V1D may replace the local diagnostic state source, but it may not replace semantic restoration ownership.

The external input contract must map absence, stale sequence, invalid metadata, producer failure, permission denial, and resolver abstention to:

```text
current semantic redraw
        -> no visual
        -> semantic-only output
```

Capture/platform types remain outside the controller extension.

## Upstream synchronization

Upstream may advance while the project remains based on 26.4.1.

Use a dedicated basis-upgrade process:

1. inspect upstream release notes and relevant diffs;
2. identify changes to Push display, bitmap abstraction, controller setup, USB transport, or Bitwig API version;
3. open a basis-upgrade issue;
4. rerun the clean build and real-device baseline;
5. replay accepted project changes in reviewable commits;
6. update central authority only after acceptance.

Do not let automated dependency tools or casual rebases rewrite the accepted basis.

## Licensing and redistribution

DrivenByMoss retains its upstream LGPL license and copyright notices.

The fork must:

- preserve license files and source notices;
- make modified source available under compatible terms;
- identify project-authored changes clearly;
- avoid implying endorsement by the upstream author;
- avoid redistributing Bitwig, Ableton, or other proprietary binaries/assets.

The central repository's MIT license applies only to original code and documentation not derived from differently licensed upstream code.

## Evidence boundary

Source changes belong in the DrivenByMoss fork.

Cross-repository build, artifact, fixture, performance, pixel-correctness, and decision evidence belongs in the central repository.

Temporary research code is identified by hashes and methodology rather than promoted into accepted source merely for archival convenience.

## Current sequence

```text
S0      accepted fixture, source pin, and display seam
V1A-0   accepted fork/build/install/rollback baseline
V1A     accepted identity frame pipeline
V1B     accepted static bounded synthetic overlay
V1C-0   accepted dynamic restoration architecture decision
V1C     active production dynamic local composition
V1D     future external generated-frame ingress
```

This sequencing prevents a process boundary or capture backend from papering over frame-restoration correctness.
