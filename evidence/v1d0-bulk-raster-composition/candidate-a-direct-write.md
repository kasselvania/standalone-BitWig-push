# Candidate A — direct writable bitmap region

## Evidence identity and source custody

- Date: 2026-09-01 PDT.
- Machine state: accepted arm64 macOS + Bitwig Studio 6.1 + DrivenByMoss 26.4.1 + Push 3 fixture.
- Central basis: `a66e1e45ebb2cb72f8ea1cb12e96d1bc46d7c343`, tree `b83e9e9507dc2e26d551abed1f03c30a6b76a551`.
- DrivenByMoss parent: `852b520933eed87fbe496a04b5c18819a10b3564`, tree `d03a372e2efcf41b22cef46501e08efbfb0c0036`.
- Local branch: `research/v1d0-direct-write`.
- Frozen local research commit: `61c659e19faad3944f610022fca5d57f09e7b442`.
- Frozen tree: `6d06def69677918e871bb5a0c978be83aab29cb8`.
- The local commit was not pushed; no source PR exists.

Exact changed paths in the frozen candidate:

```text
src/main/java/de/mossgrabers/bitwig/framework/graphics/BitmapImpl.java
src/main/java/de/mossgrabers/controller/ableton/push/controller/BulkRasterProbePushFramePipeline.java
src/main/java/de/mossgrabers/controller/ableton/push/controller/Push2Display.java
src/main/java/de/mossgrabers/framework/graphics/IRasterWritableBitmap.java
src/main/java/de/mossgrabers/framework/graphics/RasterPixelFormat.java
```

Source SHA-256 values:

```text
BitmapImpl.java                              568ad57ef03f5f0eb4c886684ddaf7928fc052f1cffe0a41a8cc99834412f46b
BulkRasterProbePushFramePipeline.java        96a7d0bb1072529df74540dae24557a88375225261ba8ebb8125dc0529b8d3f3
Push2Display.java                            165c0b98c6a1cc4eb2a9fbe7c7586093f0a4d69f53270ae58e7fa476837f2330
IRasterWritableBitmap.java                   f93d3e4c47a6dc62a2bd32a7256e15ac97f68d81081b4ce30e41b6816447e4a9
RasterPixelFormat.java                       87c352a6ff5fcea8fd5b22519e1a20b4ea823c0dd06df070d272b8b75ab99793
```

`git diff --check` passed before the local commit. The candidate and base worktrees were clean after build. The observation worktree was restored to the frozen candidate commit after retaining its patch/source hashes.

## Tested host-neutral shape

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

The only accepted research format was `RasterPixelFormat.OPAQUE_BGRA8888`. The interface contains no Bitwig `Bitmap`, `MemoryBlock`, Bitwig implementation class, USB type, platform type, capture type, or raw destination view.

`BitmapImpl` cached destination views at bitmap construction, validated the target format/dimensions/capacity, validated all request metadata and all opaque alpha bytes, bound writes to one thread, and then issued one absolute bulk `ByteBuffer.put(destinationIndex, source, sourceIndex, rowBytes)` per row. The caller retains exclusive ownership of the source array until synchronous return.

The research-only pipeline supplied class-initialized generated patterns and returned the same `IBitmap`. `Push2Display` selected it once with `pushwig.v1d0RasterProbe=true`, retained V1C full redraw, and preserved the existing single pipeline/single `PushUsbDisplay.send` call.

The prototype included a second cached view and one-time diagnostic fields solely to prove aliasing and host properties. The V1D-1 production proposal removes that verification view and diagnostic output; it caches one destination view.

## Source-carrier comparison

The same full-frame data was measured with both source-carrier shapes in the external harness:

| Carrier | p50 | p95 | max | Position/limit result |
|---|---:|---:|---:|---|
| `byte[]` | 0.010708 ms | 0.018250 ms | 2.570125 ms | Not applicable; no mutable cursor |
| read-only `ByteBuffer` | 0.010500 ms | 0.017375 ms | 0.709334 ms | Absolute operation left position/limit unchanged |

The timing difference is not material. `byte[]` is selected for V1D-1 because it has the simplest exclusive-ownership rule, exposes no mutable position/limit, needs no per-application duplicate/read-only-view allocation, and matches the local generated-raster slice. A later shared-memory ingress can copy into a bounded controller-owned reusable array; any zero-copy `ByteBuffer` external contract remains V1D-2 authority, not an implicit V1D-1 promise.

