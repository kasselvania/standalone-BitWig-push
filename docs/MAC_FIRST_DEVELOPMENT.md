# Mac-First Software Development Fixture

## Decision

The active Track V development fixture is the maintainer's macOS computer running Bitwig Studio, the `kasselvania/DrivenByMoss` derivative, and Push 3 Controller over ordinary USB.

This changes implementation order, not product scope:

- macOS supplies the fastest source/build/install/measurement loop;
- Steam Deck remains the first Track A appliance host and named Linux portability fixture;
- semantic, raster, ingress, resolver, and adapter contracts remain operating-system neutral;
- no ScreenCaptureKit, Core Graphics, or other macOS object enters the controller extension or host-neutral frame contracts.

## Accepted Mac progress

### S0 through V1B

Accepted the exact Mac + Bitwig + Push fixture, official DrivenByMoss source/artifact provenance, derivative build/install/rollback, the project-owned frame seam, and bounded static project pixels.

### V1C — dynamic restoration

```text
newest copied ModelInfo
        -> complete current-semantic redraw
        -> current optional visual
        -> same persistent IBitmap
        -> unchanged PushUsbDisplay
```

Accepted movement, resize, replacement, semantic-only states, under-coverage semantic updates, overlay-only updates, notification lifecycle, regression paths, bounded performance, real Push behavior, and exact rollback.

### V1D-1 — production raster sink

```text
current semantic redraw
        -> validate complete opaque BGRA request
        -> absolute bulk row copies, or zero writes
        -> same logical IBitmap
        -> unchanged PushUsbDisplay
```

Accepted:

- host-neutral caller-owned `byte[]` raster request;
- adapter-private cached direct destination view;
- complete geometry/overflow/source/alpha/thread validation;
- race-safe display-thread binding;
- small, padded, medium, full, replacement, absent, stale, invalid, and malformed states;
- zero source-target/outside/restoration/semantic-only/partial-write mismatches;
- one cached view and zero project-owned per-application allocation;
- all prior startup paths, full Push controls/audio, and exact rollback.

Accepted implementation:

```text
kasselvania/DrivenByMoss: pushwig/main
commit: 663d719207ef58ec84b4d235c43211ec5da43605
tree:   c4e42825d069421a44b3241349de9a7c6453a3ad
```

### V1D-2-0 — external ingress decision

Selected a capability-authenticated loopback framed stream:

```text
external generated producer
        -> TCP 127.0.0.1 protocol v1
        -> one receiver thread and complete-message validation
        -> fixed latest-publication storage
        -> display-thread tryLock copy into fixed consumer bytes
        -> local monotonic freshness
        -> accepted V1D-1 sink
        -> unchanged PushUsbDisplay
```

Research established:

- exact 80-byte network-order protocol with HELLO/FRAME/CLEAR;
- 32-byte capability, 128-bit producer session, receiver-local generation, and strictly increasing sequence;
- fixed 1,843,312 bytes of project frame/security arrays;
- no application frame queue or receiver bitmap access;
- no display-thread socket I/O or blocking lock;
- latest-frame supersession and no backlog replay at tested rates/bursts;
- exact semantic fallback after clear, disconnect, crash, stale timeout, auth/protocol/session failure, truncation, malformed input, writer rejection, bind failure, and shutdown;
- 1/15/30/60 fps, real Push behavior, five blocked-receive shutdown states, immediate restart, and exact rollback.

Accepted evidence:

```text
commit: 99e09e2a651c92ac6710fdc88c4675a874a56600
tree:   db22ec0a845146f03861581a929ae52b30204a1b
```

## Active Mac task: V1D-2 production ingress

V1D-2 now recreates the selected receiver/store/pipeline as production source against exact accepted `pushwig/main`.

Production source envelope:

```text
Push2Display.java
ExternalRasterPushFramePipeline.java
ExternalRasterReceiver.java
LatestExternalRasterFrameStore.java
```

Construction-time properties provide activation, fixed/configurable loopback port, private token-file path, and stale timeout. External mode has precedence over local diagnostic sources and forces current-semantic redraw.

The launcher/orchestrator owns token-file creation and cleanup. The extension validates a regular non-symlink owner-private file, loads exactly 32 capability bytes, and never logs or exposes the token. Fixed/configurable port plus token-file path is the current endpoint handoff; friendlier helper orchestration is later work.

The receiver owns socket, parser, staging, session, and publication. It publishes only complete authenticated frames. The display nonblockingly adopts into its own fixed array, checks local receipt-time freshness, invokes V1D-1 synchronously, and returns the same semantic bitmap to one unchanged USB writer.

Production acceptance repeats exact session/sequence/gap/reset/exhaustion rules, all failure fallbacks, 1/15/30/60 fps and burst behavior, fixed allocation and separated timing, five shutdown states, active-listener collision, immediate restart, full Push controls/audio, and exact official rollback.

No ScreenCaptureKit or window discovery enters V1D-2.

## Tail-latency posture

The selected research external pipeline measured `0.092375 ms` p95, while the combined semantic/host path measured `2.106083 ms` p95 with much larger scheduler tails. Production must repeat exact clean-head receive/publication/display-copy/writer/redraw/combined measurements.

A slow ingress handoff is not excused by accepted host tails. The project-owned display adoption plus writer must remain at or below 2 ms p95 for green, with explicit review at 2–5 ms and a stop above 5 ms.

No queue, worker compositor, second bitmap, or extra USB writer may be introduced to hide tails.

## What the Mac can still prove before the Deck returns

The Mac can establish:

1. production external latest-frame ingress;
2. macOS dedicated-window capture;
3. one floating Bitwig native-device or plug-in visual lens;
4. semantic-seeded anchor benchmarks;
5. much of the public attached-mode experience.

The Mac cannot establish Linux X11/Wayland/portal behavior, Flatpak/host boundaries, Steam Deck power/battery/headless boot, or Linux support claims. Those remain explicit later checkpoints.

## Revised sequence

```text
S0        accepted fixture and display seam
V1A-0     accepted fork/build/install baseline
V1A       accepted identity pipeline
V1B       accepted static bounded composition
V1C-0     accepted dynamic restoration selection
V1C       accepted dynamic local visual lifecycle
V1D-0     accepted bulk raster primitive
V1D-1     accepted production local raster sink
V1D-2-0   accepted external-ingress architecture
V1D-2     active production external latest-frame ingress
V2        macOS dedicated-window capture
V2A       semantic-seeded anchor benchmark
V2P       Linux/Steam Deck checkpoint
```

## Future capture posture

After V1D-2, a normal macOS helper may own ScreenCaptureKit permission, discover a dedicated top-level Bitwig native-device or plug-in window, crop/scale/convert into opaque BGRA, and publish through the accepted loopback boundary.

Apple capture objects remain entirely inside the helper. The controller extension consumes only the bounded protocol and returns to exact semantics when the helper is absent, denied, stale, malformed, or closed.

## Result

Mac-first development has proven the semantic seam, visible composition, exact dynamic restoration, the production raster sink, and the external-ingress architecture. V1D-2 now turns that final pre-capture boundary into accepted production source.
