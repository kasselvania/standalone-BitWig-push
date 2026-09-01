# AGENTS.md — Repository Execution Rules

## Mission

Build an open, inspectable adaptive visual/controller layer for Ableton Push 3 and Bitwig Studio, then reuse that software in optional portable-appliance and native-compute projects.

The repository coordinates three independent tracks:

1. universal visual/controller integration;
2. all-in-one appliance packaging;
3. CM11EB connector and native-compute research.

The current Track V reference fixture is the maintainer's macOS Bitwig/DrivenByMoss/Push system because it provides the shortest software loop. The Steam Deck remains the first Track A appliance host and named Linux portability fixture. Neither host defines the universal product.

## Authority order

When instructions conflict, use this order:

1. `AGENTS.md`
2. `CURRENT_SLICE.md`
3. `docs/PROJECT_TRACKS.md`
4. `docs/ARCHITECTURE.md`
5. `docs/MAC_FIRST_DEVELOPMENT.md`
6. `docs/DRIVENBYMOSS_DERIVATIVE_STRATEGY.md`
7. `docs/V1D2_EXTERNAL_FRAME_INGRESS.md`
8. `docs/V1D20_EXTERNAL_FRAME_INGRESS.md`
9. `docs/V1D1_LOCAL_RASTER_COMPOSITION.md`
10. `docs/V1D0_BULK_RASTER_COMPOSITION.md`
11. `docs/V1C_DYNAMIC_LOCAL_COMPOSITION.md`
12. `docs/V1C0_DYNAMIC_RASTER_COMPOSITION.md`
13. `docs/V1B_SYNTHETIC_COMPOSITION.md`
14. `docs/VISUAL_PORTABILITY.md`
15. `docs/SEMANTIC_PIXEL_ANCHOR_RESOLVER.md`
16. `docs/ROADMAP.md`
17. `docs/RUNTIME_STRATEGY.md`
18. issue / PR scope
19. implementation convenience

A contributor or coding agent must stop and surface a conflict rather than quietly widening scope.

## Core invariants

- Bitwig remains the DAW and audio-engine authority.
- DrivenByMoss, or a compatible derivative, remains the semantic Push/controller authority unless an accepted slice explicitly proves a replacement.
- The Push display is a composited output. Semantic UI and project/captured pixels are distinct source classes.
- Exactly one component owns the Push USB display endpoint in steady state.
- Final composition and USB transport remain in-process in the DrivenByMoss derivative through the current slices.
- Visual capture is visualization first. Do not replace reliable controller-API operations with fragile mouse automation.
- Attached mode adapts to existing Bitwig windows and monitor layouts; managed geometry is an optional appliance/test mode.
- Physical desktop coordinates are never the primary identity of a visual source.
- Prefer dedicated windows, semantic identity, window-relative geometry, normalized regions, anchors, and bounded calibration.
- A resolver prefers abstention and exact semantic fallback over a wrong visual lock.
- Capture-backend and operating-system objects do not enter compositor, raster, or ingress contracts.
- macOS objects such as `SCWindow`, `CGWindowID`, and `CVPixelBuffer` stay inside the later macOS helper/backend.
- Semantic fallback means restoring the exact current semantic pixels, not merely stopping future visual drawing.
- Output is derived from `current semantic frame + optional current visual`.
- Historical composed output is never restoration authority.
- Moving, replaced, resized, absent, stale, invalid, malformed, disconnected, or crashed visual sources leave no pixels behind.
- Raster validation completes before destination mutation; rejected input causes zero partial writes.
- Raster format, dimensions, stride, bounds, source ownership, destination ownership, and thread rules are explicit.
- Bitwig `Bitmap`, `MemoryBlock`, `ByteBuffer`, macOS handles, socket objects, and USB objects do not cross host-neutral raster/frame contracts.
- An external receiver thread never renders into or writes a Push bitmap. Only the established display/composition thread calls the accepted raster sink.
- The display/composition thread never performs socket accept/read/write, file blocking, thread joins, or blocking publication-lock acquisition.
- External publication is complete-frame only. Partial headers and payloads never become visible.
- External ingress uses fixed bounded storage and latest-frame-wins state, not an unbounded FIFO.
- Producer wall-clock timestamps are not freshness authority. Local monotonic receipt time determines staleness.
- Producer session identity, receiver-local generation, and per-session sequence prevent old producers from reviving stale frames.
- External ingress is loopback-only by default. Remote network binding requires separate authority.
- Producer absence, clear, disconnect, crash, staleness, malformed input, protocol mismatch, failed authentication, or failed raster application maps to exact semantic-only output.
- Controller input and audio never wait for a display/capture producer.
- The Mac and Steam Deck are reference hosts. Maintainer-specific yabridge, serialosc, Monome, or plugdata state is not a universal requirement.
- The ordinary rear Push USB path remains a first-class appliance architecture.
- Battery operation is mandatory for a portable-appliance claim; wall power is only an engineering state.
- Track A and Track H do not block universal Track V progress.
- Hardware and power claims require real measurements, photographs, continuity, enumeration, or documented specifications.
- Do not redistribute proprietary Ableton/Bitwig binaries, firmware, activation data, private assets, or casual proprietary UI screenshot fixtures.
- Prefer local generation, recipes, hashes, descriptors, and legally distributable fixtures.
- DrivenByMoss changes live in `kasselvania/DrivenByMoss`, preserve upstream history and LGPL notices, and are not vendored into this repository.
- Every implementation or research slice names an exact accepted source commit/tree.
- `pushwig/upstream-26.4.1` is the immutable accepted upstream basis.
- Project source PRs target `pushwig/main`; never target the immutable basis or upstream `master`.
- Central evidence/status changes and DrivenByMoss source changes remain separate PRs with exact cross-references.

