# V1D-2-0 — External Latest-Frame Ingress Architecture

## Purpose

V1D-1 proves that one prepared opaque-BGRA raster region can be applied to the freshly redrawn semantic Push bitmap exactly, synchronously, and efficiently.

The next unsolved boundary is process ownership:

```text
How can another process deliver the newest complete frame
without blocking the controller thread, exposing partial bytes,
creating a queue, or making producer failure visible as stale pixels?
```

V1D-2-0 selects that architecture before the project introduces ScreenCaptureKit or any real Bitwig/plugin pixels.

## Accepted foundation

DrivenByMoss integration:

```text
branch: pushwig/main
commit: 663d719207ef58ec84b4d235c43211ec5da43605
tree:   c4e42825d069421a44b3241349de9a7c6453a3ad
```

Central V1D-1 evidence:

```text
commit: a02c9c772da38bfdbc89dfff751c9617cd397c02
tree:   62b4edce8d649266cda65a638d26113692eaef04
```

Accepted local sink:

```text
current semantic redraw
        -> validate OPAQUE_BGRA8888 byte region
        -> absolute bulk row copies, or zero write
        -> same logical bitmap
        -> unchanged sole PushUsbDisplay writer
```

The external receiver may not weaken this ownership model.

## What this slice is and is not

V1D-2-0 is:

- an external-process boundary experiment;
- a transport/protocol decision;
- a thread and buffer-ownership decision;
- a sequence/session/freshness decision;
- a shutdown and failure-lifecycle decision;
- a generated-frame real-fixture proof.

V1D-2-0 is not:

- the final production receiver;
- ScreenCaptureKit;
- a permission-bearing macOS helper;
- Bitwig or plug-in window discovery;
- screen capture;
- scaling or color conversion;
- visual adapters or pixel anchors.

## Nonnegotiable ownership model

The receiver and compositor have different authorities.

### Receiver authority

The receiver may own:

- local endpoint accept/read;
- one active connection/session;
- protocol parsing;
- a fixed receive staging area;
- fixed complete-publication storage;
- transport-level validation;
- local monotonic receipt timestamps;
- accepted/rejected/superseded counters.

It may not own:

- the Push bitmap;
- `IRasterWritableBitmap` calls;
- semantic redraw;
- Push USB transport;
- Bitwig control state.

### Display-thread authority

The existing Push display/composition thread may own:

- one fixed consumer byte array;
- the latest adopted frame metadata;
- freshness evaluation;
- the call to `IRasterWritableBitmap.writeRasterRegion`;
- exact semantic-only fallback.

It may not:

- block on network I/O;
- wait for producer completion;
- acquire a blocking receiver lock;
- parse incomplete messages;
- join the receiver;
- consume receiver-mutating bytes.

### Transport authority

`PushUsbDisplay` remains unchanged and sole-owned. External ingress ends before the accepted raster sink and has no access to USB state.

## Candidate A — loopback framed TCP stream

Candidate A is first because it is:

- available through the Java standard library;
- cross-platform across the likely Mac/Linux/Windows hosts;
- easy to implement in Swift, Java, Python, Rust, or C++;
- naturally ordered and reliable;
- observable with ordinary tools;
- independent of filesystem socket paths and stale files.

The candidate must bind only to loopback, not wildcard interfaces.

### Candidate A thread shape

Exactly one owned receiver thread is preferred:

```text
server bind
    -> accept one active producer
    -> authenticate/version handshake
    -> read framed messages serially
    -> publish only complete accepted frames
    -> clear on disconnect/failure
    -> return to accept
```

No thread per producer, worker pool, decode pool, callback executor, or per-frame task is authorized.

The receiver should be stoppable by closing its server/client channels and joining for a bounded interval. It must not rely on a producer cooperating with shutdown.

### Candidate A fixed storage hypothesis

A leading fixed-memory handoff is:

```text
receiver staging array
        -> complete message read
        -> publication critical section
        -> fixed published array + primitive metadata

nonblocking display snapshot
        -> fixed display-owned consumer array + primitive metadata
        -> release publication synchronization
        -> V1D-1 writer using display-owned bytes
```

This intentionally uses one extra bounded copy to obtain a simple exclusive-ownership rule for the V1D-1 `byte[]` sink.

The research must measure whether this copy and synchronization remain negligible and whether lock contention can cause visible frame disappearance. The display may never wait for the lock.

Possible accepted contention behavior:

- retain the display-owned last complete frame if it remains fresh;
- otherwise emit semantic-only output.

The exact rule must be selected and tested.

### Why not pass receiver bytes directly

V1D-1 requires caller-exclusive source ownership until synchronous return. If the receiver can overwrite the same array while the display thread is writing it into the Push bitmap, the sink's contract is violated.

Therefore one of these must be proven:

- a display-owned copy;
- immutable fixed-slot ownership transfer;
- a lock-free slot state machine with exclusive read ownership;
- another equally explicit bounded design.

