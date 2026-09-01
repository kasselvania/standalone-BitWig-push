# Current Slice: V1D-1 — Production Local Raster Composition

## Status

Ready to execute from the current accepted central `origin/main` containing the merged V1D-0 decision and from DrivenByMoss `origin/pushwig/main` at the exact accepted V1C integration state.

Active issue: [#29 — V1D-1: Implement production local raster composition](https://github.com/kasselvania/standalone-BitWig-push/issues/29).

Before work begins, fetch central `origin/main` and verify that its history contains:

```text
63dc42ba28356a30bdbd1f54c804c91f49a659c0  # accepted V1D-0 evidence
```

Create the central evidence branch directly from the then-current accepted `origin/main`. If `origin/main` has moved, inspect every intervening commit and stop if it changes V1D-1 authority or scope.

## Primary claim

Implement the production form of the V1D-0 Candidate A decision:

```text
newest retained ModelInfo
        -> complete current-semantic redraw
        -> completely validate current opaque BGRA raster request
        -> absolute bulk row copies, or no write
        -> same logical IBitmap
        -> one unchanged PushUsbDisplay.send
```

The previous composed output is never restoration authority. Rejected metadata, unsupported target layout, absent input, stale input, or invalid input must leave the freshly redrawn current semantic frame byte-identical.

V1D-1 is a production source slice using locally generated raster frames. It does not introduce an external process, IPC, shared memory, sequence/freshness protocol, ScreenCaptureKit, or window capture.

See [`docs/V1D1_LOCAL_RASTER_COMPOSITION.md`](docs/V1D1_LOCAL_RASTER_COMPOSITION.md).

## Accepted authorities

### Central authority and evidence

```text
repository:      kasselvania/standalone-BitWig-push
V1D-0 merge:     63dc42ba28356a30bdbd1f54c804c91f49a659c0
tree:            1184afeb7c00ee86a1c298df539d3267475ce6b3
```

### DrivenByMoss implementation

```text
repository: kasselvania/DrivenByMoss
branch:     pushwig/main
commit:     852b520933eed87fbe496a04b5c18819a10b3564
tree:       d03a372e2efcf41b22cef46501e08efbfb0c0036
```

That integration contains exact accepted V1C source head:

```text
4b3326eddcf2d890de3baa10b93f6e80842d41e1
```

Immutable upstream basis remains:

```text
branch: pushwig/upstream-26.4.1
commit: fd03245ab38fa5149c45934051d937ee9fda6d08
tree:   edd2ad636b0aa1f39919f0ffd05c968015450075
```

Official extension SHA-256 to restore:

```text
98dc3195ad8d911526e18b1005f09f69a1aedcb965b080565474104654345c5a
```

## Accepted V1D-0 decision

V1D-0 selected **Candidate A — direct writable bitmap region**.

The accepted host observation established a Bitwig `ARGB32` bitmap with:

```text
dimensions:       960x160
memory bytes:     614400
row bytes:        3840
view:             writable, direct, non-array-backed
byte order:       little-endian
observed channels: blue, green, red, alpha
row origin:       top-left
alpha policy:     opaque 0xFF only
thread:           Control Surface Session
```

Distinct views aliased the same memory. One cached view remained coherent through `IBitmap.encode` and physical Push output across 1,920 sends.

The selected local production contract is a caller-owned `byte[]` with primitive source offset, source stride, destination coordinates, width, height, and `RasterPixelFormat.OPAQUE_BGRA8888`.

## Source topology

Create a source branch directly from exact `origin/pushwig/main`:

```text
pushwig/v1d1-local-raster-composition
```

The final source branch must contain one implementation commit over the accepted integration basis.

Expected production changes are exactly:

```text
src/main/java/de/mossgrabers/bitwig/framework/graphics/BitmapImpl.java
src/main/java/de/mossgrabers/controller/ableton/push/controller/Push2Display.java
src/main/java/de/mossgrabers/controller/ableton/push/controller/DynamicLocalRasterPushFramePipeline.java
src/main/java/de/mossgrabers/framework/graphics/IRasterWritableBitmap.java
src/main/java/de/mossgrabers/framework/graphics/RasterPixelFormat.java
```

Do not cherry-pick the V1D-0 research commit. Reimplement the accepted production model cleanly from the accepted integration basis.

Any additional production path requires an explicit stop and technical justification before editing.

Do not modify:

```text
AbstractGraphicDisplay.java
DynamicLocalPushFramePipeline.java
PushFramePipeline.java
PassThroughPushFramePipeline.java
SyntheticOverlayPushFramePipeline.java
PushUsbDisplay.java
GraphicsContextImpl.java
IBitmap.java
pom.xml
```

Do not change extension version, IDs, USB matching, endpoint ownership, encoding, line padding, XOR shaping, transfer scheduling, or shutdown ownership.

## Host-neutral interface

Add:

```java
public interface IRasterWritableBitmap extends IBitmap
{
    boolean writeRasterRegion (
        RasterPixelFormat format,
        byte[] source,
        int sourceOffset,
        int sourceStride,
        int destinationX,
        int destinationY,
        int width,
        int height);
}
```

`RasterPixelFormat` has one accepted V1D-1 value:

```text
OPAQUE_BGRA8888
```

The contract is all-or-nothing:

- `true`: the complete destination region was applied;
- `false`: no destination byte changed.

Source contract:

- caller retains exclusive source-array ownership until synchronous return;
- rows are top-to-bottom;
- pixels are left-to-right;
- bytes are blue, green, red, alpha;
- every copied alpha byte is `0xFF`;
- source stride is explicit and may contain ignored padding;
- source is already cropped and scaled.

No scaling, filtering, blending, premultiplication, cropping, color management, Bitwig type, macOS type, capture handle, USB type, or raw destination view crosses the interface.

## BitmapImpl production responsibilities

`BitmapImpl` alone owns:

1. the Bitwig bitmap and memory block;
2. one private cached writable destination view;
3. construction/layout support state;
4. complete request validation;
5. composition-thread binding;
6. absolute bulk row copies.

Use actual bitmap dimensions. Do not hard-code 960x160 inside the generic adapter.

A destination is raster-writable only when all support checks pass without changing ordinary behavior:

- format is Bitwig `ARGB32` with four bytes per pixel;
- dimensions are positive;
- expected byte count is exactly `width * height * 4` without overflow;
- memory block size, view limit, and view capacity match the expected byte count;
- view is writable and direct;
- initial position is zero;
- observed byte order/layout is accepted.

Unsupported format/layout/view, view-creation failure, or other initialization failure must disable raster writing and preserve existing `render()` and `encode()` behavior. Default, V1B, and V1C must not become dependent on raster support.

The cached destination view is private and never exposed. Existing `encode()` behavior remains unchanged.

`BitmapImpl` is currently a public record. If converted to a final class to hold cached state:

- preserve `public BitmapImpl(Bitmap)`;
- preserve `bitmap()`;
- prefer explicit record-equivalent `equals`, `hashCode`, and `toString` behavior;
- otherwise retain exact source-search and behavior evidence proving no accepted dependency;
- do not silently discard observable semantics.

## Validation-before-mutation

No destination byte may change until every request check and every source alpha check has passed.

Use `long` arithmetic or exact-overflow helpers for:

```text
width * 4
destinationX + width
destinationY + height
sourceOffset + (height - 1) * sourceStride + rowBytes
destination last-row start + rowBytes
```

Reject before mutation for:

- null/unsupported format;
- null source;
- zero or negative dimensions;
- negative destination coordinates;
- negative source offset;
- destination arithmetic overflow;
- destination out of bounds;
- stride below packed row bytes;
- source-end arithmetic overflow;
- short source;
- unsupported destination layout;
- any source alpha byte not equal to `0xFF`;
- wrong thread after binding.

After complete validation, copy each row through the absolute bulk overload:

```java
ByteBuffer.put(destinationIndex, source, sourceIndex, rowBytes)
```

Do not rely on or alter destination position/limit.

The first valid call may bind the owner thread. Binding must be race-safe. Invalid or malformed calls must not steal ownership. Later calls from another thread return `false` before mutation.

## Startup selection and precedence

Add the startup property:

```text
pushwig.dynamicLocalRaster=true
```

Read all properties only during `Push2Display` construction.

Required precedence:

```text
raster=true
    -> new DynamicLocalRasterPushFramePipeline

else dynamicLocalVisual=true
    -> accepted DynamicLocalPushFramePipeline

else syntheticOverlay=true
    -> accepted SyntheticOverlayPushFramePipeline

else
    -> PassThroughPushFramePipeline
```

Raster wins if several diagnostic properties are true. Exactly one pipeline is selected.

The accepted current-semantic redraw hook is enabled for V1C vector and V1D-1 raster modes. It remains disabled for default and V1B static mode.

`Push2Display.send` preserves its shutdown/null guard, invokes exactly one pipeline, invokes exactly one unchanged `PushUsbDisplay.send`, and retains one USB writer.

## Bounded local raster lifecycle

`DynamicLocalRasterPushFramePipeline` is package-private and one instance per display. It is proof scaffolding for the production raster sink, not the external frame protocol.

Use fixed class-initialized generated source arrays and bounded primitive state. Do not allocate a frame, array, renderer, collection, queue, task, future, or bitmap per send.

Exercise at least:

```text
SMALL          64x16
ODD_PADDED     117x37 with stride > width*4 and sentinel padding
MEDIUM         480x80
FULL           960x160
REPLACEMENT    moved replacement content
NONE
STALE
INVALID
MALFORMED      deliberately rejected metadata
```

Patterns must make orientation and channel errors obvious through asymmetric corners, channel bars, row/column markers, opaque alpha, and recognizable generated structure.

Valid states call `writeRasterRegion` once. NONE, STALE, and INVALID call it zero times. MALFORMED calls it with bounded invalid metadata and requires `false` with exact semantic-only output.

If the semantic bitmap does not implement `IRasterWritableBitmap`, the pipeline performs no write and returns the same semantic bitmap.

## Correctness and negative matrix

Run at least 1,000 complete local raster cycles with exact 960x160 aggregate comparisons.

Test all accepted V1D-0 negative classes, including:

- null/unsupported format and null source;
- negative and near-maximum coordinates;
- zero/negative dimensions;
- row-byte, destination, stride, and source-offset overflow;
- destination out of bounds;
- stride below row bytes;
- one-byte-short and one-row-short sources;
- non-opaque alpha;
- short/read-only/wrong-format destination support;
- wrong-thread call.

Required exact zero results:

```text
source-target mismatches
outside-current-region mismatches
old-region restoration mismatches
post-NONE full-frame mismatches
STALE full-frame mismatches
INVALID full-frame mismatches
MALFORMED full-frame mismatches
semantic-update-under-coverage mismatches
partial writes after rejected metadata
invalid accepts
escaped display-loop exceptions
```

Positive target changes must prove valid writes occurred.

No raw frame, screenshot, or proprietary UI crop may be committed.

## Regression requirements

The exact source head must prove:

1. no property -> pass-through and ordinary dirty rendering;
2. `pushwig.syntheticOverlay=true` -> accepted V1B static path;
3. `pushwig.dynamicLocalVisual=true` -> accepted V1C vector path;
4. `pushwig.dynamicLocalRaster=true` -> V1D-1 raster path;
5. all properties true -> raster path only;
6. non-raster `IBitmap` -> semantic-only fallback;
7. unchanged `PushUsbDisplay` and accepted V1A/V1B/V1C pipeline classes.

## Build and bytecode proof

Use the accepted explicit Java 21/Maven environment for exact base and proposed-head builds.

Retain:

- exact parent/head/tree and one-commit topology;
- exact five-path source envelope;
- source hashes;
- artifact size/SHA-256;
- extracted payload comparison;
- bytecode proving property precedence, validation before every put, absolute bulk rows, safe thread binding, same-reference pipeline output, and one pipeline/one transport call;
- byte-identical `PushUsbDisplay.class`;
- byte-identical accepted V1A/V1B/V1C pipeline classes.

## Performance and tail review

Collect at least 1,000 post-warmup samples for:

- semantic redraw only;
- SMALL writer and combined path;
- ODD_PADDED writer and combined path;
- MEDIUM writer and combined path;
- FULL writer and combined path;
- rejected request;
- relevant default/V1B/V1C regressions.

Retain p50, p95, maximum, bytes copied, writer-only cost, combined cost, allocation, cached-view creation, RSS/heap, and control/display/audio observations.

Required full-frame combined bands:

```text
green:  p95 <= 2 ms and max <= 10 ms
review: p95 <= 5 ms and max <= 15 ms
stop:   p95 > 5 ms or max > 15 ms
```

V1D-0 retained a MEDIUM combined maximum of `17.679042 ms` and a mixed startup/interaction outlier of `47.747125 ms`. V1D-1 must remeasure them rather than erase them.

Any post-warmup combined sample over 15 ms requires a stable rerun plus writer-only, semantic-redraw, GC, and scheduling context. Stop if the writer itself regresses or project source reproduces a persistent stop-band result. An isolated host/scheduler outlier with bounded writer cost requires explicit technical-lead review.

Do not add asynchronous buffering, a second bitmap, or a worker to hide tail latency.

Project-owned per-application allocation target is zero.

## Real fixture and rollback

Use only the exact proposed-head artifact as the sole scanned extension.

Prove:

- Push controls, pressure/MPE, encoders, transport;
- coherent semantic display;
- Push audio and audible headphones;
- all generated raster sizes and replacement state;
- correct top-left orientation, BGRA channels, opaque alpha, and padded stride;
- no sentinel leakage;
- movement, resize, replacement, NONE, STALE, INVALID, MALFORMED, and semantic-update restoration;
- default, V1B, V1C, V1D-1, and all-property precedence startups;
- no trail, partial invalid write, corruption, filtering, whole-frame clear, abnormal lag, xrun, or relevant exception;
- normal quit.

Restore the exact official artifact as the sole scanned extension, verify its accepted SHA-256, relaunch without Pushwig properties, and physically confirm standard DrivenByMoss behavior.

## PR topology

### DrivenByMoss source PR

```text
branch: pushwig/v1d1-local-raster-composition
base:   pushwig/main
commit: V1D-1: implement local raster composition
PR:     V1D-1: implement production local raster composition
```

The PR remains open, non-draft, and unmerged for review.

### Central evidence PR

Create directly from the current accepted central `origin/main`:

```text
codex/v1d1-local-raster-composition-evidence
```

Contain only:

```text
evidence/v1d1-local-raster-composition/**
```

Include `Addresses #29`, link the exact source PR/head/tree, and remain open, non-draft, and unmerged.

## Expected evidence

```text
evidence/v1d1-local-raster-composition/
├── README.md
├── source-topology.md
├── raster-contract-and-adapter.md
├── lifecycle-and-correctness.md
├── negative-validation.md
├── regression-paths.md
├── performance.md
├── build-artifact-comparison.md
├── real-fixture-and-rollback.md
└── manual-acceptance.md
```

## Non-goals

No external producer, Unix/TCP/HTTP/WebSocket/OSC transport, shared memory, memory mapping, sequence/freshness protocol, final `VisualSourceFrame`, ScreenCaptureKit, capture permission, window discovery/capture, scaling/resampling, alpha blending, color management, adapter/resolver/calibration/anchors, transport rewrite, second bitmap, second USB writer, POM/test-framework change, Push 2 claim, Steam Deck/Linux, yabridge, Monome, plugdata, appliance, battery, connector, or NUC work.

## Acceptance

V1D-1 is complete only when:

1. both exact source and evidence PR heads exist;
2. source is one commit over the accepted DrivenByMoss basis;
3. the source envelope is exactly accepted or explicitly repaired before editing;
4. the host-neutral contract and all-or-nothing writer are proven;
5. every valid and invalid mismatch category is zero;
6. default/V1B/V1C/V1D-1 regression and precedence paths pass;
7. performance is accepted with explicit tail review;
8. the real Push fixture passes;
9. `PushUsbDisplay` remains unchanged and sole-owned;
10. the exact official artifact is restored.
