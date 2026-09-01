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

### S0 through V1B

Accepted the exact Mac/Bitwig/Push fixture, source and artifact provenance, derivative build/install/rollback, the frame-pipeline seam, and bounded static project-owned pixels.

### V1C-0 and V1C — current-semantic dynamic restoration

```text
newest retained semantic model
        -> complete semantic redraw
        -> current optional visual
        -> same persistent bitmap
        -> unchanged PushUsbDisplay
```

Accepted movement, overlap, resize, replacement, semantic-only states, semantic updates under coverage, overlay-only updates, notification lifecycle, regression paths, one writer, real Push behavior, and exact rollback.

### V1D-0 and V1D-1 — production bulk raster sink

```text
current semantic redraw
        -> validate complete OPAQUE_BGRA8888 request
        -> absolute bulk row copies, or zero writes
        -> same logical bitmap
        -> unchanged PushUsbDisplay
```

Accepted a caller-owned `byte[]` host-neutral sink, adapter-private cached destination view, complete alpha/geometry/overflow/thread validation, padded/medium/full-frame writes, malformed fallback, zero restoration mismatches, bounded writer timing/allocation, all prior-mode regressions, real Push behavior, and exact rollback.

Accepted implementation:

```text
kasselvania/DrivenByMoss: pushwig/main
commit: 663d719207ef58ec84b4d235c43211ec5da43605
tree:   c4e42825d069421a44b3241349de9a7c6453a3ad
```

Accepted V1D-1 evidence:

```text
commit: a02c9c772da38bfdbc89dfff751c9617cd397c02
tree:   62b4edce8d649266cda65a638d26113692eaef04
```

### V1D-2-0 — external ingress architecture

Selected Candidate A:

```text
external generated producer
        -> capability-authenticated TCP 127.0.0.1 protocol v1
        -> complete-message receive in one receiver thread
        -> fixed latest-publication storage
        -> display-thread nonblocking adoption
        -> local monotonic freshness
        -> accepted V1D-1 sink
        -> unchanged PushUsbDisplay
```

Accepted:

- 80-byte network-order header and 614,400-byte payload cap;
- HELLO/FRAME/CLEAR messages;
- 32-byte capability, producer session identity, receiver-local generation, and strictly increasing sequence;
- legal gaps and latest-frame supersession without application backlog;
- fixed staging/publication/display arrays and one daemon receiver thread;
- complete publication only after full receive and validation;
- display `tryLock` only;
- exact semantic fallback on absence, clear, disconnect, crash, stale, protocol/authentication/session failure, truncation, malformed data, writer rejection, bind failure, and shutdown;
- 1/15/30/60 fps and burst tests;
- five blocked-receive shutdown states and immediate same-port restart;
- full real Push controls/audio/display acceptance and exact rollback.

Accepted evidence:

```text
commit: 99e09e2a651c92ac6710fdc88c4675a874a56600
tree:   db22ec0a845146f03861581a929ae52b30204a1b
```

## V1D-2 — production external latest-frame ingress — active

Implement the selected receiver/store/pipeline in production DrivenByMoss source.

Production envelope:

```text
Push2Display.java
ExternalRasterPushFramePipeline.java
ExternalRasterReceiver.java
LatestExternalRasterFrameStore.java
```

Startup contract:

```text
pushwig.externalRasterIngress=true
pushwig.externalRasterPort=<port>
pushwig.externalRasterTokenFile=<private file>
pushwig.externalRasterStaleTimeoutMs=<timeout>
```

The launcher owns the private token file; the extension validates/loads it, binds only `127.0.0.1`, receives into fixed storage, and exposes only complete authenticated latest frames to the display thread. External mode has precedence over local diagnostic sources and enables current-semantic redraw.

Acceptance requires exact protocol/security/session/sequence/freshness behavior, no receiver bitmap access, no display socket access, fixed memory, one receiver thread, nonblocking display adoption, zero torn/partial/old-session/restoration mismatches, explicit sequence-exhaustion behavior, bounded production timing, all five shutdown states, collision/restart, real Push operation, and exact rollback.

No window capture enters this slice.

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