An `AtomicReference` to newly allocated frame objects is not the preferred answer because it allocates a full frame and wrapper per publication.

## Candidate B — Unix-domain socket

Candidate B reuses the selected fixed-memory handoff but replaces the endpoint.

Potential advantages:

- filesystem permissions can provide local capability;
- no TCP port collision;
- endpoint can be discovered by path.

Required questions:

- Java 21 host support on accepted platforms;
- stale endpoint cleanup after crash;
- path length and user-runtime directory;
- permission mode;
- helper discovery;
- Windows support or backend split;
- shutdown while accept/read is blocked.

Candidate B is tested only if Candidate A fails a required gate.

## Candidate C — memory-mapped double buffer

Candidate C avoids a receiver thread but moves complexity into shared-memory publication.

It is acceptable only if it proves:

- fixed file and slot sizes;
- exact producer/consumer memory ordering;
- acquire/release or seqlock semantics across Java and the producer language;
- torn-frame detection;
- producer crash during an odd/incomplete generation;
- stale mapping cleanup;
- safe session replacement;
- bounded display-thread copy;
- no busy waiting;
- cross-platform mapping behavior.

It is not preferred merely because it may remove one copy. Correctness and portability outrank theoretical zero-copy appeal.

## Protocol design requirements

The selected protocol is binary, bounded, versioned, and language-neutral.

It must define:

### Connection/session layer

- endpoint bind/discovery;
- loopback/local-only rule;
- authentication or capability token;
- protocol version negotiation or exact version rejection;
- one active producer policy;
- connection replacement behavior;
- session generation/identity;
- sequence reset behavior.

### Message framing

- fixed magic;
- header version;
- message type;
- header length;
- payload length;
- header byte order;
- maximum header and payload;
- reserved-field behavior;
- exact read-until-complete behavior;
- EOF/truncation handling.

### Frame metadata

The first generated external frame needs only the metadata required by V1D-1 and lifecycle authority:

- session context;
- sequence;
- format;
- destination x/y;
- width/height;
- source stride;
- payload length;
- valid frame or explicit clear.

Source role, confidence, and capture metadata may be added later if they are not required to prove the transport. Do not make the first protocol speculative.

### Pixel payload

- opaque BGRA8888;
- rows top-to-bottom;
- pixels left-to-right;
- source stride explicit;
- no source offset on the wire unless a concrete need is proven;
- payload length exactly derived or bounded by the declared rows/stride;
- no compression in the first protocol;
- no Java object serialization.

### Freshness

- local monotonic receipt time is recorded only after complete accepted publication;
- producer timestamps are informational at most;
- duplicate/out-of-order frames do not refresh receipt freshness;
- explicit clear invalidates visual authority immediately;
- disconnect/crash invalidates authority according to one exact measured rule;
- silence becomes stale after one configured construction-time timeout;
- session replacement clears prior frame authority before accepting reset sequence.

## Latest-frame-wins semantics

Latest-frame-wins does not mean a hidden queue with a fast consumer.

The application must contain only bounded current state:

```text
at most one complete publication waiting to be adopted
at most one display-owned current frame
no list/deque/channel of historical frames
```

When producer sequence advances faster than display consumption:

- intermediate frames are superseded;
- the display adopts the newest complete available sequence;
- old frames are not replayed later;
- metrics record the sequence gap/supersession.

The underlying OS socket buffer is bounded transport buffering, not application frame authority. The receiver still must avoid turning every frame into an allocated queued object.

## Authentication and local security

The first selected design must bind locally and prevent accidental connection by an unrelated process.

Candidate A should evaluate a per-run capability token in the connection handshake. The decision must state:

- token size/encoding;
- how the temporary producer receives it;
- whether it is supplied by construction-time property or private runtime file;
- whether it appears in logs or process arguments;
- failure behavior;
- whether production V1D-2 needs a stronger discovery mechanism.

Do not retain real tokens in evidence.

A reviewed decision that loopback-only access is sufficient for the first production slice is possible only if the threat and accidental-collision implications are stated explicitly. Silent omission is not acceptable.

## Failure-state contract

Every failure maps to the accepted semantic base.

### No producer

No receiver publication is current. The display sends semantics only.

### Explicit clear

Clear is a complete protocol message. It invalidates the current visual without requiring an empty raster payload.

### Disconnect or crash

The active session loses authority. Old bytes may not remain current indefinitely or reappear after reconnect.

### Stale producer

If no accepted new publication arrives before the local monotonic timeout, the display stops applying the external frame.

### Duplicate or old sequence

Reject or ignore without refreshing receipt time.

### Truncated frame

Never publish. Close or reset the session according to the selected protocol. No partial payload reaches the display store.

### Oversized or malformed input

Reject before allocation/mutation. The receiver remains bounded. Decide whether the connection closes or can recover at the next header.

