# V1D-1 raster contract and Bitwig adapter

## Date, machine state, and authority

- Evidence date: 2026-09-01 PDT.
- Machine state: accepted arm64 Mac fixture; source and bytecode inspection used the exact clean proposed-head artifact.
- Central basis/tree: `c94d1b74d702e696d6cc4cc89625f1a2f7a95530` / `8539026fc9476bbf2df34b310190a57906113b90`.
- DrivenByMoss basis/tree: `852b520933eed87fbe496a04b5c18819a10b3564` / `d03a372e2efcf41b22cef46501e08efbfb0c0036`.
- Source PR/head/tree: [kasselvania/DrivenByMoss#4](https://github.com/kasselvania/DrivenByMoss/pull/4), `3c3ca02ff81ab5ce110ae3d714e20b5fca05a03f`, tree `c4e42825d069421a44b3241349de9a7c6453a3ad`.

## Public host-neutral contract

`IRasterWritableBitmap` extends `IBitmap` and adds exactly one operation:

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

`RasterPixelFormat` contains exactly `OPAQUE_BGRA8888`. The source is a caller-owned top-to-bottom, left-to-right byte array; offsets and stride are bytes. Copied pixels are blue, green, red, then alpha, and every copied alpha byte must be `0xFF`. A successful call applies every requested destination byte; `false` means no destination byte changed. The synchronous implementation does not retain the source.

No Bitwig `Bitmap`, `MemoryBlock`, `ByteBuffer`, USB type, macOS type, or capture type crosses this contract.

## `BitmapImpl` destination characterization

The accepted `BitmapImpl(Bitmap)` record was converted to a final class so it can retain one optional raster adapter. Construction preserves `bitmap()`, record-equivalent `equals`, `hashCode`, and `toString`, including null construction. Existing `setDisplayWindowTitle`, `showDisplayWindow`, `render`, and `encode` behavior remains delegated to the wrapped Bitwig bitmap.

At construction, raster support is enabled only when all of these checks pass:

- non-null Bitwig bitmap;
- `BitmapFormat.ARGB32`, four bytes per pixel;
- positive dimensions and overflow-safe row/size arithmetic;
- exact `MemoryBlock.size()` equal to width × height × 4;
- one non-null `createByteBuffer()` result;
- direct and writable buffer;
- position zero;
- limit and capacity exactly equal to expected size;
- little-endian byte order.

An initialization `RuntimeException` disables only optional raster support. It does not escape and does not disable ordinary bitmap behavior. `Error` is not caught. The accepted live Bitwig destination was:

```text
format=ARGB32
width=960 height=160
memorySize=614400
position=0 limit=614400 capacity=614400
readOnly=false direct=true order=LITTLE_ENDIAN
thread=Control Surface Session
```

The destination view is cached once. No `duplicate`, `slice`, `array`, or per-write view acquisition exists.

## Write and ownership rule

For every call, the adapter:

1. validates support, format, non-null source, positive dimensions, coordinates, source offset/stride, overflow-safe source end, destination bounds, and destination buffer bounds;
2. rejects a caller other than an already-bound owner thread;
3. scans every copied alpha byte and rejects any non-opaque pixel;
4. race-safely binds the first valid caller through a synchronized helper;
5. writes each row with absolute `ByteBuffer.put(int, byte[], int, int)`;
6. returns `true` only after every row is written.

Invalid metadata or alpha never binds ownership and never writes. The source array and destination cursor state are unchanged. Subsequent calls from the bound owner succeed; other threads return `false`. Simultaneous first-valid callers produced exactly one successful owner.

The only per-call primitives are indices, dimensions, and the current/owner thread references. Bytecode contains no per-call object or buffer allocation in `writeRasterRegion`. The class-initialized generated source arrays are owned by the bounded test pipeline, not the adapter.

## Compatibility and harness result

The final external harness (source SHA-256 `724095ad2ee2c0273164dada172dabfb63161230df0826269f09aaa5d2305038`) ran against exact artifact SHA-256 `476a57a3733cd350bd068de44a5a1019df5e198c49572d1f633e43e006ae2877` and reported:

```text
HARNESS assertions=592712 exit=PASS
COMPATIBILITY recordEquivalent=true nullConstruction=true ordinaryMethods=true
DESTINATION accepted=1 rejected=14 escapedRuntimeExceptions=0
THREAD malformedDidNotBind=true sameThreadSecondWrite=true wrongThreadRejected=true simultaneousFirstWriters=1
allocatedBytes5000=0 cachedViewCreations=1
```

## Commands and tools

Inspection used `git show`, `nl -ba`, `rg`, `javap -c -p`, SHA-256 hashing, the exact Java 21 compiler/runtime, the locally resolved Bitwig API 21 dependency, the exact clean extension artifact, fake Bitwig bitmap/memory adapters in an external harness, `ThreadMXBean`, and direct live destination observation.

## What this proves

- The public raster capability is host-neutral and has explicit source/destination ownership.
- Supported Bitwig destinations are characterized once and fail closed when any assumption is false.
- Request and alpha validation complete before destination mutation.
- The valid writer is synchronous, bounded, cursor-independent, and project-allocation-free per application.
- Existing ordinary `BitmapImpl` semantics remain available.

## What this does not prove

- The contract is not an external wire format and has no producer freshness, timestamp, or IPC semantics.
- It does not make arbitrary Bitwig pixel formats writable.
- It does not promise safety if an external host mutates or invalidates its `MemoryBlock` after successful construction; no such host behavior was observed.
- It does not authorize concurrent raster producers; the implementation deliberately binds one owner thread.
