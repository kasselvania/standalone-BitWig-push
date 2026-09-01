# V1D-0 bulk raster composition architecture decision

## Status: SELECTED

## Evidence identity

- Date: 2026-09-01 PDT.
- Machine state: accepted arm64 macOS + Bitwig Studio 6.1 + DrivenByMoss 26.4.1 + real Push 3 fixture.
- Central basis: `a66e1e45ebb2cb72f8ea1cb12e96d1bc46d7c343`, tree `b83e9e9507dc2e26d551abed1f03c30a6b76a551`.
- DrivenByMoss basis: `852b520933eed87fbe496a04b5c18819a10b3564`, tree `d03a372e2efcf41b22cef46501e08efbfb0c0036`.
- Selected Candidate A local commit/tree: `61c659e19faad3944f610022fca5d57f09e7b442` / `6d06def69677918e871bb5a0c978be83aab29cb8`.
- Main harness SHA-256: `7be829d7e302b00226f6fabf005e2a423b91132d6eebdae980acbc57657b6ee7`.
- Observation patch/artifact SHA-256: `2cba0fbffabeb6e7609f6c5ffbdb433e1e9bfa90d9f1e5414f84843a8c4b7e96` / `f7903aabd3266b9c26db34d68279632cffac6281cf453705d7763a0f0617076a`.
- No DrivenByMoss source branch/PR was published.

## Selected candidate

**Candidate A — a direct, encapsulated, writable bitmap-region capability in the Bitwig bitmap adapter.**

The production rule is:

```text
output = compose(
    redraw(newestRetainedSemanticModel),
    optionalCurrentValidOpaqueBGRARegion)
```

It is never:

```text
output = mutate(previousComposedOutput, maybeNewRaster)
```

## Exact production ownership model

1. Accepted V1C continues to retain the newest `ModelInfo` and fully redraw the one persistent Push `IBitmap` before dynamic composition.
2. A package-private local-raster pipeline owns only the current V1D-1 generated raster state and fixed generated source arrays.
3. For a current valid state, the pipeline requires `IRasterWritableBitmap`, passes opaque BGRA bytes plus primitive source/destination metadata, and receives a bounded success/rejection result.
4. `BitmapImpl` alone owns the Bitwig bitmap, `MemoryBlock`, cached writable destination view, target layout validation, complete request validation, thread binding, and absolute bulk row writes.
5. The pipeline returns the exact same logical `IBitmap`.
6. `Push2Display` invokes the unchanged `PushUsbDisplay.send` exactly once. No raster object owns USB state or transport bytes.
7. For NONE, STALE, INVALID, unsupported target, or rejected metadata, the pipeline performs no raster write; the already-fresh semantic bitmap proceeds unchanged.

## Exact expected V1D-1 source envelope

V1D-1 should change exactly these paths:

```text
src/main/java/de/mossgrabers/bitwig/framework/graphics/BitmapImpl.java
src/main/java/de/mossgrabers/controller/ableton/push/controller/Push2Display.java
src/main/java/de/mossgrabers/controller/ableton/push/controller/DynamicLocalRasterPushFramePipeline.java
src/main/java/de/mossgrabers/framework/graphics/IRasterWritableBitmap.java
src/main/java/de/mossgrabers/framework/graphics/RasterPixelFormat.java
```

`DynamicLocalRasterPushFramePipeline.java` is the production-name replacement for the research-only `BulkRasterProbePushFramePipeline.java`. It provides only the bounded locally generated V1D-1 corpus/lifecycle; it does not define external ingress.

No change is expected in:

```text
AbstractGraphicDisplay.java
DynamicLocalPushFramePipeline.java
PushFramePipeline.java
PushUsbDisplay.java
GraphicsContextImpl.java
IBitmap.java
pom.xml
```

An additional production path or a change to any excluded path is an envelope change requiring authority before editing.

## Exact host-neutral contract

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

The first enum value is `OPAQUE_BGRA8888`; unsupported values reject. The boolean is a bounded result: `true` means the complete region was applied, `false` means no destination byte changed.

