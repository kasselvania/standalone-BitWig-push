# Standalone Bitwig Push

An open-source effort to make **Ableton Push 3 Controller** a substantially richer controller for **Bitwig Studio**, then carry the same software into optional portable and native-compute appliances.

The primary product question is broader than one computer:

> Can DrivenByMoss semantic control be combined with useful live Bitwig/native-device/plug-in visuals in a way that adapts to different hosts, windows, monitor layouts, display profiles, and operating systems?

That adaptive visual/controller layer is Track V, the main open-source software product. The all-in-one appliance and Intel NUC connector work remain separate parallel tracks that consume it.

> **Status:** S0, V1A-0, V1A, V1B, V1C-0, V1C, and V1D-0 are accepted. The active slice is **V1D-1: production local raster composition**—implementing the selected validated opaque-BGRA bulk writer and a bounded locally generated raster lifecycle before external-frame IPC begins.

## Three independent tracks

### Track V — universal visual/controller integration

```text
Bitwig semantic state ------> DrivenByMoss derivative ----+
                                                          |
Bitwig / plug-in visuals ---> adaptive visual source ------+--> compositor --> Push display
                                                          |
optional direct sources ----> analyzer/adapter frames -----+
```

The software should be useful to ordinary Push/Bitwig users on existing computers.

- **Attached mode** adapts to existing Bitwig windows and monitor layouts.
- **Managed mode** uses controlled geometry for a headless appliance or reproducible test fixture.

A managed virtual desktop is not imposed on attached-mode users.

### Track A — all-in-one appliance

Package accepted Track V software as a portable headless instrument.

The maintainer's first appliance can use:

- Steam Deck;
- existing angled wooden base;
- existing protected battery;
- tested USB-C PD-to-barrel power cable;
- Push's ordinary rear USB connection;
- wireless access to the full Bitwig desktop.

A Framework mainboard or other x86 host can later replace the Deck without changing the core visual contracts.

### Track H — connector and native-compute research

Investigate Push's CM11EB/Intel NUC Compute Element carrier as an independent open-hardware effort:

- survey and measure the carrier/cavity;
- design a safe diagnostic edge card;
- map USB, mux, power, and sideband behavior;
- use an external host as a development workstation;
- evaluate used Compute Elements only after the interface is understood;
- integrate battery, power, and thermals for a native-bay final form.

A useful connector development board is a valid result even without a completed NUC conversion.

See [`docs/PROJECT_TRACKS.md`](docs/PROJECT_TRACKS.md).

## Why the visual work matters by itself

DrivenByMoss already provides deep semantic control, but controller APIs do not expose every waveform, modulation graph, device visualization, or arbitrary plug-in editor.

The project should use the strongest available source:

- semantic rendering for control state and compact labels;
- dedicated native-device or plug-in windows when available;
- adaptive capture of embedded Bitwig panels where necessary;
- direct frames from analyzers or companion tools where possible;
- exact semantic-only fallback when no visual source is valid.

The goal is not to shrink an entire desktop onto a 960×160 strip. It is to display the useful visual fragment while keeping Push controls authoritative.

## Accepted visual foundation

### S0 — fixture and display seam

The Mac + Bitwig 6.1 + Push 3 fixture was accepted, official DrivenByMoss 26.4.1 was cryptographically tied to exact source, and the semantic-renderer-to-USB path was traced.

### V1A-0 — derivative custody/build baseline

The true fork, immutable source basis, Java 21/Maven build, reversible installation, hardware parity, and exact official rollback were accepted.

### V1A — identity frame pipeline

```text
complete semantic IBitmap
        -> project-owned frame pipeline
        -> same IBitmap
        -> unchanged PushUsbDisplay
```

### V1B — static bounded composition

A startup-gated fixed mark was painted into the existing bitmap with zero changes outside its bounds, bounded cost, real-device success, and exact rollback.

### V1C-0 and V1C — dynamic restoration and production lifecycle

V1C selected and implemented:

```text
newest retained semantic model
        -> complete semantic redraw
        -> current optional visual
        -> same persistent bitmap
        -> unchanged PushUsbDisplay
```

It proved movement, overlap, resize, replacement, semantic-only fallback, semantic updates under coverage, overlay-only updates, notification lifecycle, startup regressions, one persistent bitmap, one USB writer, real Push controls/audio/display, and exact rollback.

Accepted DrivenByMoss integration:

```text
repository: kasselvania/DrivenByMoss
branch:     pushwig/main
commit:     852b520933eed87fbe496a04b5c18819a10b3564
tree:       d03a372e2efcf41b22cef46501e08efbfb0c0036
```

### V1D-0 — bulk raster decision

V1D-0 selected a direct, adapter-owned writable bitmap-region capability.

Accepted result:

```text
current semantic redraw
        -> validate complete opaque BGRA8888 request
        -> absolute bulk row copies, or no write
        -> same logical IBitmap
        -> unchanged PushUsbDisplay
```

The accepted Mac/Bitwig bitmap was writable, direct, tightly packed, top-left-origin BGRA memory. A cached destination view remained coherent through encode and physical Push output across 1,920 sends.

The generated corpus included small, padded-stride, medium, full-frame, replacement, absent, stale, invalid, malformed, and under-coverage semantic-update states. All source-target, outside, restoration, semantic-only, and partial-invalid-write mismatch counts were zero. Twenty-five malformed classes rejected without mutation. All 34 real fixture rows and exact rollback passed.

Accepted central evidence:

```text
commit: 63dc42ba28356a30bdbd1f54c804c91f49a659c0
tree:   1184afeb7c00ee86a1c298df539d3267475ce6b3
```

