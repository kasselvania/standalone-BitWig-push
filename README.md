# Standalone Bitwig Push

An open-source effort to make **Ableton Push 3 Controller** a substantially richer controller for **Bitwig Studio**, then carry the same software into optional portable and native-compute appliances.

The primary product question is broader than one computer:

> Can DrivenByMoss semantic control be combined with useful live Bitwig/native-device/plug-in visuals in a way that adapts to different hosts, windows, monitor layouts, display profiles, and operating systems?

That adaptive visual/controller layer is Track V, the main open-source software product. The all-in-one appliance and Intel NUC connector work remain separate parallel tracks that consume it.

> **Status:** S0, V1A-0, V1A, V1B, V1C-0, V1C, V1D-0, V1D-1, and V1D-2-0 are accepted. The active slice is **V1D-2: production external latest-frame ingress**—implementing the selected capability-authenticated loopback protocol, fixed latest-frame handoff, nonblocking display adoption, and exact failure fallback before any window-capture code begins.

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

Package accepted Track V software as a portable headless instrument. The maintainer's first appliance can use the Steam Deck, existing angled wooden base, protected battery, tested USB-C PD-to-barrel cable, Push's ordinary rear USB connection, and wireless access to the full Bitwig desktop. A Framework mainboard or other x86 host can later replace the Deck without changing the visual contracts.

### Track H — connector and native compute

Investigate Push's CM11EB/Intel NUC Compute Element carrier as an independent open-hardware effort: measure the carrier and cavity, create a safe diagnostic edge card, map USB/mux/power/sideband behavior, and evaluate used Compute Elements only after the interface is understood. A useful connector development board is a valid result even without a completed native-bay conversion.

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

### S0 through V1B

The Mac + Bitwig 6.1 + Push 3 fixture, official DrivenByMoss 26.4.1 source/artifact provenance, derivative build/install/rollback, the project-owned frame seam, and the first bounded static project pixels are accepted.

### V1C — exact dynamic restoration

```text
newest retained semantic model
        -> complete semantic redraw
        -> current optional visual
        -> same persistent bitmap
        -> unchanged PushUsbDisplay
```

V1C proved movement, overlap, resize, replacement, absence/stale/invalid fallback, semantic updates under coverage, overlay-only updates, notification lifecycle, one persistent bitmap, one USB writer, real Push controls/audio/display, and exact rollback.

### V1D-1 — production raster sink

```text
current semantic redraw
        -> validate complete OPAQUE_BGRA8888 request
        -> validate copied alpha and display-thread ownership
        -> absolute bulk row copies, or no write
        -> same logical IBitmap
        -> unchanged PushUsbDisplay
```

The host-neutral sink accepts caller-owned bytes plus source offset/stride and destination geometry. `BitmapImpl` alone owns the private cached Bitwig memory view and all target-layout checks.

V1D-1 proved fail-closed unsupported destinations, race-safe thread binding, padded-stride and full-frame writes, all malformed/semantic fallback states, zero pixel/restoration/partial-write mismatches, zero project-owned per-application allocation, prior-path regressions, full physical Push behavior, and exact official rollback.

Accepted implementation:

```text
repository: kasselvania/DrivenByMoss
branch:     pushwig/main
commit:     663d719207ef58ec84b4d235c43211ec5da43605
tree:       c4e42825d069421a44b3241349de9a7c6453a3ad
```

Accepted V1D-1 evidence:

```text
commit: a02c9c772da38bfdbc89dfff751c9617cd397c02
tree:   62b4edce8d649266cda65a638d26113692eaef04
```

### V1D-2-0 — external ingress decision

V1D-2-0 selected Candidate A:

```text
external generated producer
        -> capability-authenticated TCP 127.0.0.1 protocol v1
        -> complete-message receive in one receiver thread
        -> fixed latest-publication storage
        -> display-thread tryLock adoption into fixed consumer bytes
        -> local monotonic freshness
        -> accepted V1D-1 sink
        -> unchanged PushUsbDisplay
```

The selected protocol uses a fixed 80-byte big-endian header, HELLO/FRAME/CLEAR messages, a 32-byte capability, nonzero producer session identity, positive strictly increasing sequence, and a 614,400-byte payload cap. Application memory is fixed; no application frame queue exists.

