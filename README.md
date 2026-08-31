# Standalone Bitwig Push

An open-source effort to make **Ableton Push 3 Controller** a substantially richer controller for **Bitwig Studio**, and to carry that same software into optional portable and native-compute appliances.

The primary software question is broader than one computer or one all-in-one build:

> Can DrivenByMoss semantic control be combined with useful live Bitwig/native-device/plug-in visuals in a way that adapts to different computers, monitor layouts, window sizes, display profiles, and operating systems?

That adaptive visual/controller layer is the main open-source product. The all-in-one appliance and Intel NUC connector work are parallel projects that build on it.

> **Status:** S0, V1A-0, V1A, and V1B are accepted and merged. The active slice is **V1C-0: dynamic raster replacement and exact restoration feasibility**—selecting the lawful frame-ownership strategy that lets visuals move, change, disappear, or become stale without leaving pixels behind or erasing newer DrivenByMoss semantics.

## Three independent project tracks

### Track V — universal visual/controller integration

Build a host-agnostic visual extension around DrivenByMoss:

```text
Bitwig semantic state ------> controller integration ----+
                                                       |
Bitwig / plug-in visuals ---> adaptive visual source ----+--> compositor --> Push display
                                                       |
optional direct sources ----> analyzer/adapter frames ---+
```

The software should be useful to ordinary Push/Bitwig users on their existing computers. It must not depend on Steam Deck hardware or one fixed virtual desktop.

The visual system has two deployment modes:

- **attached mode:** adapt to the user's existing Bitwig windows and monitor layout;
- **managed mode:** use controlled geometry for a headless appliance or reproducible test environment.

See [`docs/VISUAL_PORTABILITY.md`](docs/VISUAL_PORTABILITY.md) and [`docs/VISUAL_RESEARCH_BASIS.md`](docs/VISUAL_RESEARCH_BASIS.md).

### Track A — all-in-one appliance

Package the proven software as a portable, headless instrument.

The maintainer's first appliance can use hardware already available:

- Steam Deck as the first appliance computer;
- existing angled wooden base;
- existing protected battery;
- tested USB-C PD-to-barrel power cable;
- Push's stock rear USB connection;
- wireless access to the full Bitwig desktop.

The Steam Deck is an appliance implementation for the maintainer, not a requirement for Track V. A Framework mainboard or another x86 computer can later replace it without changing the controller/visual contracts.

### Track H — connector and native-compute research

Investigate Push's CM11EB/Intel NUC Compute Element carrier as its own open-hardware effort:

- measure and document the bay and carrier;
- design a safe diagnostic edge card;
- map internal USB/mux/sideband behavior;
- use an external host as a development workstation;
- evaluate used Compute Elements only after the interface is understood;
- integrate battery, power, and thermals for a native-bay final form.

A useful connector development board is a valid project result even before a final NUC conversion exists.

See [`docs/PROJECT_TRACKS.md`](docs/PROJECT_TRACKS.md).

## Why the visual work matters by itself

DrivenByMoss already provides deep semantic control, but controller APIs do not expose every waveform, modulation graph, native-device visualization, or arbitrary plug-in editor.

The project should use the strongest source available:

- semantic rendering for control state and compact labels;
- dedicated plug-in/native-device windows when available;
- adaptive capture of embedded Bitwig panels where necessary;
- direct frames from analyzers or companion tools where possible;
- semantic-only fallback when no valid visual source exists.

The goal is not to shrink the entire desktop onto a 960×160 display. It is to show the right visual information at the right moment while Push controls remain authoritative.

## Mac-first development, portable architecture

The currently available Mac can carry the project through the most important early software work:

```text
trace the existing semantic renderer                 proven
        -> establish fork/build/install baseline     proven
        -> insert a no-op frame pipeline              proven
        -> mix bounded static project pixels          proven
        -> select dynamic restoration ownership      active
        -> implement dynamic local composition
        -> accept an external generated frame
        -> capture a real Bitwig/editor window
        -> benchmark semantic-seeded anchors
```

The accepted controller-extension integration branch is:

```text
kasselvania/DrivenByMoss: pushwig/main
commit: 1ae0b74f383314d170a5960ca763bdf9c319e787
tree:   a81e5c4330b31f36845c25e98e322990d62f0c67
```

The accepted path is now:

