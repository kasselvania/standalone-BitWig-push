# Accepted source, API, and bitmap-memory analysis

## Evidence identity

- Date: 2026-09-01 PDT.
- Machine state: accepted arm64 macOS + Bitwig Studio 6.1 + DrivenByMoss 26.4.1 + Push 3 fixture.
- Central basis: `a66e1e45ebb2cb72f8ea1cb12e96d1bc46d7c343`, tree `b83e9e9507dc2e26d551abed1f03c30a6b76a551`.
- DrivenByMoss basis: `852b520933eed87fbe496a04b5c18819a10b3564`, tree `d03a372e2efcf41b22cef46501e08efbfb0c0036`.
- Candidate identity: local research commit `61c659e19faad3944f610022fca5d57f09e7b442`, tree `6d06def69677918e871bb5a0c978be83aab29cb8`; final observation patch SHA-256 `2cba0fbffabeb6e7609f6c5ffbdb433e1e9bfa90d9f1e5414f84843a8c4b7e96`.

## Accepted source behavior

Exact accepted source inspection established:

1. `AbstractGraphicDisplay` constructs one persistent `IBitmap` through `IHost.createBitmap(width,height)` and retains the newest copied `ModelInfo` on every `send()`.
2. Accepted V1C calls `renderImage()` when the model changes or the specialized Push path requests a current-model redraw. It then passes that same persistent bitmap to `Push2Display.send(IBitmap)`.
3. `Push2Display` selects a frame pipeline once at construction, preserves the shutdown/null guard, invokes the pipeline once, and invokes `PushUsbDisplay.send` once with its result.
4. `BitmapImpl.render` delegates to the Bitwig bitmap render callback. `BitmapImpl.encode` obtains a bitmap `MemoryBlock` view and passes it to the encoder.
5. `IBitmap` exposes only `render` and `encode` for pixel operations; it has no region-write or destination-memory method.
6. Source search found exactly one `IBitmap` implementation: `de.mossgrabers.bitwig.framework.graphics.BitmapImpl`.
7. Source search found the display bitmap created by `AbstractGraphicDisplay`; `HostImpl.createBitmap` always wraps `host.createBitmap(width,height,BitmapFormat.ARGB32)` in `BitmapImpl`.
8. `GraphicsContextImpl.drawImage(IImage,...)` casts to `ImageImpl`, so the project wrapper cannot presently draw a project `BitmapImpl` even though the Bitwig API declares `Bitmap extends Image`.
9. `PushUsbDisplay.send` calls `IBitmap.encode` synchronously under its buffer-update lock, performs BGRA-to-16-bit conversion, scan-line padding, and XOR shaping, then submits its existing transfer task. Restoration and raster ownership remain above it.

Relevant accepted paths inspected:

```text
src/main/java/de/mossgrabers/framework/graphics/IBitmap.java
src/main/java/de/mossgrabers/framework/graphics/IImage.java
src/main/java/de/mossgrabers/framework/graphics/IRenderer.java
src/main/java/de/mossgrabers/framework/graphics/IGraphicsContext.java
src/main/java/de/mossgrabers/framework/graphics/IEncoder.java
src/main/java/de/mossgrabers/framework/daw/IHost.java
src/main/java/de/mossgrabers/framework/daw/IMemoryBlock.java
src/main/java/de/mossgrabers/bitwig/framework/graphics/BitmapImpl.java
src/main/java/de/mossgrabers/bitwig/framework/graphics/ImageImpl.java
src/main/java/de/mossgrabers/bitwig/framework/graphics/GraphicsContextImpl.java
src/main/java/de/mossgrabers/bitwig/framework/daw/HostImpl.java
src/main/java/de/mossgrabers/framework/controller/display/AbstractGraphicDisplay.java
src/main/java/de/mossgrabers/controller/ableton/push/controller/Push2Display.java
src/main/java/de/mossgrabers/controller/ableton/push/controller/DynamicLocalPushFramePipeline.java
src/main/java/de/mossgrabers/controller/ableton/push/controller/PushUsbDisplay.java
```

## Exact API 21 artifact and public signatures

