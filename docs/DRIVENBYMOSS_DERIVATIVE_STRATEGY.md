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
- visual-source, raster, external-ingress, capture, appliance, and hardware roadmaps.

It does not vendor DrivenByMoss source or generated extension binaries.

### Controller implementation

`kasselvania/DrivenByMoss`, a true fork of `git-moss/DrivenByMoss`.

Owns:

- the minimal controller-extension source delta;
- buildable LGPL derivative source;
- contribution-ready commits;
- upstream synchronization;
- semantic redraw, composition, raster consumption, and later bounded external-frame intake.

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
commit: 663d719207ef58ec84b4d235c43211ec5da43605
tree:   c4e42825d069421a44b3241349de9a7c6453a3ad
```

The integration contains accepted source heads:

```text
V1A:   6e1e4cbd2e725a7951e5b4dc1278fbb6e7b5d61c
V1B:   a2e0341b7bccfa4e6b13614f4adffc2235f785f4
V1C:   4b3326eddcf2d890de3baa10b93f6e80842d41e1
V1D-1: 3c3ca02ff81ab5ce110ae3d714e20b5fca05a03f
```

Feature and research work begins from the exact current accepted `pushwig/main` unless a separate basis-upgrade decision authorizes otherwise.

Accepted central V1D-1 evidence:

```text
commit: a02c9c772da38bfdbc89dfff751c9617cd397c02
tree:   62b4edce8d649266cda65a638d26113692eaef04
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

V1C-0, V1D-0, and V1D-2-0 are architecture-selection slices.

They may use temporary:

- local branches and worktrees;
- commits and patches;
- harnesses and generated patterns;
- external generated-frame producers;
- aggregate-only instrumentation;
- derivative build artifacts outside Git.

They must not:

- merge prototypes into `pushwig/main`;
- open a production source PR merely to archive an experiment;
- copy derivative source into the central repository;
- leave instrumentation or test credentials in an accepted artifact;
- change `PushUsbDisplay` to avoid proving the correct higher-level ownership model;
- capture proprietary Bitwig/plugin pixels before the generated external-frame boundary is accepted.

The central evidence retains exact candidate identities, protocol/source/producer hashes, changed paths, build/artifact hashes, correctness/performance, thread/buffer ownership, real-fixture/rollback results, and one selected production seam or one precise blocker.

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

## Accepted display and raster ownership

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
        -> complete current-semantic redraw
        -> current valid local vector visual or no visual
        -> same persistent IBitmap
        -> unchanged PushUsbDisplay
```

The previous composed output is never restoration authority.

### V1D-1 — production raster sink

```text
current semantic redraw
        -> complete opaque-BGRA request validation
        -> absolute bulk row writes, or no mutation
        -> same logical IBitmap
        -> unchanged PushUsbDisplay
```

Accepted production contract:

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

`BitmapImpl` privately owns the Bitwig bitmap memory view and all target support, request, alpha, and thread checks. The controller-facing interface contains no Bitwig, macOS, capture, or USB type.

The writer is all-or-nothing, synchronous, same-bitmap, and allocation-free per application. Default, V1B, V1C, raster, and all-property precedence paths remain accepted. `PushUsbDisplay` remains unchanged and sole-owned.

## V1D-2-0 external-ingress discipline

V1D-2-0 selects the transport and process-to-display handoff before production source is opened.

Primary contract:

```text
external generated producer
        -> local complete-message transport
        -> fixed latest-frame publication
        -> nonblocking display-owned adoption
        -> accepted V1D-1 writer
```

The receiver thread never writes the bitmap. The display thread never performs network I/O or blocks on the receiver.

Candidate order:

1. loopback-only versioned TCP framing plus one receiver thread and fixed staging/published/consumer storage;
2. Unix-domain socket with the same bounded handoff if TCP fails;
3. memory-mapped double buffer only if socket candidates fail;
4. precise blocked result.

Any selected architecture must:

- use a hard frame/message cap known before payload read;
- publish only complete frames;
- allocate no frame array/object per message;
- keep one active producer and fixed thread count;
- define session identity and strictly increasing per-session sequence;
- use local monotonic receipt time for freshness;
- use latest-frame-wins rather than an application queue;
- prevent receiver mutation of display-consumed bytes;
- clear old session authority on disconnect/replacement;
- map no producer, clear, crash, staleness, malformed/truncated/oversized input, failed authentication/protocol, and failed raster application to exact semantic-only output;
- shut down boundedly even with a silent or partial-message producer;
- retain one unchanged Push USB writer.

The research uses generated external test cards only. ScreenCaptureKit and real Bitwig/plugin capture remain V2.

## Production posture after V1D-2-0

If selected, V1D-2 implements the exact decided receiver/protocol/store and a temporary generated producer proof.

A likely production source PR may need responsibilities for:

- external frame protocol parsing;
- receiver lifecycle;
- fixed latest-frame storage;
- display-thread external raster pipeline;
- pipeline shutdown ownership;
- `Push2Display` startup selection and cleanup.

The exact paths and interface shape are not pre-authorized until V1D-2-0 `decision.md` selects them.

The later external frame contract should carry bounded host-neutral information such as source identity/role, dimensions, stride, pixel format, sequence, local receipt state, validity/stale reason, confidence, and bytes. V1D-2-0 may choose a narrower first wire format and evolve it explicitly.

V2 then replaces the temporary generated producer with a normal macOS helper that discovers and captures dedicated windows. Apple types remain inside that helper.

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

Source lives in the fork. Build, artifact, pixel, protocol, performance, fixture, rollback, and decision evidence lives in the central repository. Temporary research code is retained by hashes and methodology rather than promoted into accepted source merely for archival convenience.

## Current sequence

```text
S0        accepted fixture/source/display seam
V1A-0     accepted fork/build/install/rollback baseline
V1A       accepted identity frame pipeline
V1B       accepted static bounded vector composition
V1C-0     accepted dynamic restoration architecture
V1C       accepted production dynamic local lifecycle
V1D-0     accepted direct bulk raster primitive
V1D-1     accepted production local raster sink
V1D-2-0   active external latest-frame ingress selection
V1D-2     future production external generated-frame ingress
V2        future macOS window capture
```