```text
persistent semantic IBitmap
        -> project-owned PushFramePipeline
        -> optional startup-scoped static diagnostic layer
        -> exact same IBitmap reference
        -> unchanged PushUsbDisplay
```

V1B proved that a second bounded render callback can paint one fixed two-color mark with zero outside-region changes. It also proved default-off behavior, representative semantic updates, bounded cost, recovery after restart, and exact official rollback.

That is not yet a complete dynamic compositor. DrivenByMoss reuses a persistent bitmap and redraws semantic content only when its `ModelInfo` changes. If a future visual moves from region A to B—or disappears because a helper closes—simply drawing B or stopping drawing does not necessarily restore A.

V1C-0 therefore selects one exact restoration model before the project introduces IPC:

1. redraw the retained current semantic model before each dynamic layer;
2. preserve a pristine semantic bitmap and rebuild one reusable final bitmap;
3. use a generation-aware region restore; or
4. use a narrow backend copy primitive if higher-level paths fail.

See [`docs/V1C0_DYNAMIC_RASTER_COMPOSITION.md`](docs/V1C0_DYNAMIC_RASTER_COMPOSITION.md), [`docs/V1B_SYNTHETIC_COMPOSITION.md`](docs/V1B_SYNTHETIC_COMPOSITION.md), and [`docs/DRIVENBYMOSS_DERIVATIVE_STRATEGY.md`](docs/DRIVENBYMOSS_DERIVATIVE_STRATEGY.md).

## Visual portability strategy

The project must not identify a visual source by hard-coded physical desktop coordinates.

The preferred acquisition order is:

1. discover and capture a dedicated top-level plug-in or floating native-device window;
2. resolve an embedded Bitwig region from semantic state, application-window geometry, panel state, normalized coordinates, and visual anchors;
3. use bounded one-time calibration when automatic resolution cannot be proven;
4. accept direct project-owned frames from analyzers or companion integrations.

One promising implementation is a **semantic-seeded pixel anchor resolver**: DrivenByMoss supplies the selected device and expected visual role, then a lightweight multi-anchor matcher searches only plausible Bitwig windows/regions, solves translation/scale, validates confidence, and locks the visual crop. This turns generic screen recognition into a bounded registration problem and can be benchmarked explicitly for wrong-lock rate, acquisition latency, and CPU cost.

See [`docs/SEMANTIC_PIXEL_ANCHOR_RESOLVER.md`](docs/SEMANTIC_PIXEL_ANCHOR_RESOLVER.md).

Cross-platform capture backends remain behind a platform-neutral frame contract. macOS is the first implementation fixture because it is currently available; Linux and later Windows backends remain explicit portability targets.

## Accepted milestones

### S0 — fixture and display seam

Retained under `evidence/s0-macos-reference-fixture/`.

It proved the accepted Mac + Bitwig + Push baseline, cryptographically pinned official DrivenByMoss 26.4.1, traced the complete semantic-renderer-to-USB path, and located the lawful cut inside `Push2Display.send(IBitmap)`.

### V1A-0 — derivative custody and build baseline

Retained under `evidence/v1a0-drivenbymoss-build-baseline/`.

It proved the true fork, immutable upstream basis, explicit Java 21/Maven build, bounded local-vs-official artifact comparison, reversible installation, real-device parity, and exact official rollback.

### V1A — identity frame pipeline

Retained under `evidence/v1a-identity-frame-pipeline/`.

It proved the exact reference-preserving synchronous frame boundary, bounded the executable delta to three classes, kept `PushUsbDisplay.class` byte-identical, passed all eleven real Push checks, produced no visual difference, shut down normally, and restored the exact official artifact.

### V1B — startup-scoped static synthetic overlay

Retained under `evidence/v1b-static-synthetic-overlay/`.

It proved:

- default startup still selects the pass-through path;
- startup diagnostic activation selects one reusable synthetic pipeline;
- the exact same bitmap receives one fixed pink/white mark;
- 1,529 target pixels changed and all 152,064 outside pixels remained identical;
- repeated sends and Track, Device Parameters, Session, and Browser updates remained coherent;
- property-off restart removed the mark;
- enabled p95/max processing cost was 54.542 µs / 194 µs;
- the full real Push baseline and exact rollback passed.

## Current research slice

V1C-0 asks:

> What is the smallest exact mechanism that rebuilds output from the current semantic frame plus the current optional visual, rather than mutating historical output and hoping old pixels disappear?

