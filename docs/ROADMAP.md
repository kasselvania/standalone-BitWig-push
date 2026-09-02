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

Accepted the exact Mac/Bitwig/Push fixture, source/artifact provenance, reversible DrivenByMoss derivative workflow, frame seam, and first bounded project-owned pixels.

### V1C-0 and V1C — current-semantic restoration

```text
newest retained semantic model
        -> complete semantic redraw
        -> current optional visual
        -> same persistent bitmap
        -> unchanged PushUsbDisplay
```

Accepted movement, overlap, resize, replacement, semantic-only states, semantic updates under coverage, overlay/notification lifecycle, prior-mode regressions, one writer, real Push controls/audio/display, and exact rollback.

### V1D-0 and V1D-1 — production bulk raster sink

```text
current semantic redraw
        -> validate complete OPAQUE_BGRA8888 request
        -> absolute bulk row copies, or zero write
        -> same logical bitmap
        -> unchanged PushUsbDisplay
```

Accepted the host-neutral `byte[]` region writer, adapter-private destination memory, exact geometry/stride/alpha/thread validation, padded/full-frame tests, zero partial invalid writes, bounded writer timing/allocation, prior-path regressions, real Push behavior, and rollback.

### V1D-2-0 and V1D-2 — production external latest-frame ingress

```text
external producer
        -> capability-authenticated TCP 127.0.0.1 protocol v1
        -> one receiver thread
        -> complete latest-frame publication in fixed storage
        -> display-thread tryLock adoption
        -> local monotonic freshness
        -> accepted raster sink
        -> unchanged PushUsbDisplay
```

Accepted:

- exact 80-byte network-order protocol and 614,400-byte payload cap;
- HELLO / FRAME / CLEAR;
- private 32-byte capability-file authentication;
- producer session + receiver-local generation;
- strictly increasing sequence, legal gaps, exhaustion/reconnect behavior;
- fixed staging/publication/display arrays and one daemon receiver;
- no application frame FIFO;
- complete publication only after receive/auth/session/geometry/alpha validation;
- display `tryLock` only;
- exact semantic fallback for no producer, clear, disconnect, crash, stale, auth/protocol/session failure, malformed/truncated/oversized data, writer rejection, bind failure, and shutdown;
- 1/15/30/60 fps, supersession, reconnect, five blocked-receive shutdown states, active-listener collision, immediate same-port restart;
- production source/evidence, real Push controls/audio/display, and exact rollback.

Accepted source integration:

```text
kasselvania/DrivenByMoss: pushwig/main
commit: 7e3416a1bdddbcbeec4e35e6531652e1618723de
tree:   c8bc3f9e052e8f0b7b5dd256657697349d303740
```

Accepted central V1D-2 evidence:

```text
commit: 198b44a838009dac0df83464501004b6e6b59d9d
tree:   76d9f92ae8ec7369790b0b8dd325cd4a602e3dbb
```

## V2 — macOS dedicated-window visual lens — active

**Claim:** capture real pixels from dedicated top-level Bitwig windows through the unchanged accepted external ingress and show them usefully on Push.

Required source classes:

1. one floating/undocked Bitwig native-device Expanded Device View;
2. one already-installed ordinary plug-in editor.

Production helper source lives under:

```text
capture/macos/**
```

The helper uses ScreenCaptureKit, a stable macOS app identity, normal Screen Recording permission, logical window descriptors, normalized source-relative crops, bounded helper-local scaling, opaque BGRA output, and accepted V1D-2 protocol v1.

Acceptance requires:

- no DrivenByMoss change;
- unique-window selection by owner bundle id + exact title + source role;
- abstention on zero/multiple matches;
- same-display movement;
- resize smaller/larger with normalized crop recomputation;
- close -> semantic fallback;
- reopen/new windowID -> reacquire;
- occlusion behavior retained;
- cross-display move when two displays exist, otherwise explicit no-claim;
- Screen Recording denial -> semantic fallback, then same-build success after normal permission grant/relaunch;
- useful real native-device pixels on the actual Push;
- useful real plug-in pixels on the actual Push;
- no accidental whole-desktop/wrong-window capture;
- bounded 15/30 fps capture/processing; 60 fps optional;
- normal Push controls/audio and helper/Bitwig shutdown;
- exact official DrivenByMoss rollback.

V2 does not solve embedded Bitwig panels, pixel anchors, public adapter SDK, or Linux capture.

See [`V2_MACOS_DEDICATED_WINDOW_LENS.md`](V2_MACOS_DEDICATED_WINDOW_LENS.md).

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