This interface is host-neutral. Bitwig `Bitmap`, `MemoryBlock`, `ByteBuffer`, macOS types, capture handles, USB types, and transport objects do not cross it.

## Source-carrier choice

**Select `byte[]` for V1D-1.**

- Ownership: caller has exclusive array ownership until the synchronous call returns.
- Position/limit: not present, so validator/application cannot see inconsistent cursor metadata.
- Allocation: no duplicate/read-only source view is required per application.
- Performance: indistinguishable in practical terms from the measured read-only `ByteBuffer` alternative.
- Later shared memory: V1D-2 may copy one validated current external frame into a bounded controller-owned reusable array. A future zero-copy buffer overload requires its own producer concurrency/lifetime authority; V1D-1 does not silently promise it.

## Pixel and row contract

- Pixel format: four sequential bytes, blue, green, red, alpha (`BGRA8888`).
- Alpha policy: require every source alpha byte to equal `0xFF`, validate the complete region first, then copy the opaque alpha bytes. Any non-opaque byte rejects the whole operation.
- Row order: source row zero maps to destination y; y increases downward.
- Column order: source column zero maps to destination x; x increases rightward.
- Destination frame: 960x160, four bytes per pixel, tightly packed 3,840-byte rows on the accepted adapter.
- Source stride: explicit and `>= width * 4`; padding is ignored and never copied.
- Source offset: explicit byte offset of the first source pixel.
- No scaling, cropping from a larger source, filtering, blending, premultiplication, or color conversion occurs.

## Validation and overflow rule

Before the first destination byte changes, validate:

1. destination bitmap format, dimensions, writability, memory size, view limit/capacity, and expected tight packing;
2. supported raster format and non-null source;
3. positive width/height and nonnegative x/y/source offset;
4. `destinationX + width`, `destinationY + height`, and `width * 4` with `long` arithmetic;
5. destination extents within actual bitmap dimensions;
6. `sourceStride >= width * 4`;
7. `sourceOffset + (height - 1) * sourceStride + width * 4` with `long` arithmetic and within array length;
8. final destination offset with `long` arithmetic and within memory/view bounds;
9. every source alpha byte is `0xFF`;
10. current raster state is valid and access is on the bound composition thread.

Any failed check returns `false` without a write. After complete validation, each row is copied with absolute bulk `ByteBuffer.put(destinationIndex,source,sourceIndex,rowBytes)`. Primitive metadata cannot mutate mid-call. The source ownership rule forbids concurrent content mutation. These rules prevent validation-triggered partial writes; a construction-invalid destination never becomes raster-writable.

## Destination ownership, view lifetime, and thread rule

- `BitmapImpl` owns the destination memory for the bitmap lifetime and exposes no raw destination view.
- V1D-1 converts the current record to a final class while preserving its `bitmap()` accessor.
- It calls `MemoryBlock.createByteBuffer()` once at construction for the production writer and caches that view.
- Construction validates the exact required storage properties; unsupported layout remains semantic-only.
- Research proved the cached view across 1,920 real sends and more than 1,000 applications. Because API 21 does not document this lifetime, the construction checks and exact-host acceptance remain mandatory.
- Writes execute synchronously on the controller/display composition thread. The first valid write binds the owner thread; later writes from another thread reject before mutation. The accepted fixture thread name was `Control Surface Session`.
- No queue, executor, worker, timer, lock-free handoff, or second output bitmap is added.

## Stale, absent, invalid, and malformed behavior

All such states use the same rule:

```text
complete current-semantic redraw
        -> no raster application
        -> exact semantic-only bitmap
        -> existing send path
```

No previous raster, previous output, region snapshot, captured buffer, or Push transport byte store is restoration authority.

## Allocation and timing budgets