## Build and extracted payload

Both exact base and frozen candidate built successfully with OpenJDK 21.0.11 and Maven 3.9.16 under the accepted explicit environment. Only existing Maven shade/module warnings appeared.

```text
accepted base artifact:
  size:   14367247 bytes
  sha256: 87e838811ff264101044903edf1b557ab64845e46d891c871b5f1021dabea65c

candidate artifact:
  size:   14373998 bytes
  sha256: b001a77a4b697111fdb985a90a25f0e583551b271bdd80ca06cf17e4075f476d
```

Both manifests reported `Implementation-Title: DrivenByMoss`, `Implementation-Version: 26.4.1`, `Java-Version: 21`, and `Build-Jdk-Spec: 21`; embedded Maven properties remained `de.mossgrabers:DrivenByMoss:26.4.1`.

Extracted payload differences were exactly:

```text
changed  de/mossgrabers/bitwig/framework/graphics/BitmapImpl.class
changed  de/mossgrabers/controller/ableton/push/controller/Push2Display.class
new      de/mossgrabers/controller/ableton/push/controller/BulkRasterProbePushFramePipeline.class
new      de/mossgrabers/controller/ableton/push/controller/BulkRasterProbePushFramePipeline$Pattern.class
new      de/mossgrabers/framework/graphics/IRasterWritableBitmap.class
new      de/mossgrabers/framework/graphics/RasterPixelFormat.class
```

`PushUsbDisplay.class` was byte-identical in both artifacts:

```text
288b576b3f2ed064f8d9a0c6f6d384fb3516a0858cc22e7879bee896df83dec3
```

Accepted V1C `DynamicLocalPushFramePipeline.class` also remained byte-identical:

```text
8db7fc9e80ca659fc934b7f653e7b17305fe5d74bdf4b44c9d9269fcfb9330e4
```

## Bytecode and synchronous ownership

`javap -c -p` proved:

- `writeRasterRegion` calls validation before any `ByteBuffer.put`.
- The row loop uses the absolute bulk `ByteBuffer.put(int,byte[],int,int)` overload.
- The application method contains no `new`, bitmap construction, thread, queue, executor, future, or transport call.
- The pipeline returns its input `IBitmap` reference.
- `Push2Display.send` retains the shutdown/null guard and exactly one pipeline call followed by exactly one `PushUsbDisplay.send` call.
- No asynchronous raster handoff exists; `PushUsbDisplay` remains unchanged and the sole USB owner.

## Real observation custody

Final aggregate-only observation identity:

```text
uncommitted patch sha256: 2cba0fbffabeb6e7609f6c5ffbdb433e1e9bfa90d9f1e5414f84843a8c4b7e96
artifact size:            14381447 bytes
artifact sha256:          f7903aabd3266b9c26db34d68279632cffac6281cf453705d7763a0f0617076a
```

Observation-only changed paths atop the frozen candidate:

```text
src/main/java/de/mossgrabers/controller/ableton/push/controller/BulkRasterProbePushFramePipeline.java
src/main/java/de/mossgrabers/controller/ableton/push/controller/Push2Display.java
src/main/java/de/mossgrabers/framework/controller/display/AbstractGraphicDisplay.java
```

The instrumentation emitted aggregate counts/timings only, retained no raw frames, was never committed, and was completely removed. The observation worktree is clean at `61c659e19faad3944f610022fca5d57f09e7b442`.

## Commands and tools

Used exact base/candidate worktrees, `git diff --check`, `git diff-tree`, `shasum -a 256`, Java 21/Maven build, `unzip`, extracted payload hashing/diffing, `javap -c -p`, external harnesses, and temporary real-Bitwig aggregate instrumentation.

## What this proves

Candidate A provides the required exact bulk operation behind a narrow host-neutral capability, remains synchronous and allocation-bounded, preserves same-bitmap identity, and leaves transport/USB ownership unchanged.

## What this does not prove

The frozen local commit is research code, not the proposed V1D-1 source. Its generated probe, diagnostic view/logging, and startup property are not production architecture. No source branch or PR was published.
