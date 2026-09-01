# AGENTS.md — Repository Execution Rules

## Mission

Build an open, inspectable adaptive visual/controller layer for Ableton Push 3 and Bitwig Studio, then reuse that software in optional portable-appliance and native-compute projects.

The repository coordinates three independent tracks:

1. universal visual/controller integration;
2. all-in-one appliance packaging;
3. CM11EB connector and native-compute research.

The current Track V reference fixture is the maintainer's macOS Bitwig/DrivenByMoss/Push system because it provides the shortest software loop. The Steam Deck remains the first Track A appliance host and the named Linux portability fixture. Neither host defines the universal product.

## Authority order

When instructions conflict, use this order:

1. `AGENTS.md`
2. `CURRENT_SLICE.md`
3. `docs/PROJECT_TRACKS.md`
4. `docs/ARCHITECTURE.md`
5. `docs/MAC_FIRST_DEVELOPMENT.md`
6. `docs/DRIVENBYMOSS_DERIVATIVE_STRATEGY.md`
7. `docs/V1D0_BULK_RASTER_COMPOSITION.md`
8. `docs/V1C_DYNAMIC_LOCAL_COMPOSITION.md`
9. `docs/V1C0_DYNAMIC_RASTER_COMPOSITION.md`
10. `docs/V1B_SYNTHETIC_COMPOSITION.md`
11. `docs/VISUAL_PORTABILITY.md`
12. `docs/SEMANTIC_PIXEL_ANCHOR_RESOLVER.md`
13. `docs/ROADMAP.md`
14. `docs/RUNTIME_STRATEGY.md`
15. issue / PR scope
16. implementation convenience

A contributor or coding agent must stop and surface a conflict rather than quietly widening scope.

## Core invariants

- Bitwig remains the DAW and audio-engine authority.
- DrivenByMoss, or a compatible derivative, remains the semantic Push/controller authority unless an accepted slice explicitly proves a replacement.
- The Push display is a composited output. Semantic UI and project/captured pixels are distinct source classes.
- Exactly one component owns the Push USB display endpoint in steady state.
- Final composition and USB transport remain in-process in the DrivenByMoss derivative through the current slices.
- Visual capture is visualization first. Do not replace reliable controller-API operations with fragile mouse automation.
- Attached mode must adapt to a user's existing Bitwig windows and monitor layout.
- Managed geometry is an appliance/test mode, not a requirement imposed on desktop users.
- Physical desktop coordinates are never the primary identity of a visual source.
- Prefer dedicated windows, semantic identity, window-relative geometry, normalized regions, anchors, and bounded calibration.
- A resolver must prefer abstention and exact semantic fallback over a wrong visual lock.
- Capture-backend and operating-system types do not belong in compositor/frame contracts.
- macOS objects such as `SCWindow`, `CGWindowID`, and `CVPixelBuffer` stay inside the macOS helper/backend.
- Semantic fallback means restoring the exact **current** semantic pixels, not merely stopping future visual drawing.
- Output is derived from `current semantic frame + optional current visual`.
- Historical composed output is never restoration authority.
- A moving, replaced, resized, absent, stale, invalid, or malformed visual must not leave pixels behind.
- Validation must complete before raster mutation; rejected input must cause zero partial writes.
- Raster format, dimensions, stride, destination bounds, ownership, and thread rules must be explicit.
- The Mac and Steam Deck are reference hosts. Do not generalize maintainer-specific yabridge, serialosc, Monome, or plugdata state into universal requirements.
- The ordinary rear Push USB path remains a first-class appliance architecture.
- Battery operation is mandatory for a portable-appliance claim; wall power is only an engineering state.
- Track A and Track H do not block universal Track V progress.
- Hardware and power claims require real measurements, photographs, continuity, enumeration, or documented specifications.
- Do not redistribute proprietary Ableton/Bitwig binaries, firmware, activation data, or private assets.
- Do not casually redistribute proprietary UI screenshots or templates. Prefer local generation, recipes, hashes, descriptors, and legally distributable fixtures.
- DrivenByMoss changes live in `kasselvania/DrivenByMoss`, preserve upstream history and LGPL notices, and are not vendored into this repository.
- Every implementation or research slice names an exact accepted source commit/tree.
- `pushwig/upstream-26.4.1` is the immutable accepted upstream basis.
- Project source PRs target `pushwig/main`; never target the immutable basis or upstream `master`.
- Central evidence/status changes and DrivenByMoss source changes remain separate PRs with exact cross-references.