### Failed V1D-1 application

A failed sink write clears or suppresses the current external visual according to one explicit rule. The freshly redrawn semantic frame proceeds unchanged.

### Receiver bind/start failure

Bitwig and normal DrivenByMoss must remain usable. External ingress is unavailable and semantics continue.

### Shutdown

No new frame can become authoritative after shutdown begins. Socket closure must unblock accept/read. Receiver termination has a bounded join. The display path and USB shutdown remain orderly.

## Test producer

The research producer is intentionally not the future ScreenCaptureKit helper.

It should be a small external process capable of:

- generating deterministic asymmetric BGRA patterns;
- sending at chosen rates;
- sending sequence gaps, duplicates, and old frames;
- explicit clear;
- clean close;
- abrupt exit;
- partial header/payload;
- wrong magic/version/token;
- oversized length;
- slow-byte delivery;
- reconnect with new session;
- high-rate burst.

Prefer a language-neutral demonstration, such as a Python or Swift producer using only standard libraries. A Java producer is acceptable as a secondary oracle, but the selected wire protocol may not depend on Java serialization or in-process classes.

## Correctness matrix

At least 1,000 accepted external publications are required.

Measure:

- source-target pixels;
- pixels outside current region;
- old-region restoration;
- explicit-clear semantics;
- disconnect/crash semantics;
- stale semantics;
- malformed/truncated/oversized semantics;
- reconnect and old-session suppression;
- duplicate/out-of-order freshness;
- partial/torn visibility;
- consumer-source mutation;
- escaped display exceptions.

All failure counts must be zero.

Positive evidence must include:

- accepted publications;
- display adoptions;
- superseded sequences;
- dropped intermediate frames under burst;
- stale expirations;
- reconnect/new-session acceptance.

## Rate and performance matrix

Test generated frames at:

```text
1 fps
15 fps
30 fps
60 fps where practical
faster-than-display burst
```

For small, medium, and full-frame payloads, measure separately:

- receiver read and parse;
- validation;
- staging-to-publication copy;
- publication lock/critical section;
- display snapshot lock attempt;
- publication-to-consumer copy;
- V1D-1 writer;
- semantic redraw;
- combined display work;
- no-frame/stale work;
- shutdown.

Retain:

- p50/p95/max;
- frame counts;
- bytes and throughput;
- lock misses;
- superseded/dropped sequences;
- fixed storage bytes;
- per-frame allocation by receiver and display threads;
- thread count;
- RSS and heap;
- control/display/audio observations.

The project-owned display snapshot/copy plus writer target is:

```text
green:  p95 <= 2 ms
review: p95 <= 5 ms
stop:   p95 > 5 ms
```

The accepted semantic redraw may still have host scheduling tails. Those must be measured separately rather than used to excuse a slow handoff.

## Proposed research source boundaries

V1D-2-0 may temporarily change the minimum DrivenByMoss paths needed to prove a candidate, likely including:

- `Push2Display.java` for startup and shutdown selection;
- one external-raster pipeline;
- one receiver/protocol class or small package;
- one bounded latest-frame store;
- possibly `PushFramePipeline.java` if an explicit lifecycle method is selected;
- no change to `BitmapImpl` unless the accepted V1D-1 sink itself has a demonstrated defect;
- no change to `PushUsbDisplay`.

The final production source envelope is selected by `decision.md`; this list is not preauthorization for V1D-2 production.

## Evidence topology

Central evidence:

```text
evidence/v1d20-external-frame-ingress/
├── README.md
├── accepted-source-and-constraints.md
├── candidate-a-loopback-stream.md
├── alternative-candidates.md
├── protocol.md
├── buffer-and-thread-ownership.md
├── lifecycle-and-failure-correctness.md
├── performance.md
├── real-fixture-and-rollback.md
└── decision.md
```

No production DrivenByMoss PR is expected from V1D-2-0.

Retain source, patch, producer, harness, and artifact hashes rather than committing temporary implementations or generated frames.

## Decision criteria

A selected architecture must name exactly:

- transport;
- endpoint and discovery;
- local security/authentication;
- wire fields and byte order;
- payload cap;
- session and sequence semantics;
- receipt-time freshness and timeout;
- buffer count, size, and owner;
- synchronization;
- display lock-miss behavior;
- complete publication rule;
- clear/disconnect/crash/stale/malformed/reconnect behavior;
- receiver startup and shutdown order;
- fixed/per-frame allocation;
- performance budget;
- production source envelope;
- reference-producer role.

If no candidate satisfies those items, the result is `BLOCKED`, with one precise missing capability and next experiment.

## Result

V1D-2-0 is the final generated-frame architecture gate before the project can truthfully say:

```text
A separate process can publish live pixels,
DrivenByMoss can consume only the newest complete frame,
and every producer failure returns Push to exact current semantics.
```
