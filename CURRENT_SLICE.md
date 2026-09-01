# Current Slice: V1D-2-0 — External Latest-Frame Ingress Architecture

## Status

Ready to execute from the current accepted central `origin/main` containing merged V1D-1 evidence and from DrivenByMoss `origin/pushwig/main` at the exact accepted V1D-1 integration state.

Active issue: [#32 — V1D-2-0: Select external latest-frame ingress architecture](https://github.com/kasselvania/standalone-BitWig-push/issues/32).

Before work begins, fetch central `origin/main` and verify that its history contains:

```text
a02c9c772da38bfdbc89dfff751c9617cd397c02  # accepted V1D-1 evidence
```

Create the central evidence branch directly from the then-current accepted `origin/main`. If `origin/main` has moved, inspect every intervening commit and stop if it changes V1D-2-0 authority or scope.

## Primary claim

Select and prove the smallest production-capable architecture by which a separate local process can publish generated raster frames to the accepted V1D-1 sink while preserving:

- complete-frame publication only;
- fixed and bounded memory;
- latest-frame-wins behavior rather than backlog playback;
- nonblocking display-thread consumption;
- explicit producer session and sequence authority;
- local monotonic freshness;
- exact current-semantic fallback for every absence/failure state;
- clean connection, replacement, shutdown, and restart behavior;
- one unchanged Push display USB writer.

The accepted conceptual path is:

```text
external generated producer
        -> local framed transport
        -> complete receive and ingress validation
        -> fixed-memory latest-frame publication
        -> nonblocking display-thread acquisition
        -> accepted V1D-1 raster sink
        -> unchanged PushUsbDisplay
```

The receiver thread may never write the Push bitmap. The display thread may never perform network I/O or wait for a producer.

V1D-2-0 is an evidence-first architecture gate. It does not merge a production external receiver, add ScreenCaptureKit, discover a Bitwig window, or capture proprietary pixels.

See [`docs/V1D20_EXTERNAL_FRAME_INGRESS.md`](docs/V1D20_EXTERNAL_FRAME_INGRESS.md).

## Accepted authorities

### Central authority and evidence

```text
repository:  kasselvania/standalone-BitWig-push
V1D-1 merge: a02c9c772da38bfdbc89dfff751c9617cd397c02
tree:        62b4edce8d649266cda65a638d26113692eaef04
```

### DrivenByMoss implementation

```text
repository: kasselvania/DrivenByMoss
branch:     pushwig/main
commit:     663d719207ef58ec84b4d235c43211ec5da43605
tree:       c4e42825d069421a44b3241349de9a7c6453a3ad
```

That integration contains exact accepted V1D-1 source head:

```text
3c3ca02ff81ab5ce110ae3d714e20b5fca05a03f
```

Immutable upstream basis remains:

```text
branch: pushwig/upstream-26.4.1
commit: fd03245ab38fa5149c45934051d937ee9fda6d08
tree:   edd2ad636b0aa1f39919f0ffd05c968015450075
```

Official extension SHA-256 to restore after any real-fixture prototype:

```text
98dc3195ad8d911526e18b1005f09f69a1aedcb965b080565474104654345c5a
```

## Accepted V1D-1 consumer

V1D-1 established a production host-neutral sink:

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

Accepted behavior:

- first format `OPAQUE_BGRA8888`;
- caller owns source bytes exclusively until synchronous return;
- complete request and alpha validation precede mutation;
- `true` means full application;
- `false` means zero destination bytes changed;
- one private adapter-owned destination view;
- first valid call binds the display/composition thread race-safely;
- wrong-thread and malformed calls reject before mutation;
- source padding is ignored;
- no scaling, filtering, blending, or conversion;
- current V1C semantic redraw remains restoration authority;
- `PushUsbDisplay` remains unchanged and sole-owned.

Accepted V1D-1 source and evidence proved 1,000 local cycles, 28 negative/thread cases, all required mismatch counts zero, zero project-owned allocation across 5,000 full-frame applications, all physical fixture phases, and exact official rollback.

## Why this gate is required

The local raster sink does not answer the external process questions:

1. Which local transport is sufficiently portable and observable?
2. How is a frame delimited and versioned?
3. How are untrusted lengths bounded before allocation/read?
4. When does a partially received frame become visible? It must not.
5. Which thread owns socket reads, staging bytes, published bytes, and consumer bytes?
6. How does the display thread adopt a new frame without blocking?
7. How does a faster producer supersede old frames without an application queue?
8. How are duplicate/out-of-order sequence values handled?
9. How does producer restart reset sequence without reviving prior-session data?
10. What local monotonic event determines staleness?
11. How do disconnect, crash, truncated input, slow send, and shutdown clear authority?
12. How is accidental or unauthorized local injection bounded?
13. How is the receiver stopped without hanging Bitwig shutdown?

Those must be selected before production source hardens around one transport.

## Candidate order

Evaluate candidates in this exact order and stop after the first decisive winner.

### Candidate A — loopback framed stream plus fixed latest-frame handoff

Use:

- a loopback-only TCP server;
- one owned receiver thread;
- one active producer session;
- a versioned language-neutral binary protocol;
- fixed maximum-size receive staging;
- fixed complete-publication storage;
- fixed display-owned consumer storage;
- nonblocking display-thread snapshot/adoption;
- local monotonic receipt time;
- latest-frame-wins publication.

Leading conceptual ownership:

```text
receiver thread
    owns socket + staging array
    reads complete header/payload
    validates transport/session/sequence/size
    copies complete frame into bounded published storage

Push display thread
    performs no network I/O
    never waits for receiver lock
    adopts only a complete newer publication into display-owned bytes
    evaluates local receipt-time freshness
    calls V1D-1 writer synchronously
```

This staging/published/consumer arrangement is a hypothesis to prove, not preaccepted production architecture.

No thread per connection, unbounded queue, remote bind, Java object serialization, per-frame byte-array allocation, or receiver-thread bitmap access is allowed.

### Candidate B — Unix-domain socket plus the same bounded handoff

Test only if Candidate A cannot satisfy the complete lifecycle, security, discovery, portability, or performance requirements.

Retain:

- path discovery;
- file permissions;
- stale socket cleanup;
- macOS/Linux portability;
- Windows implications;
- shutdown behavior.

### Candidate C — memory-mapped double buffer

Test only if socket candidates fail.

Any mapped design must prove:

- explicit publication/acquire semantics;
- torn-frame detection;
- producer crash during write;
- session replacement;
- fixed file/buffer sizing;
- stale detection;
- display-thread copy cost;
- safe cleanup.

Do not select memory mapping merely because it sounds faster.

### BLOCKED

If no candidate passes, retain the smallest missing capability and next bounded experiment. Do not proceed to capture or silently accept a blocking/unbounded design.

## Protocol requirements

The selected protocol must define exactly:

- magic;
- protocol version;
- fixed or bounded header length;
- header byte order;
- producer session identity or equivalent connection generation;
- strictly increasing sequence within one session;
- valid-frame and explicit-clear message types;
- pixel-format identifier;
- destination x/y;
- width and height;
- source stride;
- payload length;
- maximum payload/message size;
- authentication/capability or an explicit reviewed local-security rationale;
- unknown version/type/format/reserved-field behavior;
- duplicate/out-of-order/skipped sequence behavior;
- EOF mid-header and mid-payload behavior;
- oversized length behavior;
- reconnect and sequence-reset behavior.

The protocol must be language-neutral. Java serialization is prohibited.

Ingress publication occurs only after the complete message has arrived and all ingress-level checks pass. Partial bytes never alter current publication state.

Producer wall-clock time is not freshness authority. The receiver records local monotonic receipt time only after a complete publication is accepted.

## Fixed-memory ownership

The selected architecture must declare every buffer and owner.

At minimum distinguish:

- receiver staging bytes;
- complete published bytes;
- display-owned consumer bytes;
- V1D-1 destination bitmap bytes.

Requirements:

- all maximum-size storage allocated at startup/construction;
- hard payload cap enforced before any untrusted allocation;
- no frame object, byte array, buffer view, task, closure, or queue node per frame;
- receiver never mutates display-consumer bytes;
- display consumer bytes remain exclusive until `writeRasterRegion` returns;
- publisher never mutates the current consumer copy;
- no application FIFO queue;
- newest complete frame supersedes older unpublished/unconsumed frames;
- old session storage is invalidated on connection replacement;
- fixed memory remains bounded under producer flood.

## Nonblocking display-thread contract

The display/composition thread must never:

- accept or connect a socket;
- read or write a socket;
- wait for a complete message;
- block acquiring a receiver lock;
- join a receiver thread;
- allocate from frame metadata;
- parse a partial message;
- wait for producer shutdown.

The selected snapshot operation must be bounded and nonblocking. If a new complete frame cannot be adopted immediately, use the exact selected rule for the last display-owned fresh frame or semantic-only output. Do not read receiver-owned bytes without ownership.

## Session, sequence, and freshness

Prove:

- no producer at startup;
- first authenticated/accepted session;
- strictly increasing sequence;
- skipped sequence accepted as a supersession signal;
- duplicate and out-of-order sequence rejected without refreshing freshness;
- explicit clear;
- clean disconnect;
- forced producer exit;
- silence until stale timeout;
- reconnect/new session with sequence reset;
- old-session bytes cannot reappear;
- wrong token/handshake;
- protocol-version mismatch;
- malformed header;
- partial header;
- partial payload;
- oversized declaration;
- slow sender;
- receiver bind/listen failure;
- shutdown while connected;
- shutdown while silent;
- shutdown while mid-message.

Define exact fallback bounds in sends and milliseconds for:

- clear;
- disconnect;
- crash;
- stale timeout;
- malformed message;
- failed raster application;
- receiver failure;
- shutdown.

Receipt-time staleness must use `System.nanoTime()` or an equivalent monotonic source.

## Generated external producer

Use a temporary standalone producer with no Bitwig dependency and only generated asymmetric opaque-BGRA test cards.

It must support deterministic modes for:

- moving/replacing bounded regions;
- full-frame content;
- 1, 15, 30, and 60 fps rates where practical;
- faster-than-display bursts;
- duplicate/out-of-order/skipped sequences;
- explicit clear;
- malformed, truncated, oversized, and slow messages;
- clean exit;
- forced crash/kill;
- reconnect/new session.

Prefer at least one implementation that demonstrates the protocol is independent of Java object serialization. Retain producer source hash and command, but do not commit it as the final macOS capture helper.

## Correctness requirements

Run at least 1,000 accepted external frame publications plus the full failure matrix.

Required exact zero counts:

```text
published source-target mismatches
outside-current-region mismatches
old-region restoration mismatches
clear semantic-only mismatches
disconnect semantic-only mismatches
crash semantic-only mismatches
stale semantic-only mismatches
malformed/truncated/oversized semantic-only mismatches
old-session appearances after reconnect
duplicate/out-of-order freshness refreshes
partial/torn frame visibility
consumer-source mutation during V1D-1 application
escaped display-loop exceptions
```

Require positive evidence for:

- frame publication;
- display adoption;
- sequence advancement;
- supersession;
- producer frames dropped/superseded before display consumption;
- reconnect/new session;
- stale expiration.

Use generated frames only. Do not commit raw frames or screenshots.

## Performance and allocation

After startup settling and warmup, measure separately:

1. receiver header/payload receive;
2. ingress validation;
3. publication critical section;
4. published-frame supersession;
5. display nonblocking snapshot/adoption;
6. display-owned byte copy;
7. V1D-1 writer;
8. current-semantic redraw;
9. combined display path;
10. stale/no-frame path;
11. malformed/rejected path;
12. receiver shutdown/join.

Test small, medium, full-frame, 1/15/30/60 fps, and burst behavior.

Retain:

- p50/p95/max;
- byte counts and useful throughput;
- lock misses/contention;
- accepted/superseded/dropped/rejected frames;
- fixed storage bytes;
- per-frame allocations by thread;
- thread count;
- RSS/heap;
- shutdown time;
- control/display/audio observations.

Project-owned display snapshot/copy plus V1D-1 writer band:

```text
green:  p95 <= 2 ms
review: p95 <= 5 ms
stop:   p95 > 5 ms
```

The accepted V1D-1 combined host/redraw tails remain visible, but they do not excuse a slow ingress handoff. Separate all measurements.

No unbounded memory growth or per-frame byte-array/frame allocation is acceptable.

## Real fixture

Only the leading offline-safe candidate reaches the accepted Mac + Bitwig 6.1 + Push 3 fixture.

Using an exact temporary prototype and external generated producer, prove:

1. Push connects normally.
2. Pads, pressure/MPE, encoders, and transport work.
3. Semantic display remains coherent.
4. Push remains the Bitwig audio device.
5. Headphone output is audible.
6. External bounded and full-frame patterns appear correctly.
7. BGRA channels, orientation, stride, and bounds remain correct.
8. 15/30/60 fps updates are coherent where supported.
9. Faster producer frames supersede without backlog playback.
10. Movement/replacement restores prior semantics.
11. Explicit clear restores semantics.
12. Clean disconnect restores semantics.
13. Forced producer exit restores semantics.
14. Silence reaches stale semantic fallback in the declared bound.
15. Duplicate/out-of-order messages do not refresh or regress the frame.
16. Malformed/truncated/oversized input never appears partially.
17. Reconnect/new session accepts sequence reset without old-frame return.
18. Representative Track, Device Parameters, and Session/Browser modes work.
19. A semantic update beneath coverage reappears.
20. No blocking, trail, torn frame, corruption, abnormal lag, xrun, or relevant exception occurs.
21. Bitwig shuts down normally with producer connected.
22. Bitwig shuts down normally with a silent producer.
23. Bitwig shuts down normally while a producer is mid-message.
24. The exact official extension is restored and physically confirmed.

## Research topology

### DrivenByMoss

Use clean temporary worktrees rooted at exact accepted `origin/pushwig/main` commit `663d719207ef58ec84b4d235c43211ec5da43605`.

Temporary branches, commits, patches, receiver code, producer code, harnesses, and aggregate instrumentation are permitted locally.

Do not:

- push a production feature branch;
- open a DrivenByMoss production PR;
- merge a prototype into `pushwig/main`;
- modify the immutable upstream branch;
- copy derivative source into the central repository.

Retain exact local commit/patch/source hashes and remove temporary instrumentation afterward.

### Central evidence

Create directly from the then-current accepted central `origin/main`:

```text
codex/v1d20-external-frame-ingress-evidence
```

The reviewable output is one ordinary, non-draft, open, unmerged PR containing only:

```text
evidence/v1d20-external-frame-ingress/**
```

Suggested files:

```text
README.md
accepted-source-and-constraints.md
candidate-a-loopback-stream.md
alternative-candidates.md
protocol.md
buffer-and-thread-ownership.md
lifecycle-and-failure-correctness.md
performance.md
real-fixture-and-rollback.md
decision.md
```

Include `Addresses #32` and state exact basis/head/tree.

## Decision output

`decision.md` must choose exactly one top-level status:

```text
SELECTED
```

or:

```text
BLOCKED
```

For `SELECTED`, state:

- transport and bind rule;
- endpoint discovery;
- authentication/local-security rule;
- exact wire protocol and byte order;
- hard header/payload limits;
- producer session and sequence rules;
- receipt-time freshness and timeout;
- complete-publication rule;
- buffer count, sizes, and owners;
- synchronization and nonblocking snapshot rule;
- last-frame versus semantic-only behavior on contention;
- clear/disconnect/crash/malformed/reconnect behavior;
- receiver thread count and lifecycle;
- startup and shutdown order;
- fixed and per-frame allocation budgets;
- performance budget;
- exact proposed production source envelope;
- temporary reference-producer role;
- why later candidates were not reached.

For `BLOCKED`, state the smallest missing capability, experiments performed, and next bounded research.

Do not write a vague hybrid recommendation.

## Non-goals

V1D-2-0 does not add or prove:

- a production DrivenByMoss source PR;
- a final public helper application;
- ScreenCaptureKit;
- Screen Recording permission;
- Bitwig/native-device/plug-in window discovery or capture;
- scaling, resampling, alpha blending, or color management;
- visual adapters, resolver, calibration, or anchors;
- remote-network ingress;
- WebSocket, HTTP, or OSC frame transport;
- Push transport changes;
- a second USB writer;
- Push 2 hardware acceptance;
- Steam Deck/Linux portability;
- appliance, battery, connector, or NUC work;
- yabridge, Monome, or plugdata integration.

## Acceptance

V1D-2-0 is complete only when:

1. Research starts from the exact accepted central and DrivenByMoss states.
2. Candidate A is tested first or rejected by decisive source evidence.
3. One transport/protocol/handoff architecture proves complete-frame publication and bounded fixed memory.
4. The display path proves nonblocking consumption and exclusive consumer-byte ownership.
5. Session, sequence, reconnect, and local receipt-time freshness rules are exact.
6. No producer failure, partial message, malformed input, or old session can leave or revive a visual.
7. Latest-frame supersession is demonstrated without application backlog playback.
8. All required correctness/failure counts are zero.
9. Performance, allocation, contention, thread count, RSS/heap, and shutdown are retained.
10. The leading candidate passes the real fixture or one precise safety blocker is retained.
11. The exact official artifact is restored after any live prototype.
12. `decision.md` selects one exact production architecture or one precise blocker.
13. No prototype source is merged.
14. The central evidence PR is open, non-draft, unmerged, and pinned to an exact head/tree.