## Accepted source posture

Accepted DrivenByMoss integration:

```text
branch: pushwig/main
commit: 663d719207ef58ec84b4d235c43211ec5da43605
tree:   c4e42825d069421a44b3241349de9a7c6453a3ad
```

That merge contains exact accepted V1D-1 source head:

```text
3c3ca02ff81ab5ce110ae3d714e20b5fca05a03f
```

Immutable upstream basis:

```text
branch: pushwig/upstream-26.4.1
commit: fd03245ab38fa5149c45934051d937ee9fda6d08
tree:   edd2ad636b0aa1f39919f0ffd05c968015450075
```

Accepted central evidence:

```text
V1D-1:   a02c9c772da38bfdbc89dfff751c9617cd397c02
          tree 62b4edce8d649266cda65a638d26113692eaef04
V1D-2-0: 99e09e2a651c92ac6710fdc88c4675a874a56600
          tree db22ec0a845146f03861581a929ae52b30204a1b
```

## Accepted ownership chain

### V1A — frame seam

```text
complete semantic IBitmap
        -> PushFramePipeline.process
        -> same IBitmap
        -> unchanged PushUsbDisplay
```

### V1C — current-semantic restoration

```text
newest copied ModelInfo
        -> retain before render decision
        -> complete current-semantic redraw in selected dynamic mode
        -> current optional visual
        -> same persistent IBitmap
        -> unchanged PushUsbDisplay
```

Historical composed pixels are not restoration authority.

### V1D-1 — production local raster sink

```text
current semantic redraw
        -> validate complete OPAQUE_BGRA8888 request
        -> validate copied alpha and bound composition thread
        -> absolute bulk row copies, or no destination mutation
        -> same logical IBitmap
        -> unchanged PushUsbDisplay
```

The accepted sink is a public host-neutral `IRasterWritableBitmap` using caller-owned `byte[]` plus primitive metadata. `BitmapImpl` alone owns its private cached destination view and Bitwig layout checks. Writer-only stable p95/max were `0.079834 ms` / `0.678917 ms`; larger combined tails were retained as semantic/host scheduling tails, not reclassified as green.

### V1D-2-0 — selected external ingress architecture

```text
external generated producer
        -> TCP 127.0.0.1 protocol v1
        -> capability-authenticated complete-message receive
        -> fixed staging and latest-publication arrays
        -> display-thread tryLock adoption into fixed consumer bytes
        -> local monotonic freshness
        -> accepted V1D-1 sink
        -> same semantic IBitmap
        -> unchanged PushUsbDisplay
```

Accepted properties:

