# V1D-2 — Production External Latest-Frame Ingress

## Purpose

V1D-2 turns the accepted V1D-2-0 architecture into production DrivenByMoss source. It allows one separate local process to publish generated opaque-BGRA raster frames into the accepted V1D-1 sink without moving network I/O onto the Push display thread, introducing an application frame queue, exposing partial messages, or weakening exact current-semantic fallback.

The production path is:

```text
external generated producer
        -> TCP 127.0.0.1 protocol v1
        -> capability-authenticated complete-message receive
        -> fixed latest-frame publication
        -> display-thread nonblocking adoption
        -> accepted V1D-1 raster writer
        -> same semantic IBitmap
        -> one unchanged PushUsbDisplay.send
```

V1D-2 uses generated external conformance frames only. ScreenCaptureKit, Bitwig or plug-in window discovery, crop/scale logic, and the public adapter SDK remain later work.

## Accepted authorities

Central V1D-2-0 decision:

```text
repository: kasselvania/standalone-BitWig-push
commit:     99e09e2a651c92ac6710fdc88c4675a874a56600
tree:       db22ec0a845146f03861581a929ae52b30204a1b
```

DrivenByMoss V1D-1 integration:

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

## Primary production claim

The exact proposed source head must establish:

```text
receiver thread:
    loopback accept/read
    -> authenticate HELLO
    -> receive complete fixed header and bounded payload
    -> validate protocol/session/sequence/geometry/alpha
    -> publish one complete latest frame

display thread:
    redraw newest current semantics
    -> tryLock once
    -> adopt newest complete frame into display-owned bytes
    -> check local receipt freshness
    -> call V1D-1 writeRasterRegion, or apply no raster
    -> return the same IBitmap
    -> call the existing PushUsbDisplay.send once
```

The receiver never receives or invokes `IRasterWritableBitmap`. The display thread never accepts, connects, reads, writes, parses, waits for a producer, takes a blocking publication lock, or joins the receiver.

Historical external bytes and previous composed pixels are never fallback authority.

## Source envelope

Create:

```text
branch: pushwig/v1d2-external-frame-ingress
base:   pushwig/main @ 663d719207ef58ec84b4d235c43211ec5da43605
```

Expected production changes are exactly:

```text
src/main/java/de/mossgrabers/controller/ableton/push/controller/Push2Display.java
src/main/java/de/mossgrabers/controller/ableton/push/controller/ExternalRasterPushFramePipeline.java
src/main/java/de/mossgrabers/controller/ableton/push/controller/ExternalRasterReceiver.java
src/main/java/de/mossgrabers/controller/ableton/push/controller/LatestExternalRasterFrameStore.java
```

Do not cherry-pick the V1D-2-0 research commit. Recreate the accepted design against the exact integration basis.

Stop for authority review before changing any additional production file.

Explicitly unchanged:

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

Version, extension/controller IDs, USB matching, endpoint, pixel encoding, scan-line padding, XOR shaping, transfer scheduling, and sole USB ownership remain unchanged.

## Construction-time configuration

Read once in `Push2Display` construction:

```text
pushwig.externalRasterIngress=true
pushwig.externalRasterPort=<1024..65535>            # default 45291
pushwig.externalRasterTokenFile=<required path>
pushwig.externalRasterStaleTimeoutMs=<100..10000>   # default 1500
```

Pipeline precedence is:

```text
external ingress
    > local raster
    > dynamic local vector
    > static overlay
    > pass-through
```

Exactly one pipeline is selected. Current-semantic redraw is enabled for external, local-raster, and dynamic-vector modes; it remains disabled for static/default modes.

Invalid external configuration or bind failure starts no receiver thread and leaves ordinary current semantics usable after one bounded error. No property is polled per display send.

## Token and endpoint custody

The launcher/orchestrator—not the controller extension—owns token-file creation, delivery, lifetime, and cleanup.

Required token file:

- regular file;
- symbolic links rejected;
- exactly 64 ASCII hexadecimal characters plus optional trailing ASCII whitespace;
- decodes to exactly 32 bytes;
- no POSIX group/other permission bits; target mode `0600`;
- owner matches the current user where owner identity is available;
- capability value is never logged or supplied directly in arguments or environment;
- only token-file path, port, and timeout are supplied as properties;
- temporary file bytes are zeroed after parsing;
- decoded in-memory token is zeroed during shutdown;
- launcher retains the file for producer restarts during the run and removes it after producer/Bitwig shutdown.

