# SELECTED

## Date and authority

- Date: 2026-09-01 PDT.
- Machine state: accepted macOS 26.4.1 arm64, Bitwig Studio 6.1, real Push 3, Push headphone audio.
- Central basis/tree: `5597624bd50e5ef95ecd3af82ea1816ce4facd21` / `ec016bd3174345e32f1a6d47eb061820e7a1e9b9`.
- DrivenByMoss basis/tree: `663d719207ef58ec84b4d235c43211ec5da43605` / `c4e42825d069421a44b3241349de9a7c6453a3ad`.
- Selected research candidate head/tree: `4f00972355fcf7b5f0ead0fef3365b81850be12f` / `7202267e51d0f2613cea93d186b132a996ec14ec`.

## Selected production architecture

### Transport, bind, discovery, and local security

- Transport: one versioned binary TCP stream bound only to IPv4 `127.0.0.1`.
- Endpoint: construction-time configurable port, default `45291`; no wildcard bind and no network discovery service in the first production slice.
- Address reuse is enabled before bind for immediate normal restart; a second active listener remains rejected.
- Exactly one active authenticated producer is handled by one receiver thread.
- Authentication: 32-byte capability token in HELLO, loaded from an owner-private token file, exact constant-time comparison before frame authority.
- A production slice must retain a bounded private token-delivery/cleanup mechanism; the research temporary-file path is evidence, not automatically the final user-facing mechanism.

### Wire language

- Magic/version/header: `0x50575852` / `1` / `80` bytes.
- Byte order: network byte order for every multibyte field.
- Header fields at exact offsets: magic 0, version 4, header length 6, message type 8, flags/reserved 12, format 16, reserved 20, session high 24, session low 32, sequence 40, destination x/y 48/52, width/height 56/60, stride 64, payload length 68, reserved 72.
- Types: `HELLO=1`, `FRAME=2`, `CLEAR=3`.
- Formats: `NONE=0`, `OPAQUE_BGRA8888=1`.
- Maximum header/payload/message: `80` / `614,400` / `614,480` bytes.
- FRAME payload is top-to-bottom opaque BGRA, implicit source offset zero, exact `(height-1)*stride + width*4`, destination bounded to `960x160`.
- CLEAR has next positive sequence and zero format/geometry/payload.
- Unknown or nonzero reserved fields, unsupported version/type/format, malformed arithmetic/geometry, oversize, or nonopaque alpha reject the session; there is no v1 extension/ignore rule.

### Session, sequence, reconnect, and freshness

- Session: producer supplies a nonzero 128-bit identity in authenticated HELLO; receiver adds a local generation that gates publication.
- Sequence: positive signed Java `long`, strictly increasing within a session.
- Duplicate/lower/nonpositive sequence invalidates the session and does not refresh freshness.
- Skipped sequence is accepted and counted; no intermediate application frame is queued or replayed.
- New authenticated connection invalidates old authority and permits sequence reset to `1`; old generation cannot publish afterward.
- Freshness: local `System.nanoTime()` at complete accepted publication only.
- Default stale timeout: `1,500 ms`, construction-time bounded to `100..10,000 ms`.
- No producer clock or timestamp is authority.

### Fixed ownership and synchronization

- Receiver thread count: exactly one daemon; it may block in accept/header/payload read.
- Fixed arrays: header `80`, token `32`, staging `614,400`, publication `614,400`, display consumer `614,400`; total `1,843,312` bytes plus fixed objects/JDK/OS socket storage.
- Receiver owns staging/session/parser; receiver never sees the bitmap.
- Publication is one complete latest frame plus primitive metadata under `ReentrantLock`.
- Display calls `tryLock` only. A newer publication is copied into its fixed consumer array; lock releases before V1D-1.
- Lock miss reuses the already display-owned frame only while its authority epoch is unchanged and receipt remains fresh; otherwise semantics.
- Display owns consumer bytes through synchronous `writeRasterRegion` return.
- Same semantic `IBitmap` then reaches exactly one unchanged `PushUsbDisplay.send`; there is no second USB owner.

### Complete publication and fallbacks

- Publication occurs only after full header, full bounded payload, all common/session/sequence/geometry/alpha checks, and local receipt time.
- Partial/truncated/slow-incomplete messages publish nothing.
- Explicit clear, disconnect, producer crash, stale expiry, new session, sequence authority failure, malformed/oversized/auth failure, receiver close/failure, writer rejection, and shutdown all end in newly redrawn current semantic-only output.
- Historical external bytes and historical composed pixels are never semantic restoration authority.

### Startup and shutdown

1. `Push2Display` reads the external-ingress activation once at construction.
2. External mode enables current retained-model semantic redraw.
3. Pipeline constructs fixed store/display arrays and attempts token validation/loopback bind.
4. Failed configuration/bind starts no thread and leaves ordinary semantics usable after one error.
5. Successful bind starts exactly one named daemon receiver.
6. Shutdown sets pipeline closing, closes store authority nonblockingly, closes client/server to unblock read/accept, then the existing shutdown executor performs one bounded 2-second receiver join before existing USB/super shutdown.
7. No frame accepted after closing may become authoritative.

