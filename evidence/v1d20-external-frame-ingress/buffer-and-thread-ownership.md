# Buffer and thread ownership

## Date, state, and authority

- Date: 2026-09-01 PDT.
- Machine state: accepted macOS 26.4.1 arm64 fixture; exact final candidate built and tested with the real Push 3.
- Central basis/tree: `5597624bd50e5ef95ecd3af82ea1816ce4facd21` / `ec016bd3174345e32f1a6d47eb061820e7a1e9b9`.
- DrivenByMoss basis/tree: `663d719207ef58ec84b4d235c43211ec5da43605` / `c4e42825d069421a44b3241349de9a7c6453a3ad`.
- Candidate head/tree: `4f00972355fcf7b5f0ead0fef3365b81850be12f` / `7202267e51d0f2613cea93d186b132a996ec14ec`.

## Thread ownership

Exactly one project-owned receiver thread is created at candidate construction:

```text
Pushwig External Raster Receiver (daemon)
```

It serially owns `accept`, HELLO/token verification, header and payload reads, protocol validation, staging bytes, session/sequence state, and publication attempts. There is no connection thread, pool, scheduled worker, message queue, or frame deque. While a producer is connected, that one receiver handles it until close/rejection/shutdown; then it returns to accept.

The existing Push display/composition thread owns semantic redraw, nonblocking adoption, display-consumer bytes, and the V1D-1 raster call. The receiver has no reference to the bitmap or `IRasterWritableBitmap`. The display thread has no socket/channel/input-stream reference.

Shutdown uses the pre-existing `Push2Display` shutdown executor. The display/controller path first marks ingress closing and closes authority/sockets without a publication lock. The executor, not the display/composition callback, performs the bounded receiver join before existing USB/superclass shutdown.

## Fixed project-owned storage

| Storage | Bytes | Lifetime | Exclusive mutation owner |
| --- | ---: | --- | --- |
| Fixed header array | 80 | receiver lifetime | receiver thread |
| Loaded token array | 32 | receiver lifetime; zeroed on shutdown | construction/receiver |
| Receiver staging array | 614,400 | receiver lifetime | receiver thread |
| Published latest-frame array | 614,400 | store lifetime | receiver inside publication lock |
| Display-consumer array | 614,400 | pipeline lifetime | display thread after `tryLock` copy |
| **Total fixed frame/security arrays** | **1,843,312** | construction bounded | as above |

This total excludes fixed Java objects, one receiver thread stack, JDK/OS socket buffers, and the temporary producer. Startup token-file parsing briefly uses the file-byte array and a 32-byte result, then zeroes file bytes; it is not a per-frame allocation.

No project-owned byte array, bitmap, frame object, `ByteBuffer`, collection, closure, task, future, or queue is allocated per accepted frame or per display send.

## Publication synchronization

Receiver publication:

1. Read/validate the complete message in receiver-owned staging.
2. Take `publicationLock` with blocking `lock()`; blocking is allowed only on the receiver.
3. Verify `closed` and active local generation.
4. Count an unadopted prior publication as superseded.
5. Copy the complete payload to `publishedBytes` and update primitive metadata/receipt time/version consistently.
6. Release the lock.

Display adoption:

1. Synchronize the volatile authority epoch into the display-owned frame.
2. Call `tryLock()` exactly once; never wait.
3. On success, copy only a newer non-rejected publication to the display array and copy primitive metadata.
4. Release the lock before V1D-1.
5. Call `writeRasterRegion` synchronously using the display-owned bytes.
6. Retain exclusive ownership of those bytes until `writeRasterRegion` returns, then return the same semantic bitmap to the unchanged USB path.

The publication lock is never held across raster application, semantic drawing, encoding, or USB transfer.

## Lock-miss and authority rule

On `tryLock` failure, the display thread increments the lock-miss counter, re-reads the volatile authority epoch, and:

- reuses its already owned last complete frame only if authority is unchanged and local receipt time is still fresh;
- otherwise returns semantic-only output.

Clear, session invalidation, disconnect, receiver close, writer rejection, and shutdown invalidate authority. The second epoch read prevents a concurrent invalidation from leaving an old display-owned frame current merely because the publication lock was missed.

The final full harness induced `5` lock misses while retaining zero source-target, outside-region, restoration, semantic-only, mutation, or exception mismatches.

## Source ownership through the sink

```text
receiver staging
    --complete copy under lock-->
published latest bytes
    --nonblocking newer-version copy under lock-->
display-owned consumer bytes
    --exclusive synchronous call-->
IRasterWritableBitmap.writeRasterRegion
    --returns before consumer bytes can change-->
same IBitmap -> unchanged PushUsbDisplay.send
```

Historical published bytes and historical composed pixels are never restoration authority. `Push2Display` forces a current retained-model semantic redraw in external mode before each eligible pipeline call; absence/failure simply leaves that current semantic bitmap unchanged.

## Allocation readback

The exact-final `ThreadMXBean` harness accepted `4,200` frames and observed:

- display thread: `36,048` allocated bytes over `195,956` writer calls = `0.18396` bytes/call amortized;
- receiver thread: `7,888` allocated bytes over `4,200` frames = `1.87810` bytes/frame;
- fixed harness bitmap: `614,400` bytes.

Those tiny aggregate values are JVM/JDK measurement/runtime noise, not frame-sized project allocation. Source/bytecode inspection confirms all project frame arrays are fields constructed once and there is no per-cycle `new` on the receiver/pipeline/store hot paths.

## Commands and tools

Proof used source inspection, `javap -c -p`, the deterministic correctness and allocation harnesses, `ThreadMXBean.getThreadAllocatedBytes`, source forbidden-symbol searches, `lsof`, `ps`, and physical display/control/audio observation.

## What this proves

- Application memory is fixed, thread count is one, application frame authority is latest-only, and display acquisition is genuinely nonblocking.
- The receiver never owns the bitmap and the display thread never owns transport parsing.
- The existing synchronous one-USB-writer boundary remains intact.

## What this does not prove

- It does not claim zero allocation inside the JDK socket implementation, Bitwig host, existing semantic renderer, or existing USB encoder.
- It does not bound OS TCP buffer memory as project frame authority; those bytes cannot become visible without complete receiver validation/publication.
- It does not authorize asynchronous composition, another display writer, or buffer exposure to future adapters.