Inspected artifact:

```text
path:   $HOME/.m2/repository/com/bitwig/extension-api/21/extension-api-21.jar
size:   166421 bytes
sha256: eef420a95b1e8c418ee23a5d3969e000413fd5c10432e53a76ede8de31238888
```

Relevant `javap` signatures:

```text
public interface Bitmap extends Image {
    int getWidth();
    int getHeight();
    BitmapFormat getFormat();
    MemoryBlock getMemoryBlock();
    void render(Renderer);
}

public interface Image {
    int getWidth();
    int getHeight();
}

public interface GraphicsOutput {
    void drawImage(Image, double, double);
}

public enum BitmapFormat {
    ARGB32, RGB24_32;
    int bytesPerPixel();
}

public interface MemoryBlock {
    int size();
    ByteBuffer createByteBuffer();
}
```

These signatures establish public access to bitmap dimensions, format, and memory views. They do not document whether views are writable/direct, their byte order, row stride, aliasing, lifetime, thread requirements, or coherence with render/encode. Those questions required real-host observation.

## Real 960x160 bitmap characterization

The final observation build printed one sanitized construction/use record after a validated small write:

```text
format=ARGB32
width=960
height=160
MemoryBlock.size=614400
position=0
limit=614400
capacity=614400
readOnly=false
direct=true
hasArray=false
order=LITTLE_ENDIAN
distinctViews=true
aliasesAfterWrite=true
thread=Control Surface Session
```

Additional exact results:

- `614400 == 960 * 160 * 4`; destination rows are tightly packed at `3840` bytes with no hidden row padding.
- Two calls to `createByteBuffer()` returned distinct view objects over the same backing memory; a write through one was immediately readable through the other.
- Absolute bulk writes did not mutate destination position or limit.
- The cached view remained valid and coherent for more than 1,000 eligible applications and 1,920 real output sends.
- `IBitmap.encode` observed every accepted write exactly; the physical Push displayed the same generated asymmetric patterns.
- Physical corner markers established top-left origin, rows increasing downward, and columns increasing rightward.
- Sequential memory bytes are blue, green, red, alpha. The selected alpha policy copies only prevalidated `0xFF` alpha bytes.
- The subsequent accepted V1C current-semantic redraw replaced prior raster bytes predictably before the next current raster or semantic-only state.
- The debug bitmap window was not separately relied upon and is recorded as NOT TESTED for independent visibility.

## Boundary classification

### Documented public API

- `Bitmap extends Image`.
- Bitmap dimensions, `BitmapFormat`, `MemoryBlock`, and `MemoryBlock.createByteBuffer()` are public API.
- `GraphicsOutput.drawImage(Image,...)` is public API.

### Current project-wrapper limits

- `IBitmap` lacks a narrow bulk region-write capability.
- `GraphicsContextImpl.drawImage` accepts project `IImage` but casts it to `ImageImpl`; it cannot draw `BitmapImpl` without a wrapper change.
- `BitmapImpl` obtains a new memory view for each existing `encode` call.

### Real-host observations

- Writable/direct/little-endian/tightly packed memory, view aliasing, cached-view lifetime, render replacement, encode visibility, physical Push visibility, and `Control Surface Session` ownership.

### Unresolved/documentation gap

- API 21 does not formally promise cached-view lifetime or layout. V1D-1 must retain construction-time layout checks and fail closed if the exact fixture properties do not hold.

## Commands and tools

Used `rg` for implementation/call-site enumeration, `nl`/`sed` for exact source inspection, `shasum -a 256`, `stat`, Java 21 `javap`, candidate bytecode disassembly, temporary one-shot aggregate observation, `IBitmap.encode` comparisons, and physical Push observation.

## What this proves

The accepted Bitwig adapter owns a coherent writable 960x160 BGRA byte store that can support a narrow direct-write capability without changing the host-neutral semantic/pipeline boundary or the transport.

## What this does not prove

It does not turn observed Bitwig implementation behavior into a cross-host API guarantee, test bitmap-as-image filtering, define an external frame contract, or authorize any `PushUsbDisplay` change.