- Fixed production allocations: one cached destination view and fixed scalar metadata/thread reference per `BitmapImpl`; one bounded local pipeline and class-initialized V1D-1 generated arrays.
- Observation-only second view, diagnostics, counters, timing arrays, and source patterns not required by V1D-1 production behavior must be absent unless explicitly part of its bounded acceptance fixture.
- Project-owned per-application allocation: exactly zero objects/bytes.
- Required full redraw + full-frame application green band: p95 `<= 2 ms`, max `<= 10 ms`.
- Review band: p95 `<= 5 ms`, max `<= 15 ms`, with technical review.
- Stop band: p95 `> 5 ms` or max `> 15 ms`.
- Exact V1D-1 proposed head must repeat all size-class timings and retain startup/GC/scheduling outliers, including review of the isolated V1D-0 medium-path maximum.

## One-writer rule

Composition ends before transport. `Push2Display` remains the sole caller handing one selected bitmap to the existing `PushUsbDisplay`; `PushUsbDisplay` remains the only Push display transport/USB owner. V1D-0 candidate/base `PushUsbDisplay.class` was byte-identical at:

```text
288b576b3f2ed064f8d9a0c6f6d384fb3516a0858cc22e7879bee896df83dec3
```

## Later-candidate disposition

- Candidate B: NOT REACHED. A second source bitmap/blit adds allocation and exact-filter/premultiplication proof without a Candidate A gap.
- Candidate C: NOT REACHED. Encode-time composition adds an output buffer/copy and transport-adjacent ownership without a Candidate A gap.

They remain bounded fallbacks, not secretly tested or declared impossible.

## Exact V1D-1 acceptance proposal

V1D-1 should be accepted only when one exact proposed source head proves:

1. The five-path source envelope above, with no `PushUsbDisplay` or build/version/ID change.
2. The exact `byte[]`/primitive interface and opaque BGRA contract above.
3. Complete pre-write validation, all 25 negative classes, bad-alpha rejection, wrong-thread rejection, and zero partial writes.
4. At least 1,000 complete locally generated SMALL/ODD-PADDED/MEDIUM/FULL/replacement/movement/overlap/enlarge/reduce/NONE/STALE/INVALID/malformed cycles with every mismatch category at zero.
5. Exact source/target/outside/restoration hashes and positive target-change counts.
6. Same-reference synchronous pipeline bytecode, absolute bulk rows, and zero project-owned per-application allocations.
7. One cached destination view, exact construction/layout checks, and no raw destination exposure.
8. Same-toolchain base/head builds and extracted payload delta bounded to the five paths.
9. Byte-identical `PushUsbDisplay.class`, one pipeline call, one transport call, and one USB writer.
10. Post-warmup timing for all required sizes, with full-frame combined path inside the accepted band and explicit review of tail outliers.
11. Real Bitwig encode coherence, real Push orientation/channel/padding/restoration behavior, and all 34 manual fixture rows.
12. Exact official-artifact rollback and physical confirmation of standard DrivenByMoss behavior.
13. No external ingress, IPC/shared memory, sequence/freshness protocol, capture, scaling, alpha blending, color management, or Push 2 claim.

## Explicit unresolved questions

- Bitwig API 21 does not formally document cached memory-view lifetime/layout; V1D-1 must preserve fail-closed construction checks and exact fixture evidence.
- The isolated MEDIUM combined maximum (`17.679042 ms`) and mixed startup/interaction outliers require retained V1D-1 remeasurement even though the required full-frame gate was green and no lag was observed.
- V1D-2 must separately choose producer-buffer ownership, sequence/freshness, copy-versus-zero-copy policy, and shared-memory lifetime. V1D-1's `byte[]` is not the final wire contract.
- The debug display window was not an independent authority; encode and physical Push coherence passed.
- No Push 2 hardware behavior is claimed.

## Commands and tools

This decision rests on exact source/API inspection, real bitmap characterization, frozen local candidate build/bytecode/payload comparison, two external Java harnesses, temporary real-Bitwig aggregate observation, memory/timing/allocation readback, all 34 physical fixture results, normal shutdown, and exact official rollback.

## What this proves

This is a precise, implementable V1D-1 bulk-raster sink decision with explicit ownership, validation, format, lifetime, performance, and one-writer rules.

## What this does not prove

No production source is merged or proposed by V1D-0, and no external visual source, protocol, capture path, scaling path, or final public frame type exists yet.
