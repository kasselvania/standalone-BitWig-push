# Accepted source and constraints

## Date, state, and bases

- Date: 2026-09-01 PDT.
- Machine state: accepted macOS 26.4.1 arm64 fixture; source inspection and builds used the local Maven/API cache.
- Central basis/tree: `5597624bd50e5ef95ecd3af82ea1816ce4facd21` / `ec016bd3174345e32f1a6d47eb061820e7a1e9b9`.
- DrivenByMoss basis/tree: `663d719207ef58ec84b4d235c43211ec5da43605` / `c4e42825d069421a44b3241349de9a7c6453a3ad`.
- Candidate head/tree: `4f00972355fcf7b5f0ead0fef3365b81850be12f` / `7202267e51d0f2613cea93d186b132a996ec14ec`.

## Accepted source behavior

The following accepted-basis responsibilities were inspected before prototyping:

| Source | Accepted responsibility relevant to V1D-2-0 |
| --- | --- |
| `BitmapImpl.java` | Wraps the persistent Bitwig bitmap/memory and implements the V1D-1 host adapter. |
| `IBitmap.java` | Host-neutral semantic bitmap contract; no external transport concern. |
| `IRasterWritableBitmap.java` | Synchronous bounded raster-region write seam selected by V1D-1. |
| `RasterPixelFormat.java` | Host-neutral exact pixel-format vocabulary; accepted format is opaque BGRA8888. |
| `AbstractGraphicDisplay.java` | Owns the persistent semantic bitmap and retained `ModelInfo`; redraw occurs before pipeline/send when required. |
| `Push2Display.java` | Owns pipeline selection and the single call from complete semantic bitmap through pipeline to `PushUsbDisplay.send`. |
| `DynamicLocalRasterPushFramePipeline.java` | Proves the accepted V1D-1 synchronous writer and same-`IBitmap` return rule. |
| `PushUsbDisplay.java` | Sole transport/USB writer; not a composition or ingress owner. |

The accepted V1D-1 sink is therefore reusable. Network receipt and publication must be new internal responsibilities, while semantic redraw, raster application, bitmap lifetime, and USB ownership remain where accepted.

Existing OSC patterns were inspected for lifecycle ideas only. OSC was rejected as a frame payload because it would not remove the need for a fixed maximum, complete-message framing, explicit session/sequence rules, and a bounded latest-frame store.

## Exact Bitwig API 21 artifact

- Artifact: `$HOME/.m2/repository/com/bitwig/extension-api/21/extension-api-21.jar`.
- Size: `166,421` bytes.
- SHA-256: `eef420a95b1e8c418ee23a5d3969e000413fd5c10432e53a76ede8de31238888`.

`javap` on the exact resolved artifact established:

```text
Bitmap extends Image
Bitmap.getMemoryBlock(): MemoryBlock
Bitmap.render(Renderer): void
GraphicsOutput.drawImage(Image, double, double): void
MemoryBlock.size(): int
MemoryBlock.createByteBuffer(): ByteBuffer
```

This confirms that direct bitmap/memory capabilities are public Bitwig API, while DrivenByMoss's host-neutral wrappers deliberately constrain which operations reach controller code. V1D-2-0 did not widen the public frame contract or leak `MemoryBlock`, `ByteBuffer`, sockets, or Bitwig types through it.

## Constraints retained in the selected candidate

- `PushUsbDisplay.java`, `pom.xml`, version/IDs, USB interface/endpoint, conversion, scan-line padding, XOR shaping, transfer executor, and existing USB shutdown were unchanged.
- Receiver code never receives or calls `IRasterWritableBitmap`.
- Display code never accepts/connects/reads a socket, parses an incomplete message, waits for a producer, takes a blocking publication lock, or joins the receiver.
- All maximum raster arrays are construction-time fixed allocations.
- Default startup without `pushwig.v1d20ExternalIngress=true` follows the accepted V1D-1 selection path.
- The prototype uses only Java 21 standard-library networking/concurrency; no Maven dependency or POM edit was required.

## Build and extracted-payload custody

The exact base and final candidate were built separately under the same Java 21/Maven environment.

| Artifact | Size | SHA-256 |
| --- | ---: | --- |
| Accepted base | 14,373,269 | `cf5a0714da07a6edc64516457923dcad323d242d2c31698eaabe8825d10eb4c7` |
| Final candidate | 14,386,473 | `b7b3e98438292c86e79bcf284a18c156f7bfc6b86cb116e4ecdead26fa615464` |

`diff -qr` on extracted payloads found exactly:

- new `ExternalRasterPushFramePipeline.class`;
- new `ExternalRasterReceiver.class`;
- new `LatestExternalRasterFrameStore.class`;
- new `LatestExternalRasterFrameStore$DisplayFrame.class`;
- changed `Push2Display.class`.

All other `4,444` common files were byte-identical. In particular:

- `PushUsbDisplay.class`: both SHA-256 `288b576b3f2ed064f8d9a0c6f6d384fb3516a0858cc22e7879bee896df83dec3`.
- `BitmapImpl.class`: both SHA-256 `e65e21f2c250a2b24a76b23710c85d216cb3ab18bd50aa226085e05d857cd23a`.

The manifest remains DrivenByMoss `26.4.1`, Java 21.

## Commands and tools

Commands included `rg`, `nl`, `git show`, `git diff`, `shasum -a 256`, `javap`, `jar`/`unzip`, `diff -qr`, and same-toolchain Maven builds. Source paths were inspected at exact commits rather than inferred from flattened API dumps.

## What this proves

- The selected source seam preserves the accepted semantic redraw, V1D-1 writer, and one-writer transport boundaries.
- The exact locally resolved API artifact supports the inspected adapter implementation, while the proposed public/internal boundary remains host-neutral.
- Executable deltas are bounded to the four research concerns plus `Push2Display` selection/lifecycle wiring.

## What this does not prove

- It does not make the temporary four-file candidate production-ready by itself.
- It does not claim Bitwig API implementation internals beyond public signatures and observed accepted adapter behavior.
- It does not authorize modifying `PushUsbDisplay`, exposing Bitwig memory types, or adopting another transport.
