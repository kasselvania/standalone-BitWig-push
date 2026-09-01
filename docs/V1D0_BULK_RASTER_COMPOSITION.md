# V1D-0 Bulk Raster Composition Research

## Purpose

V1C established a complete dynamic visual lifecycle for locally generated vector graphics:

```text
newest current semantic model
        -> full semantic redraw
        -> current valid visual, or no visual
        -> same persistent bitmap
        -> unchanged PushUsbDisplay
```

That lifecycle solves restoration, movement, replacement, absence, staleness, invalidity, overlay-only updates, and notification expiration.

The next missing capability is not IPC. It is the ability to apply an image-sized block of already-prepared pixels to that current semantic frame efficiently and exactly.

A future Bitwig native-device or plug-in capture will arrive as raster data. Representing it as thousands of `fillRectangle` calls would be the wrong abstraction and an unacceptable performance/complexity basis.

V1D-0 therefore asks:

> What is the smallest safe, host-neutral, production-capable bulk raster primitive for the V1C composition lifecycle?

## Accepted starting point

Central V1C evidence:

```text
commit: e748d168ce9983bd787fad25ac03ccb5b650edb1
tree:   2d0a7a812e25c15aa082025f6d2ec90e8595b65c
```

DrivenByMoss integration:

```text
branch: pushwig/main
commit: 852b520933eed87fbe496a04b5c18819a10b3564
tree:   d03a372e2efcf41b22cef46501e08efbfb0c0036
```

The integration contains exact accepted V1C source head:

```text
4b3326eddcf2d890de3baa10b93f6e80842d41e1
```

V1D-0 must preserve V1C restoration authority and the existing sole Push USB writer.

## Why external ingress is deferred

An external frame protocol would need to choose:

- pixel format;
- dimensions and stride;
- destination geometry;
- buffer ownership and lifetime;
- validation behavior;
- malformed-input behavior;
- consumer copy/write semantics;
- and performance budget.

Those decisions cannot be responsibly made while the in-process consumer has no accepted raster sink.

V1D-0 proves the sink first. V1D-1 implements it in production with locally generated raster bytes. V1D-2 then adds process boundaries, sequence, freshness, producer restart, and latest-frame-wins behavior.

## Canonical first raster class

The first sink is intentionally narrow:

```text
format:      opaque BGRA8888
source:      already cropped
source:      already scaled to destination dimensions
destination: explicit x, y, width, height in the 960x160 frame
stride:      explicit source row stride
execution:   synchronous on the display/composition thread
```

This is enough to prove the critical operation without prematurely selecting capture, scaling, or public wire-format policy.

### Why opaque BGRA8888

The accepted Bitwig bitmap observation is four-byte BGRA. Ordinary captured UI regions are opaque. Starting with opaque BGRA avoids conflating the first bulk write with:

- premultiplied-alpha policy;
- compositing equations;
- blend-mode behavior;
- transparency edge cases;
- or color-space conversion.

The research format may later become one accepted internal format, but V1D-0 does not yet define the public external frame format.

### What the sink does not do

The sink does not:

- scale or resample;
- crop from a larger image;
- alpha blend;
- color convert;
- discover a source;
- interpret monitor coordinates;
- retain capture handles;
- or schedule asynchronous work.

Those operations belong upstream of the raster sink.

## Correct ownership rule

The raster operation runs after V1C has redrawn the newest semantic state:

```text
newest retained ModelInfo
        -> current-semantic redraw
        -> validate current raster metadata completely
        -> apply current raster region, or apply nothing
        -> same persistent bitmap
        -> unchanged PushUsbDisplay
```

Rejected input must leave the freshly redrawn semantic frame intact.

The sink must never restore from:

- previous composed output;
- a previous raster;
- a region snapshot;
- encoded Push transport bytes;
- or a stale producer buffer.

## Fail-closed validation

Validation must complete before the first destination write.

At minimum validate:

1. supported pixel format;
2. positive width and height;
3. nonnegative destination coordinates;
4. destination right/bottom bounds within 960×160;
5. `width * 4` without integer overflow;
6. source stride at least `width * 4`;
7. stride/height required-byte calculation without overflow;
8. source capacity or remaining bytes sufficient for all rows;
9. source access state and lifetime;
10. current local validity state.