## Accepted source posture

Accepted DrivenByMoss integration state:

```text
branch: pushwig/main
commit: 852b520933eed87fbe496a04b5c18819a10b3564
tree:   d03a372e2efcf41b22cef46501e08efbfb0c0036
```

That merge contains exact accepted V1C source head:

```text
4b3326eddcf2d890de3baa10b93f6e80842d41e1
```

Immutable upstream basis:

```text
branch: pushwig/upstream-26.4.1
commit: fd03245ab38fa5149c45934051d937ee9fda6d08
tree:   edd2ad636b0aa1f39919f0ffd05c968015450075
```

Accepted default path:

```text
complete semantic IBitmap
        -> PassThroughPushFramePipeline
        -> same IBitmap
        -> unchanged PushUsbDisplay
```

Accepted V1B diagnostic path:

```text
pushwig.syntheticOverlay=true
        -> one fixed bounded vector overlay
        -> same IBitmap
        -> unchanged PushUsbDisplay
```

Accepted V1C dynamic-local path:

```text
newest copied ModelInfo
        -> retain before render decision
        -> complete semantic redraw for dynamic mode
        -> current valid local vector visual, or no visual
        -> same persistent IBitmap
        -> unchanged PushUsbDisplay
```

V1C proved movement, overlap, resize, replacement, absence, stale/invalid fallback, overlay-only updates, notification lifecycle, current-semantic restoration, default/V1B regressions, one writer, bounded performance, real Push behavior, and exact rollback.

## Slice discipline

Each slice states:

- exact accepted basis;
- one primary claim;
- files/components in scope;
- explicit non-goals;
- executable acceptance criteria;
- retained evidence requirements.

Do not merge uncertainty domains merely because they are adjacent. In particular:

- dynamic local vector composition is separate from bulk raster application;
- bulk raster selection is separate from production raster lifecycle;
- production raster lifecycle is separate from external-frame IPC;
- external-frame IPC is separate from operating-system capture;
- window capture is separate from visual-source resolution;
- top-level windows are separate from embedded Bitwig-panel recognition;
- anchor benchmarking is separate from live resolver integration;
- attached desktop adaptation is separate from managed headless geometry;
- macOS proof is separate from Linux portability;
- appliance packaging is separate from CM11EB connector research.

## V1D-0 bulk-raster research rules

V1D-0 selects the bulk raster composition primitive needed before external frames can be useful.

### Research posture

- Begin from exact DrivenByMoss integration commit `852b520933eed87fbe496a04b5c18819a10b3564` and current accepted central `origin/main` containing V1C evidence merge `e748d168ce9983bd787fad25ac03ccb5b650edb1`.
- Use temporary local worktrees, branches, commits, patches, harnesses, and observation instrumentation.
- Do not open or merge a production DrivenByMoss PR in V1D-0.
- Retain complete candidate identities, changed paths, build/artifact hashes, pixel evidence, timing, live-fixture results, and rollback.
- Stop after the first candidate satisfies every required gate.
- The final central evidence must select one exact production seam or one precise blocker.

### Canonical first raster

Research the narrow contract:

```text
format:      opaque BGRA8888
source:      already cropped and scaled
destination: explicit x/y/width/height
stride:      explicit and validated
thread:      synchronous display/composition thread
```

Do not add scaling, alpha blending, color management, source discovery, capture handles, or physical desktop coordinates to this sink.

### Candidate order

1. direct validated writable bitmap-region capability;
2. reusable source bitmap plus bitmap-as-image blit;
3. encode-time composition wrapper above transport;
4. precise blocked result.

Do not continue to later candidates after an exact, bounded winner.

