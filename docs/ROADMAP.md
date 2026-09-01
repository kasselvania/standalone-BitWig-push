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

Accepted source integration:

```text
kasselvania/DrivenByMoss: pushwig/main
commit: 852b520933eed87fbe496a04b5c18819a10b3564
tree:   d03a372e2efcf41b22cef46501e08efbfb0c0036
```

### V1D-0 — bulk raster composition decision

Selected Candidate A:

```text
current semantic redraw
        -> validate complete opaque BGRA8888 region
        -> absolute bulk row copies, or no write
        -> same logical bitmap
        -> unchanged PushUsbDisplay
```

Accepted evidence includes:

- writable/direct/tightly packed real Bitwig bitmap memory;
- top-left BGRA byte layout and opaque alpha;
- cached destination-view coherence across 1,920 sends;
- 1,000 cycles / 9,000 transitions;
- zero source-target, outside, restoration, semantic-only, semantic-update, and partial-invalid-write mismatches;
- 25 fail-closed malformed classes;
- green full-frame combined timing;
- all 34 real fixture rows;
- exact official rollback.

Accepted central evidence:

```text
commit: 63dc42ba28356a30bdbd1f54c804c91f49a659c0
tree:   1184afeb7c00ee86a1c298df539d3267475ce6b3
```

## V1D-1 — production local raster composition — active

**Claim:** implement the selected bulk writer as production source and exercise it through a bounded locally generated raster lifecycle.

Production envelope:

```text
BitmapImpl.java
Push2Display.java
DynamicLocalRasterPushFramePipeline.java
IRasterWritableBitmap.java
RasterPixelFormat.java
```

First sink contract:

```text
carrier:      caller-owned byte[]
format:       OPAQUE_BGRA8888
source:       already cropped and scaled
metadata:     source offset/stride + destination x/y/width/height
application:  synchronous absolute bulk row writes
result:       complete write or zero write
```

Acceptance requires:

- adapter-owned private cached destination view;
- complete pre-write geometry/overflow/source/alpha/thread validation;
- zero partial writes for every rejected request;
- SMALL, ODD_PADDED, MEDIUM, FULL, REPLACEMENT, NONE, STALE, INVALID, and MALFORMED states;
- exact V1C restoration and semantic-only fallback;
- default, V1B, V1C, V1D-1, and all-property precedence regressions;
- preservation of `BitmapImpl(Bitmap)` / `bitmap()` and observable record behavior if the record becomes a class;
- exact source/build/bytecode/payload proof;
- explicit remeasurement of V1D-0 tail outliers;
- full real Push acceptance and exact rollback.

No external producer or capture API enters V1D-1.

## V1D-2 — external latest-frame ingress

Add an optional producer boundary with explicit frame metadata, sequence, timestamp, validity, stale reason, confidence, and bytes. Use latest-frame-wins storage, no unbounded queue, nonblocking consumer behavior, exact semantic fallback on absence/crash/staleness/malformed input, and full-path remeasurement. No capture API yet.

## V2 — macOS dedicated-window visual lens

Use a normal macOS helper to discover and capture one floating Bitwig native-device view and one ordinary plug-in editor. Preserve window identity through move/resize/monitor changes, use source-relative crops, recover from close/reopen and permission denial, and keep Apple types inside the helper.

## V2A — semantic-seeded pixel-anchor benchmark

Benchmark normalized grayscale, correlation, edge-map, coarse-to-fine, and only then feature-based methods. Require strong negatives, multiple consistent anchors, zero wrong locks in the retained matrix, abstention on ambiguity, and explicit acquisition/validation/CPU/memory metrics.

## V2P — Linux/Steam Deck checkpoint

Reproduce Push control/audio/display, V1C restoration, raster sink, external-frame contract, and one useful visual source on Linux. Characterize Flatpak/host IPC, capture backend behavior, CPU, and power without redesigning Mac-neutral contracts.

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
