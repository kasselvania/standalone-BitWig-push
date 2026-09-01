# Current Slice: V1D-0 — Bulk Raster Composition Feasibility

## Status

Ready to execute from the current accepted central `origin/main` containing the merged V1C evidence and from DrivenByMoss `origin/pushwig/main` at the exact accepted V1C integration state.

Active issue: [#26 — V1D-0: Select bulk raster composition primitive](https://github.com/kasselvania/standalone-BitWig-push/issues/26).

Before work begins, fetch central `origin/main` and verify that its history contains:

```text
e748d168ce9983bd787fad25ac03ccb5b650edb1  # accepted V1C evidence
```

Create the central evidence branch directly from the then-current accepted `origin/main`. If `origin/main` has moved, inspect every intervening commit and stop if it changes V1D-0 authority or scope.

## Primary claim

Select and prove the smallest production-capable mechanism that can place an already-cropped, already-scaled raster region onto the **current V1C semantic frame in bulk** while preserving:

- exact source pixels inside the declared destination;
- exact current semantic pixels outside it;
- exact V1C restoration after movement, replacement, absence, staleness, invalidity, or malformed metadata;
- bounded synchronous cost and memory;
- one existing `PushUsbDisplay` writer;
- a host-neutral boundary suitable for later external frames.

V1C proved the complete dynamic lifecycle for project-owned vector renderers. It did not prove how a captured Bitwig or plug-in image—an array of pixels—can enter that lifecycle without thousands of drawing calls.

V1D-0 is an evidence-first architecture gate. It does not merge production DrivenByMoss source, open an external socket, add shared memory, define the final `VisualSourceFrame`, or capture a window.

See [`docs/V1D0_BULK_RASTER_COMPOSITION.md`](docs/V1D0_BULK_RASTER_COMPOSITION.md).

## Accepted authorities

### Central authority and evidence

```text
repository: kasselvania/standalone-BitWig-push
V1C merge:  e748d168ce9983bd787fad25ac03ccb5b650edb1
tree:       2d0a7a812e25c15aa082025f6d2ec90e8595b65c
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

Official extension SHA-256 to restore after any live prototype:

```text
98dc3195ad8d911526e18b1005f09f69a1aedcb965b080565474104654345c5a
```

## Accepted V1C ownership rule

The accepted dynamic output lifecycle is:

```text
newest retained ModelInfo
        -> complete current-semantic redraw
        -> optional current visual
        -> same persistent IBitmap
        -> unchanged PushUsbDisplay
```

Historical composed output is never restoration authority.

V1D-0 may replace the temporary local vector source in a research prototype, but it must not replace this restoration model.

## First canonical raster contract

The research target is deliberately narrow:

```text
pixel format: BGRA8888 opaque
source:       already cropped and already scaled
destination:  explicit x, y, width, height inside 960x160
stride:       explicit and validated
execution:    synchronous on the current display/composition thread
```

The first sink does not perform:

- scaling;
- alpha blending;
- color management;
- physical-desktop coordinate conversion;
- capture-source discovery;
- or operating-system image conversion.

Those belong outside the sink.

Opaque BGRA8888 is selected for the research because the accepted Bitwig bitmap observation is four-byte BGRA and ordinary captured UI regions are opaque. This is a candidate internal format, not yet the public external wire contract.

## Fail-closed rule

Before any destination byte is changed, the sink must validate:

- supported pixel format;
- positive dimensions;
- destination coordinates;
- destination bounds;
- source stride;
- required byte count;
- arithmetic overflow;
- source-buffer accessibility;
- and current visual validity.

Absent, stale, invalid, unsupported, malformed, overflowed, short, or out-of-bounds input must perform **no raster write** after the complete current-semantic redraw. The result must be exact semantic-only output.

Partial writes followed by rejection are forbidden.

## Candidate order

Evaluate in this order and stop when one candidate satisfies every correctness, abstraction, lifecycle, one-writer, and performance requirement.

### Candidate A — direct writable bitmap-region capability

Temporarily add the narrowest host-neutral capability needed to copy validated BGRA8888 rows into the current V1C bitmap after semantic redraw and before the unchanged transport.

Prove all of the following:

1. The Bitwig bitmap `MemoryBlock` view is writable.
2. Writes are visible to bitmap encode, debug display where useful, and the physical Push.
3. Row order, channel order, alpha byte, capacity, and stride are exact.
4. Destination writes do not scale, filter, translate, or alter pixels outside the declared rectangle.
5. Validation completes before the first write.
6. Buffer/view lifetime and thread ownership are explicit.
7. No Bitwig API type enters the future host-neutral frame contract.
8. Fixed or cached resources prevent unbounded native/JVM allocation.
9. `PushUsbDisplay` remains unchanged and sole-owned.

Candidate A is preferred because it can place already-prepared pixels without a second bitmap or host filtering.

### Candidate B — reusable source bitmap plus bitmap-as-image blit

Test only if Candidate A is unavailable, unsafe, incoherent, or architecturally unacceptable.

Allocate one reusable source bitmap, populate it in bulk, and draw it onto the current semantic bitmap through a narrow project graphics capability.

Prove:

- one-time bitmap allocation;
- exact source write;
- exact destination pixels;
- no unexpected scaling, interpolation, premultiplication, or color conversion;
- clean project-wrapper design;
- bounded cost;
- and unchanged restoration/transport ownership.

### Candidate C — encode-time compositing wrapper above transport

Test only if A and B fail.

Any encode-time design must remain above and outside `PushUsbDisplay`, preserve V1C semantic redraw as restoration authority, avoid a second USB writer, and declare every intermediate buffer and lifetime.

Transport bytes may not become semantic authority.

### Blocked outcome

If no candidate passes, retain the smallest missing capability, exact experiments, and the next bounded research. Do not modify `PushUsbDisplay`, draw one rectangle per pixel, or hide the gap with a platform-specific capture object.

## Required accepted-source inspection

Before prototyping, inspect the exact accepted V1C source and actual resolved Bitwig Extension API 21 JAR.

At minimum inspect:

```text
IBitmap
IImage
IRenderer
IGraphicsContext
IEncoder
IHost
IMemoryBlock
BitmapImpl
ImageImpl
GraphicsContextImpl
HostImpl
AbstractGraphicDisplay
Push2Display
DynamicLocalPushFramePipeline
PushUsbDisplay
```

Inspect these Bitwig API 21 classes directly with `javap` or equivalent:

```text
com.bitwig.extension.api.graphics.Bitmap
com.bitwig.extension.api.graphics.Image
com.bitwig.extension.api.graphics.GraphicsOutput
com.bitwig.extension.api.graphics.BitmapFormat
com.bitwig.extension.api.MemoryBlock
```

Retain:

- API JAR path, size, and SHA-256;
- every project implementation of `IBitmap`;
- relevant public signatures;
- the exact `HostImpl.createBitmap` implementation;
- whether `ByteBuffer` is read-only or writable;
- direct/heap status, byte order, position, limit, capacity, and reuse behavior;
- whether two buffer views alias the same native memory;
- row origin and orientation;
- byte/channel order;
- alpha behavior;
- and whether memory writes are visible without a second host render callback.

Do not rely on a flattened third-party API dump when the resolved JAR and real host object are available.

## Research topology

### Central evidence

From the then-current accepted central `origin/main`, create:

```text
codex/v1d0-bulk-raster-composition-evidence
```

The final reviewable output is one ordinary, non-draft, open, unmerged central PR containing only:

```text
evidence/v1d0-bulk-raster-composition/**
```

Include `Addresses #26` and identify the exact basis/head/tree.

### DrivenByMoss experiments

Use clean temporary worktrees rooted at exact accepted `origin/pushwig/main`.

Temporary branches, commits, patches, harnesses, and uncommitted instrumentation are allowed locally. They must not be merged into `pushwig/main`, and no production DrivenByMoss PR is expected from V1D-0.

Retain patch/source/harness hashes, changed paths, build results, artifact hashes, and final removal/cleanliness. Do not copy DrivenByMoss source into the central repository.

## Required generated-raster tests

Use only project-generated test patterns. Do not use or retain Bitwig, Ableton, or third-party plug-in screenshots.

Test at least:

```text
small:       64x16
odd/padded:  117x37 with source stride > width*4
medium:      480x80
full frame:  960x160
```

Patterns must make orientation and channel mistakes obvious. Include at least:

- asymmetric corners;
- per-channel color bars;
- row and column markers;
- a checker or gradient;
- and a recognizable generated test card.

Exercise changing content, movement, overlap, enlargement, reduction, replacement, NONE, STALE, INVALID, and a semantic update beneath prior coverage through the accepted V1C lifecycle.

## Exact correctness requirements

Run at least 1,000 complete lifecycle cycles or an equivalent number of rigorously counted transitions.

Required exact results:

```text
source-versus-target pixel mismatches           0
outside-current-region mismatches               0
old-region restoration mismatches               0
post-NONE full-frame mismatches                  0
STALE full-frame mismatches                      0
INVALID full-frame mismatches                    0
semantic-update-under-coverage mismatches        0
partial writes after invalid metadata            0
```

Negative validation must include:

- negative coordinates;
- coordinates near integer limits;
- zero/negative dimensions;
- destination extent overflow;
- destination out of bounds;
- stride below `width * 4`;
- stride arithmetic overflow;
- short source data;
- unsupported format;
- and inconsistent metadata changed between validation and application where the candidate exposes that possibility.

Every rejection must leave the full output equal to the freshly redrawn current semantic reference.

Retain only hashes, mismatch counts, dimensions, strides, masks, commands, and representative mismatch coordinates. Do not commit frames or screenshots.

## Performance and memory

For every serious candidate, collect at least 1,000 post-warmup samples for:

- current semantic redraw with no raster;
- small raster application;
- odd/padded raster application;
- medium raster application;
- full-frame raster application;
- validation rejection.

Record:

- p50, p95, and maximum;
- bytes copied;
- fixed construction-time allocation;
- project-owned per-cycle allocation;
- `ByteBuffer` or view creation;
- working-set start/end/peak;
- useful JVM heap readback;
- and any control, display, or audio effect.

Review bands for current-semantic redraw plus full-frame raster application on the accepted Mac:

```text
green:  p95 <= 2 ms and max <= 10 ms
review: p95 <= 5 ms and max <= 15 ms
stop:   p95 > 5 ms or max > 15 ms
```

A review-band result requires an explicit technical recommendation. A stop-band result stops the candidate.

Do not introduce threads, queues, another bitmap, or transport changes merely to hide synchronous cost.

## Build and source custody

Use the accepted explicit Java 21/Maven environment:

```text
env \
  JAVA_HOME=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home \
  PATH=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin \
  mvn clean install package -Dbitwig.extension.directory=target
```

For each candidate retain:

- exact parent commit/tree;
- temporary branch/worktree;
- complete patch or commit SHA-256;
- changed paths;
- `git diff --check`;
- clean-state readback;
- build result;
- artifact size/SHA-256;
- extracted class/resource delta;
- and `PushUsbDisplay.class` identity for any candidate reaching hardware.

No generated extension artifact or prototype source is committed to the central repository.

## Real fixture gate

Take only the leading exact candidate to the real Mac + Bitwig 6.1 + Push 3 fixture after offline correctness and performance pass.

Before installation, preserve the accepted safe replacement and rollback procedure.

Prove on the physical fixture:

1. Push connects normally.
2. Pads, pressure/MPE, encoders, and transport work.
3. Push remains the audio device and headphone output is audible.
4. Generated raster cards appear at the declared bounds.
5. Orientation and BGRA channel bars are correct.
6. The odd-width/padded-stride pattern is not skewed.
7. A large or full-frame pattern is coherent.
8. Movement, replacement, resize, NONE, STALE, and INVALID restore current semantics.
9. A semantic change beneath prior coverage reappears.
10. Rejected malformed metadata performs no partial visible write.
11. There is no trail, stale block, unexpected filtering, whole-frame clear, coordinate error, lag, xrun, or relevant exception.
12. Bitwig quits normally.
13. The exact official extension is restored as the sole scanned artifact and physically confirmed.

If the candidate behaves unexpectedly, stop, quit safely, restore the official artifact, and retain the failure. Do not widen the source during the live phase.

## Expected evidence

```text
evidence/v1d0-bulk-raster-composition/
├── README.md
├── accepted-source-and-api.md
├── candidate-a-direct-write.md
├── alternative-candidates.md
├── raster-correctness.md
├── negative-validation.md
├── performance.md
├── real-fixture-and-rollback.md
└── decision.md
```

Files may be omitted only when `decision.md` explains why the corresponding candidate was not reached.

Every file must state what it proves and what it does not prove.

## Decision output

`decision.md` must choose exactly one status:

```text
SELECTED
```

or:

```text
BLOCKED
```

For `SELECTED`, state:

- selected candidate;
- exact production source seam and expected paths;
- host-neutral interface shape;
- pixel format and alpha policy;
- validation and overflow rules;
- source/destination buffer ownership;
- thread and lifetime rule;
- current-semantic fallback rule;
- fixed and per-cycle allocation budget;
- performance budget;
- and alternative disposition.

For `BLOCKED`, state the smallest missing API/capability, experiments performed, and next bounded research.

Do not write a vague hybrid recommendation.

## Explicit non-goals

V1D-0 does not add or prove:

- a production DrivenByMoss source PR;
- an external helper process;
- Unix-domain, TCP, HTTP, WebSocket, or OSC frame transport;
- shared memory or memory-mapped IPC;
- the final `VisualSourceFrame` contract;
- sequence numbers or producer freshness;
- ScreenCaptureKit or Screen Recording permission;
- Bitwig/plugin window discovery or capture;
- scaling or resampling;
- alpha blending;
- color management;
- adapter/resolver/calibration/pixel anchors;
- `PushUsbDisplay` changes;
- a second USB writer;
- Push 2 hardware acceptance;
- Steam Deck/Linux;
- appliance, battery, connector, or NUC work;
- yabridge, Monome, or plugdata work.

## Acceptance

V1D-0 is complete only when:

1. Research starts from the exact accepted central and DrivenByMoss states.
2. The actual API and bitmap implementation are inspected directly.
3. Candidate A is tested first or rejected by exact source/API evidence.
4. One candidate applies small, padded, medium, and full-frame generated rasters in bulk.
5. Every required pixel/restoration mismatch count is zero.
6. Every negative-validation case is fail-closed with zero partial writes.
7. Buffer, thread, lifetime, and abstraction ownership are explicit.
8. Performance/allocation evidence is retained.
9. `PushUsbDisplay` remains unchanged and sole-owned.
10. The leading candidate receives bounded real-fixture validation or has one precise safety blocker.
11. Exact official rollback passes after any live prototype.
12. `decision.md` selects one production seam or one precise blocker.
13. No temporary source or instrumentation is merged.
14. The central evidence PR is open, non-draft, unmerged, and identifies exact basis/head/tree.

## Handoff

If a candidate is selected, **V1D-1 — Production Bulk Raster Frame Lifecycle** implements only the chosen raster sink with locally generated byte frames.

Only after that production sink is accepted does **V1D-2 — External Latest-Frame Ingress** add a process boundary, freshness, sequence, malformed producer handling, and producer restart.

Operating-system window capture remains V2.

## Review standard

Do not accept V1D-0 merely because a colored block appears. The candidate must prove exact source pixels, stride and bounds, no partial invalid writes, semantic restoration, bounded cost, host-neutral containment, one writer, and exact rollback.