The fixed/configurable port plus explicit token-file path is the complete V1D-2 rendezvous. A friendlier launch broker or discovery mechanism is later product work.

The capability protects frame authority from a process without the token. It is not an operating-system identity proof and does not prevent a same-user process that can read the token or occupy the one local connection from causing an availability denial.

## Protocol version 1

### Transport

```text
address:     IPv4 127.0.0.1 only
port:        default 45291, configurable 1024..65535
backlog:     1
reuse:       SO_REUSEADDR before bind
connections: one active connection
threads:     one daemon receiver
```

No wildcard, remote, HTTP, WebSocket, OSC-frame, or Java-serialization transport is accepted.

### Fixed header

All multibyte fields use network byte order. Header length is exactly 80 bytes.

| Offset | Width | Field |
| ---: | ---: | --- |
| 0 | 4 | magic `0x50575852` (`PWXR`) |
| 4 | 2 | version `1` |
| 6 | 2 | header length `80` |
| 8 | 4 | message type |
| 12 | 4 | flags/reserved, zero |
| 16 | 4 | pixel format |
| 20 | 4 | reserved, zero |
| 24 | 8 | session high |
| 32 | 8 | session low |
| 40 | 8 | signed sequence |
| 48 | 4 | destination x |
| 52 | 4 | destination y |
| 56 | 4 | width |
| 60 | 4 | height |
| 64 | 4 | source stride |
| 68 | 4 | payload length |
| 72 | 8 | reserved, zero |

Message types:

```text
HELLO = 1
FRAME = 2
CLEAR = 3
```

Formats:

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

### HELLO

- type `HELLO`;
- format `NONE`;
- nonzero 128-bit producer session;
- sequence and geometry fields zero;
- payload length exactly 32;
- payload is the raw decoded capability token.

Authentication completes before any session/frame authority exists. Capability comparison covers all bytes without an early-exit equality decision.

### FRAME

- type `FRAME`;
- format `OPAQUE_BGRA8888`;
- session matches authenticated HELLO;
- positive strictly increasing sequence;
- top-to-bottom, left-to-right BGRA bytes;
- every copied alpha byte `0xFF`;
- source offset implicit zero;
- explicit destination x/y, width/height, and stride;
- destination fits 960×160;
- exact payload length `(height - 1) * stride + width * 4` under checked long arithmetic;
- maximum payload 614,400 bytes.

No compression, scaling, blending, producer timestamp, or color-management field exists in v1.

### CLEAR

- type `CLEAR`;
- format `NONE`;
- same authenticated session;
- next positive sequence;
- zero geometry and payload.

CLEAR invalidates current external authority immediately while the authenticated connection may remain open.

### Strict failure behavior

Wrong magic/version/header length/type/format/session, nonzero reserved fields, invalid arithmetic/geometry/stride/length, oversized declaration, nonopaque alpha, invalid sequence, or authentication failure invalidates the connection/session before publication. Protocol v1 has no ignore-unknown extension rule.

## Complete-message publication

The latest publication changes only after:

1. the full fixed header is received;
2. common protocol fields are accepted;
3. authentication/session/sequence authority is accepted;
4. all geometry and length arithmetic is accepted;
5. the complete bounded payload is received;
6. every copied alpha byte is opaque;
7. local monotonic receipt time is obtained;
8. the complete payload and primitive metadata are committed under the publication lock.

EOF, shutdown, timeout, or close mid-header/payload publishes nothing from that message. A slow but valid frame appears atomically only after completion.

The receiver never allocates from the producer's payload length.

## Session, sequence, and freshness

- Producer supplies a nonzero 128-bit session identity.
- Receiver attaches a local monotonically changing connection generation.
- Sequence is a positive signed Java `long`, strictly increasing within one authenticated session.
- Duplicate, lower, or nonpositive sequence invalidates the session and does not refresh freshness.
- Skipped sequence is accepted and counted; no missing frame is replayed.
- A new authenticated connection clears old authority and may restart at sequence 1.
- Sequence `Long.MAX_VALUE` is the final valid publication in that session. Any subsequent FRAME/CLEAR is invalid; producer reconnects with a new session.
- Freshness authority is `System.nanoTime()` taken only when a complete FRAME publication succeeds.
- Default stale timeout is 1,500 ms and may be configured from 100–10,000 ms.
- Producer wall-clock timestamps are absent and cannot influence freshness.

