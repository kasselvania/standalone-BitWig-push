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

Accepted exact protocol/security/session/sequence/freshness behavior, fixed storage, no application frame FIFO, complete publication, nonblocking display adoption, exact semantic fallback, 1/15/30/60 fps, supersession, reconnect, five blocked-receive shutdown states, collision/restart, production source/evidence, real Push controls/audio/display, and exact rollback.

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

## V2 strategy correction

The original dedicated-window hypothesis did not hold on the accepted Bitwig/macOS fixture: native-device and plug-in editor surfaces were not exposed as useful independently capturable ScreenCaptureKit windows.

The branch:

```text
capture/v2-macos-dedicated-window-lens
f5bd7fd990ee74956aa1168ba8b747f0f63286ab
```

is quarantined, has no PR, and is not accepted source.

A temporary override proved that an explicit `SCDisplay` plus a bounded normalized crop of the Bitwig main-window device-chain region can deliver real Sampler pixels to Push through unchanged V1D-2. The proof sent 7,192 frames at a requested 30 fps and returned cleanly to semantics, but the rough mapping visibly distorted the image.

That result selects the next production tactic without completing V2.

## V2 — macOS display-crop visual lens — active

**Claim:** implement a normal macOS helper that captures one explicit display-relative crop containing the Bitwig device-chain region, maps it without distortion, and publishes useful live Sampler pixels through unchanged V1D-2.

Production helper source lives under:

```text
capture/macos/**
```

Required authority:

```text
exact SCDisplay id
+ expected display dimensions
+ bounded normalized crop
+ declared Push destination
+ bounded Bitwig source-validity guard
+ explicit aspect-preserving mapping
```

Acceptance requires:

- no DrivenByMoss change;
- no reuse of the quarantined branch as implementation basis;
- stable `.app`/TCC identity;
- normal Screen Recording permission and semantic fallback;
- explicit display inventory and selection, never implicit first-display choice;
- source crop validated against selected display dimensions;
- a public-API Bitwig active-context guard;
- no full-display transmission;
- one explicit uniform aspect mapping with no visible distortion;
- opaque BGRA output through accepted protocol v1;
- useful live Sampler/device-chain pixels on the actual Push;
- meaningful captured content change while the fixture remains stable;
- CLEAR/semantic fallback on invalid permission, display, crop, guard, helper loss, or Bitwig quit;
- bounded 15/30 fps processing and memory; 60 fps optional;
- normal Push controls, audio, headphones, helper/Bitwig shutdown;
- exact official DrivenByMoss rollback.

V2 is a fixture proof. It does not claim automatic response to Bitwig window movement, resize, panel rearrangement, UI scaling, or cross-display migration.

It does not require a dedicated native-device window or plug-in editor and makes no VST/VST3/CLAP identity claim.

See [`V2_MACOS_DISPLAY_CROP_LENS.md`](V2_MACOS_DISPLAY_CROP_LENS.md).

## V2A — semantic-seeded pixel-anchor benchmark

Use the accepted display-crop path as the source image plane, then benchmark normalized grayscale, correlation, edge-map, coarse-to-fine, and only then feature-based methods.

Require DrivenByMoss selected-device semantics as the search seed, strong positive and negative fixture states, multiple geometrically consistent anchors, zero wrong locks in the retained matrix, abstention on ambiguity, and explicit acquisition, validation, CPU, memory, and relock metrics.

V2A does not yet become the production resolver.

## V2P — Linux/Steam Deck checkpoint

Reproduce Push control/audio/display, current-semantic restoration, raster sink, external-frame contract, and one useful visual source on Linux.

The first Linux source may use managed geometry or an explicit crop; it must not redesign Mac-neutral contracts.

Characterize Flatpak/host IPC, capture backend behavior, CPU, power, and semantic fallback.

## V3–V7 — public portability

- **V3:** public visual-source and adapter SDK.
- **V4:** adaptive embedded Bitwig-panel resolver using semantic/layout state, confidence-validated anchors, and bounded abstention.
- **V5:** bounded calibration and portable local descriptors.
- **V6:** attached-mode release across a defined Mac/Linux/layout matrix.
- **V7:** an additional OS backend without compositor or adapter redesign.

Dedicated-window/VST identity may return as a separate acquisition research item if a host exposes those surfaces lawfully. It is not assumed.

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
