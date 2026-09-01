# Mac-First Software Development Fixture

## Decision

The active Track V development fixture is the maintainer's macOS computer running Bitwig Studio, the `kasselvania/DrivenByMoss` derivative, and Push 3 Controller over ordinary USB.

This changes implementation order, not product scope:

- macOS supplies the fastest source/build/install/measurement loop;
- Steam Deck remains the first Track A appliance host and named Linux portability fixture;
- semantic, raster, frame, resolver, and adapter contracts remain operating-system neutral;
- no ScreenCaptureKit, Core Graphics, or other macOS object may leak into the controller extension or public frame contracts.

## Accepted Mac progress

### S0 — exact fixture and display path

Accepted Bitwig 6.1, Push controls/audio/display, official DrivenByMoss 26.4.1 provenance, the persistent 960×160 bitmap, and the `Push2Display` to `PushUsbDisplay` seam.

### V1A-0 — derivative custody and build

Accepted the true fork, immutable source basis, explicit Java 21/Maven environment, reversible installation, real Push parity, and exact official rollback.

### V1A — identity pipeline

```text
complete semantic IBitmap
        -> PushFramePipeline
        -> same IBitmap
        -> unchanged PushUsbDisplay
```

### V1B — static bounded composition

Accepted a fixed startup-gated vector mark with zero outside-region mismatches, bounded cost, representative semantic modes, real controls/audio, and exact rollback.

### V1C-0 — dynamic restoration decision

Selected current-semantic redraw rather than historical output mutation, a second bitmap, region snapshots, or raw transport ownership.

### V1C — production dynamic local lifecycle

Accepted:

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

Accepted central evidence:

```text
commit: e748d168ce9983bd787fad25ac03ccb5b650edb1
tree:   2d0a7a812e25c15aa082025f6d2ec90e8595b65c
```

## Why the next Mac task is bulk raster—not IPC

The current dynamic local source draws a few vector primitives through `IBitmap.render(...)`. A real captured device or plug-in view will be a raster image.

The project therefore needs a production-capable bulk raster sink before another process can usefully publish frames.

The relevant accepted facts are:

- project `IBitmap` exposes render and encode, but no accepted region write;
- Bitwig's bitmap exposes a `MemoryBlock` and is also an `Image`;
- the current project wrapper does not establish writable coherence, exact row/channel/stride behavior, or pixel-exact bitmap blitting;
- V1C semantic redraw already solves movement/removal/fallback and must remain restoration authority.

V1D-0 selects the narrow raster primitive before IPC.

## V1D-0 — bulk raster feasibility

The first research contract is:

```text
opaque BGRA8888
already cropped and scaled
explicit destination bounds
explicit validated source stride
synchronous current display thread
```

Candidate order:

1. direct validated write into the current bitmap backing memory;
2. one reusable source bitmap and exact bitmap-as-image blit;
3. encode-time composition above transport;
4. precise blocker.

The research must prove:

- buffer writeability, aliasing, lifetime, and coherence;
- channel, row, alpha, capacity, and stride behavior;
- small, odd padded, medium, and full-frame generated patterns;
- validation before mutation and zero partial invalid writes;
- exact source pixels and exact semantic restoration;
- bounded performance/allocation;
- unchanged `PushUsbDisplay` and one writer;
- real Push behavior and exact official rollback for the leading candidate.

No proprietary UI capture is needed. Generated test cards are sufficient.

## What the Mac can still prove before the Deck returns

The Mac can establish:

1. exact bulk raster application;
2. production local raster lifecycle;
3. external latest-frame-wins ingress and freshness;
4. macOS dedicated-window capture;
5. one floating Bitwig native-device or plug-in visual lens;
6. semantic-seeded anchor benchmarks;
7. much of the public attached-mode experience.

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
V1D-0   active bulk raster primitive selection
V1D-1   production local raster lifecycle
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
- validate before applying;
- preserve V1C current-semantic redraw;
- map helper absence, crash, stale sequence, invalid metadata, permission failure, and resolver abstention to exact semantic-only output.

## macOS capture posture

Screen capture eventually belongs in a normal macOS helper application with stable permission identity. Dedicated top-level native-device and plug-in windows remain the first targets. Embedded Bitwig panels and pixel anchors remain later work.

## Result

Mac-first development has already proven the semantic seam, visible composition, and exact dynamic restoration. It now proves the bulk raster sink and external-frame contract before the same portable architecture moves to Steam Deck/Linux.
