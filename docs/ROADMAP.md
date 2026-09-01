# Roadmap

The roadmap has three parallel tracks. Later achievements do not retroactively define earlier ones.

## Valid project successes

1. Adaptive Bitwig/native-device/plug-in visuals mixed with DrivenByMoss for ordinary desktop users.
2. A portable Steam Deck appliance using the existing stand and battery.
3. A reproducible Framework or compact-x86 appliance.
4. An open CM11EB diagnostic/development board.
5. A used Compute Element native-bay instrument.

# Track V — Universal visual/controller software

The Mac is the first implementation fixture; Steam Deck/Linux is the named second-host and appliance checkpoint.

## Accepted foundations

### S0 — fixture and display seam

Accepted the Mac + Bitwig 6.1 + Push 3 fixture, pinned official DrivenByMoss 26.4.1 to exact source, and traced the persistent 960×160 semantic bitmap through `Push2Display` to the sole `PushUsbDisplay` transport.

### V1A-0 — derivative custody/build baseline

Accepted the true fork, immutable upstream basis, Java 21/Maven build, reversible installation, real-device parity, and exact official rollback.

### V1A — identity frame pipeline

```text
semantic IBitmap
        -> PushFramePipeline
        -> same IBitmap
        -> unchanged PushUsbDisplay
```

### V1B — static bounded composition

Accepted one startup-gated fixed mark with zero outside-region mismatches, bounded timing, preserved semantic modes, real controls/audio, and exact rollback.

### V1C-0 — dynamic restoration architecture

Selected current-semantic redraw before current optional visual. Historical composed pixels are not restoration authority.

### V1C — production dynamic local lifecycle

Accepted movement, overlap, resize, replacement, NONE, STALE, INVALID, semantic updates under coverage, overlay-only updates, notification lifecycle, all startup regression paths, exact restoration, bounded performance, one writer, real Push behavior, and exact rollback.

### V1D-0 — bulk raster composition decision

Selected direct, adapter-owned opaque-BGRA region writing with complete validation before mutation, one cached destination view, synchronous display-thread ownership, zero partial invalid writes, exact V1C restoration, green full-frame timing, real Push behavior, and exact rollback.

### V1D-1 — production local raster sink

Accepted source integration:

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

Production contract:

```text
current semantic redraw
        -> IRasterWritableBitmap.writeRasterRegion(...)
        -> complete OPAQUE_BGRA8888 validation
        -> absolute bulk rows, or zero write
        -> same logical bitmap
        -> unchanged PushUsbDisplay
```

Accepted evidence includes:

- one public host-neutral raster capability and one pixel format;
- private adapter-owned cached direct destination view;
- preserved `BitmapImpl` constructor/accessor and record-equivalent behavior;
- fail-closed unsupported destination layouts;
- race-safe first-valid writer thread binding;
- 28 negative/thread cases with zero changed bytes or rows;
- 1,000 complete nine-state cycles with all mismatch categories zero;
- one cached view and zero project-owned allocation across 5,000 full-frame applications;
- default, V1B, V1C, raster, and all-property precedence behavior;
- full real Push control/display/audio acceptance and exact rollback.

The writer-only stable p95/max were `0.079834 ms` / `0.678917 ms`. Combined wall-clock tails above 15 ms were retained and explicitly accepted as pre-existing semantic/host scheduling tails, not reclassified as green.

## V1D-2-0 — external latest-frame ingress architecture — active

**Claim:** select the exact process transport, protocol, fixed-memory handoff, session, sequence, freshness, failure, and shutdown architecture by which a local producer can publish generated raster frames to the accepted V1D-1 sink.

Candidate order:

1. loopback-only framed TCP stream plus one receiver thread and fixed staging/published/display-consumer storage;
2. Unix-domain socket with the same bounded handoff if TCP fails;
3. memory-mapped double buffer only if socket candidates fail;
4. precise blocked result.

