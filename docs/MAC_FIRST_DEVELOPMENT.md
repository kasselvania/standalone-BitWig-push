# Mac-First Software Development Fixture

## Decision

The active Track V development fixture is the maintainer's macOS computer running Bitwig Studio, the `kasselvania/DrivenByMoss` derivative, and Push 3 Controller over ordinary USB.

This changes implementation order, not product scope:

- macOS supplies the fastest source/build/install/measurement loop;
- Steam Deck remains the first Track A appliance host and named Linux portability fixture;
- semantic, raster, external-frame, resolver, and adapter contracts remain operating-system neutral;
- no ScreenCaptureKit, Core Graphics, or other macOS object may leak into the controller extension or public frame contracts.

## Accepted Mac progress

### S0 through V1B

Accepted the exact Mac + Bitwig + Push fixture, official DrivenByMoss source/artifact provenance, derivative build/install/rollback, the project-owned frame seam, and the first bounded static visual pixels.

### V1C-0 and V1C

Selected and implemented current-semantic redraw as dynamic restoration authority:

```text
newest copied ModelInfo
        -> complete current-semantic redraw
        -> current optional local visual
        -> same persistent IBitmap
        -> unchanged PushUsbDisplay
```

V1C proved movement, overlap, resize, replacement, semantic-only states, semantic changes under coverage, overlay-only updates, notification lifecycle, regression paths, bounded performance, real Push behavior, and exact rollback.

### V1D-0 and V1D-1

Selected and implemented a direct writable bitmap-region sink:

```text
current semantic redraw
        -> complete opaque-BGRA request validation
        -> absolute bulk row copies, or zero write
        -> same logical IBitmap
        -> unchanged PushUsbDisplay
```

Accepted source:

```text
kasselvania/DrivenByMoss: pushwig/main
commit: 663d719207ef58ec84b4d235c43211ec5da43605
tree:   c4e42825d069421a44b3241349de9a7c6453a3ad
```

Accepted central evidence:

```text
commit: a02c9c772da38bfdbc89dfff751c9617cd397c02
tree:   62b4edce8d649266cda65a638d26113692eaef04
```

V1D-1 established:

- one host-neutral `IRasterWritableBitmap` contract;
- one opaque BGRA pixel format;
- one private cached direct Bitwig destination view;
- all-or-nothing geometry, source, alpha, destination, and thread validation;
- race-safe first-valid display-thread binding;
- padded row support and exact bulk copying;
- fail-closed unsupported destinations;
- default, V1B, V1C, raster, and all-property precedence behavior;
- 1,000 complete raster cycles with every mismatch category zero;
- 28 negative/thread cases with no changed byte;
- zero project-owned allocation across 5,000 full-frame applications;
- full real Push control/display/audio acceptance;
- exact official rollback.

The writer itself remained extremely small in the stable real run. Repeated larger combined wall-clock maxima were explicitly retained and accepted as pre-existing semantic/host scheduling tails, not described as green. Any external handoff must be measured independently from those tails.

## Active Mac task: V1D-2-0 external latest-frame ingress architecture

The Mac can now consume a prepared raster efficiently. The active task is to prove how another local process safely supplies the latest complete raster.

The required separation is:

```text
external process
        -> local transport and complete-message parser
        -> fixed latest-frame publication
        -> nonblocking display-owned frame adoption
        -> V1D-1 raster writer
```

The external receiver never writes the Push bitmap. The Push display thread never performs network I/O, waits for the producer, or blocks on the receiver.

Candidate order:

1. loopback-only framed TCP stream with one receiver thread and fixed storage;
2. Unix-domain socket if the loopback candidate cannot satisfy the requirements;
3. memory-mapped double buffer only if socket candidates fail.

V1D-2-0 must select:

- endpoint binding/discovery and local security;
- language-neutral versioned framing;
- maximum message/payload sizes;
- producer session identity and per-session sequence;
- local monotonic receipt-time freshness;
- explicit clear and disconnect behavior;
- fixed staging, publication, and display-consumer ownership;
- nonblocking adoption and latest-frame supersession;
- partial/truncated/malformed/oversized rejection;
- clean shutdown while connected, silent, or mid-message;
- exact production source seam.

The test producer uses only generated asymmetric BGRA frames. No Screen Recording permission or proprietary window capture is needed.

## Why another architecture gate is appropriate

External ingress introduces a new concurrency boundary that the local sink deliberately avoided.

A premature production implementation could accidentally:

- expose a partial frame;
- block the control surface thread;
- allocate a new full-frame array on every update;
- build a FIFO backlog;
- refresh stale state with duplicate sequence values;
- let an old producer session reappear after reconnect;
- race producer mutation against `writeRasterRegion`;
- hang Bitwig shutdown on a slow sender;
- treat producer wall-clock time as freshness authority.

V1D-2-0 resolves those ownership questions with generated frames before the project adds real capture complexity.

## Expected first candidate

The leading candidate is:

```text
one loopback server
one active producer
one receiver thread
one fixed receive staging array
one fixed complete-publication array
one fixed display-owned consumer array
one versioned binary protocol
one local receipt-time freshness clock
no application frame queue
```

The receiver publishes only complete frames. The display thread uses a nonblocking snapshot/copy to update its own stable bytes and may continue using that frame only while it remains fresh. Producer clear, disconnect, crash, staleness, protocol failure, malformed data, or sink rejection produces exact current semantics.

This remains a candidate until the slice proves correctness, fixed allocation, rates, supersession, failure behavior, and shutdown.

## Tail-latency posture

V1D-2-0 must measure separately:

- receiver receive/parse/publish;
- publication critical section;
- display snapshot/copy;
- raster writer;
- semantic redraw;
- combined display path.

The accepted V1D-1 host/redraw tails remain visible, but they are not a waiver for a slow or blocking handoff. The project-owned display snapshot/copy plus writer targets p95 at or below 2 ms and must not allocate per frame.

## What the Mac can still prove before the Deck returns

The Mac can establish:

1. external generated-frame transport, latest-frame ownership, and freshness;
2. production external ingress;
3. macOS dedicated-window capture;
4. one floating Bitwig native-device or plug-in visual lens;
5. semantic-seeded anchor benchmarks;
6. much of the public attached-mode experience.

The Mac cannot establish:

- Linux X11/Wayland/portal behavior;
- Flatpak/host IPC boundaries;
- Steam Deck power, battery, headless boot, or managed geometry;
- Linux support claims.

Those remain explicit later checkpoints.

## Revised sequence

```text
S0        accepted fixture and display seam
V1A-0     accepted fork/build/install baseline
V1A       accepted identity pipeline
V1B       accepted static bounded composition
V1C-0     accepted dynamic restoration selection
V1C       accepted dynamic local lifecycle
V1D-0     accepted bulk raster primitive
V1D-1     accepted production local raster sink
V1D-2-0   active external latest-frame ingress architecture
V1D-2     production external generated-frame ingress
V2        macOS dedicated-window capture
V2A       semantic-seeded anchor benchmark
V2P       Linux/Steam Deck checkpoint
```

## Future macOS capture posture

After external ingress is accepted, Screen capture belongs in a normal macOS helper application with stable permission identity. Dedicated top-level native-device and plug-in windows remain the first capture targets.

The helper will convert/crop/scale its platform frame into the accepted external raster contract. Apple types remain inside the helper. The controller side sees only bounded host-neutral metadata and opaque raster bytes.

Embedded Bitwig panels and pixel anchors remain later work.

## Result

Mac-first development has proven the semantic seam, visible composition, exact dynamic restoration, and a production bulk raster sink. It now proves the process boundary and latest-frame lifecycle before real window capture begins.
