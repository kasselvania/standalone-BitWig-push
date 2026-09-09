# Pushwig

**Live Bitwig visuals and DrivenByMoss control on Ableton Push 3.**

Pushwig is an open-source integration that makes **Ableton Push 3 Controller** a richer controller for **Bitwig Studio**. DrivenByMoss remains responsible for musical control and the normal Push interface; Pushwig adds optional visual and presentation layers for information that benefits from graphics.

> **Project status:** experimental, working on real hardware, not yet an end-user release.
>
> Pushwig does **not** run Bitwig on AbletonOS, modify Push firmware, or require Push Standalone/Ableton's compute upgrade.

The repository is still named `standalone-BitWig-push` for historical reasons. **Pushwig** is the project name.

## What is proven

On a physical Push 3 Controller, Pushwig has proven:

- normal DrivenByMoss pads, encoders, transport, sequencing, device control, and Push audio/headphones remain available;
- current visual frames can be composed into the Push display with low latency and bounded CPU/RSS;
- current DrivenByMoss semantics return when visual authority clears, becomes stale, disconnects, or fails;
- one separate local producer can publish complete authenticated latest frames without blocking the controller/display path;
- real Bitwig pixels can be cropped, scaled, normalized, and delivered to the physical Push;
- DrivenByMoss retains one final Push USB display writer;
- ordinary Bitwig launch enables the existing receiver through a persisted Push controller setting and private session rendezvous, with successful shutdown, fresh restart, and exact official rollback.

The downstream frame path and ordinary activation are accepted. This does not select a product-valid capture source.

## What is not yet solved

The tested ScreenCaptureKit primary-window stream obstructed normal Bitwig window controls, and the later V5 bakeoff did not select a replacement. Device localization and presentation still need a source that is usable with the ordinary Bitwig desktop.

## System shape

```text
Bitwig / DrivenByMoss semantics -----------------------------+
                                                              |
optional product-valid source -> bounded producer -> V1D-2 data plane
                                                              |
                                                              v
                                         context-gated composition
                                                              |
                                                              v
                                             sole Push USB display writer
```

The accepted activation/rendezvous plane determines how an ordinary Bitwig session brings V1D-2 online and how a producer securely discovers it. Capture/media backends never own Push MIDI, audio, or USB transport.

Read [Architecture](docs/ARCHITECTURE.md) and [Protocols](docs/PROTOCOLS.md).

## Current development

V5A ordinary-launch ingress activation is accepted. There is no active implementation slice; [`CURRENT_SLICE.md`](CURRENT_SLICE.md) is the current-work pointer.

The [accepted activation guide](docs/design/ordinary-launch-ingress-activation.md) explains the default-Off **Pushwig → External visual ingress (requires restart)** setting, ordinary relaunch, private producer discovery and limitations. [Final acceptance](evidence/v5a-ordinary-ingress-activation/README.md) records the exact tested source and official rollback.

The prior [V5 frame-source bakeoff](docs/design/portable-frame-source-bakeoff.md) is closed as failed/superseded. Closed, unmerged PR #52 is historical work, not an accepted substrate.

## Device-aware presentation

The desired product preserves good DrivenByMoss screens and adds deliberate experiences only for supported objects and tasks. Ordinary activation is now available; the Sampler device-page goal remains blocked on a viable visual source mode.

See:

- [device-aware presentation model](docs/design/device-aware-presentation-layer.md);
- [native-device behavior matrix](docs/design/native-device-behavior-matrix.md);
- [blocked V4 issue](https://github.com/kasselvania/standalone-BitWig-push/issues/49).

## Platform direction

macOS remains the active development fixture. A future selected media/frame path must have a concrete Linux continuation without allowing Apple/Linux backend handles to define portable product identity. No successor or capture backend is selected by V5A's completion.

A future managed appliance may expose the complete Bitwig desktop to another device while Push receives a curated presentation. That is a later runtime/deployment layer.

## Development

Start with:

- [Development](docs/DEVELOPMENT.md);
- [Testing](docs/TESTING.md);
- [Contributing](CONTRIBUTING.md);
- [Documentation index](docs/README.md).

Detailed fixture evidence is under [`evidence/`](evidence/); it is not required onboarding.

## Independence and trademarks

Pushwig is independent and is not affiliated with or endorsed by Ableton, Bitwig, Apple, Valve, Intel, Framework Computer, or the DrivenByMoss project.
