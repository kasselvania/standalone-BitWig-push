# Pushwig

**Live Bitwig visuals and DrivenByMoss control on Ableton Push 3.**

Pushwig is an open-source integration that makes **Ableton Push 3 Controller** a richer controller for **Bitwig Studio**. DrivenByMoss remains responsible for musical control and the normal Push interface; Pushwig adds optional visual/presentation paths for information that benefits from graphics.

> **Project status:** experimental, working on real hardware, not yet an end-user release.
>
> Pushwig does **not** run Bitwig on AbletonOS, does not modify Push firmware, and does not require Push Standalone or Ableton's compute-module upgrade.

The repository is still named `standalone-BitWig-push` for historical reasons. **Pushwig** is the project name.

## What has been proven

On a physical Push 3 Controller, Pushwig has demonstrated that real computer-hosted pixels can be:

- captured and processed with bounded CPU/memory cost;
- converted to opaque BGRA and delivered through a bounded local frame path;
- combined with current DrivenByMoss semantics;
- displayed with good responsiveness while pads, encoders, transport, audio and headphones remain operational;
- removed cleanly when the visual source becomes stale, invalid, disconnected or absent.

The accepted Mac work also proved window-relative capture, movement, resize/loss/recreation handling, and explicit helper-local crop/scale.

That work answered the first engineering question: **real host visuals can reach Push quickly and safely.**

## What the Mac did not prove

The Mac was the first development fixture, not the product architecture.

The current ScreenCaptureKit primary-window path is not accepted for ordinary attached-desktop use on the tested fixture because macOS sharing UI obstructs normal Bitwig window controls while capture is active.

Therefore:

```text
proven downstream frame/display system
        !=
accepted end-user source mode
```

The blocked Sampler device-page goal remains tracked in [issue #49](https://github.com/kasselvania/standalone-BitWig-push/issues/49).

## Current development — managed Bitwig workspace

[V5 — Managed Bitwig workspace and PipeWire frame source](https://github.com/kasselvania/standalone-BitWig-push/issues/50) is active.

V5 returns to the original managed/appliance architecture:

```text
one authoritative Bitwig session
        -> one canonical Linux graphical workspace
             +-> raw frame stream -> Pushwig -> Push
             +-> full remote desktop/input -> another device
```

The first reference implementation uses Weston and PipeWire on Linux, plus a remote-desktop backend. Those tools are implementation fixtures, not permanent product dependencies.

The important product property is that the remote viewer and Push visual source are independent consumers of the same Bitwig workspace. A laptop/tablet can resize, zoom, disconnect or reconnect without redefining the canonical workspace geometry used by Pushwig.

See [Managed visual workspace](docs/design/managed-visual-workspace.md).

## How it fits the eventual appliance

The intended portable system is:

```text
Push 3 Controller
        + managed Linux Bitwig host
        + battery / boot / recovery
        + curated Push-native interface
        + full wireless Bitwig desktop when needed
```

The full desktop is for deep editing, configuration, plug-in management and recovery. The Push display remains a purpose-built musical interface rather than a tiny remote desktop.

The Steam Deck remains the first named appliance fixture; Framework/compact-x86 systems remain possible later hosts. Internal CM11EB/native-compute research is optional and does not block the external-USB appliance.

## Device-aware presentation

Once a viable visual-source operating mode exists, Pushwig's device-aware layer can combine:

- current controller/device/parameter semantics from DrivenByMoss;
- captured native Bitwig visuals where useful;
- direct/generated waveforms, analyzers, browser state and graphs where structured data is better;
- Push-specific labels, values, highlighting and task views.

The current design vocabulary is documented in [Device-aware presentation](docs/design/device-aware-presentation-layer.md). The [native-device behavior matrix](docs/design/native-device-behavior-matrix.md) inventories Bitwig's top-level native devices and initial design priorities.

## Current requirements

Accepted Mac development work uses:

- Ableton Push 3 **Controller**;
- Bitwig Studio;
- the Pushwig DrivenByMoss fork;
- ordinary USB controller/audio connectivity.

V5 additionally requires one Linux host capable of running Bitwig, Weston and PipeWire for the managed-workspace proof.

## Development and testing

Start with:

- [Architecture](docs/ARCHITECTURE.md)
- [Development](docs/DEVELOPMENT.md)
- [Testing](docs/TESTING.md)
- [Runtime strategy](docs/RUNTIME_STRATEGY.md)
- [Contributing](CONTRIBUTING.md)
- [Documentation index](docs/README.md)

Detailed hardware/fixture evidence remains under [`evidence/`](evidence/) for audit and reproduction; it is not required reading for new contributors.

## What Pushwig is not yet

Pushwig is not currently:

- a one-click installer;
- a finished device-aware Sampler/browser interface;
- a supported macOS attached capture product;
- a finished Linux attached capture product;
- a finished Steam Deck appliance;
- a modification of AbletonOS or Push firmware.

## Independence and trademarks

Pushwig is independent and is not affiliated with or endorsed by Ableton, Bitwig, Apple, Valve, Intel, Framework Computer, Weston, PipeWire, or the DrivenByMoss project.

Names are used only to describe compatibility and integration targets.
