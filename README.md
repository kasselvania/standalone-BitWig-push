# Pushwig

**Live Bitwig visuals and DrivenByMoss control on Ableton Push 3.**

Pushwig is an open-source project exploring a richer Bitwig Studio experience on **Ableton Push 3 Controller**. DrivenByMoss remains responsible for musical control and the normal Push interface. Pushwig adds an optional visual and presentation path for information that is otherwise available only in Bitwig's graphical interface.

> **Project status:** experimental engineering foundation; not yet an end-user release.
>
> Pushwig does **not** run Bitwig on AbletonOS, does not modify Push firmware, and does not require Push Standalone or Ableton's compute-module upgrade.

The repository is still named `standalone-BitWig-push` for historical reasons. **Pushwig** is the project name going forward.

## What has been proven

The project has exercised a maintained macOS helper and a small DrivenByMoss fork together on a physical Push 3 Controller.

The accepted work proves that Pushwig can:

- preserve normal DrivenByMoss pads, encoders, transport, sequencing, browsing, device control, Push audio, and headphone output;
- compose real-time raster visuals onto Push's 960×160 display;
- restore current DrivenByMoss semantics when a visual disappears, becomes stale, or fails;
- receive the newest complete visual frame from a separate local process without blocking the Push display/control path;
- capture a selected Bitwig window and apply an explicit helper-local crop and aspect-preserving scale;
- keep that window-relative source attached through ordinary movement, supported resize, loss, and recreation;
- reject missing or ambiguous source windows instead of choosing an unrelated one;
- perform the visual capture, processing, transport, and composition at low enough cost for responsive real-hardware use.

These results answer the initial engineering question: **yes, computer-hosted visuals can reach Push quickly, accurately, and without taking over musical control or audio.**

## Current product blocker

The present macOS window-capture source is not acceptable as a normal attached-desktop product mode.

On the tested Mac, continuous desktop-independent capture of Bitwig's primary window causes macOS to place a sharing badge over Bitwig's normal window controls. While capture was active, the maintainer could not access the normal minimize and full-screen controls. Stopping capture removed the obstruction.

The helper already excludes system cursor pixels and click indicators. Pointer-adjacent Bitwig hover/tool-tip behavior remains a separate usability concern.

Therefore V2/V3 are treated as **capture and delivery proofs**, not as a supported end-user attached-desktop workflow. V4 stopped at preflight before any production Sampler-page implementation. See [`CURRENT_SLICE.md`](CURRENT_SLICE.md) and the [blocker evidence](https://github.com/kasselvania/standalone-BitWig-push/blob/52f6f41f4fc7285d652453a3530b9764e0295cc5/evidence/v4-sampler-device-page/README.md).

## Architecture

```text
Bitwig controller state ──> DrivenByMoss ───────────────┐
                                                        │
viable visual source ──> platform helper ──> frame ingress
                                                        │
                                                        v
                                     context-gated Push presentation
                                                        │
                                                        v
                                                Ableton Push 3
```

There is one important ownership rule: **DrivenByMoss remains the sole writer to the Push display USB endpoint.** A visual source never owns Push MIDI or audio. If the visual path fails, musical control and audio do not wait for it.

The downstream raster, latest-frame, semantic-restoration, and one-writer architecture is established. The unresolved product question is now the upstream **visual-source operating mode**: how to obtain useful native visual information without compromising normal use of the host application.

Read [Architecture](docs/ARCHITECTURE.md) and [Protocols](docs/PROTOCOLS.md).

## Device-aware presentation direction

Pushwig does not intend to replace every controller screen.

- Track, mixer, session, transport, and performance pages stay with DrivenByMoss unless a specific better experience is designed.
- Supported device and Browser contexts may receive deliberate Pushwig presentations.
- Unsupported, stale, ambiguous, or unavailable visual states fall back to ordinary DrivenByMoss.

The [device-aware presentation model](docs/design/device-aware-presentation-layer.md) and [native-device behavior matrix](docs/design/native-device-behavior-matrix.md) remain the intended product vocabulary. Implementation is paused until a viable visual-source mode is selected.

## Current requirements

The accepted engineering fixture uses:

- Ableton Push 3 **Controller**;
- Bitwig Studio;
- the Pushwig DrivenByMoss fork;
- macOS for the first capture experiments;
- a normal USB connection between the computer and Push.

Linux and Steam Deck remain portability targets. Push 2 has not received the same hardware acceptance testing.

## What Pushwig is not yet

Pushwig is not currently:

- an end-user-ready attached-desktop capture system;
- a one-click installer;
- an automatic detector for every Bitwig device or plug-in editor;
- a finished device-aware Sampler interface;
- a finished Linux release;
- a battery-powered appliance product;
- a modification of AbletonOS or Push firmware.

The repository also contains research for a future self-contained Linux appliance and Push's internal compute bay. Those are optional deployment/hardware directions, not requirements for the core visual/controller software.

## Current work

There is no active implementation slice.

[V4 / issue #49](https://github.com/kasselvania/standalone-BitWig-push/issues/49) is blocked at its required desktop-usability preflight. The next work is an explicit design and feasibility decision about the visual-source operating mode—not more Sampler page code layered on the same obstructive window capture.

## Development and testing

The macOS helper is ordinary Swift source under [`capture/macos/`](capture/macos/), with committed regression tests. The controller integration lives in the project DrivenByMoss fork.

Start with:

- [Development](docs/DEVELOPMENT.md);
- [Testing](docs/TESTING.md);
- [Contributing](CONTRIBUTING.md);
- [Documentation index](docs/README.md).

Detailed hardware and experiment evidence lives under [`evidence/`](evidence/) for audit and reproduction; it is not required reading for normal project orientation.

## Contributing

Useful contribution areas include:

- viable attached or managed visual-source architectures;
- direct/generated waveform and analyzer views;
- device-aware Push presentations;
- macOS and Linux capture backends;
- Bitwig window/layout and visual-source research;
- Browser and device interaction design;
- Push/Bitwig compatibility testing;
- packaging and developer experience.

## Independence and trademarks

Pushwig is independent and is not affiliated with or endorsed by Ableton, Bitwig, Apple, Valve, Intel, Framework Computer, or the DrivenByMoss project.

Ableton, Push, Bitwig, macOS, Steam Deck, Intel, Framework, and DrivenByMoss are names used only to describe compatibility and integration targets.