- fixed 80-byte big-endian header and 614,400-byte payload cap;
- HELLO / FRAME / CLEAR messages;
- nonzero 128-bit producer session and receiver-local connection generation;
- positive strictly increasing sequence, legal gaps, no backlog replay;
- one daemon receiver thread and no per-connection thread;
- fixed project-owned frame/security arrays totaling 1,843,312 bytes;
- one short publication lock, blocking only on receiver, `tryLock` only on display;
- complete publication only after protocol, geometry, payload, and opaque-alpha validation;
- local `System.nanoTime()` receipt freshness, default 1,500 ms;
- exact semantic fallback for every absence/failure state;
- five blocked-receive shutdown states and immediate same-port restart.

## Slice discipline

Do not merge adjacent uncertainty domains:

- local raster application is separate from external process ingress;
- external-ingress research is separate from production implementation;
- external generated frames are separate from operating-system capture;
- window capture is separate from visual-source resolution;
- top-level windows are separate from embedded Bitwig-panel recognition;
- anchor benchmarking is separate from live resolver integration;
- attached desktop adaptation is separate from managed headless geometry;
- macOS proof is separate from Linux portability;
- appliance packaging is separate from CM11EB connector research.

## V1D-2 production rules

V1D-2 implements the selected external latest-frame ingress using generated conformance frames only.

### Source custody

- Begin from exact `kasselvania/DrivenByMoss:pushwig/main` at `663d719207ef58ec84b4d235c43211ec5da43605`.
- Reimplement from the accepted basis; do not cherry-pick the V1D-2-0 research commit.
- Expected production paths are exactly:
  - `Push2Display.java`
  - `ExternalRasterPushFramePipeline.java`
  - `ExternalRasterReceiver.java`
  - `LatestExternalRasterFrameStore.java`
- Stop before editing any additional production path.
- `PushUsbDisplay`, `BitmapImpl`, `IRasterWritableBitmap`, `RasterPixelFormat`, `AbstractGraphicDisplay`, accepted prior pipelines, the POM, version, IDs, endpoint encoding, padding, XOR, and transfer scheduling remain unchanged.

### Startup and endpoint contract

Read construction-time properties only:

```text
pushwig.externalRasterIngress=true
pushwig.externalRasterPort=<1024..65535>            # default 45291
pushwig.externalRasterTokenFile=<required path>
pushwig.externalRasterStaleTimeoutMs=<100..10000>   # default 1500
```

Precedence is external > local raster > dynamic vector > static > pass-through. Exactly one pipeline is selected. External, local-raster, and dynamic-vector modes request current-semantic redraw.

The launcher/orchestrator owns token-file creation, delivery, lifetime, and cleanup. V1D-2 adds no discovery service. The token file is a regular non-symlink file containing exactly 64 hexadecimal characters plus optional trailing ASCII whitespace, decodes to 32 bytes, has no POSIX group/other permission bits, and is owned by the current user where owner identity is available. The token value is never logged or placed in process arguments/environment. Only its path is supplied. Temporary parse bytes are zeroed; the in-memory token is zeroed at shutdown.

The fixed/configurable port plus explicit token-file path is the complete V1D-2 handoff. Friendlier helper orchestration belongs to later product work.

### Protocol v1

- TCP bound exactly to IPv4 `127.0.0.1`, backlog 1, address reuse enabled before bind.
- Magic `0x50575852`, version 1, header length 80, network byte order.
- Message types: `HELLO=1`, `FRAME=2`, `CLEAR=3`.
- Formats: `NONE=0`, `OPAQUE_BGRA8888=1`.
- Maximum payload/message: 614,400 / 614,480 bytes.
- HELLO carries a nonzero 128-bit session, sequence/geometry zero, and exactly 32 token bytes.
- FRAME carries matching session, positive sequence, top-to-bottom opaque BGRA, explicit destination/size/stride, implicit source offset zero, and exact payload length.
- CLEAR carries matching session, next positive sequence, and zero format/geometry/payload.
- Unknown/nonzero reserved fields, wrong version/type/format, invalid arithmetic/geometry, oversize, or nonopaque alpha invalidates the connection before publication.

### Session and freshness

- Sequence is a positive signed `long`, strictly increasing per authenticated session.
- Duplicate/lower/nonpositive sequence invalidates the session and does not refresh freshness.
- Gaps are accepted and counted; historical frames are never replayed.
- A new authenticated connection clears old authority and permits sequence reset.
- After sequence `Long.MAX_VALUE`, the producer reconnects with a new session before publishing again.
- Freshness is local complete-receipt `System.nanoTime()` only.
- Stale output becomes semantic-only on the next eligible send.