### Allocation and timing budget

- Fixed project frame/security allocation: `1,843,312` bytes.
- Project-owned per-frame full-size array/object allocation: `0` by source/bytecode; exact-final aggregate measurement was `0.184` display bytes/call and `1.878` receiver bytes/frame as JVM/JDK noise.
- Production acceptance budget: project-owned publication-to-consumer copy plus V1D-1 writer p95 `<=2 ms`; review `<=5 ms`; stop above `5 ms`.
- Observed live worst project-owned full pipeline p95: `0.092375 ms`; publication critical-section p95: `0.024916 ms`; display copy p95: `0.023167 ms`.
- Combined semantic/host path p95 `2.106083 ms` is retained in review band; repeat exact clean-head aggregate measurement and review host scheduling maxima rather than adding asynchronous concealment.
- No queue, worker, executor, second bitmap, frame backlog, or extra buffer may be added to hide synchronous cost.

## Exact proposed V1D-2 DrivenByMoss source envelope

Expected production source changes are exactly:

1. `src/main/java/de/mossgrabers/controller/ableton/push/controller/Push2Display.java`
2. `src/main/java/de/mossgrabers/controller/ableton/push/controller/ExternalRasterPushFramePipeline.java`
3. `src/main/java/de/mossgrabers/controller/ableton/push/controller/ExternalRasterReceiver.java`
4. `src/main/java/de/mossgrabers/controller/ableton/push/controller/LatestExternalRasterFrameStore.java`

The three new types remain package-private/internal. Existing `PushFramePipeline`, `IBitmap`, `IRasterWritableBitmap`, and `RasterPixelFormat` are the only cross-boundary contracts required. `PushUsbDisplay.java`, `BitmapImpl.java`, `AbstractGraphicDisplay.java`, `pom.xml`, version/IDs, and accepted V1D-1 sink behavior are outside the production change envelope unless a new authority decision identifies a concrete blocker.

No prototype commit is to be merged. Production work must be recreated/reviewed from this decision against the accepted integration basis.

## Temporary producer role

The Python producer is a deterministic language-neutral oracle only. It proves protocol implementability and failure cases; it is not committed product code or a final adapter. The production slice should retain an external reference/conformance producer outside the extension source, without expanding into ScreenCaptureKit, window discovery, or a public visual-adapter protocol.

## Alternative disposition

- Candidate B Unix-domain socket: not reached because Candidate A passed every gate; it would add filesystem socket permissions/stale-path cleanup without resolving a blocker.
- Candidate C mapped double buffer: not reached because Candidate A already proves fixed-memory latest-only ownership; mapping would add memory-ordering/generation/crash-custody complexity without resolving a blocker.

## Exact V1D-2 production acceptance proposal

1. Branch directly from then-current accepted `pushwig/main`; preserve immutable upstream basis.
2. Limit production source to the four-path envelope or stop for authority review.
3. Retain exact protocol/security/session/freshness rules above and a conformance producer with no retained token.
4. Re-run at least 1,000 complete publications, all mismatch counters at zero, positive supersession/gap/clear/stale/session counts, and the complete malformed/truncation matrix.
5. Prove exact-final display `tryLock`, fixed arrays, zero frame-sized per-cycle allocation, same `IBitmap`, and byte-identical `PushUsbDisplay.class`.
6. Repeat exact clean-head base/artifact extraction comparison and bytecode proof.
7. Repeat aggregate performance after 60-second startup exclusion with at least 1,000 samples/category; require project p95 green or stop/review by the declared bands.
8. Repeat the real Push no-producer, valid 1/15/30/60, burst/session, fallback, and five-state shutdown matrix on one exact proposed artifact.
9. Prove immediate same-port restart and safe active-listener collision.
10. Restore and physically confirm the official artifact at exact accepted SHA-256 before merging anything.

## Explicit unresolved questions for V1D-2

- Select the production capability-token creation/delivery/cleanup owner; the research private file proves security mechanics but is not yet a product UX.
- Decide whether the fixed/configurable port remains internal or gains one bounded discovery handoff to the external producer.
- Decide how aggregate counters/errors are exposed for support without per-frame logging or a public setting.
- Define conformance behavior near positive signed sequence exhaustion; no practical test reached `Long.MAX_VALUE`.
- Repeat exact clean-production-head live aggregate timing and disposition of combined host/scheduler maxima.
- Define the eventual adapter-facing frame source in a later authorized slice; do not conflate it with this transport decision.

## Commands and exact result

The decision follows exact source/API inspection, Candidate A commit/patch/artifact custody, deterministic Java/Python harnesses, bytecode, same-toolchain build/extraction, aggregate live timing, physical Push acceptance, all five exact-final shutdown states, and exact official rollback. No source branch/PR was published.

## What this proves

- One precise production architecture is selected with exact ownership, protocol, fallback, timing, source-envelope, and acceptance rules.
- V1D-2 can begin without rediscovering transport, publication, session, freshness, memory, or shutdown architecture.

## What this does not prove

- It is not itself a production implementation or protocol stability promise.
- It does not authorize capture, external adapters, remote transport, multiple producers, scaling, alpha, compression, or another USB writer.
