# DrivenByMoss Derivative and Upstream Strategy

## Purpose

Track V needs a narrow DrivenByMoss derivative, while the central repository owns product authority, cross-component contracts, retained evidence, and roadmap decisions.

## Repository roles

### Central authority

`kasselvania/standalone-BitWig-push`

Owns:

- architecture and active-slice authority;
- accepted source bases;
- evidence and technical decisions;
- visual-source, raster, IPC, capture, appliance, and hardware roadmaps.

It does not vendor DrivenByMoss source or generated extension binaries.

### Controller implementation

`kasselvania/DrivenByMoss`, a true fork of `git-moss/DrivenByMoss`.

Owns:

- the minimal controller-extension source delta;
- buildable LGPL derivative source;
- contribution-ready commits;
- upstream synchronization;
- production code for semantic redraw, composition, raster consumption, and later external-frame intake.

## Accepted branches and bases

Immutable upstream basis:

```text
version/tag: 26.4.1
branch:      pushwig/upstream-26.4.1
commit:      fd03245ab38fa5149c45934051d937ee9fda6d08
tree:        edd2ad636b0aa1f39919f0ffd05c968015450075
```

Accepted project integration:

```text
branch: pushwig/main
commit: 852b520933eed87fbe496a04b5c18819a10b3564
tree:   d03a372e2efcf41b22cef46501e08efbfb0c0036
```

The integration contains accepted source heads:

```text
V1A: 6e1e4cbd2e725a7951e5b4dc1278fbb6e7b5d61c
V1B: a2e0341b7bccfa4e6b13614f4adffc2235f785f4
V1C: 4b3326eddcf2d890de3baa10b93f6e80842d41e1
```

Feature and research work begins from the exact current accepted `pushwig/main` unless a separate basis-upgrade decision authorizes otherwise.

Accepted V1D-0 central decision:

```text
commit: 63dc42ba28356a30bdbd1f54c804c91f49a659c0
tree:   1184afeb7c00ee86a1c298df539d3267475ce6b3
```

## Local remote topology

```text
origin   git@github.com:kasselvania/DrivenByMoss.git
upstream https://github.com/git-moss/DrivenByMoss.git
```

Before each source or research slice, retain:

```text
git remote -v
git fetch origin --prune
git fetch upstream --prune --tags
git rev-parse <basis>
git rev-parse <basis>^{tree}
git status --short
```

Never silently move work to fork `master` or upstream `master`.

## Production PR convention

Production branches include:

```text
pushwig/v1a-no-op-frame-pipeline
pushwig/v1b-static-synthetic-overlay
pushwig/v1c-dynamic-local-composition
pushwig/v1d1-local-raster-composition
pushwig/v1d2-external-frame-ingress
```

A production implementation slice normally produces:

1. one narrow source PR in `kasselvania/DrivenByMoss`, targeting `pushwig/main`;
2. one narrow evidence PR in the central repository;
3. exact cross-references between the two and the active issue;
4. exact tested heads left open until technical-lead review.

## Research-slice exception

V1C-0 and V1D-0 were architecture-selection slices.

They could use temporary local branches, worktrees, commits, patches, harnesses, generated patterns, aggregate-only instrumentation, and derivative artifacts outside Git. They could not merge prototype source or open a production source PR merely to archive an experiment.

Their accepted central evidence retains exact candidate identities, changed paths, build/artifact hashes, correctness/performance, real-fixture/rollback results, and one selected production seam.

## Accepted build and rollback baseline

Build with the explicit accepted environment:

```text
env \
  JAVA_HOME=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home \
  PATH=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin \
  mvn clean install package -Dbitwig.extension.directory=target
```

Accepted toolchain:

```text
Java:  Homebrew OpenJDK 21.0.11
Maven: 3.9.16
```

Canonical extension path:

```text
$HOME/Documents/Bitwig Studio/Extensions/DrivenByMoss.bwextension
```

Accepted official artifact SHA-256:

```text
98dc3195ad8d911526e18b1005f09f69a1aedcb965b080565474104654345c5a
```

Never overwrite the only official copy. Replace extensions only while Bitwig is stopped, keep exactly one scanned artifact, and restore/reverify the official artifact after every live derivative experiment unless explicitly directed otherwise.

## Accepted display ownership

### V1A — frame seam

```text
complete semantic IBitmap
        -> PushFramePipeline.process
        -> same IBitmap
        -> unchanged PushUsbDisplay
```

### V1B — static diagnostic

```text
pushwig.syntheticOverlay=true
        -> one fixed bounded vector render
        -> same IBitmap
```

### V1C — current-semantic dynamic lifecycle

