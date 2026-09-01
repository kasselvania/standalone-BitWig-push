# Current Slice: V1D-2 — Production External Latest-Frame Ingress

## Status

Ready to execute from the current accepted central `origin/main` containing the merged V1D-2-0 decision and from DrivenByMoss `origin/pushwig/main` at the exact accepted V1D-1 integration state.

Active issue: [#35 — V1D-2: Implement production external latest-frame ingress](https://github.com/kasselvania/standalone-BitWig-push/issues/35).

Before work begins, fetch central `origin/main` and verify that its history contains:

```text
99e09e2a651c92ac6710fdc88c4675a874a56600  # accepted V1D-2-0 decision
```

Create the central evidence branch directly from the then-current accepted `origin/main`. If `origin/main` has moved, inspect every intervening commit and stop if it changes V1D-2 authority or scope.

## Primary claim

Implement the production form of the selected V1D-2-0 architecture:

```text
external generated producer
        -> TCP 127.0.0.1 protocol v1
        -> capability-authenticated complete receive
        -> fixed latest-frame publication
        -> display-thread nonblocking adoption
        -> accepted V1D-1 raster writer
        -> same semantic IBitmap
        -> one unchanged PushUsbDisplay.send
```

The receiver thread never calls `IRasterWritableBitmap`. The display/composition thread never performs socket I/O, waits for the producer, takes a blocking publication lock, parses incomplete messages, or joins the receiver.

No producer, clear, disconnect, crash, staleness, malformed/truncated/oversized input, authentication/protocol/session/sequence failure, writer rejection, bind failure, or shutdown may leave external pixels visible. Fallback is always a newly redrawn current semantic frame.

V1D-2 uses generated external conformance frames only. It does not add ScreenCaptureKit, discover a Bitwig or plug-in window, capture proprietary pixels, or define the public visual-adapter SDK.

See [`docs/V1D2_EXTERNAL_FRAME_INGRESS.md`](docs/V1D2_EXTERNAL_FRAME_INGRESS.md).

## Accepted authorities

### Central

```text
repository:        kasselvania/standalone-BitWig-push
V1D-2-0 decision: 99e09e2a651c92ac6710fdc88c4675a874a56600
tree:              db22ec0a845146f03861581a929ae52b30204a1b
```

### DrivenByMoss

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

Immutable upstream basis:

```text
branch: pushwig/upstream-26.4.1
commit: fd03245ab38fa5149c45934051d937ee9fda6d08
tree:   edd2ad636b0aa1f39919f0ffd05c968015450075
```

Official artifact to restore after live testing:

```text
$HOME/Documents/Bitwig Studio/Extensions/DrivenByMoss.bwextension
SHA-256: 98dc3195ad8d911526e18b1005f09f69a1aedcb965b080565474104654345c5a
```

## Source topology

Create a source branch directly from exact `origin/pushwig/main`:

```text
pushwig/v1d2-external-frame-ingress
```

The final source branch contains exactly one implementation commit over the accepted integration basis.

Expected production changes are exactly:

```text
src/main/java/de/mossgrabers/controller/ableton/push/controller/Push2Display.java
src/main/java/de/mossgrabers/controller/ableton/push/controller/ExternalRasterPushFramePipeline.java
src/main/java/de/mossgrabers/controller/ableton/push/controller/ExternalRasterReceiver.java
src/main/java/de/mossgrabers/controller/ableton/push/controller/LatestExternalRasterFrameStore.java
```

Do not cherry-pick the V1D-2-0 research commit. Reimplement the accepted production model cleanly from the accepted integration basis.

Any additional production path requires an explicit stop and technical justification before editing.

Do not modify:

```text
PushUsbDisplay.java
BitmapImpl.java
IRasterWritableBitmap.java
RasterPixelFormat.java
AbstractGraphicDisplay.java
DynamicLocalRasterPushFramePipeline.java
DynamicLocalPushFramePipeline.java
SyntheticOverlayPushFramePipeline.java
PassThroughPushFramePipeline.java
PushFramePipeline.java
pom.xml
```

Do not change version, IDs, MIDI discovery, Push VID/PID, USB interface/endpoint, RGB565 conversion, line padding, XOR shaping, transfer scheduling, or the sole USB writer.

## Startup selection

Read these Java system properties once during `Push2Display` construction:

```text
pushwig.externalRasterIngress=true
pushwig.externalRasterPort=<1024..65535>            # default 45291
pushwig.externalRasterTokenFile=<required path>
pushwig.externalRasterStaleTimeoutMs=<100..10000>   # default 1500
```

Required pipeline precedence:

```text
external ingress
    > local raster
    > dynamic local vector
    > static overlay
    > pass-through
```

Exactly one pipeline is selected. Current-semantic redraw is enabled for external ingress, local raster, and dynamic vector modes. It remains disabled for static and default modes.

Invalid external configuration or bind failure must create no receiver thread and must leave current semantics fully usable after one bounded error. Do not poll properties per frame.

## Token and endpoint contract

The V1D-2 launcher/orchestrator owns token-file creation, distribution, lifetime, and cleanup. The extension does not add discovery.

Required token file:

- regular file with symbolic links rejected;
- 64 ASCII hexadecimal characters plus optional trailing ASCII whitespace;
- exactly 32 decoded bytes;
- no POSIX group/other permission bits; target mode `0600`;
- current-user ownership where the host exposes owner identity;
- capability value never logged or passed directly through process arguments/environment;
- only path, port, and timeout appear in construction properties;
- temporary file bytes zeroed after parse;
- in-memory token zeroed on shutdown;
- launcher keeps the file available for producer restarts and removes it after Bitwig/producer shutdown.

The fixed/configurable port and explicit token-file path are the complete V1D-2 handoff. A friendlier rendezvous service belongs to later helper/product work.

Threat model: the capability prevents unauthorized frame authority by a process without the token. It does not prove OS identity or defend availability against a same-user process able to read the token or occupy the single local connection.

## Protocol v1

Transport:

```text
TCP IPv4 127.0.0.1 only
backlog 1
SO_REUSEADDR before bind
one active connection
one daemon receiver thread
```

Fixed header:

```text
magic:         0x50575852 (PWXR)
version:       1
header length: 80 bytes
byte order:    network/big-endian
```

Fields:

```text
0   u32 magic
4   u16 version
6   u16 header length
8   u32 message type
12  u32 flags/reserved
16  u32 pixel format
20  u32 reserved
24  u64 session high
32  u64 session low
40  i64 sequence
48  i32 destination x
52  i32 destination y
56  i32 width
60  i32 height
64  i32 source stride
68  i32 payload length
72  u64 reserved
```

Message types:

```text
HELLO = 1
FRAME = 2
CLEAR = 3
```

Pixel formats:

```text
NONE = 0
OPAQUE_BGRA8888 = 1
```

Limits:

```text
header:          80 bytes
maximum payload: 614400 bytes
maximum message: 614480 bytes
```

HELLO carries a nonzero 128-bit session identity, zero sequence/geometry, and exactly 32 raw token bytes. FRAME carries the authenticated session, a positive sequence, top-to-bottom opaque BGRA bytes, destination/size/stride, and exact payload length `(height-1)*stride + width*4`. CLEAR carries the next positive sequence and zero format/geometry/payload.

Reserved fields must be zero. Unknown version/type/format, invalid arithmetic/geometry, oversize, or nonopaque alpha invalidates the connection before publication. No payload allocation may depend on an untrusted length.

## Complete publication

Publication changes only after:

1. complete 80-byte header;
2. accepted magic/version/type/reserved fields;
3. authenticated session and accepted sequence;
4. overflow-safe geometry/length validation;
5. complete bounded payload;
6. complete opaque-alpha validation;
7. local monotonic receipt timestamp.

EOF, close, or shutdown mid-header/payload publishes nothing from that message. Slow complete input becomes visible atomically only after final validation.

## Session, sequence, and freshness

- Producer supplies a nonzero 128-bit session identity; receiver adds a local connection generation.
- Sequence is a positive signed Java `long`, strictly increasing within one authenticated session.
- Duplicate, lower, or nonpositive sequence invalidates that session and does not refresh freshness.
- Skipped sequence is accepted and counted; no missing frame is replayed.
- A new authenticated connection clears old authority and permits sequence reset.
- Sequence `Long.MAX_VALUE` is the final valid value in that session; publish again only after reconnect/new session.
- Freshness uses `System.nanoTime()` recorded only for a complete accepted FRAME publication.
- Default stale timeout is 1,500 ms, bounded to 100–10,000 ms.
- Producer wall-clock time is not accepted.

## Fixed storage and ownership

Allocate once:

| Storage | Bytes | Owner |
| --- | ---: | --- |
| header | 80 | receiver |
| token | 32 | construction/receiver |
| staging | 614,400 | receiver |
| latest publication | 614,400 | receiver under publication lock |
| display consumer | 614,400 | display thread |

Total fixed project-owned frame/security arrays: `1,843,312` bytes.

Receiver owns accept, authentication, parsing, staging, session/sequence state, and publication. It never references the bitmap or raster writer.

`LatestExternalRasterFrameStore` protects one complete latest publication plus primitive metadata with one `ReentrantLock`. Receiver may call blocking `lock`; display calls `tryLock` exactly once and never waits. Display copies only a newer complete publication into its own fixed array, releases the lock, then calls V1D-1 synchronously.

On lock miss, display may reuse only its already-owned frame while authority epoch is unchanged and receipt remains fresh. Otherwise it returns semantics. Clear, disconnect, session invalidation, receiver close, writer rejection, and shutdown advance authority.

No application FIFO exists. An unadopted publication is overwritten by a newer complete frame and counted as superseded.

## Failure behavior

Each of the following must end in exact current-semantic output with no partial raster:

- no producer;
- explicit clear;
- clean disconnect;
- forced producer exit;
- stale timeout;
- wrong token, magic, version, type, format, session, or reserved bits;
- duplicate/lower/nonpositive sequence;
- malformed geometry/stride/length;
- oversized declaration;
- nonopaque alpha;
- partial header or payload;
- receiver/bind failure;
- V1D-1 writer rejection;
- shutdown.

A stalled connected peer may occupy the single receiver slot; it may not affect display/control/audio correctness. Closing that peer or shutting down must unblock the receiver.

## Shutdown

1. Mark external ingress closing.
2. Invalidate latest/display authority.
3. Close active client and server sockets without waiting on publication lock.
4. Unblock `accept` or payload/header read.
5. On the existing Push shutdown executor, join the receiver for at most two seconds.
6. Report a failed join but continue existing USB/superclass shutdown.
7. Accept no publication after closing begins.
8. Ensure the final semantic shutdown message is not covered by external pixels.

Prove shutdown while waiting in accept, authenticated idle, continuous receive, partial header, and partial payload. Prove immediate same-port normal restart and active-listener collision rejection.

## Production proof

Use an external standard-library Python or Swift conformance producer. It is a language-neutral oracle, not the capture helper.

The exact source head must prove:

- one source commit and exact four-path envelope;
- exact protocol constants and field parsing;
- token regular-file/symlink/permission/owner/content validation and zeroing;
- fixed arrays and exactly one receiver thread;
- display `tryLock` only;
- complete-message publication;
- no receiver bitmap access and no display socket access;
- no project-owned frame-sized allocation per message or send;
- latest-frame supersession without application backlog replay;
- session reset, duplicate/lower/gap, and sequence-exhaustion behavior;
- local monotonic freshness;
- every failure maps to exact current semantics;
- same `IBitmap` and one unchanged `PushUsbDisplay.send`;
- byte-identical `PushUsbDisplay.class` and accepted V1D-1 sink classes.

Run at least 1,000 accepted publications and require zero source-target, outside, old-region, clear/disconnect/crash/stale/malformed/truncated/oversized, old-session, duplicate/out-of-order freshness, torn-frame, consumer-mutation, partial-write, and escaped-display mismatch counts. Require positive adoption, supersession, gap, clear, stale, session, and rejection counts.

## Performance

After a 60-second startup exclusion and at least 100 warmups, measure receiver read/validation/publication, critical section, display try-acquire/copy, V1D-1 writer, semantic redraw, external pipeline, combined send, no-frame/stale/rejected paths, and close/join.

Project-owned display adoption plus writer:

```text
green:  p95 <= 2 ms
review: p95 <= 5 ms
stop:   p95 > 5 ms
```

Combined semantic/host tails are retained separately. V1D-2-0 observed a green `0.092375 ms` external-pipeline p95 and a `2.106083 ms` combined p95; production must repeat exact clean-head aggregate timing and explicitly disposition repeated above-band results.

No unbounded memory growth, frame-sized per-cycle project allocation, control lag, abnormal display lag, or audio xrun/dropout is accepted.

## Real fixture

Use the exact proposed-head artifact as the sole scanned extension and prove:

- no-producer semantics;
- valid 1/15/30/60 fps generated frames;
- moving, replacement, small/medium/full and odd-stride frames;
- burst supersession without delayed replay;
- clear, disconnect, crash, stale, malformed/truncated/slow complete, and reconnect behavior;
- sequence reset/gaps/duplicate/lower/exhaustion;
- representative Track, Device Parameters, and Session/Browser modes;
- pads, pressure/MPE, encoders, transport, Push audio, and headphones;
- no torn frame, trail, corruption, backlog, abnormal lag, xrun, or relevant exception;
- all five shutdown states and immediate restart.

Restore the exact official artifact as the sole scanned extension, verify its SHA-256, relaunch without Pushwig properties, and physically confirm standard display, controls, audio, and absence of generated pixels.

## PR topology

### DrivenByMoss

```text
branch: pushwig/v1d2-external-frame-ingress
base:   pushwig/main
commit: V1D-2: implement external latest-frame ingress
PR:     V1D-2: implement production external latest-frame ingress
```

Leave the source PR open, non-draft, and unmerged for technical-lead review.

### Central evidence

Create directly from then-current central `origin/main`:

```text
codex/v1d2-external-frame-ingress-evidence
```

Contain only:

```text
evidence/v1d2-external-frame-ingress/**
```

Include `Addresses #35`, link exact source PR/head/tree, and leave open/non-draft/unmerged.

Suggested evidence:

```text
README.md
source-topology.md
protocol-and-security.md
buffer-and-thread-ownership.md
session-sequence-freshness.md
lifecycle-and-failure-correctness.md
performance.md
build-artifact-comparison.md
real-fixture-and-rollback.md
manual-acceptance.md
```

## Non-goals

No ScreenCaptureKit, Screen Recording permission, Bitwig/native-device/plug-in window discovery or capture, scaling, blending, color management, public adapter SDK, resolver/calibration/anchors, remote-network ingress, HTTP/WebSocket/OSC frames, multiple simultaneous producers, transport rewrite, second bitmap, second USB writer, POM/dependency change, Push 2 claim, Steam Deck/Linux, yabridge, Monome, plugdata, appliance, battery, connector, or NUC work.

## Acceptance

Close only when both exact PR heads exist and the production source proves the selected transport/protocol/security/ownership model, complete publication, nonblocking latest-frame adoption, exact session/sequence/freshness/failure behavior, fixed memory, bounded performance, full real Push behavior, all shutdown/restart cases, normal quit, and exact official rollback.
