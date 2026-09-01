# AGENTS.md — Repository Execution Rules

## Mission

Build an open, inspectable adaptive visual/controller layer for Ableton Push 3 and Bitwig Studio, then reuse that software in optional portable-appliance and native-compute projects.

The repository coordinates three independent tracks:

1. universal visual/controller integration;
2. all-in-one appliance packaging;
3. CM11EB connector and native-compute research.

The current Track V reference fixture is the maintainer's macOS Bitwig/DrivenByMoss/Push system because it provides the shortest software loop. The Steam Deck remains the first Track A appliance host and the named Linux portability fixture. Neither host defines the universal product.

## Authority order

When instructions conflict, use this order:

1. `AGENTS.md`
2. `CURRENT_SLICE.md`
3. `docs/PROJECT_TRACKS.md`
4. `docs/ARCHITECTURE.md`
5. `docs/MAC_FIRST_DEVELOPMENT.md`
6. `docs/DRIVENBYMOSS_DERIVATIVE_STRATEGY.md`
7. `docs/V1D20_EXTERNAL_FRAME_INGRESS.md`
8. `docs/V1D1_LOCAL_RASTER_COMPOSITION.md`
9. `docs/V1D0_BULK_RASTER_COMPOSITION.md`
10. `docs/V1C_DYNAMIC_LOCAL_COMPOSITION.md`
11. `docs/V1C0_DYNAMIC_RASTER_COMPOSITION.md`
12. `docs/V1B_SYNTHETIC_COMPOSITION.md`
13. `docs/VISUAL_PORTABILITY.md`
14. `docs/SEMANTIC_PIXEL_ANCHOR_RESOLVER.md`
15. `docs/ROADMAP.md`
16. `docs/RUNTIME_STRATEGY.md`
17. issue / PR scope
18. implementation convenience

A contributor or coding agent must stop and surface a conflict rather than quietly widening scope.

## Core invariants

- Bitwig remains the DAW and audio-engine authority.
- DrivenByMoss, or a compatible derivative, remains the semantic Push/controller authority unless an accepted slice explicitly proves a replacement.
- The Push display is a composited output. Semantic UI and project/captured pixels are distinct source classes.
- Exactly one component owns the Push USB display endpoint in steady state.
- Final composition and USB transport remain in-process in the DrivenByMoss derivative through the current slices.
- Visual capture is visualization first. Do not replace reliable controller-API operations with fragile mouse automation.
- Attached mode must adapt to a user's existing Bitwig windows and monitor layout.
- Managed geometry is an appliance/test mode, not a requirement imposed on desktop users.
- Physical desktop coordinates are never the primary identity of a visual source.
- Prefer dedicated windows, semantic identity, window-relative geometry, normalized regions, anchors, and bounded calibration.
- A resolver must prefer abstention and exact semantic fallback over a wrong visual lock.
- Capture-backend and operating-system types do not belong in compositor/frame contracts.
- macOS objects such as `SCWindow`, `CGWindowID`, and `CVPixelBuffer` stay inside the future macOS helper/backend.
- Semantic fallback means restoring the exact **current** semantic pixels, not merely stopping future visual drawing.
- Output is derived from `current semantic frame + optional current visual`.
- Historical composed output is never restoration authority.
- A moving, replaced, resized, absent, stale, invalid, malformed, disconnected, or crashed visual source must not leave pixels behind.
- Raster validation must complete before destination mutation; rejected input causes zero partial writes.
- Raster format, dimensions, stride, destination bounds, source ownership, destination ownership, and thread rules are explicit.
- Bitwig `Bitmap`, `MemoryBlock`, `ByteBuffer`, macOS handles, and USB objects do not cross host-neutral raster or external-frame contracts.
- An external receiver thread never renders into or writes a Push bitmap. Only the established display/composition thread calls the accepted raster sink.
- The display/composition thread never performs socket accept/read/write, file blocking, thread joins, or a blocking lock acquisition.
- External-frame publication is complete-frame only. A partial header or payload is never visible as a current frame.
- External ingress uses fixed, bounded storage and latest-frame-wins state, not an unbounded FIFO queue.
- Producer wall-clock timestamps are not freshness authority. Local monotonic receipt time determines staleness.
- Producer session identity and per-session sequence must prevent old or restarted producers from reviving stale frames.
- External ingress is local-only by default. Remote network binding requires separate authority.
- Producer absence, clear, disconnect, crash, staleness, malformed input, protocol mismatch, failed authentication, or failed raster application maps to exact semantic-only output.
- Controller input and audio may never wait for a display/capture producer.
- The Mac and Steam Deck are reference hosts. Do not generalize maintainer-specific yabridge, serialosc, Monome, or plugdata state into universal requirements.
- The ordinary rear Push USB path remains a first-class appliance architecture.
- Battery operation is mandatory for a portable-appliance claim; wall power is only an engineering state.
- Track A and Track H do not block universal Track V progress.
- Hardware and power claims require real measurements, photographs, continuity, enumeration, or documented specifications.
- Do not redistribute proprietary Ableton/Bitwig binaries, firmware, activation data, or private assets.
- Do not casually redistribute proprietary UI screenshots or templates. Prefer local generation, recipes, hashes, descriptors, and legally distributable fixtures.
- DrivenByMoss changes live in `kasselvania/DrivenByMoss`, preserve upstream history and LGPL notices, and are not vendored into this repository.
- Every implementation or research slice names an exact accepted source commit/tree.
- `pushwig/upstream-26.4.1` is the immutable accepted upstream basis.
- Project source PRs target `pushwig/main`; never target the immutable basis or upstream `master`.
- Central evidence/status changes and DrivenByMoss source changes remain separate PRs with exact cross-references.