The research proof retained more than 1,000 accepted publications, positive supersession/gap/session/failure counts, zero source-target/outside/restoration/semantic-only/old-session/torn-frame/consumer-mutation mismatches, 1/15/30/60 fps and burst behavior, all five blocked-receive shutdown states, immediate same-port restart, full Push controls/audio/display behavior, and exact rollback.

Accepted V1D-2-0 evidence:

```text
commit: 99e09e2a651c92ac6710fdc88c4675a874a56600
tree:   db22ec0a845146f03861581a929ae52b30204a1b
```

See [`docs/V1D20_EXTERNAL_FRAME_INGRESS.md`](docs/V1D20_EXTERNAL_FRAME_INGRESS.md).

## Active V1D-2 work

V1D-2 now implements that architecture as production DrivenByMoss source.

Construction-time properties select a loopback-only receiver, fixed/configurable port, private token-file path, and stale timeout. The launcher/orchestrator owns token-file creation and cleanup; the extension validates and loads it without exposing the token. External mode has precedence over local diagnostics and keeps current-semantic redraw active.

The production source is limited to:

```text
Push2Display.java
ExternalRasterPushFramePipeline.java
ExternalRasterReceiver.java
LatestExternalRasterFrameStore.java
```

The receiver never touches the bitmap. The display thread never touches the socket. Complete accepted frames replace one latest publication; the display nonblockingly adopts into its own fixed bytes and calls the accepted V1D-1 sink. Clear, disconnect, crash, stale timeout, protocol/authentication failure, truncation, malformed/oversized input, writer rejection, bind failure, and shutdown all produce exact current semantics.

See [`docs/V1D2_EXTERNAL_FRAME_INGRESS.md`](docs/V1D2_EXTERNAL_FRAME_INGRESS.md).

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
S0        accepted fixture and display seam
V1A-0     accepted fork/build/install baseline
V1A       accepted identity pipeline
V1B       accepted static bounded composition
V1C-0     accepted dynamic restoration architecture
V1C       accepted production dynamic local lifecycle
V1D-0     accepted bulk raster primitive
V1D-1     accepted production local raster sink
V1D-2-0   accepted external ingress architecture
V1D-2     active production external latest-frame ingress
V2        macOS dedicated-window capture
V2A       semantic-seeded anchor benchmark
V2P       Linux/Steam Deck portability checkpoint
```

Each step is independently reviewable. Capture does not get to paper over unresolved transport, handoff, session, or freshness behavior.

## Valid stopping points

Each is a successful project result:

1. adaptive Bitwig/native-device/plug-in visuals mixed with DrivenByMoss for desktop users;
2. a portable Steam Deck appliance using the existing stand and battery;
3. a reproducible Framework/compact-x86 appliance;
4. an open CM11EB diagnostic/development board;
5. a used Compute Element native-bay instrument.

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
7. [`docs/V1D2_EXTERNAL_FRAME_INGRESS.md`](docs/V1D2_EXTERNAL_FRAME_INGRESS.md)
8. [`docs/V1D20_EXTERNAL_FRAME_INGRESS.md`](docs/V1D20_EXTERNAL_FRAME_INGRESS.md)
9. [`docs/V1D1_LOCAL_RASTER_COMPOSITION.md`](docs/V1D1_LOCAL_RASTER_COMPOSITION.md)
10. [`docs/VISUAL_PORTABILITY.md`](docs/VISUAL_PORTABILITY.md)
11. [`docs/SEMANTIC_PIXEL_ANCHOR_RESOLVER.md`](docs/SEMANTIC_PIXEL_ANCHOR_RESOLVER.md)
12. [`docs/ROADMAP.md`](docs/ROADMAP.md)
13. [`docs/RUNTIME_STRATEGY.md`](docs/RUNTIME_STRATEGY.md)
14. [`docs/HARDWARE_DOSSIER.md`](docs/HARDWARE_DOSSIER.md)
15. [`CONTRIBUTING.md`](CONTRIBUTING.md)

## Safety and legal notes

Hardware modification can damage equipment and create electrical, thermal, or battery hazards. Hardware and power claims require measurements rather than inference.

This project is independent and is **not affiliated with or endorsed by Ableton AG, Bitwig GmbH, Intel, Apple, Valve, Framework Computer, or the DrivenByMoss project**.
