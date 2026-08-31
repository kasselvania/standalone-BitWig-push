# Accepted source and API analysis

## Date, machine state, and authorities

- Evidence date: 2026-08-31 PDT.
- Machine state: accepted macOS 26.4.1 arm64 fixture; source/API inspection was read-only before prototype work.
- Central basis: `24431c70eb720235b9c7836d9b2842a798d81d54`, tree `bb72673d2b3ce01ed6525a6ab7f2096dde1ac7bf`.
- DrivenByMoss basis: `1ae0b74f383314d170a5960ca763bdf9c319e787`, tree `a81e5c4330b31f36845c25e98e322990d62f0c67`.
- Candidate identity referenced by later tests: local commit `3e8df95e9cc489e69da72b9acb82f2d06c90dd00`, tree `f448eeda923232346037074a75b71c485e56ebe8`.
- API artifact: `$HOME/.m2/repository/com/bitwig/extension-api/21/extension-api-21.jar`, 166,421 bytes, SHA-256 `eef420a95b1e8c418ee23a5d3969e000413fd5c10432e53a76ede8de31238888`.

## Commands and inspected source

Tools and command shapes included `git show`, `rg`, `sed`, `nl`, `shasum -a 256`, and Java 21 `javap -classpath ...`. The accepted source inspection covered:

```text
src/main/java/de/mossgrabers/framework/controller/display/AbstractGraphicDisplay.java
src/main/java/de/mossgrabers/framework/graphics/display/ModelInfo.java
src/main/java/de/mossgrabers/framework/graphics/IBitmap.java
src/main/java/de/mossgrabers/framework/graphics/IRenderer.java
src/main/java/de/mossgrabers/framework/graphics/IGraphicsContext.java
src/main/java/de/mossgrabers/framework/daw/IHost.java
src/main/java/de/mossgrabers/bitwig/framework/graphics/BitmapImpl.java
src/main/java/de/mossgrabers/bitwig/framework/graphics/GraphicsContextImpl.java
src/main/java/de/mossgrabers/bitwig/framework/graphics/ImageImpl.java
src/main/java/de/mossgrabers/controller/ableton/push/controller/Push2Display.java
src/main/java/de/mossgrabers/controller/ableton/push/controller/PushFramePipeline.java
src/main/java/de/mossgrabers/controller/ableton/push/controller/PassThroughPushFramePipeline.java
src/main/java/de/mossgrabers/controller/ableton/push/controller/SyntheticOverlayPushFramePipeline.java
src/main/java/de/mossgrabers/controller/ableton/push/controller/PushUsbDisplay.java
```

The actual locally resolved API 21 JAR was inspected directly for:

```text
com.bitwig.extension.api.graphics.Bitmap
com.bitwig.extension.api.graphics.Image
com.bitwig.extension.api.graphics.GraphicsOutput
com.bitwig.extension.api.MemoryBlock
```

No flattened third-party API dump was used as authority.

## Exact accepted lifecycle

### Persistent bitmap and model

`AbstractGraphicDisplay` creates one bitmap in its constructor with `host.createBitmap(width, height)`, retains it in a final field, and sends that same persistent `IBitmap`. Before the candidate, `send()` created a `ModelInfo`, rendered only when it differed from the previous model, cleared the temporary component/overlay lists, and sent the persistent bitmap even when no semantic redraw occurred.

`ModelInfo` copies both input lists in its constructor. Its `equals` and `hashCode` include components and notification but omit overlays. That omission matters for restoration: a redraw request must retain the newest `ModelInfo` even when equality-covered fields did not change. Candidate A therefore assigns the newest model before the ordinary dirty-render decision.

`renderImage()` uses the retained `ModelInfo` to draw the semantic image. The method is private in the accepted source, so a production solution needs a narrow default-off request seam rather than exposing the method publicly or forcing every graphic controller to redraw.

### Bitmap abstraction and concrete adapter

Project `IBitmap` exposes only:

```text
void render(boolean, IRenderer)
void encode(IEncoder)
```

It exposes no copy, write, blit, read-region, restore, dimensions, or raw-buffer operation.

`BitmapImpl.render` delegates to Bitwig `Bitmap.render` and constructs a `GraphicsContextImpl` for the host callback. `BitmapImpl.encode` obtains `bitmap.getMemoryBlock().createByteBuffer()` and supplies the buffer plus width/height to the project encoder. This makes aggregate observation possible, but does not make raw memory the preferred production restoration model.

`HostImpl.createBitmap` requests Bitwig `BitmapFormat.ARGB32`. The accepted fixture observation interprets the exposed byte layout as 960x160 BGRA8888, four bytes per pixel.

`GraphicsContextImpl.drawImage(IImage, x, y)` currently casts the project wrapper to `ImageImpl`. That is a project-wrapper limitation: it cannot presently accept a generic project `IBitmap` even though the underlying Bitwig API can draw a `Bitmap` as an `Image`.

### Exact API 21 signatures

Direct `javap` output established these public API facts:

```text
public interface Bitmap extends Image
Bitmap.getWidth(): int
Bitmap.getHeight(): int
Bitmap.getFormat(): BitmapFormat
Bitmap.getMemoryBlock(): MemoryBlock
Bitmap.render(Renderer): void
GraphicsOutput.drawImage(Image, double, double): void
MemoryBlock.size(): int
MemoryBlock.createByteBuffer(): java.nio.ByteBuffer
```

Therefore Bitwig's public API permits a bitmap to cross `drawImage(Image, ...)`. The unresolved questions for Candidate B would have been project-wrapper shape and pixel-exact/filtering behavior, not API type assignability.

### Transport ownership

`Push2Display.send(IBitmap)` preserves the shutdown/null guard, calls exactly one `PushFramePipeline.process`, and calls exactly one `PushUsbDisplay.send` with the result. `PushUsbDisplay` owns the existing encode/USB path and is unrelated to semantic restoration authority. It must remain untouched.

## Hypothesis disposition

| Hypothesis | Result |
| --- | --- |
| `AbstractGraphicDisplay` owns one persistent bitmap | Confirmed. |
| `send()` rerenders only when `ModelInfo` changes | Confirmed for the accepted base. |
| `ModelInfo` copies component and overlay lists | Confirmed. |
| `renderImage()` draws from retained `ModelInfo` | Confirmed. |
| `IBitmap` has render/encode but no copy/write | Confirmed. |
| `BitmapImpl.encode` observes bitmap memory | Confirmed. |
| `GraphicsContextImpl.drawImage` accepts only `ImageImpl` | Confirmed as a project-wrapper constraint. |
| Bitwig `Bitmap` cannot be drawn as an `Image` | Corrected: API 21 declares `Bitmap extends Image`. |
| `PushUsbDisplay` should participate in restoration | Rejected; it remains transport-only and unchanged. |

## What this proves

- Candidate A can be tested with existing semantic drawing authority and no second bitmap.
- Candidate B was technically researchable through the public Bitwig API, but would require a new wrapper capability and pixel-exact blit proof.
- Restoration belongs before `PushUsbDisplay`, while the current semantic model and graphics context are still available.

## What this does not prove

- API type compatibility alone does not prove bitmap-to-bitmap blits are pixel-exact or allocation-free.
- Retained component references are not formally immutable; real fixture and deterministic pixel tests provide bounded evidence for the tested states, not a theorem covering every future component.
- This inspection does not authorize public Bitwig types, `MemoryBlock`, or `ByteBuffer` in a future host-neutral visual-frame contract.
