# Pushwig

**Live Bitwig visuals and DrivenByMoss control on Ableton Push 3.**

Pushwig is an open-source integration that makes **Ableton Push 3 Controller** a richer controller for **Bitwig Studio**. DrivenByMoss remains responsible for musical control and the normal Push interface; Pushwig adds optional visual and presentation layers for information that benefits from graphics.

> **Project status:** experimental, working on real hardware, not yet an end-user release.
>
> Pushwig does **not** run Bitwig on AbletonOS, modify Push firmware, or require Push Standalone/Ableton's compute upgrade.

The repository is still named `standalone-BitWig-push` for historical reasons. **Pushwig** is the project name.

## What is proven

On a physical Push 3 Controller, the project has proven that it can:

- retain normal DrivenByMoss pads, encoders, transport, sequencing, device control, and Push audio/headphones;
- inject current visual frames into the Push display with low latency and bounded CPU/RSS;
- restore current DrivenByMoss semantics when a visual disappears, becomes stale, or fails;
- receive complete latest frames from a separate local process without blocking the controller/display path;
- crop, scale, and normalize real Bitwig pixels before composition;
- keep one unchanged DrivenByMoss-owned Push USB display writer.

That is the major downstream engineering result.

## What is not yet solved

The tested ScreenCaptureKit continuous capture of the user's primary Bitwig window is not an acceptable product source on the current Mac fixture because macOS sharing UI obstructs ordinary Bitwig window controls.

This disqualifies that source configuration—not macOS and not the downstream Push visual architecture.

Pushwig therefore needs a different frame-source substrate before the blocked Sampler device page can resume.

## How it works

```text
Bitwig controller state -> DrivenByMoss -------------------+
                                                          |
product-usable frame source -> shared frame processing -> V1D-2
                                                          |
                                                          v
                                      context-gated Push composition
                                                          |
                                                          v
                                                   Ableton Push 3
```

DrivenByMoss remains the sole writer to the Push display USB endpoint. Capture/media backends never own Push MIDI or audio.

Read [Architecture](docs/ARCHITECTURE.md) and [Protocols](docs/PROTOCOLS.md).

## Current development

[V5 — Mac-first portable frame-source bakeoff](https://github.com/kasselvania/standalone-BitWig-push/issues/50) is active.

V5 stays on the Mac and compares materially different capture/media stacks. Candidate research includes unusual second-screen and remote-streaming projects as well as GStreamer, FFmpeg/libav, direct raw-capture libraries, WebRTC desktop capture, OBS/libobs, RustDesk, Sunshine, Weylus, and Wii U GamePad simulation projects.

A framework name is not enough: the actual macOS source backend must be identified. A wrapper around the rejected ScreenCaptureKit primary-window path is not a new solution.

The selected framework/common media path must also support Linux later. V5 does not move implementation to Linux or Steam Deck, and Windows is not a current requirement.

See the [portable frame-source bakeoff design](docs/design/portable-frame-source-bakeoff.md).

## Device-aware presentation

The desired product still preserves good DrivenByMoss screens and adds deliberate experiences only for supported objects and tasks. The Sampler device-page goal remains blocked until a viable frame source exists.

See:

- [device-aware presentation model](docs/design/device-aware-presentation-layer.md);
- [native-device behavior matrix](docs/design/native-device-behavior-matrix.md);
- [blocked V4 issue](https://github.com/kasselvania/standalone-BitWig-push/issues/49).

## Platform direction

macOS remains the active development fixture for the foreseeable work. A selected media/frame substrate must have a concrete Linux path so the same raw-frame and transform contracts can later support Linux and the Steam Deck appliance.

A future managed appliance may expose the complete Bitwig desktop to another device while Push receives a curated presentation. That is a later runtime/deployment layer, not V5's implementation target.

## Development

Start with:

- [Development](docs/DEVELOPMENT.md);
- [Testing](docs/TESTING.md);
- [Contributing](CONTRIBUTING.md);
- [Documentation index](docs/README.md).

Detailed fixture evidence is under [`evidence/`](evidence/); it is not required onboarding.

## Independence and trademarks

Pushwig is independent and is not affiliated with or endorsed by Ableton, Bitwig, Apple, Valve, Intel, Framework Computer, or the DrivenByMoss project.
