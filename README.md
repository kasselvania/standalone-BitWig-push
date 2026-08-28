# Standalone Bitwig Push

An open-source effort to make **Ableton Push 3 Controller** a substantially richer controller for **Bitwig Studio**, and to carry that same software into optional portable and native-compute appliances.

The primary software question is broader than one Steam Deck or one all-in-one build:

> Can DrivenByMoss semantic control be combined with useful live Bitwig/native-device/plug-in visuals in a way that adapts to different computers, monitor layouts, window sizes, display profiles, and operating systems?

That adaptive visual/controller layer is the main open-source product. The all-in-one appliance and Intel NUC connector work are parallel projects that build on it.

> **Status:** S0 external-baseline and display-path reconnaissance on the maintainer's Steam Deck reference fixture.

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

- Steam Deck as one development computer;
- existing angled wooden base;
- existing protected battery;
- tested USB-C PD-to-barrel power cable;
- Push's stock rear USB connection;
- wireless access to the full Bitwig desktop.

The Steam Deck is a reference implementation for the maintainer, not a project-wide requirement. A Framework mainboard or another x86 computer can later replace it without changing the controller/visual contracts.

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

## Visual portability strategy

The project must not identify a visual source by hard-coded physical desktop coordinates.

The preferred acquisition order is:

1. discover and capture a dedicated top-level plug-in or floating native-device window;
2. resolve an embedded Bitwig region from semantic state, application-window geometry, panel state, normalized coordinates, and visual anchors;
3. use bounded one-time calibration when automatic resolution cannot be proven;
4. accept direct project-owned frames from analyzers or companion integrations.

Cross-platform capture backends remain behind a platform-neutral frame contract. Linux is the first implementation target; Windows and macOS backends must remain architecturally possible.

## Valid stopping points

Each of these is a successful deliverable:

1. adaptive Bitwig/native-device/plug-in visuals mixed with DrivenByMoss for ordinary desktop users;
2. a portable Steam Deck/reference-host appliance using the existing stand and battery;
3. a reproducible Framework/compact-x86 appliance profile;
4. an open CM11EB diagnostic/development board;
5. a used NUC Compute Element native-bay instrument.

Later integrations are larger achievements, not retroactive requirements for earlier ones.

## Runtime and optional integrations

The current Steam Deck Flatpak is only the maintainer's first software fixture.

- Native Linux CLAP/VST3 compatibility is useful for testing visual editors.
- yabridge/Wine is optional compatibility research and already has known usability/UI problems in the maintainer's Deck experiments.
- Monome/serialosc and plugdata/Pure Data are independent maintainer projects that may later provide optional visual sources; they are not core dependencies or roadmap gates.

See [`docs/RUNTIME_STRATEGY.md`](docs/RUNTIME_STRATEGY.md).

## Current first slice

S0 records the maintainer's real Steam Deck + Bitwig + DrivenByMoss + Push baseline and traces the existing semantic-display path to its USB sender.

The Steam Deck is being used because it is available and already works—not because the project is defined around it.

The S0 handoff should identify the narrow seam required for S1:

```text
semantic renderer -> frame handoff -> project compositor -> Push USB display
```

See [`CURRENT_SLICE.md`](CURRENT_SLICE.md).

## Start here

1. [`AGENTS.md`](AGENTS.md)
2. [`CURRENT_SLICE.md`](CURRENT_SLICE.md)
3. [`docs/PROJECT_TRACKS.md`](docs/PROJECT_TRACKS.md)
4. [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md)
5. [`docs/VISUAL_PORTABILITY.md`](docs/VISUAL_PORTABILITY.md)
6. [`docs/VISUAL_RESEARCH_BASIS.md`](docs/VISUAL_RESEARCH_BASIS.md)
7. [`docs/ROADMAP.md`](docs/ROADMAP.md)
8. [`docs/RUNTIME_STRATEGY.md`](docs/RUNTIME_STRATEGY.md)
9. [`docs/HARDWARE_DOSSIER.md`](docs/HARDWARE_DOSSIER.md)
10. [`CONTRIBUTING.md`](CONTRIBUTING.md)

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

This project is independent and is **not affiliated with or endorsed by Ableton AG, Bitwig GmbH, Intel, Valve, Framework Computer, or the DrivenByMoss project**.