### Fail-closed validation

Before the first write, validate:

- format;
- dimensions;
- coordinates;
- destination extent;
- stride;
- source byte count;
- arithmetic overflow;
- buffer accessibility;
- visual validity/freshness state supplied by the local test.

Any absent, stale, invalid, unsupported, malformed, overflowing, short, or out-of-bounds input must leave the freshly redrawn semantic frame unchanged. Partial writes are forbidden.

### Correctness

Use project-generated patterns only. Require exact zero mismatches for:

- source pixels inside the destination;
- pixels outside the current destination;
- prior visual regions after movement/replacement;
- full frame after NONE;
- full frame after STALE;
- full frame after INVALID;
- semantic updates under prior coverage;
- all rejected malformed inputs.

Test small, odd-width/padded-stride, medium, and full-frame rasters.

### Ownership and abstraction

- V1C current-semantic redraw remains restoration authority.
- `PushUsbDisplay` remains unchanged and sole-owned.
- Bitwig `Bitmap`, `MemoryBlock`, `ByteBuffer`, graphics handles, and operating-system capture objects do not enter a future public frame contract.
- Buffer view lifetime, aliasing, thread access, byte order, row order, channel order, alpha policy, and stride must be measured and declared.
- Do not fake bulk raster support with one rectangle draw per pixel.
- Do not add threads, queues, a second writer, or transport mutation.

### Performance

For redraw plus full-frame raster application on the accepted Mac:

```text
green:  p95 <= 2 ms and max <= 10 ms
review: p95 <= 5 ms and max <= 15 ms
stop:   p95 > 5 ms or max > 15 ms
```

Measure small, padded, medium, full-frame, and rejected inputs. Retain fixed and per-cycle allocation behavior, buffer-view creation, working set, and real control/display/audio observations.

### Real fixture

Only the leading offline-safe candidate reaches the Mac + Bitwig 6.1 + Push 3 fixture. Use the exact artifact as the sole scanned extension, prove raster orientation/channels/stride and V1C restoration, then restore the official artifact exactly.

## Evidence rules

Retain evidence under `evidence/` when practical:

- accepted bases and repository topology;
- source/API signatures;
- prototype patch and source hashes;
- build and artifact hashes;
- bitmap buffer properties;
- raster dimensions/strides/pixel formats;
- target/outside/restoration/negative mismatch counts;
- timing percentiles and allocation observations;
- RSS/heap observations;
- real-fixture and rollback results;
- final selected/blocked decision.

Do not commit:

- proprietary screenshots or raw frames;
- generated extension binaries;
- temporary harness/instrumentation source or binaries;
- credentials, activation data, serial numbers, UUIDs, hostnames, IP addresses, or unsanitized personal paths.

## Engineering preferences

- Use the Mac for rapid source/build/fixture loops while keeping contracts host-neutral.
- Preserve the exact V1C semantic-redraw lifecycle.
- Prefer validated direct bulk write if it is coherent and safely encapsulated.
- Prefer a reusable source bitmap if direct memory mutation is unavailable or unsafe.
- Do not design IPC before a production raster sink exists.
- Use latest-frame-wins—not queues—when external ingress eventually begins.
- Never block controller input or audio on capture/producer availability.
- Require semantic-only output for all producer and resolver failure states.
- Remeasure full-path performance when an external producer is added.

## Connector-development rules

A CM11EB development card is staged open hardware:

- expose only proven grounds, candidate USB pairs, and purpose-specific observations first;
- leave power rails disconnected by default;
- do not fan all high-speed contacts onto generic headers;
- USB 3/PCIe/eSPI work requires a bounded experiment and controlled-impedance design;
- connector geometry and pin mapping require independent review before insertion.

## Current posture

S0, V1A-0, V1A, V1B, V1C-0, and V1C are accepted.

V1D-0 now selects the bulk raster primitive. If selected, V1D-1 implements that sink with locally generated byte frames. V1D-2 then adds external latest-frame ingress. V2 remains the first macOS dedicated-window capture slice.

See `CURRENT_SLICE.md` before changing code.
