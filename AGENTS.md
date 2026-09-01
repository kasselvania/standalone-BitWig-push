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
7. `docs/V1D1_LOCAL_RASTER_COMPOSITION.md`
8. `docs/V1D0_BULK_RASTER_COMPOSITION.md`
9. `docs/V1C_DYNAMIC_LOCAL_COMPOSITION.md`
10. `docs/V1C0_DYNAMIC_RASTER_COMPOSITION.md`
11. `docs/V1B_SYNTHETIC_COMPOSITION.md`
12. `docs/VISUAL_PORTABILITY.md`
13. `docs/SEMANTIC_PIXEL_ANCHOR_RESOLVER.md`
14. `docs/ROADMAP.md`
15. `docs/RUNTIME_STRATEGY.md`
16. issue / PR scope
17. implementation convenience

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
- Raster validation must complete before destination mutation; rejected input must cause zero partial writes.
- Raster format, dimensions, stride, destination bounds, source ownership, destination ownership, and thread rules must be explicit.
- Bitwig `Bitmap`, `MemoryBlock`, `ByteBuffer`, macOS handles, and USB objects do not cross host-neutral raster or frame contracts.
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

Accepted V1D-0 bulk-raster decision:

```text
current semantic redraw
        -> validate complete opaque BGRA8888 region request
        -> absolute bulk row copies into the persistent bitmap, or no write
        -> same logical IBitmap
        -> unchanged PushUsbDisplay
```

Central accepted V1D-0 evidence:

```text
commit: 63dc42ba28356a30bdbd1f54c804c91f49a659c0
tree:   1184afeb7c00ee86a1c298df539d3267475ce6b3
```

V1D-0 selected a host-neutral `byte[]` + primitive metadata contract, opaque BGRA bytes, complete pre-write validation, one adapter-owned cached destination view, synchronous composition-thread ownership, zero partial invalid writes, one writer, bounded cost, real Push acceptance, and exact rollback.

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

## V1D-1 production local-raster rules

V1D-1 implements the accepted V1D-0 direct-write decision with locally generated byte frames only.

### Source custody

- Begin from exact `kasselvania/DrivenByMoss:pushwig/main` at `852b520933eed87fbe496a04b5c18819a10b3564`.
- Reimplement from the accepted basis; do not cherry-pick the V1D-0 research commit.
- Expected production paths are exactly:
  - `BitmapImpl.java`
  - `Push2Display.java`
  - `DynamicLocalRasterPushFramePipeline.java`
  - `IRasterWritableBitmap.java`
  - `RasterPixelFormat.java`
- Stop before editing any additional production path.
- `PushUsbDisplay`, `AbstractGraphicDisplay`, accepted V1A/V1B/V1C pipelines, `IBitmap`, graphics contexts, the POM, version, IDs, endpoint, encoding, padding, XOR, and transfer scheduling remain unchanged.

### Host-neutral write contract

The production interface is:

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

The first accepted format is `OPAQUE_BGRA8888`.

- `true` means the complete region was written.
- `false` means no destination byte changed.
- Caller owns the source array exclusively until synchronous return.
- Source rows are top-to-bottom; pixels are left-to-right.
- Pixel bytes are blue, green, red, alpha.
- Every alpha byte must be `0xFF` before any write begins.
- Source stride is explicit; padding is ignored.
- No scaling, filtering, blending, premultiplication, cropping, or color conversion occurs.

### Bitmap adapter ownership

- `BitmapImpl` alone owns the Bitwig bitmap, memory block, cached destination view, target-layout support state, request validation, thread binding, and absolute bulk row copies.
- Use actual bitmap dimensions; do not hard-code Push dimensions inside the generic adapter.
- Unsupported destination format/layout/view must disable raster writing without changing ordinary render or encode behavior.
- The cached destination view remains private and must never cross the host-neutral interface.
- `encode()` remains behaviorally unchanged.
- If `BitmapImpl` is converted from a record to a final class, preserve `BitmapImpl(Bitmap)` and `bitmap()`, and preserve record-equivalent observable semantics unless exact evidence proves no dependency.

### Validation and thread rules

Before the first destination byte changes, validate:

- destination support state;
- format and non-null source;
- positive dimensions;
- nonnegative destination coordinates and source offset;
- row-byte, source-end, destination-end, and extent arithmetic without overflow;
- destination bounds;
- source stride;
- source capacity;
- every alpha byte;
- bound composition thread.

