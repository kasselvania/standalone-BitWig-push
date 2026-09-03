# Pushwig

**Live Bitwig visuals and DrivenByMoss control on Ableton Push 3.**

Pushwig is an open-source integration that makes **Ableton Push 3 Controller** a richer controller for **Bitwig Studio**. DrivenByMoss remains responsible for musical control and the normal Push interface; Pushwig adds an optional visual and presentation layer for information that Bitwig exposes only in its graphical interface.

> **Project status:** experimental, working on real hardware, not yet an end-user release.
>
> Pushwig does **not** run Bitwig on AbletonOS, does not modify Push firmware, and does not require Push Standalone or Ableton's compute-module upgrade.

The repository is still named `standalone-BitWig-push` for historical reasons. **Pushwig** is the project name going forward.

## What works today

The project has a maintained macOS capture helper and a small DrivenByMoss fork that have been exercised together on a physical Push 3 Controller.

Today the system can:

- keep normal DrivenByMoss pads, encoders, transport, sequencing, browsing and device control;
- preserve Push as Bitwig's audio interface, including headphone output;
- compose live raster visuals onto Push's 960×160 display;
- restore current DrivenByMoss semantics when a visual source disappears, becomes stale or fails;
- receive the newest complete visual frame from a separate local process without blocking the Push display/control path;
- load a small JSON profile and capture a normalized region of one unique Bitwig main window;
- apply the profile crop explicitly inside the helper and scale it without aspect distortion;
- keep that window-relative source active through ordinary movement, supported resize, loss and recreation;
- reject missing or ambiguous source windows rather than showing unrelated pixels.

The accepted V3 window lens follows a region of the Bitwig window. It does not yet identify a device inside Bitwig or follow internal panel reflow. V3 proved the capture, delivery and window-lifecycle foundation; the current phase is designing device-aware presentations on top of it.

## How it works

```text
Bitwig controller state ──> DrivenByMoss ───────────────┐
                                                        │
Bitwig visual source ──> Pushwig capture helper ──> frame ingress
                                                        │
                                                        v
                                     context-gated Push presentation
                                                        │
                                                        v
                                                Ableton Push 3
```

There is one important ownership rule: **DrivenByMoss remains the sole writer to the Push display USB endpoint.** The capture helper never owns Push, MIDI or audio. It publishes bounded visual frames; the controller extension decides when a Pushwig experience is appropriate and combines valid pixels with current semantic state.

If the visual path fails, musical control and audio do not wait for it.

Read [Architecture](docs/ARCHITECTURE.md) for the component boundaries and [Protocols](docs/PROTOCOLS.md) for the raster/frame contracts.

## Device-aware presentation

Pushwig does not intend to replace every controller screen.

- Track, mixer, session, transport and performance pages stay with DrivenByMoss unless a specific better experience is designed.
- Supported native-device and Browser contexts may receive deliberate Pushwig presentations.
- Unsupported, stale or ambiguous states fall back to ordinary DrivenByMoss.

The shared design vocabulary is the [device-aware presentation operating model](docs/design/device-aware-presentation-layer.md). The [native-device behavior matrix](docs/design/native-device-behavior-matrix.md) inventories Bitwig's top-level devices, current generic DrivenByMoss coverage, provisional behavior families and priorities.

## Current requirements

The accepted development fixture uses:

- Ableton Push 3 **Controller**;
- Bitwig Studio;
- the Pushwig DrivenByMoss fork;
- macOS for the first capture backend;
- a normal USB connection between the computer and Push.

Linux and Steam Deck are planned portability targets. Push 2 has not received the same hardware acceptance testing.

## Run the current window-relative lens

Build the packaged helper as described in [Development](docs/DEVELOPMENT.md), then inspect only Bitwig-owned capture candidates:

```bash
PushwigCaptureHelper \
  --list-windows \
  --owner-bundle-id com.bitwig.studio
```

Run the maintained device-chain profile against an already configured local frame receiver:

```bash
PushwigCaptureHelper \
  --profile capture/macos/Profiles/bitwig-device-chain.json \
  --port 45291 \
  --token-file /path/to/private-token
```

The profile contains visual geometry and source selection only. The token path, capability, socket session, physical desktop position and current macOS window ID are runtime state.

## What Pushwig is not yet

Pushwig is not currently:

- a one-click installer;
- an automatic detector for every Bitwig device or plug-in editor;
- a device-aware resolver that follows internal Bitwig panel reflow;
- a finished Linux release;
- a battery-powered appliance product;
- a modification of AbletonOS or Push firmware.

The repository also contains research for a future self-contained Linux appliance and Push's internal compute bay. Those are optional deployment/hardware directions, not requirements for the core visual/controller software.

## Current development

[V4 — Sampler device-page foundation](https://github.com/kasselvania/standalone-BitWig-push/issues/49) is the active product milestone.

V4 leaves existing good controller pages untouched and builds the first deliberate hybrid page for one supported Bitwig Sampler Device context: current encoder names and values, a tightly framed native visual, touched-control emphasis, context-safe activation and exact fallback to ordinary DrivenByMoss.

It does not yet attempt universal device recognition, touch-driven camera zoom, sliced-Sampler task views or Browser redesign. Those are later capabilities using the same [operating model](docs/design/device-aware-presentation-layer.md).

## Development and testing

The macOS helper is ordinary Swift source under [`capture/macos/`](capture/macos/), with committed regression tests. The controller integration lives in the project DrivenByMoss fork.

Start with:

- [Development](docs/DEVELOPMENT.md) — build and local setup;
- [Testing](docs/TESTING.md) — repeatable tests versus retained experimental evidence;
- [Contributing](CONTRIBUTING.md) — PR, branch and evidence expectations;
- [Documentation index](docs/README.md) — current designs and deeper references.

Pushwig keeps detailed hardware/experiment evidence under [`evidence/`](evidence/). That material is there for audit and reproduction; it is **not** required reading to understand the project.

## Contributing

Contributions are welcome in areas such as:

- device-aware Push presentations;
- macOS and Linux capture backends;
- Bitwig window/layout and visual-source resolution;
- generated waveform/analyzer views;
- Browser and device interaction design;
- Push/Bitwig compatibility testing;
- packaging and developer experience;
- documentation and visual design.

A new contributor should be able to understand the project without reading maintainer control files. Start with [CONTRIBUTING.md](CONTRIBUTING.md) and the [documentation index](docs/README.md).

`AGENTS.md`, `CURRENT_SLICE.md` and the evidence directories exist for maintainers and coding agents; they are not the public onboarding path.

## Independence and trademarks

Pushwig is independent and is not affiliated with or endorsed by Ableton, Bitwig, Apple, Valve, Intel, Framework Computer or the DrivenByMoss project.

Ableton, Push, Bitwig, macOS, Steam Deck, Intel, Framework and DrivenByMoss are names used only to describe compatibility and integration targets.