## Fixed memory and thread ownership

Construction-time arrays:

| Storage | Bytes | Mutation owner |
| --- | ---: | --- |
| header | 80 | receiver thread |
| token | 32 | construction/receiver, zeroed on shutdown |
| receiver staging | 614,400 | receiver thread |
| latest publication | 614,400 | receiver under publication lock |
| display consumer | 614,400 | display thread |

Total fixed project-owned frame/security bytes: `1,843,312`, excluding fixed objects, receiver stack, and JDK/OS socket buffers.

Exactly one daemon receiver thread owns accept, HELLO, header/payload reads, protocol validation, staging, session/sequence state, and publication attempts. There is no thread per connection, executor pool, scheduled worker, or application frame FIFO.

`LatestExternalRasterFrameStore` owns one `ReentrantLock` around the latest complete publication and primitive metadata.

Receiver path:

```text
complete staging frame
    -> lock()
    -> verify active generation/closing state
    -> overwrite latest publication
    -> update metadata, sequence, receipt time, and publication version
    -> unlock
```

Display path:

```text
current semantic redraw
    -> tryLock() exactly once
    -> copy only a newer complete publication into display-owned bytes
    -> copy primitive metadata
    -> unlock
    -> evaluate authority epoch and freshness
    -> call V1D-1 synchronously
```

The publication lock is released before raster application, encoding, or USB transfer.

On a lock miss, display may reuse only its already-owned frame while authority epoch remains unchanged and receipt remains fresh. Otherwise it renders semantics only.

A producer faster than the display overwrites an unadopted latest publication. Intermediate frames are counted as superseded and never replayed.

## Failure and fallback

The following remove external visual authority and produce a newly redrawn current semantic frame:

- no producer;
- explicit CLEAR;
- clean disconnect;
- forced producer exit;
- stale timeout;
- wrong token, magic, version, type, format, session, or reserved fields;
- duplicate/lower/nonpositive sequence;
- malformed geometry, stride, length, or alpha;
- oversized declaration;
- partial header or payload;
- receiver or bind failure;
- V1D-1 writer rejection;
- shutdown.

A stalled authenticated peer may occupy the single receiver slot, but it cannot block the display thread or disturb controls/audio. Closing client/server during shutdown must unblock the receiver.

## Startup and shutdown

Startup:

1. `Push2Display` reads construction properties.
2. External mode wins precedence and enables current-semantic redraw.
3. Token path/permissions/owner/content, port, and timeout are validated.
4. Fixed store/pipeline/receiver storage is constructed.
5. Server binds `127.0.0.1` with address reuse enabled before bind.
6. Exactly one named daemon receiver starts.
7. Failure starts no receiver and leaves semantics usable after one bounded error.

Shutdown:

1. Mark ingress closing.
2. Invalidate store and display authority without waiting for publication lock.
3. Close active client and server sockets.
4. Unblock accept/header/payload reads.
5. On the existing Push shutdown executor, join the receiver for at most two seconds.
6. Report failed join but continue existing USB/superclass shutdown.
7. Accept no new publication after closing begins.
8. Ensure the final semantic shutdown screen is not covered by an external frame.
9. Zero the in-memory capability.

Required live shutdown states: waiting in accept, authenticated idle, continuous receive, partial header, and partial payload. Immediate normal same-port restart and active-listener collision rejection are mandatory.

## Conformance producer

Use a temporary standalone Python or Swift standard-library producer as a language-neutral oracle. Retain source SHA-256 and commands, but do not commit it as the future capture helper.

It must generate:

- valid small, odd-stride, medium, full, moving, and replacement patterns;
- 1, 15, 30, and 60 fps streams;
- faster-than-display bursts and legal gaps;
- duplicate/lower sequence;
- sequence near and at `Long.MAX_VALUE`;
- CLEAR;
- wrong token/magic/version/type/format/session;
- malformed geometry/stride/length/alpha;
- oversized declaration;
- partial header/payload;
- slow complete/incomplete sends;
- clean disconnect, immediate process exit, and new-session reconnect.

