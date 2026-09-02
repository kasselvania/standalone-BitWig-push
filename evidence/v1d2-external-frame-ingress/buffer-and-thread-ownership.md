# Buffer and thread ownership

## Date, state, and authority

- Date: 2026-09-01 PDT.
- Machine state: accepted macOS 26.4.1 arm64, Bitwig Studio 6.1, real Push 3;
  final state is closed Bitwig with the official extension restored.
- Central basis/tree:
  `fe8216fcadc9879bafa96acbb0f064f1d6625f4b` /
  `580786862a6f034aa111b60c4d434e64c44c7211`.
- DrivenByMoss basis/tree:
  `663d719207ef58ec84b4d235c43211ec5da43605` /
  `c4e42825d069421a44b3241349de9a7c6453a3ad`.
- Source PR/head/tree:
  <https://github.com/kasselvania/DrivenByMoss/pull/5> /
  `830b778b720a06f56de08861d27052228c82c63b` /
  `c8bc3f9e052e8f0b7b5dd256657697349d303740`.
- Harness/producer/observer SHA-256:
  `007822786260f89a9c3d005b669162389843a4dad2fb3293c6c131762c32bd18` /
  `993cb0f4d14c0a909a629ac4063e6e1937cb50ca42075e9fbbd3f099253bacbb` /
  `2e6ff0f6e2236e0b6ad85a831ba3f8c18f3362263eeaba425749fb4cbf929eb4`.

## Fixed arrays

All project-owned frame/security byte arrays are allocated once during
construction:

| Owner | Purpose | Bytes |
| --- | --- | ---: |
| receiver | fixed protocol header | 80 |
| receiver | decoded capability | 32 |
| receiver | staging payload | 614,400 |
| store | latest complete publication | 614,400 |
| pipeline/display | consumer-owned frame | 614,400 |
| **Total** | | **1,843,312** |

The compiler-generated `DisplayFrame` is one construction-time primitive
metadata holder paired with the fixed consumer bytes. There is no frame object,
array, `ByteBuffer`, queue node, closure, task, or future allocated from producer
metadata per accepted message or display send.

## Receiver ownership

Exactly one named daemon thread, `Pushwig External Raster Receiver`, owns:

- the explicitly loopback-bound server socket;
- at most one active client socket;
- accept, HELLO authentication, header/payload reads, and connection/session
  parser state;
- the fixed header, capability, and staging arrays;
- receiver-local generation/sequence primitives;
- publication calls into the store.

The thread accepts and handles connections serially. No per-client thread,
executor pool, timer, retry worker, or scheduler exists. A connected/stalled
peer may occupy this one slot, but it cannot block the display, controls, audio,
or shutdown socket close.

Source, bytecode, and class-reference inspection prove that the receiver never
references `IBitmap`, `IRasterWritableBitmap`, `BitmapImpl`, `PushUsbDisplay`,
or a Push USB object.

## Publication ownership

`LatestExternalRasterFrameStore` owns one `ReentrantLock`, the fixed publication
array, publication version, authority epoch, local receipt time, session/local
generation, sequence, geometry/stride/length, closing state, and bounded
primitive counters.

The receiver may call blocking `lock()` only around the short publication
critical section. After rechecking generation/closing, it counts any unadopted
prior version as superseded, copies a complete accepted staging payload,
updates primitive metadata consistently, publishes the version last, and
releases promptly.

The lock is never held during socket read, semantic redraw, V1D-1 raster write,
bitmap encoding, or USB transfer.

## Display ownership

The display/composition thread calls store `tryLock()` exactly once per eligible
process call and never waits. Under a successful acquisition it copies only a
newer complete publication into the pipeline's fixed consumer bytes, copies
primitive metadata, and releases before raster application.

A lock miss may reuse the already display-owned bytes only while both the
authority epoch and freshness remain valid and the writer has not rejected the
frame. Otherwise the pipeline returns current semantics without an external
raster.

After adoption, only the display thread owns the consumer bytes through the
synchronous return of `writeRasterRegion`. The receiver can continue to mutate
staging/publication bytes but cannot mutate the consumer array. The pipeline
performs no network operation or blocking join.

## One writer and semantic ownership

Each eligible external send is:

1. a newly current semantic `IBitmap` from retained-model redraw;
2. zero or one nonblocking latest-frame adoption;
3. zero or one accepted V1D-1 `writeRasterRegion` call;
4. the exact same `IBitmap` reference returned to `Push2Display`;
5. exactly one call to the unchanged `PushUsbDisplay.send`.

`PushUsbDisplay.class` is byte-identical between base and head at SHA-256
`288b576b3f2ed064f8d9a0c6f6d384fb3516a0858cc22e7879bee896df83dec3`.
There is no second bitmap, no historical composed-output authority, and no
second Push USB writer.

## Deterministic ownership results

The final harness reported:

- fixed array bytes: `1,843,312`;
- receiver thread count: `1`;
- accepted/published: `1,511 / 1,511`;
- adopted/superseded: `1,111 / 398`;
- induced lock misses: `1`;
- receiver mutation of consumer bytes: `0`;
- consumer mutation during writer: `0`;
- partial destination writes: `0`;
- partial/torn visibility: `0`;
- escaped display-loop exceptions: `0`.

The live observer independently counted 4,701 accepted/published, 4,236
adopted, 465 superseded, four lock misses, 7,065 successful writer calls, and
zero writer rejects during the healthy physical run. `jcmd` observed exactly
one receiver thread.

## Shutdown ownership

`beginShutdown` first marks closing and revokes store/display authority, then
closes the active client/server sockets and prevents later publication. The
normal final semantic shutdown message is sent with external pixels disabled.
Only then does the existing shutdown executor call the receiver's bounded
two-second await before unchanged USB/superclass shutdown. The display thread
never joins.

All five blocking states—accept, authenticated idle, continuous receive,
mid-header, and mid-payload—ended normally with listener removal and immediate
rebind.

## Commands and tools

Evidence used source searches, `javap -c -p`, extracted class comparison,
reflection-based fixed-array/counter inspection, JVM thread/allocation probes,
the deterministic concurrent-writer harness, `jcmd`, `lsof`, exact producer
process control, and five normal physical Bitwig quits.

## Exact result

The ownership model passed: fixed bounded arrays, one receiver, short
receiver-blocking/store and display-nonblocking synchronization, exclusive
display consumer bytes, one synchronous V1D-1 writer, and one unchanged USB
writer.

## What this proves

- Producer I/O and partial parsing cannot enter the display thread.
- Display adoption cannot block on the publication lock and cannot observe a
  partial publication.
- Supersession is latest-only without a queue or historical replay.
- Shutdown revokes authority before the final semantic frame and transport
  close.

## What this does not prove

- One receiver thread is not multi-producer arbitration; a stalled peer is an
  acknowledged protocol-v1 availability limitation.
- JVM/JDK socket objects remain bounded per connection but are not included in
  the 1,843,312 project-owned byte-array total.
- This does not claim hard-real-time scheduling or Push 2 hardware behavior.
