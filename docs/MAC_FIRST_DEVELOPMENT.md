# Mac-First Software Development Fixture

## Decision

The active Track V development fixture is the maintainer's macOS computer running Bitwig Studio, the `kasselvania/DrivenByMoss` derivative, and Push 3 Controller over ordinary USB.

This changes implementation order, not product scope:

- macOS supplies the fastest source/build/install/measurement loop;
- Steam Deck remains the first Track A appliance host and named Linux portability fixture;
- semantic, raster, frame, resolver, and adapter contracts remain operating-system neutral;
- no ScreenCaptureKit, Core Graphics, or other macOS object may leak into the controller extension or public frame contracts.

## Accepted Mac progress

### S0 through V1B

Accepted the exact Mac + Bitwig + Push fixture, official DrivenByMoss source/artifact provenance, derivative build/install/rollback, the project-owned frame seam, and the first bounded static visual pixels.

### V1C-0 and V1C

Selected and implemented current-semantic redraw as dynamic restoration authority:

```text
newest copied ModelInfo
        -> complete current-semantic redraw
        -> current optional local vector visual
        -> same persistent IBitmap
        -> unchanged PushUsbDisplay
```

V1C proved movement, overlap, resize, replacement, semantic-only states, semantic changes under coverage, overlay-only updates, notification lifecycle, regression paths, bounded performance, real Push behavior, and exact rollback.

Accepted source:

```text
kasselvania/DrivenByMoss: pushwig/main
commit: 852b520933eed87fbe496a04b5c18819a10b3564
tree:   d03a372e2efcf41b22cef46501e08efbfb0c0036
```

### V1D-0 — bulk raster decision

V1D-0 selected a direct writable bitmap-region capability inside the Bitwig bitmap adapter.

The accepted real bitmap was:

```text
format:           ARGB32
size:             960x160
memory:           614400 bytes
rows:             tightly packed, 3840 bytes
view:             writable, direct, non-array-backed
observed channels: BGRA
origin:           top-left
alpha:            opaque 0xFF
thread:           Control Surface Session
```

Distinct views aliased the same memory. A cached destination view stayed coherent through encode and the physical Push across 1,920 sends.

The selected host-neutral operation uses a caller-owned `byte[]`, primitive source/destination metadata, and `OPAQUE_BGRA8888`. Complete validation and alpha scanning precede the first absolute bulk row write; rejection performs no mutation.

V1D-0 proved:

- small, padded-stride, medium, full-frame, replacement, NONE, STALE, INVALID, malformed, and under-coverage semantic-update states;
- zero source-target, outside, restoration, semantic-only, and partial-invalid-write mismatches;
- 25 malformed classes rejected all-or-nothing;
- zero project-owned per-application allocation;
- green full-frame redraw-plus-write timing;
- all 34 real Push fixture rows;
- exact official rollback.

Accepted central evidence:

```text
commit: 63dc42ba28356a30bdbd1f54c804c91f49a659c0
tree:   1184afeb7c00ee86a1c298df539d3267475ce6b3
```

## Active Mac task: V1D-1 production local raster composition

V1D-1 now implements the selected sink as production source before any external producer exists.

The production shape is:

```text
current V1C semantic redraw
        -> locally generated current byte[] raster
        -> complete validation
        -> absolute bulk row copies, or no write
        -> same logical IBitmap
        -> unchanged PushUsbDisplay
```

Expected source envelope:

```text
BitmapImpl.java
Push2Display.java
DynamicLocalRasterPushFramePipeline.java
IRasterWritableBitmap.java
RasterPixelFormat.java
```

The local pipeline exercises SMALL, ODD_PADDED, MEDIUM, FULL, REPLACEMENT, NONE, STALE, INVALID, and MALFORMED states. It proves the real sink without introducing another process, transport, capture API, or final frame protocol.

`BitmapImpl` owns one private cached destination view and every host-specific layout check. The host-neutral interface exposes only the pixel format, caller-owned bytes, source offset/stride, destination x/y, width, height, and all-or-nothing boolean result.

The exact source head must preserve:

- default pass-through;
- V1B static mode;
- V1C vector mode;
- raster mode with explicit precedence;
- current-semantic restoration;
- one pipeline call;
- one unchanged `PushUsbDisplay.send`;
- exact official rollback.

It must also preserve the public constructor/accessor and observable record semantics if `BitmapImpl` changes from a record to a final class.

## Tail-latency posture

V1D-0's required full-frame path was green, but it retained:

```text
MEDIUM combined max:          17.679042 ms
mixed startup/interaction:    47.747125 ms
```

V1D-1 must repeat stable post-warmup per-size measurements and separate writer-only, semantic-redraw, GC, and scheduling context. A persistent writer regression blocks acceptance. An isolated host/scheduler outlier with bounded writer cost remains visible for technical review rather than being hidden with asynchronous machinery.

## What the Mac can still prove before the Deck returns

The Mac can establish:

1. production local raster application;
2. external latest-frame-wins ingress and freshness;
3. macOS dedicated-window capture;
4. one floating Bitwig native-device or plug-in visual lens;
5. semantic-seeded anchor benchmarks;
6. much of the public attached-mode experience.

The Mac cannot establish:

- Linux X11/Wayland/portal behavior;
- Flatpak/host IPC boundaries;
- Steam Deck power, battery, headless boot, or managed geometry;
- Linux support claims.

Those remain explicit later checkpoints.

## Revised sequence

```text
S0      accepted fixture and display seam
V1A-0   accepted fork/build/install baseline
V1A     accepted identity pipeline
V1B     accepted static bounded composition
V1C-0   accepted dynamic restoration selection
V1C     accepted dynamic local vector lifecycle
V1D-0   accepted bulk raster primitive
V1D-1   active production local raster lifecycle
V1D-2   external latest-frame ingress
V2      macOS dedicated-window capture
V2A     semantic-seeded anchor benchmark
V2P     Linux/Steam Deck checkpoint
```

## Future external-frame posture

Only after V1D-1 should a helper publish a platform-neutral raster frame containing bounded metadata such as source identity/role, dimensions, stride, pixel format, sequence, timestamp, validity, stale reason, confidence, and bytes.

The controller extension must:

- never wait for the producer;
- use latest-frame-wins rather than a queue;
- establish explicit producer/controller buffer ownership;
- validate before applying;
- preserve V1C current-semantic redraw;
- map helper absence, crash, stale sequence, invalid metadata, permission failure, and resolver abstention to exact semantic-only output.

V1D-1's `byte[]` sink does not predetermine the V1D-2 wire or shared-memory representation.

## macOS capture posture

Screen capture eventually belongs in a normal macOS helper application with stable permission identity. Dedicated top-level native-device and plug-in windows remain the first targets. Embedded Bitwig panels and pixel anchors remain later work.

## Result

Mac-first development has now proven the semantic seam, visible composition, exact dynamic restoration, and the direct raster primitive. V1D-1 hardens that primitive into production source; V1D-2 then adds external frame ownership before real window capture begins.
