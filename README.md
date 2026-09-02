# Standalone Bitwig Push

An open-source effort to make **Ableton Push 3 Controller** a substantially richer controller for **Bitwig Studio**, then carry the same software into optional portable and native-compute appliances.

The primary software product is Track V: combine DrivenByMoss semantic control with useful live Bitwig/native-device/plug-in visuals while preserving exact semantic fallback and one Push display owner.

> **Status:** S0, V1A-0, V1A, V1B, V1C-0, V1C, V1D-0, V1D-1, V1D-2-0, and V1D-2 are accepted. The active slice is **V2 — macOS display-crop visual lens**: the first production ScreenCaptureKit source for real Bitwig pixels.

## Three independent tracks

### Track V — universal visual/controller integration

```text
Bitwig semantic state ------> DrivenByMoss derivative ----+
                                                          |
Bitwig / plug-in visuals ---> adaptive visual source ------+--> Push display
                                                          |
optional direct sources ----> generated/analyzer frames ---+
```

Track V should ultimately work for ordinary Push/Bitwig users on existing computers.

- **Attached mode** adapts to existing windows and monitor layouts.
- **Managed mode** may use controlled geometry for an appliance/test fixture.
- Earlier fixture proofs are valid milestones when their limitations are explicit.

### Track A — all-in-one appliance

Package accepted Track V software with a portable host, battery, boot/recovery services, and wireless desktop management. The maintainer's Steam Deck/base/battery setup is the first appliance fixture, not the product definition.

### Track H — connector/native compute

Investigate Push's CM11EB/Intel NUC Compute Element carrier, publish safe development hardware, and eventually evaluate a native-bay compute installation.

Track A and Track H consume Track V; they do not block it.

## Accepted visual foundation

### Semantic seam and derivative custody

S0 and V1A established the real Mac/Bitwig/Push fixture, exact DrivenByMoss source/artifact provenance, a reversible derivative workflow, and one project-owned frame pipeline above the unchanged Push USB transport.

### Dynamic restoration

V1B and V1C proved that project-owned visuals can be composed onto the persistent Push bitmap while restoring the **newest current semantic frame** after movement, replacement, absence, staleness, invalidity, overlay/notification changes, or failure.

```text
newest retained semantic model
        -> complete semantic redraw
        -> current optional visual
        -> same persistent IBitmap
        -> unchanged PushUsbDisplay
```

Historical composed pixels are never restoration authority.

### Production raster sink

V1D-0 and V1D-1 selected and implemented a host-neutral opaque-BGRA bulk raster writer:

```text
current semantic redraw
        -> complete raster validation
        -> absolute bulk row copies, or zero write
        -> same logical IBitmap
        -> unchanged PushUsbDisplay
```

The Bitwig adapter owns its private destination-memory view. Rejected geometry, stride, alpha, target layout, or thread ownership changes no destination bytes.

### Production external latest-frame ingress

V1D-2-0 and V1D-2 selected and implemented the external producer boundary:

```text
external producer
        -> capability-authenticated TCP 127.0.0.1 protocol v1
        -> one receiver thread
        -> fixed complete latest-frame publication
        -> nonblocking display adoption
        -> accepted raster writer
        -> one unchanged Push USB writer
```

Accepted implementation:

```text
repository: kasselvania/DrivenByMoss
branch:     pushwig/main
commit:     7e3416a1bdddbcbeec4e35e6531652e1618723de
tree:       c8bc3f9e052e8f0b7b5dd256657697349d303740
```

Accepted V1D-2 evidence:

```text
commit: 198b44a838009dac0df83464501004b6e6b59d9d
tree:   76d9f92ae8ec7369790b0b8dd325cd4a602e3dbb
```

The boundary has explicit authentication, session, sequence, freshness, complete-message, fixed-memory, latest-frame-wins, malformed-input, disconnect/crash, shutdown, and exact semantic-fallback behavior.

## Active V2 work — real macOS display-crop pixels

The original V2 plan assumed Bitwig native-device and plug-in editors would be available as independently capturable ScreenCaptureKit windows. On the accepted fixture, that assumption did not hold.