### Fixed memory and nonblocking display

- One daemon receiver thread owns accept/read/parse/staging/session state.
- Fixed arrays: header 80, token 32, staging 614,400, publication 614,400, display consumer 614,400.
- Receiver publishes one complete latest frame under a short `ReentrantLock` critical section.
- Display calls `tryLock` once, copies only a newer complete publication into its own array, releases before V1D-1, and never blocks.
- A lock miss reuses only a still-fresh display-owned frame under the same authority epoch; otherwise semantics.
- No application FIFO exists. Unadopted publications are overwritten and counted as superseded.
- Receiver never references the bitmap; display never references socket/parser state.

### Failure and shutdown

No producer, clear, disconnect, crash, stale timeout, authentication/protocol/session/sequence failure, malformed/truncated/oversized input, receiver/bind failure, writer rejection, or shutdown produces external pixels.

Shutdown must invalidate authority and close client/server before the existing Push shutdown executor performs a bounded receiver join. The final semantic shutdown message is not covered by an external frame. A join failure is reported but cannot block existing USB/super shutdown.

A connected same-user peer owns the single receiver slot until it closes or shutdown closes it. Capability authentication protects frame authority, not availability against a malicious same-user process.

### Required proof

- one implementation commit and exact four-path envelope;
- exact protocol constants and complete-message publication;
- token-file validation, owner/permission/symlink checks, and zeroing;
- fixed arrays, one receiver thread, and no frame-sized per-cycle project allocation;
- nonblocking display adoption and exclusive consumer ownership through V1D-1 return;
- latest-frame supersession, session reset, duplicate/lower/gap and sequence-exhaustion behavior;
- exact semantic fallback through the complete failure matrix;
- five blocked-receive shutdown states, collision rejection, and immediate same-port restart;
- byte-identical `PushUsbDisplay.class` and accepted V1D-1 sink classes;
- at least 1,000 accepted publications with every mismatch category zero;
- exact real Push controls/display/audio acceptance and official rollback.

### Performance

Remeasure receive, validation, publication, display adoption/copy, V1D-1 writer, semantic redraw, external pipeline, combined send, no-frame/stale/rejected paths, and close/join on the exact proposed head.

The project-owned display adoption + writer target remains:

```text
green:  p95 <= 2 ms
review: p95 <= 5 ms
stop:   p95 > 5 ms
```

Combined host/redraw tails are retained separately. The selected research `2.106083 ms` combined p95 and larger host maxima do not waive a slow production handoff.

## Evidence rules

Retain evidence under `evidence/v1d2-external-frame-ingress/` for exact bases, source hashes, protocol, token custody, fixed ownership, correctness/failure counts, timing/allocation, fixture/shutdown, and rollback.

Do not commit proprietary screenshots/raw frames, generated extension binaries, temporary producer/harness/instrumentation source, capability tokens, credentials, activation data, serial numbers, UUIDs, hostnames, non-loopback addresses, or unsanitized personal paths.

## Engineering preferences

- Preserve the selected simple loopback framed stream.
- Keep all network I/O off the display/control thread.
- Keep the receiver away from the bitmap.
- Prefer fixed arrays and latest-frame overwrite over per-frame objects or queues.
- Use local monotonic receipt time, not producer wall time.
- Fail closed on every ambiguity.
- Do not add ScreenCaptureKit or a macOS helper before production ingress is accepted.
- Remeasure the exact full path at 1/15/30/60 fps and burst conditions.

## Connector-development rules

A CM11EB development card is staged open hardware:

- expose only proven grounds, candidate USB pairs, and purpose-specific observations first;
- leave power rails disconnected by default;
- do not fan all high-speed contacts onto generic headers;
- USB 3/PCIe/eSPI work requires a bounded experiment and controlled-impedance design;
- connector geometry and pin mapping require independent review before insertion.

## Current posture

S0, V1A-0, V1A, V1B, V1C-0, V1C, V1D-0, V1D-1, and V1D-2-0 are accepted.

V1D-2 now implements production external generated-frame ingress. V2 remains the first macOS dedicated-window capture slice. See `CURRENT_SLICE.md` before changing code.
