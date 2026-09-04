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
- DrivenByMoss retains one final Push USB display writer.

These results establish the downstream frame data plane once it has been activated.

## What is not yet solved

Two product boundaries remain distinct:

1. **ordinary-launch activation:** the accepted V1D-2 fixture used startup JVM properties supplied through a special Bitwig executable launch; an ordinary user launch has not yet been proven to activate and expose that receiver;
2. **product-valid visual source:** the tested ScreenCaptureKit primary-window stream obstructed normal Bitwig window controls, and the later V5 bakeoff did not select a replacement.

The failed V5 work showed that source selection cannot proceed honestly until ordinary-launch ingress activation exists.

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

The activation/rendezvous plane determines how an ordinary Bitwig session brings V1D-2 online and how a producer securely discovers it. Capture/media backends never own Push MIDI, audio, or USB transport.

Read [Architecture](docs/ARCHITECTURE.md) and [Protocols](docs/PROTOCOLS.md).

## Current development

[V5A — ordinary Bitwig external-ingress activation](https://github.com/kasselvania/standalone-BitWig-push/issues/53) is active.

V5A is deliberately narrow. It recovers the stopped fixture, audits DrivenByMoss construction/configuration ownership, replaces JVM-environment activation with a supported extension-owned lifecycle and private session rendezvous, proves one generated frame through an ordinary Bitwig launch, and verifies shutdown/restart/rollback.

It does **not** implement a capture backend or resume the Sampler page. See the [V5A design](docs/design/ordinary-launch-ingress-activation.md) and [`CURRENT_SLICE.md`](CURRENT_SLICE.md).

The prior [V5 frame-source bakeoff](docs/design/portable-frame-source-bakeoff.md) is closed as a failed/superseded slice. Its code in draft PR #52 is not an accepted substrate.

## Device-aware presentation

The desired product preserves good DrivenByMoss screens and adds deliberate experiences only for supported objects and tasks. The Sampler device-page goal remains blocked until ordinary activation and a viable source mode are both proven.

See:

- [device-aware presentation model](docs/design/device-aware-presentation-layer.md);
- [native-device behavior matrix](docs/design/native-device-behavior-matrix.md);
- [blocked V4 issue](https://github.com/kasselvania/standalone-BitWig-push/issues/49).

## Platform direction

macOS remains the active development fixture. After V5A, source work may resume in a new bounded slice. A selected media/frame path must later prove a concrete Linux implementation without allowing Apple/Linux backend handles to define portable product identity.

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