An invalid source must cause no partial write. Validation and application cannot observe inconsistent mutable metadata.

## Candidate A — direct writable bitmap-region capability

### Concept

Expose the narrowest host-neutral operation needed to write validated BGRA8888 rows directly into the current bitmap's backing memory.

```text
current semantic bitmap
        -> obtain or use bounded writable view
        -> validated row copies at destination offsets
        -> unchanged transport
```

### Why it is first

If the Bitwig `MemoryBlock` view is safely writable and coherent, direct row copying provides:

- exact pixels;
- no filtering;
- no scaling;
- no second bitmap;
- no extra render callback;
- straightforward stride support;
- and a natural fit for already-prepared external frames.

### Questions that must be answered

- Is the returned `ByteBuffer` writable?
- Is it direct or heap-backed?
- What byte order does it report, and does order matter for byte copies?
- Does a fresh view alias the same bitmap memory?
- Does the view remain valid for the bitmap lifetime?
- Are writes immediately visible to `encode`, the debug bitmap window, and Push output?
- Does a later Bitwig render replace or preserve those writes as expected?
- What is the exact row origin and orientation?
- What is the exact channel order and alpha behavior?
- Is bitmap storage tightly packed at `width * 4`, or is there hidden row padding?
- Can the view be cached, or must a new view be obtained per operation?
- Is access lawful only on the controller/display thread?
- What does the API document, and what remains fixture-derived behavior?

### Boundary requirement

A future public raster interface must not expose Bitwig `MemoryBlock`, Bitwig `Bitmap`, or `ByteBuffer` as semantic protocol authority.

A possible eventual shape is a host-neutral method accepting primitive metadata and a read-only source byte region, while the Bitwig adapter owns destination memory access internally. V1D-0 selects the exact shape only after measurement.

## Candidate B — reusable source bitmap plus blit

### Concept

```text
prepared raster bytes
        -> populate one reusable source bitmap
        -> draw source bitmap as Image onto semantic bitmap
        -> unchanged transport
```

Bitwig API 21 declares `Bitmap extends Image`, and `GraphicsOutput.drawImage(Image, x, y)` exists. The current project wrapper, however, only accepts `ImageImpl` through `IGraphicsContext.drawImage`.

### Questions that must be answered

- Can a project bitmap be represented as an image without leaking Bitwig types?
- Can source bitmap memory be populated exactly?
- Does `drawImage` preserve one source pixel to one destination pixel at equal dimensions?
- Is filtering disabled or irrelevant for exact-size draws?
- Is alpha premultiplied or transformed?
- Does the operation allocate?
- Can the source bitmap be allocated once and reused safely across size classes?
- Would separate source sizes be required?
- Is full-frame behavior exact and fast enough?

Candidate B is reached only if direct destination writing is unavailable, unsafe, incoherent, or architecturally worse.

## Candidate C — encode-time composition above transport

This is a last higher-level fallback before declaring a blocker.

It might build an encoded/composed representation above `PushUsbDisplay`, but it must not move semantic authority into transport bytes or modify `PushUsbDisplay` itself.

Any design must declare:

- intermediate buffer ownership;
- exact format and stride;
- when semantic redraw is encoded;
- where raster application occurs;
- whether output is copied again by transport;
- and why the design remains cleaner than a destination write or bitmap blit.

## Generated test corpus

Use project-owned generated patterns only.

### Small: 64×16

Purpose:

- exact destination positioning;
- basic channel bars;
- movement and restoration;
- low-cost timing.

### Odd/padded: 117×37

Use source stride greater than `117 * 4` and fill padding bytes with sentinels.

Purpose:

- prove row-by-row copying;
- detect accidental tightly-packed assumptions;
- detect padding leakage;
- detect skew and row offset.

### Medium: 480×80

Purpose:

- realistic large lens area;
- throughput and timing;
- partial-frame overwrite/restoration.

### Full frame: 960×160

Purpose:

- maximum first-sink throughput;
- complete orientation/channel verification;
- bound full-frame cost;
- prove exact semantic recovery after removal.

### Pattern features

Include:

- distinct colors in each corner;
- asymmetric row and column markers;
- red/green/blue/white/black bars;
- a checker or gradient;
- an obvious generated label/card shape;
- sentinels in source padding;
- alpha bytes set to the declared opaque value.

