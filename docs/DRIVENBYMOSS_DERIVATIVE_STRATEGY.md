# DrivenByMoss Derivative and Upstream Strategy

## Purpose

Track V needs a narrow DrivenByMoss derivative, while the central repository owns product authority, cross-component contracts, retained evidence, and roadmap decisions.

## Repository roles

### Central authority

`kasselvania/standalone-BitWig-push`

Owns architecture, active-slice authority, accepted source bases, retained evidence, protocol/raster/capture contracts, and Track V/A/H roadmap decisions. It does not vendor DrivenByMoss source or generated extension binaries.

### Controller implementation

`kasselvania/DrivenByMoss`, a true fork of `git-moss/DrivenByMoss`.

Owns the minimal LGPL-compatible controller-extension source delta, buildable derivative source, contribution-ready commits, upstream synchronization, semantic redraw, raster composition, external frame intake, and the sole accepted Push display transport path.

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

Contained accepted source heads:

```text
V1A:   6e1e4cbd2e725a7951e5b4dc1278fbb6e7b5d61c
V1B:   a2e0341b7bccfa4e6b13614f4adffc2235f785f4
V1C:   4b3326eddcf2d890de3baa10b93f6e80842d41e1
V1D-1: 3c3ca02ff81ab5ce110ae3d714e20b5fca05a03f
```

Accepted central decisions/evidence:

```text
V1D-1:   a02c9c772da38bfdbc89dfff751c9617cd397c02
V1D-2-0: 99e09e2a651c92ac6710fdc88c4675a874a56600
```

Feature and research work begins from the exact current accepted `pushwig/main` unless a separate basis-upgrade decision authorizes otherwise.

## Local remote topology

```text
origin   git@github.com:kasselvania/DrivenByMoss.git
upstream https://github.com/git-moss/DrivenByMoss.git
```

Before each source or research slice, retain remotes, fetched refs/tags, exact commit/tree, and clean status. Never silently move work to fork `master` or upstream `master`.

## Production PR convention

Production branches include:

```text
pushwig/v1a-no-op-frame-pipeline
pushwig/v1b-static-synthetic-overlay
pushwig/v1c-dynamic-local-composition
pushwig/v1d1-local-raster-composition
pushwig/v1d2-external-frame-ingress
```

A production slice normally produces:

1. one narrow source PR in `kasselvania/DrivenByMoss`, targeting `pushwig/main`;
2. one narrow central evidence PR;
3. exact cross-references between both and the active issue;
4. exact tested heads left open until technical-lead review.

## Accepted build and rollback baseline

Build with:

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

Canonical extension path and official artifact:

```text
$HOME/Documents/Bitwig Studio/Extensions/DrivenByMoss.bwextension
SHA-256: 98dc3195ad8d911526e18b1005f09f69a1aedcb965b080565474104654345c5a
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

### V1C — dynamic restoration

```text
newest copied ModelInfo
        -> complete current-semantic redraw
        -> current optional visual
        -> same persistent IBitmap
        -> unchanged PushUsbDisplay
```

Previous composed output is never restoration authority.

### V1D-1 — raster sink

```text
current semantic redraw
        -> host-neutral OPAQUE_BGRA8888 request
        -> complete validation and thread ownership
        -> absolute bulk row copies, or zero writes
        -> same logical IBitmap
        -> unchanged PushUsbDisplay
```

`IRasterWritableBitmap` carries only `RasterPixelFormat`, caller-owned `byte[]`, source offset/stride, destination x/y, and dimensions. `BitmapImpl` alone owns Bitwig memory and a private cached destination view. V1D-1's local generated raster lifecycle is proof scaffolding, not an external protocol.

## Accepted V1D-2-0 architecture

```text
external generated producer
        -> loopback TCP framed protocol v1
        -> capability-authenticated complete receive
        -> fixed staging + latest publication
        -> display-thread tryLock copy into fixed consumer bytes
        -> local monotonic freshness
        -> accepted V1D-1 writer
        -> same IBitmap
        -> unchanged PushUsbDisplay
```

Selected rules:

- bind exactly `127.0.0.1`, default/configurable port 45291, backlog 1, address reuse before bind;
- one active connection and one daemon receiver thread;
- fixed 80-byte network-order header;
- HELLO, FRAME, and CLEAR messages;
- 32-byte capability authentication before frame authority;
- nonzero 128-bit producer session plus receiver-local connection generation;
- positive strictly increasing sequence with legal gaps and no historical replay;
- maximum 614,400-byte opaque-BGRA payload;
- complete protocol/geometry/alpha validation before publication;
- fixed staging, publication, and display-consumer arrays;
- receiver blocking lock allowed only for publication; display uses `tryLock` only;
- local complete-receipt `System.nanoTime()` freshness, default 1,500 ms;
- exact semantic fallback after every absence/failure state;
- bounded close/join and immediate same-port restart.

## V1D-2 production discipline

V1D-2 implements the accepted architecture in exactly:

```text
Push2Display.java
ExternalRasterPushFramePipeline.java
ExternalRasterReceiver.java
LatestExternalRasterFrameStore.java
```

Any additional production path requires authority before editing.

The source must:

- preserve V1C current-semantic redraw as restoration authority;
- preserve the accepted V1D-1 sink without modification;
- read external activation/port/token-path/stale-timeout only at construction;
- give external ingress precedence over local raster/vector/static diagnostics;
- bind only IPv4 loopback;
- validate a private regular non-symlink 32-byte capability file before starting the receiver;
- use one receiver thread and fixed frame arrays;
- publish only complete authenticated current frames;
- use display `tryLock` and display-owned consumer bytes;
- perform no socket operation or blocking wait on the display thread;
- prevent the receiver from owning bitmap or writer objects;
- implement exact session/sequence/gap/reset/exhaustion and receipt-time freshness rules;
- map clear/disconnect/crash/stale/auth/protocol/truncation/malformed/oversize/writer/bind/shutdown failures to current semantics;
- keep `PushUsbDisplay` unchanged and sole-owned;
- pass five blocked-receive shutdown states, collision, restart, performance, fixture, and rollback gates.

The launcher/orchestrator owns token-file creation and cleanup. Fixed/configurable port plus token-file path is the V1D-2 handoff; a friendlier helper rendezvous belongs to later product work.

A connected local peer owns the single receiver slot until close or shutdown. The capability protects frame authority, not availability against a same-user process that can read the token or occupy the slot.

## External protocol status

Protocol v1 is an internal project protocol during V1D-2. It is exact enough for a conformance producer and later capture helper, but it is not yet promised as a stable public SDK surface.

The later helper must generate/crop/scale opaque BGRA frames outside DrivenByMoss, then publish them through this boundary. Apple capture objects never enter the controller extension.

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

Source lives in the fork. Build, artifact, protocol, timing, fixture, rollback, and decision evidence lives in the central repository. Temporary conformance producer/harness code is retained by hash and methodology rather than promoted into product source merely for archival convenience.

## Current sequence

```text
S0        accepted fixture/source/display seam
V1A-0     accepted fork/build/install/rollback baseline
V1A       accepted identity frame pipeline
V1B       accepted static bounded composition
V1C-0     accepted dynamic restoration architecture
V1C       accepted production dynamic local lifecycle
V1D-0     accepted direct bulk raster primitive
V1D-1     accepted production local raster sink
V1D-2-0   accepted external-ingress architecture
V1D-2     active production external latest-frame ingress
V2        future macOS dedicated-window capture
```