The producer is not a capture API or stable SDK artifact.

## Correctness acceptance

Run at least 1,000 accepted external publications. Require positive counts for publication, adoption, supersession, sequence gaps, clear, stale expiration, authenticated sessions, disconnects, and rejected messages.

Require exact zero counts for:

```text
source-target mismatches
outside-current-region mismatches
old-region restoration mismatches
clear semantic-only mismatches
disconnect/crash semantic-only mismatches
stale semantic-only mismatches
malformed/truncated/oversized semantic-only mismatches
old-session frame appearances
duplicate/out-of-order freshness refreshes
partial/torn frame visibility
receiver mutation of display-consumer bytes
consumer mutation during V1D-1 application
partial destination writes
escaped display-loop exceptions
```

The exact proposed source head must also prove default/V1B/V1C/local-raster/external/all-property precedence behavior, same-`IBitmap` return, one pipeline call, one transport call, and byte-identical `PushUsbDisplay.class` and accepted V1D-1 sink classes.

## Performance acceptance

After at least 60 seconds of startup exclusion and 100 warmups, retain separate measurements for:

- header and payload receive;
- ingress validation;
- staging-to-publication copy;
- publication critical section;
- display `tryLock`;
- publication-to-consumer copy;
- V1D-1 writer;
- current-semantic redraw;
- complete external pipeline;
- combined display/send path;
- no-frame, stale, and rejected paths;
- socket close and receiver join.

Project-owned display adoption plus writer:

```text
green:  p95 <= 2 ms
review: p95 <= 5 ms
stop:   p95 > 5 ms
```

Combined semantic/host tails are retained separately. The research external pipeline measured `0.092375 ms` p95 while combined semantic/host measured `2.106083 ms` p95 with larger scheduling maxima. Production must repeat exact clean-head timing and explicitly disposition repeated above-band results.

No unbounded growth, frame-sized project allocation per message/send, control lag, abnormal display lag, or audio xrun/dropout is accepted.

## Real fixture acceptance

The exact proposed-head artifact must prove on the real Mac + Bitwig 6.1 + Push 3 fixture:

- no-producer semantics and normal controls/audio;
- valid 1/15/30/60 fps generated external frames;
- correct bounds/orientation/channels/stride;
- movement/replacement and semantic restoration;
- burst supersession without delayed replay;
- session reset, gaps, duplicate/lower, and exhaustion behavior;
- clear, disconnect, forced exit, stale timeout, wrong auth/protocol/session, malformed/truncated/oversized/slow-complete behavior;
- representative Track, Device Parameters, and Session/Browser modes;
- pads, pressure/MPE, encoders, transport, Push audio, and headphones;
- no torn frame, trail, corruption, backlog, abnormal lag, xrun, or relevant exception;
- all five shutdown states, collision, restart, and normal quit.

After testing, restore the exact official artifact as the sole scanned extension, verify its accepted SHA-256, relaunch without Pushwig properties, and physically confirm standard display, controls, audio, and absence of generated pixels.

## Evidence and PR topology

DrivenByMoss:

```text
branch: pushwig/v1d2-external-frame-ingress
base:   pushwig/main
commit: V1D-2: implement external latest-frame ingress
PR:     V1D-2: implement production external latest-frame ingress
```

Central evidence:

```text
branch: codex/v1d2-external-frame-ingress-evidence
paths:  evidence/v1d2-external-frame-ingress/**
PR:     V1D-2: retain external latest-frame ingress evidence
issue:  Addresses #35
```

Both PRs remain open, non-draft, unmerged, and pinned to exact tested heads for technical-lead review.

Suggested evidence files:

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

V1D-2 does not add ScreenCaptureKit, screen-recording permission, Bitwig/native-device/plug-in window discovery or capture, scaling, resampling, alpha blending, color management, a public adapter SDK, resolver/calibration/anchors, remote networking, HTTP/WebSocket/OSC frames, multiple simultaneous producers, another bitmap, another USB writer, a POM dependency, Push 2 acceptance, Steam Deck/Linux, yabridge, Monome, plugdata, appliance, battery, connector, or NUC work.