No proprietary screenshots or UI crops are needed.

## Correctness matrix

Run at least 1,000 complete cycles or a rigorously equivalent transition count.

Exercise:

- changing pattern content;
- movement;
- partial overlap;
- enlargement and reduction;
- replacement;
- NONE;
- STALE;
- INVALID;
- malformed metadata;
- semantic changes under previous raster coverage.

Required zero mismatch counts:

```text
source-versus-target pixels
outside current destination
old destination restoration
post-NONE full frame
STALE full frame
INVALID full frame
semantic update under previous coverage
partial writes after rejected metadata
```

Positive target mismatch counts must prove that valid rasters actually changed pixels.

## Negative validation matrix

Test at minimum:

- negative x/y;
- x/y near integer maximum;
- zero and negative dimensions;
- width/height multiplication overflow;
- right/bottom extent overflow;
- destination outside 960×160;
- stride smaller than row bytes;
- stride multiplication overflow;
- source capacity one byte short;
- unsupported format;
- null or inaccessible source where representable;
- mutable metadata inconsistency where the candidate design permits it.

For every rejection:

```text
fresh current semantic frame before call
        ==
output after rejected call
```

No write-then-rollback approach is accepted for malformed data.

## Performance and memory

Measure at least 1,000 post-warmup samples for:

- semantic redraw alone;
- small raster;
- odd padded raster;
- medium raster;
- full-frame raster;
- rejected metadata.

Retain:

- p50, p95, maximum;
- bytes copied;
- throughput where useful;
- fixed allocations;
- project-owned per-operation allocations;
- buffer-view creation and caching behavior;
- existing host-adapter allocations;
- RSS start/end/peak;
- JVM heap readback;
- any control, display, or audio effect.

Full-path review bands on the accepted Mac:

```text
green:  p95 <= 2 ms and max <= 10 ms
review: p95 <= 5 ms and max <= 15 ms
stop:   p95 > 5 ms or max > 15 ms
```

Do not add concurrency, queues, a second bitmap, or transport mutation merely to hide synchronous cost.

## Real fixture gate

Only the leading exact candidate reaches the physical Push after offline exactness and performance pass.

The fixture must show:

- normal controller connection and semantic behavior;
- pads, pressure/MPE, encoders, and transport;
- Push audio-device continuity and audible headphone output;
- generated raster cards at correct bounds;
- correct top/bottom and left/right orientation;
- correct BGRA color bars;
- correct padded-stride display without skew;
- coherent medium and full-frame patterns;
- movement/replacement/resize/absence restoration;
- semantic update beneath previous coverage;
- no visible partial write from malformed input;
- no trail, stale block, unexpected filtering, clear, lag, xrun, or relevant error;
- normal Bitwig quit;
- exact official-artifact rollback.

If live behavior is unexpected, stop and restore. Do not redesign during the live run.

## Research and evidence topology

V1D-0 creates no production DrivenByMoss PR.

Temporary local prototype branches, commits, patches, harnesses, and observation instrumentation are allowed. Retain exact identities and remove them from accepted branches.

Central evidence belongs under:

```text
evidence/v1d0-bulk-raster-composition/
```

Suggested files:

```text
README.md
accepted-source-and-api.md
candidate-a-direct-write.md
alternative-candidates.md
raster-correctness.md
negative-validation.md
performance.md
real-fixture-and-rollback.md
decision.md
```

The final PR remains open, non-draft, and unmerged for technical-lead review.

## Decision requirements

The result is exactly one of:

```text
SELECTED
```

or:

```text
BLOCKED
```

A selected decision must state:

- exact production source seam and expected changed paths;
- host-neutral interface;
- pixel and alpha policy;
- validation and overflow rules;
- buffer ownership and lifetime;
- thread rule;
- V1C fallback behavior;
- fixed/per-operation allocation budget;
- performance budget;
- alternative disposition;
- exact V1D-1 acceptance proposal.

A blocked decision must identify the smallest missing capability and next bounded research.

## Handoff

If selected:

```text
V1D-1
    production bulk raster sink
    locally generated byte frames only
        ↓
V1D-2
    external latest-frame ingress
    sequence, freshness, malformed producer, restart
        ↓
V2
    macOS dedicated-window capture
```

This ordering prevents IPC or capture code from papering over an unresolved pixel-consumer boundary.
