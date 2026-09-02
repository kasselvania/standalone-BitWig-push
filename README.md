# Pushwig

**Live Bitwig visuals and DrivenByMoss control on Ableton Push 3.**

Pushwig is an open-source integration that makes **Ableton Push 3 Controller** a richer controller for **Bitwig Studio**. DrivenByMoss remains responsible for musical control and the normal Push interface; Pushwig adds an optional visual path for information that Bitwig exposes only in its graphical interface.

> **Project status:** experimental, working on real hardware, not yet an end-user release.
>
> Pushwig does **not** run Bitwig on AbletonOS, does not modify Push firmware, and does not require Push Standalone or Ableton's compute-module upgrade.

The repository is still named `standalone-BitWig-push` for historical reasons. **Pushwig** is the project name going forward.

## What works today

The project has a maintained macOS capture helper and a small DrivenByMoss fork that have been exercised together on a physical Push 3 Controller.

Today the system can:

- keep normal DrivenByMoss pads, encoders, transport, sequencing, browsing, and device control;
- preserve Push as Bitwig's audio interface, including headphone output;
- compose live raster visuals onto part of Push's 960×160 display;
- restore the current DrivenByMoss display when a visual source disappears, becomes stale, or fails;
- receive the newest complete visual frame from a separate local process without blocking the Push display/control path;
- capture a configured crop of Bitwig's macOS display and show live Sampler pixels on Push;
- fail back to the semantic DrivenByMoss display when capture permission, source validity, the helper, or the external frame connection is lost.

The current accepted macOS source is intentionally a **fixed-layout fixture**: the display and crop are configured explicitly. It proves the real pixel path. Active V3 work is replacing that physical-display dependency with a Bitwig-window-relative visual profile.

## How it works

```text
Bitwig controller state ──> DrivenByMoss ───────────────┐
                                                        │
Bitwig visual source ──> Pushwig capture helper ──> frame ingress
                                                        │
                                                        v
                                             Push display composition
                                                        │
                                                        v
                                                Ableton Push 3
```

There is one important ownership rule: **DrivenByMoss remains the sole writer to the Push display USB endpoint.** The capture helper never owns Push, MIDI, or audio. It publishes bounded visual frames; the controller extension decides whether the newest frame is valid and combines it with the current semantic display.

If the visual path fails, musical control and audio do not wait for it.

Read [Architecture](docs/ARCHITECTURE.md) for the component boundaries and [Protocols](docs/PROTOCOLS.md) for the raster/frame contracts.

## Current requirements

The accepted development fixture uses:

- Ableton Push 3 **Controller**;
- Bitwig Studio;
- the Pushwig DrivenByMoss fork;
- macOS for the first capture backend;
- a normal USB connection between the computer and Push.

Linux and Steam Deck are planned portability targets. Push 2 has not received the same hardware acceptance testing.

## What Pushwig is not yet

Pushwig is not currently:

- a one-click installer;
- an automatic detector for every Bitwig device or plug-in editor;
- a universal window/layout tracker;
- a finished Linux release;
- a battery-powered appliance product;
- a modification of AbletonOS or Push firmware.

The repository also contains research for a future self-contained Linux appliance and Push's internal compute bay. Those are optional deployment/hardware directions, not requirements for the core visual/controller software.

## Development and testing

The macOS helper is ordinary Swift source under [`capture/macos/`](capture/macos/), with committed regression tests.

Start with:

- [Development](docs/DEVELOPMENT.md) — build and local setup;
- [Testing](docs/TESTING.md) — repeatable tests versus retained experimental evidence;
- [Contributing](CONTRIBUTING.md) — PR, branch, and evidence expectations.

Pushwig keeps detailed hardware/experiment evidence under [`evidence/`](evidence/). That material is there for audit and reproduction; it is **not** required reading to understand the project.

## Current development

[V3 — Adaptive Bitwig window-relative visual lens](https://github.com/kasselvania/standalone-BitWig-push/issues/45) is active.

The goal is to make the working visual lens follow the Bitwig application window instead of a fixed physical display coordinate: load a small visual profile, capture relative to the current Bitwig window, and survive window move, supported resize, and recreation while preserving semantic fallback and normal Push controls/audio.

See the [active design](docs/design/window-relative-visual-lens.md) and [roadmap](docs/ROADMAP.md).

## Contributing

Contributions are welcome in areas such as:

- macOS and Linux capture backends;
- Bitwig window/layout tracking;
- visual-source detection and profiles;
- generated waveform/analyzer views;
- Push/Bitwig compatibility testing;
- packaging and developer experience;
- documentation and visual design.

A new contributor should be able to understand the project without reading maintainer control files. Start with [CONTRIBUTING.md](CONTRIBUTING.md) and the [documentation index](docs/README.md).

`AGENTS.md`, `CURRENT_SLICE.md`, and the evidence directories exist for maintainers and coding agents; they are not the public onboarding path.

## Independence and trademarks

Pushwig is independent and is not affiliated with or endorsed by Ableton, Bitwig, Apple, Valve, Intel, Framework Computer, or the DrivenByMoss project.

Ableton, Push, Bitwig, macOS, Steam Deck, Intel, Framework, and DrivenByMoss are names used only to describe compatibility and integration targets.