Required properties:

```text
complete-message publication only
fixed maximum payload and storage
one active producer and fixed thread count
latest-frame-wins, no application FIFO queue
session identity and increasing per-session sequence
local monotonic receipt-time freshness
nonblocking display-owned adoption
receiver never touches bitmap
exact semantic fallback on clear/disconnect/crash/stale/malformed input
bounded shutdown while connected, silent, or mid-message
one unchanged Push USB writer
```

Use a temporary standalone generated-frame producer and generated asymmetric opaque-BGRA cards only. Prove 1/15/30/60 fps where practical, producer bursts, supersession, duplicates/out-of-order messages, clear, crash, stale timeout, truncation, oversized input, reconnect/sequence reset, fixed allocation, no torn frames, real Push behavior, and exact rollback.

V1D-2-0 is evidence-only. It opens no production source PR and performs no window capture.

## V1D-2 — production external generated-frame ingress

Implement only the architecture selected by V1D-2-0.

Expected responsibilities include:

- versioned local protocol parsing;
- one bounded receiver lifecycle;
- fixed latest-frame storage;
- nonblocking display-owned snapshot/copy;
- local receipt-time freshness;
- session/sequence/reset handling;
- clear/disconnect/crash/malformed fallback;
- pipeline shutdown ownership;
- exact V1D-1 sink use;
- temporary generated producer acceptance.

No ScreenCaptureKit or real window capture is required for this slice.

## V2 — macOS dedicated-window visual lens

Use a normal macOS helper to discover and capture one floating Bitwig native-device view and one ordinary plug-in editor. Preserve window identity through move/resize/monitor changes, use source-relative crops, recover from close/reopen and permission denial, and keep Apple types inside the helper.

## V2A — semantic-seeded pixel-anchor benchmark

Benchmark normalized grayscale, correlation, edge-map, coarse-to-fine, and only then feature-based methods. Require strong negatives, multiple consistent anchors, zero wrong locks in the retained matrix, abstention on ambiguity, and explicit acquisition/validation/CPU/memory metrics.

## V2P — Linux/Steam Deck checkpoint

Reproduce Push control/audio/display, current-semantic restoration, raster sink, external-frame contract, and one useful visual source on Linux. Characterize Flatpak/host IPC, capture backend behavior, CPU, and power without redesigning Mac-neutral contracts.

## V3–V7 — public portability

- **V3:** public visual-source and adapter SDK.
- **V4:** adaptive embedded Bitwig-panel resolver.
- **V5:** bounded calibration and portable local descriptors.
- **V6:** attached-mode release across a defined Mac/Linux/layout matrix.
- **V7:** an additional OS backend without compositor or adapter redesign.

# Track A — All-in-one appliance

Track A consumes Track V; it does not define it.

- **A0:** measure the wooden base, battery, power cable, USB topology, airflow, and service access.
- **A1:** managed/headless Steam Deck profile with safe boot, save, restart, and shutdown.
- **A2:** battery-powered maintainer appliance with measured runtime/thermals and wireless full desktop.
- **A3:** reproducible Framework/compact-x86 appliance with public BOM and service procedure.

A2 is already a complete project success.

# Track H — Connector and native compute

- **H0:** measured Push bay/carrier survey.
- **H1:** passive CM11EB diagnostic edge card with power disconnected by default.
- **H2:** protected selectable USB development card with ESD and explicit VBUS control.
- **H3:** internal carrier-path enumeration of display, MIDI/control, and audio.
- **H4:** purpose-specific high-speed or sideband tooling.
- **H5:** used Compute Element Linux bring-up and Track V acceptance.
- **H6:** native-bay battery, charging, thermal, shutdown, service, and recovery final form.

# Optional ecosystem work

Wine/yabridge, plugdata/Pure Data, Monome/serialosc, device-specific analyzers, and alternative controller integrations remain independent efforts that may consume public interfaces without owning the core roadmap.