The required conceptual contract is:

```text
output = compose(currentSemanticFrame, optionalCurrentVisual)
```

The rejected conceptual contract is:

```text
output = mutate(previousOutput, maybeNewVisual)
```

V1C-0 uses temporary, unmerged prototypes and produces a central evidence/decision PR only. It must prove moving, replacement, absence, stale fallback, and a semantic update underneath a previously covered region. The selected candidate must have zero unexplained restoration and outside-region mismatches, bounded cost, one USB writer, and a precise next production seam.

External generated-frame ingress is now **V1D**, after the local dynamic lifecycle is proven in V1C.

See [`CURRENT_SLICE.md`](CURRENT_SLICE.md).

## Valid stopping points

Each of these is a successful deliverable:

1. adaptive Bitwig/native-device/plug-in visuals mixed with DrivenByMoss for ordinary desktop users;
2. a portable Steam Deck/reference-host appliance using the existing stand and battery;
3. a reproducible Framework/compact-x86 appliance profile;
4. an open CM11EB diagnostic/development board;
5. a used NUC Compute Element native-bay instrument.

Later integrations are larger achievements, not retroactive requirements for earlier ones.

## Runtime and optional integrations

The active Mac is the first software-development fixture. The Steam Deck Flatpak remains a later Linux and appliance fixture.

- Native plug-ins and Bitwig native devices provide useful visual test sources on the Mac.
- Native Linux CLAP/VST3 compatibility remains relevant to the later Deck/Linux port.
- yabridge/Wine is optional compatibility research and already has known usability/UI problems in the maintainer's Deck experiments.
- Monome/serialosc and plugdata/Pure Data are independent maintainer projects that may later provide optional visual sources; they are not core dependencies or roadmap gates.

See [`docs/RUNTIME_STRATEGY.md`](docs/RUNTIME_STRATEGY.md).

## Start here

1. [`AGENTS.md`](AGENTS.md)
2. [`CURRENT_SLICE.md`](CURRENT_SLICE.md)
3. [`docs/PROJECT_TRACKS.md`](docs/PROJECT_TRACKS.md)
4. [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md)
5. [`docs/MAC_FIRST_DEVELOPMENT.md`](docs/MAC_FIRST_DEVELOPMENT.md)
6. [`docs/DRIVENBYMOSS_DERIVATIVE_STRATEGY.md`](docs/DRIVENBYMOSS_DERIVATIVE_STRATEGY.md)
7. [`docs/V1C0_DYNAMIC_RASTER_COMPOSITION.md`](docs/V1C0_DYNAMIC_RASTER_COMPOSITION.md)
8. [`docs/V1B_SYNTHETIC_COMPOSITION.md`](docs/V1B_SYNTHETIC_COMPOSITION.md)
9. [`docs/VISUAL_PORTABILITY.md`](docs/VISUAL_PORTABILITY.md)
10. [`docs/SEMANTIC_PIXEL_ANCHOR_RESOLVER.md`](docs/SEMANTIC_PIXEL_ANCHOR_RESOLVER.md)
11. [`docs/VISUAL_RESEARCH_BASIS.md`](docs/VISUAL_RESEARCH_BASIS.md)
12. [`docs/ROADMAP.md`](docs/ROADMAP.md)
13. [`docs/RUNTIME_STRATEGY.md`](docs/RUNTIME_STRATEGY.md)
14. [`docs/HARDWARE_DOSSIER.md`](docs/HARDWARE_DOSSIER.md)
15. [`CONTRIBUTING.md`](CONTRIBUTING.md)

## Upstream work

The project expects to build on and collaborate with:

- **DrivenByMoss** for Push/Bitwig semantic control;
- Bitwig's open controller extension API;
- platform capture APIs and open capture implementations;
- open Push 3 display/protocol research;
- Push standalone and CM11EB reverse-engineering work.

Optional external integrations retain their own project boundaries and licenses.

## Safety and legal notes

Hardware modification can damage equipment and create electrical, thermal, or battery hazards. Hardware and power claims require measurements rather than inference.

Do not commit or redistribute proprietary Ableton/Bitwig binaries, activation data, firmware, or private assets without redistribution rights.

This project is independent and is **not affiliated with or endorsed by Ableton AG, Bitwig GmbH, Intel, Apple, Valve, Framework Computer, or the DrivenByMoss project**.