See [`docs/V1D0_BULK_RASTER_COMPOSITION.md`](docs/V1D0_BULK_RASTER_COMPOSITION.md).

## Active V1D-1 work

V1D-1 turns the selected research primitive into a production source slice.

The first host-neutral sink is intentionally narrow:

```text
source carrier: caller-owned byte[]
format:         opaque BGRA8888
source:         already cropped and scaled
metadata:       source offset/stride + destination x/y/width/height
execution:      synchronous display/composition thread
result:         complete write or zero write
```

The Bitwig adapter alone owns the private cached destination memory view, target-layout validation, complete request validation, thread binding, and absolute bulk row copies.

The local proof lifecycle covers SMALL, ODD_PADDED, MEDIUM, FULL, REPLACEMENT, NONE, STALE, INVALID, and MALFORMED states. It preserves the accepted default, V1B static, and V1C vector paths. External producer ownership, latest-frame sequence/freshness, shared memory, and capture remain V1D-2 and V2 work.

See [`docs/V1D1_LOCAL_RASTER_COMPOSITION.md`](docs/V1D1_LOCAL_RASTER_COMPOSITION.md).

## Visual portability strategy

Visual sources must not be identified by hard-coded physical desktop coordinates.

Preferred acquisition order:

1. capture a dedicated top-level plug-in or floating native-device window;
2. resolve an embedded Bitwig region from semantic state, application-window geometry, normalized coordinates, and visual anchors;
3. use bounded one-time calibration where automatic resolution is not proven;
4. accept direct project-owned analyzer/companion frames.

A promising later approach is the **semantic-seeded pixel anchor resolver**: DrivenByMoss supplies device identity and expected visual role, while a lightweight multi-anchor matcher searches only plausible windows/regions, solves translation/scale, validates confidence, and abstains on ambiguity.

See [`docs/VISUAL_PORTABILITY.md`](docs/VISUAL_PORTABILITY.md) and [`docs/SEMANTIC_PIXEL_ANCHOR_RESOLVER.md`](docs/SEMANTIC_PIXEL_ANCHOR_RESOLVER.md).

## Current sequence

```text
S0      accepted fixture and display seam
V1A-0   accepted fork/build/install baseline
V1A     accepted identity pipeline
V1B     accepted static bounded composition
V1C-0   accepted dynamic restoration architecture
V1C     accepted production dynamic local lifecycle
V1D-0   accepted bulk raster primitive
V1D-1   active production local raster lifecycle
V1D-2   external latest-frame ingress
V2      macOS dedicated-window capture
V2A     semantic-seeded anchor benchmark
V2P     Linux/Steam Deck portability checkpoint
```

Each step is independently reviewable. External ingress does not get to paper over an unresolved raster sink, and capture does not get to paper over unresolved IPC/freshness behavior.

## Valid stopping points

Each is a successful project result:

1. adaptive Bitwig/native-device/plug-in visuals mixed with DrivenByMoss for desktop users;
2. a portable Steam Deck appliance using the existing stand and battery;
3. a reproducible Framework/compact-x86 appliance;
4. an open CM11EB diagnostic/development board;
5. a used NUC Compute Element native-bay instrument.

A later result is not required to validate an earlier one.

## Runtime and optional integrations

- macOS remains the current Track V development fixture.
- Steam Deck/Flatpak remains the first Linux portability and appliance fixture.
- Native Linux CLAP/VST3 matters to that later deployment.
- yabridge/Wine remains optional compatibility research with known Deck UI/usability problems.
- Monome/serialosc and plugdata/Pure Data remain independent projects that may later consume general visual interfaces.

## Start here

1. [`AGENTS.md`](AGENTS.md)
2. [`CURRENT_SLICE.md`](CURRENT_SLICE.md)
3. [`docs/PROJECT_TRACKS.md`](docs/PROJECT_TRACKS.md)
4. [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md)
5. [`docs/MAC_FIRST_DEVELOPMENT.md`](docs/MAC_FIRST_DEVELOPMENT.md)
6. [`docs/DRIVENBYMOSS_DERIVATIVE_STRATEGY.md`](docs/DRIVENBYMOSS_DERIVATIVE_STRATEGY.md)
7. [`docs/V1D1_LOCAL_RASTER_COMPOSITION.md`](docs/V1D1_LOCAL_RASTER_COMPOSITION.md)
8. [`docs/V1D0_BULK_RASTER_COMPOSITION.md`](docs/V1D0_BULK_RASTER_COMPOSITION.md)
9. [`docs/V1C_DYNAMIC_LOCAL_COMPOSITION.md`](docs/V1C_DYNAMIC_LOCAL_COMPOSITION.md)
10. [`docs/VISUAL_PORTABILITY.md`](docs/VISUAL_PORTABILITY.md)
11. [`docs/SEMANTIC_PIXEL_ANCHOR_RESOLVER.md`](docs/SEMANTIC_PIXEL_ANCHOR_RESOLVER.md)
12. [`docs/ROADMAP.md`](docs/ROADMAP.md)
13. [`docs/RUNTIME_STRATEGY.md`](docs/RUNTIME_STRATEGY.md)
14. [`docs/HARDWARE_DOSSIER.md`](docs/HARDWARE_DOSSIER.md)
15. [`CONTRIBUTING.md`](CONTRIBUTING.md)

## Safety and legal notes

Hardware modification can damage equipment and create electrical, thermal, or battery hazards. Hardware and power claims require measurements rather than inference.

This project is independent and is **not affiliated with or endorsed by Ableton AG, Bitwig GmbH, Intel, Apple, Valve, Framework Computer, or the DrivenByMoss project**.