## Accepted source posture

Accepted DrivenByMoss integration state:

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

Accepted central V1D-1 evidence:

```text
commit: a02c9c772da38bfdbc89dfff751c9617cd397c02
tree:   62b4edce8d649266cda65a638d26113692eaef04
```

## Accepted display and raster ownership

### V1A — frame seam

```text
complete semantic IBitmap
        -> PushFramePipeline.process
        -> same IBitmap
        -> unchanged PushUsbDisplay
```

### V1B — static diagnostic

```text
pushwig.syntheticOverlay=true
        -> one fixed bounded vector render
        -> same IBitmap
```

### V1C — current-semantic dynamic lifecycle

```text
newest copied ModelInfo
        -> retain before render decision
        -> complete current-semantic redraw in selected dynamic mode
        -> current valid local visual or no visual
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

Accepted V1D-1 properties:

- public host-neutral `IRasterWritableBitmap` contract;
- caller-owned `byte[]` with primitive source/destination metadata;
- one `RasterPixelFormat.OPAQUE_BGRA8888` value;
- adapter-owned private cached direct destination view;
- fail-closed unsupported-target behavior;
- record-equivalent `BitmapImpl` constructor/accessor/equality/hash/string behavior;
- complete pre-write geometry, overflow, source-length, alpha, and thread validation;
- race-safe first-valid thread binding;
- absolute bulk row copies with source padding ignored;
- default, V1B, V1C, raster, and all-property precedence paths;
- 1,000 complete local raster cycles and all mismatch counts zero;
- 28 negative/thread cases with zero mutation;
- one cached destination view and zero project-owned per-application allocation;
- full physical Push acceptance and exact official rollback.

The accepted V1D-1 writer-only stable p95/max were `0.079834 ms` / `0.678917 ms`. Repeated combined wall-clock tails above 15 ms were explicitly accepted for V1D-1 as pre-existing semantic/host scheduling tails, not reclassified as green. External ingress must repeat separate handoff, writer, semantic-redraw, and combined measurements.

## Slice discipline

Each slice states:

- exact accepted basis;
- one primary claim;
- files/components in scope;
- explicit non-goals;
- executable acceptance criteria;
- retained evidence requirements.

Do not merge uncertainty domains merely because they are adjacent. In particular:

- local raster application is separate from external process ingress;
- external ingress transport/handoff selection is separate from its production implementation;
- external generated frames are separate from operating-system capture;
- window capture is separate from visual-source resolution;
- top-level windows are separate from embedded Bitwig-panel recognition;
- anchor benchmarking is separate from live resolver integration;
- attached desktop adaptation is separate from managed headless geometry;
- macOS proof is separate from Linux portability;
- appliance packaging is separate from CM11EB connector research.

## V1D-2-0 external-ingress research rules

V1D-2-0 selects one exact transport, protocol, fixed-memory handoff, sequence/freshness, and shutdown architecture before a production external receiver is merged.

### Research posture

- Begin from exact DrivenByMoss integration commit `663d719207ef58ec84b4d235c43211ec5da43605` and central main containing V1D-1 evidence `a02c9c772da38bfdbc89dfff751c9617cd397c02`.
- Use temporary local worktrees, branches, commits, patches, harnesses, generated producers, and aggregate-only instrumentation.
- Do not open or merge a production DrivenByMoss PR in V1D-2-0.
- Do not capture Bitwig or plug-in windows.
- Retain complete candidate identities, protocol bytes, source/producer hashes, build/artifact hashes, correctness, timing, fixed-memory/thread behavior, live-fixture results, shutdown, and rollback.
- Stop after the first candidate satisfies every required gate.
- The final central evidence selects one exact production seam or one precise blocker.

### Candidate order

1. loopback-only framed TCP stream plus one receiver thread and fixed latest-frame store;
2. Unix-domain socket plus the same bounded handoff if TCP cannot satisfy the requirements;
3. memory-mapped double buffer with explicit torn-frame/publication semantics only if socket candidates fail;
4. precise blocked result.

Do not continue after a decisive winner.

### Transport and protocol

The selected protocol is language-neutral and versioned. It defines magic, version, session identity, per-session sequence, message type, format, dimensions, destination, stride, payload length, byte order, maximum size, authentication/local-security posture, and failure behavior.

- Bind only to loopback or an equivalently local endpoint.
- Use one active producer and a fixed thread count.
- Do not allocate from untrusted length fields.
- Do not use Java object serialization.
- Do not publish until the complete header and payload pass ingress checks.
- Duplicate or out-of-order sequence values do not refresh freshness.
- New producer sessions clear prior session authority before sequence reset is accepted.
- EOF mid-message, oversized input, wrong token/version/type, and malformed metadata fail closed.

### Buffer and thread ownership

- The receiver never calls `IRasterWritableBitmap`.
- All maximum-size frame arrays/buffers are fixed at startup.
- Receiver staging, published storage, and display-owned consumer bytes have explicit exclusive owners.
- The display thread may nonblockingly adopt a newer complete publication into its own stable array.
- The byte array passed to V1D-1 remains display-owned until synchronous return.
- No receiver can mutate bytes currently being applied.
- No application FIFO queue exists.
- A producer faster than the display supersedes older unpublished/uncopied frames rather than causing backlog playback.

A staging + published + display-consumer arrangement is a leading hypothesis, not accepted authority until V1D-2-0 proves it.

### Freshness and fallback

- Local monotonic receipt time is freshness authority.
- Explicit clear and clean disconnect remove external visual authority.
- Crash/EOF, stale timeout, malformed input, failed raster application, and receiver failure reach semantic-only output within a measured bound.
- The display path never blocks while waiting for a clear/publication lock.
- No old session or pre-reconnect frame may reappear.

### Correctness

Use generated external patterns only. Require zero unexplained counts for:

- source/target mismatches;
- outside and old-region mismatches;
- clear/disconnect/crash/stale/malformed semantic-only mismatches;
- old-session appearances after reconnect;
- duplicate/out-of-order freshness refreshes;
- torn/partial frame visibility;
- source mutation during sink application;
- escaped display-loop exceptions.

Prove positive supersession/dropped-frame counts under producer rates above display consumption.

### Performance

Measure receiver parse/publish, critical-section duration, display nonblocking snapshot/copy, V1D-1 writer, semantic redraw, combined path, stale/no-frame path, lock misses, supersession, fixed memory, per-frame allocation, thread count, RSS/heap, and shutdown time.

The project-owned display-thread handoff plus writer targets:

```text
green:  p95 <= 2 ms
review: p95 <= 5 ms
stop:   p95 > 5 ms
```

The existing host/redraw tails remain visible but are not a waiver for a slow external handoff.

### Real fixture and rollback

Only the leading safe candidate reaches the Mac + Bitwig 6.1 + Push 3 fixture. Prove generated external frames, rates, latest-frame supersession, clear, disconnect, crash, staleness, malformed/truncated input, reconnect/new session, semantic restoration, controls, audio, shutdown while connected/mid-message, and exact official rollback.

## Evidence rules

Retain evidence under `evidence/v1d20-external-frame-ingress/`:

- accepted bases and source topology;
- protocol bytes/version and endpoint/security rules;
- producer and candidate hashes;
- fixed buffer/thread ownership;
- sequence/session/freshness results;
- complete failure matrix;
- timing, allocation, lock, supersession, RSS/heap, and shutdown results;
- real-fixture and rollback evidence;
- one `SELECTED` or `BLOCKED` decision.

Do not commit proprietary screenshots/raw frames, generated extension binaries, temporary producer/harness/instrumentation source, credentials, tokens, activation data, serial numbers, UUIDs, hostnames, IP addresses, or unsanitized personal paths.

## Engineering preferences

- Prefer a simple loopback, versioned framed stream if it meets every gate.
- Prefer fixed arrays and one bounded receiver thread over per-frame object creation.
- Keep network I/O entirely off the display/control thread.
- Prefer a display-owned consumer array and latest-frame-wins snapshot over sharing producer-mutable bytes with the raster writer.
- Use receipt monotonic time, not producer wall time, for staleness.
- Clear visual authority on connection/session replacement before accepting reset sequence numbers.
- Fail closed rather than keeping an ambiguous frame.
- Do not introduce ScreenCaptureKit or a macOS helper before the external generated-frame boundary is exact.
- Remeasure the full path under 1/15/30/60 fps and burst conditions.

## Connector-development rules

A CM11EB development card is staged open hardware:

- expose only proven grounds, candidate USB pairs, and purpose-specific observations first;
- leave power rails disconnected by default;
- do not fan all high-speed contacts onto generic headers;
- USB 3/PCIe/eSPI work requires a bounded experiment and controlled-impedance design;
- connector geometry and pin mapping require independent review before insertion.

## Current posture

S0, V1A-0, V1A, V1B, V1C-0, V1C, V1D-0, and V1D-1 are accepted.

V1D-2-0 now selects the external generated-frame transport, protocol, handoff, sequence, freshness, and shutdown model. A production external-ingress slice follows only after that decision. V2 remains the first macOS dedicated-window capture slice.

See `CURRENT_SLICE.md` before changing code.