Use absolute bulk row writes. Do not mutate destination position/limit.

Malformed calls must not bind the owner thread. First valid binding must be race-safe. Wrong-thread calls reject before mutation.

### Startup selection

Read properties once during `Push2Display` construction. Precedence is:

```text
pushwig.dynamicLocalRaster=true
    -> DynamicLocalRasterPushFramePipeline

else pushwig.dynamicLocalVisual=true
    -> accepted V1C vector pipeline

else pushwig.syntheticOverlay=true
    -> accepted V1B static pipeline

else
    -> pass-through
```

Exactly one pipeline is selected. Raster mode and V1C vector mode request current-semantic redraw; default and V1B static mode do not.

### Local generated lifecycle

The package-private raster pipeline uses class-initialized generated arrays and bounded primitive state. It must exercise:

```text
SMALL
ODD_PADDED
MEDIUM
FULL
REPLACEMENT
NONE
STALE
INVALID
MALFORMED
```

Valid states perform one complete write. NONE/STALE/INVALID perform no write. MALFORMED performs one rejected call and leaves exact semantic-only output. An unsupported non-raster bitmap also falls back to semantics.

No per-send raster array, bitmap, renderer, collection, queue, task, future, or transport allocation is allowed.

### Correctness and regressions

Require zero unexplained mismatches for:

- source versus target;
- pixels outside current bounds;
- previous raster regions;
- NONE, STALE, INVALID, and MALFORMED full frames;
- semantic update beneath previous coverage;
- every rejected metadata class;
- partial invalid writes.

Prove default, V1B static, V1C vector, V1D-1 raster, and all-properties precedence paths. Preserve one pipeline call, one transport call, and one USB writer.

### Performance

Remeasure semantic-only, small, padded, medium, full-frame, and rejected paths on the exact proposed head.

Required full-frame combined bands:

```text
green:  p95 <= 2 ms and max <= 10 ms
review: p95 <= 5 ms and max <= 15 ms
stop:   p95 > 5 ms or max > 15 ms
```

The V1D-0 medium-path `17.679042 ms` and mixed startup `47.747125 ms` samples must remain visible in V1D-1 comparison. A repeated project-owned writer regression is a blocker. An isolated host/scheduler outlier with bounded writer-only cost requires explicit review, not concealment.

Do not add queues, workers, another bitmap, or asynchronous masking to hide synchronous cost.

### Real fixture and rollback

Use the exact proposed-head artifact as the sole scanned extension. Prove raster orientation, channels, stride, movement, restoration, semantic fallback, regressions, controls, audio, and normal shutdown. Restore and reverify the exact official artifact afterward.

## Evidence rules

Retain useful evidence under `evidence/`:

- accepted bases and topology;
- source and interface hashes;
- target-layout and cached-view behavior;
- build and extracted payload comparison;
- bytecode and harness results;
- raster dimensions, strides, hashes, and mismatch counts;
- complete negative-validation results;
- timing, allocations, RSS/heap, and tail review;
- real-fixture and exact rollback.

Do not commit proprietary screenshots/raw frames, generated extension binaries, temporary harness/instrumentation source, credentials, activation data, serial numbers, UUIDs, hostnames, IP addresses, or unsanitized personal paths.

## Engineering preferences

- Use the Mac for rapid source/build/fixture loops while keeping contracts host-neutral.
- Preserve V1C current-semantic redraw as the only restoration authority.
- Keep direct memory access inside the Bitwig adapter.
- Fail closed when target layout or request metadata is unsupported.
- Do not design external producer ownership, sequence, or freshness in V1D-1.
- Use latest-frame-wins rather than queues when V1D-2 begins.
- Never block controller input or audio on capture or producer availability.
- Remeasure full-path cost after external ingress is added.

## Connector-development rules

A CM11EB development card is staged open hardware:

- expose only proven grounds, candidate USB pairs, and purpose-specific observations first;
- leave power rails disconnected by default;
- do not fan all high-speed contacts onto generic headers;
- USB 3/PCIe/eSPI work requires a bounded experiment and controlled-impedance design;
- connector geometry and pin mapping require independent review before insertion.

## Current posture

S0, V1A-0, V1A, V1B, V1C-0, V1C, and V1D-0 are accepted.

V1D-1 now implements the production local raster sink and lifecycle. V1D-2 will separately define external latest-frame ownership, sequence, freshness, and IPC. V2 remains the first macOS dedicated-window capture slice.

See `CURRENT_SLICE.md` before changing code.