The incomplete branch:

```text
capture/v2-macos-dedicated-window-lens
f5bd7fd990ee74956aa1168ba8b747f0f63286ab
```

is quarantined and has no PR.

A temporary override proved the viable path:

```text
explicit SCDisplay
        -> bounded normalized crop of the Bitwig main-window device chain
        -> opaque BGRA
        -> accepted V1D-2 ingress
        -> real Sampler pixels on Push
```

The temporary helper sent 7,192 real frames at a requested 30 fps, produced one CLEAR on exit, retained responsive controls/audio, and restored ordinary semantics cleanly. Its rough mapping visibly distorted the image, so it selected the tactic but did not complete V2.

Production V2 now requires:

- a stable signed/ad-hoc macOS helper app identity;
- exact explicit `SCDisplay` selection and expected dimensions;
- a bounded normalized display-relative crop;
- a public-API Bitwig source-validity guard;
- one explicit aspect-preserving mapping with no visible stretch;
- opaque BGRA output through unchanged V1D-2;
- live Sampler/device-chain pixels on the real Push;
- permission/configuration/guard/helper-loss fallback to semantics;
- bounded 15/30 fps processing and memory;
- normal Push controls/audio;
- exact official DrivenByMoss rollback.

The V2 crop is fixture configuration, not universal device identity. Main-window movement, resize, panel rearrangement, UI-scale changes, cross-display migration, plug-in identity, and automatic localization remain later work.

See [`docs/V2_MACOS_DISPLAY_CROP_LENS.md`](docs/V2_MACOS_DISPLAY_CROP_LENS.md).

## Visual portability strategy

The current acquisition progression is:

1. explicit display crop as the first real-pixel fixture proof;
2. selected-device/layout-aware embedded Bitwig-panel prediction;
3. confidence-validated semantic-seeded pixel anchors;
4. bounded local calibration where necessary;
5. dedicated top-level sources when a host actually exposes them;
6. direct project-owned analyzer frames.

Wrong visual selection is worse than semantic fallback.

See [`docs/VISUAL_PORTABILITY.md`](docs/VISUAL_PORTABILITY.md) and [`docs/SEMANTIC_PIXEL_ANCHOR_RESOLVER.md`](docs/SEMANTIC_PIXEL_ANCHOR_RESOLVER.md).

## Current sequence

```text
S0        accepted fixture and display seam
V1A-0     accepted fork/build/install baseline
V1A       accepted identity pipeline
V1B       accepted static composition
V1C-0     accepted dynamic restoration architecture
V1C       accepted dynamic local lifecycle
V1D-0     accepted bulk raster decision
V1D-1     accepted production raster sink
V1D-2-0   accepted external-ingress architecture
V1D-2     accepted production external latest-frame ingress
V2        active macOS display-crop visual lens
V2A       semantic-seeded pixel-anchor benchmark
V2P       Linux/Steam Deck portability checkpoint
V3        public visual-source/adapter SDK
V4        adaptive embedded Bitwig-panel resolver
V5        bounded calibration/descriptors
V6        attached-mode release matrix
V7        additional OS backend
```

Dedicated-window/VST identity is deferred rather than treated as a V2 completion gate.

## Start here

1. [`AGENTS.md`](AGENTS.md)
2. [`CURRENT_SLICE.md`](CURRENT_SLICE.md)
3. [`docs/V2_MACOS_DISPLAY_CROP_LENS.md`](docs/V2_MACOS_DISPLAY_CROP_LENS.md)
4. [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md)
5. [`docs/VISUAL_PORTABILITY.md`](docs/VISUAL_PORTABILITY.md)
6. [`docs/ROADMAP.md`](docs/ROADMAP.md)

## Safety and legal notes

This project is independent and is **not affiliated with or endorsed by Ableton AG, Bitwig GmbH, Apple, Intel, Valve, Framework Computer, or the DrivenByMoss project**.

Do not redistribute proprietary Ableton/Bitwig binaries, firmware, activation data, or committed proprietary UI screenshot fixtures. Capture evidence should prefer hashes, geometry, metadata, and local-only inspection.