```text
newest copied ModelInfo
        -> retain before render decision
        -> complete current-semantic redraw in selected dynamic mode
        -> current valid local vector visual or no visual
        -> same persistent IBitmap
        -> unchanged PushUsbDisplay
```

The previous composed output is never restoration authority. Default displays retain dirty rendering through a protected hook that defaults false. Only selected dynamic Push modes request current-model redraw.

## Accepted V1D-0 raster decision

V1D-0 selected a direct writable bitmap-region capability owned by the Bitwig bitmap adapter.

The first accepted local contract is:

```java
boolean writeRasterRegion (
    RasterPixelFormat format,
    byte[] source,
    int sourceOffset,
    int sourceStride,
    int destinationX,
    int destinationY,
    int width,
    int height);
```

The first format is opaque BGRA8888. Complete geometry, overflow, source length, alpha, destination support, and thread validation must finish before the first absolute bulk row write. `false` means zero destination mutation.

The controller-facing contract contains no Bitwig `Bitmap`, `MemoryBlock`, `ByteBuffer`, macOS handle, capture object, or USB type. `BitmapImpl` alone owns the cached destination view and host-specific layout checks.

V1D-0 proved small, padded-stride, medium, and full-frame writes, V1C restoration, 25 malformed classes, zero partial invalid writes, green full-frame timing, real Push behavior, and exact rollback.

## V1D-1 production discipline

V1D-1 implements the selected sink with locally generated byte frames.

Expected source paths:

```text
BitmapImpl.java
Push2Display.java
DynamicLocalRasterPushFramePipeline.java
IRasterWritableBitmap.java
RasterPixelFormat.java
```

Any additional source path requires authority before editing.

The production source must:

- preserve V1C current-semantic redraw as restoration authority;
- use one private adapter-owned cached destination view;
- validate the complete request and opaque alpha before mutation;
- use absolute bulk row writes;
- bind and enforce the synchronous composition thread safely;
- reject unsupported targets and malformed requests with exact semantic-only output;
- retain the same logical bitmap and one `PushUsbDisplay` writer;
- preserve default, V1B static, and V1C vector paths;
- add `pushwig.dynamicLocalRaster=true` with raster > vector > static > default precedence;
- exercise SMALL, ODD_PADDED, MEDIUM, FULL, REPLACEMENT, NONE, STALE, INVALID, and MALFORMED local states;
- add no external producer, IPC, scaling, blending, or capture.

`BitmapImpl` is currently a public record. If production caching requires conversion to a final class, preserve the public constructor and `bitmap()` accessor, and preserve record-equivalent observable behavior unless exact evidence demonstrates no dependency.

The exact proposed head must repeat all correctness, negative-validation, allocation, tail-latency, real-fixture, and rollback evidence.

## External-frame posture after V1D-1

V1D-2 may then define a bounded host-neutral current-frame representation with source identity/role, dimensions, stride, pixel format, sequence, timestamp, validity, stale reason, confidence, and bytes.

The controller consumer must be nonblocking, use latest-frame-wins storage, and map absence, crash, staleness, malformed data, restart, permission failure, and resolver abstention to exact semantic-only output through V1C and the V1D-1 sink.

V1D-1's caller-owned `byte[]` is not a promise of a zero-copy external wire format. Producer-buffer ownership, copy-versus-zero-copy, shared-memory lifetime, and sequence/freshness remain V1D-2 authority.

## Upstream synchronization

Upstream changes require a separate basis-upgrade process:

1. inspect release notes and relevant source diffs;
2. identify Push display, bitmap, controller setup, USB, or Bitwig API changes;
3. open a basis-upgrade issue;
4. rerun clean build and fixture baseline;
5. replay accepted project changes in reviewable commits;
6. update central authority only after acceptance.

Do not allow automated rebases or dependency tooling to rewrite the accepted basis silently.

## Licensing and evidence boundary

DrivenByMoss retains upstream LGPL licensing and notices. Modified source remains available under compatible terms and must not imply upstream endorsement.

Source lives in the fork. Build, artifact, pixel, performance, fixture, rollback, and decision evidence lives in the central repository. Temporary research code is retained by hashes and methodology rather than promoted into accepted source merely for archival convenience.

## Current sequence

```text
S0      accepted fixture/source/display seam
V1A-0  accepted fork/build/install/rollback baseline
V1A    accepted identity frame pipeline
V1B    accepted static bounded vector composition
V1C-0  accepted dynamic restoration architecture
V1C    accepted production dynamic local lifecycle
V1D-0  accepted direct bulk raster primitive
V1D-1  active production local raster lifecycle
V1D-2  future external latest-frame ingress
V2      future macOS window capture
```
