# Architecture

## Product thesis

Pushwig combines two information sources without confusing their responsibilities:

- **semantic control/state** from Bitwig's controller API and DrivenByMoss;
- **visual pixels** from an optional helper or direct visual source when Bitwig exposes useful information only in its GUI.

The controller path remains useful when the visual path is absent or broken.

## Current system

```text
Push controls
    |
    v
DrivenByMoss fork <---------------- Bitwig controller API
    |
    | current semantic Push frame
    |
    +<--------- newest valid visual frame --------+
    |                                             |
    v                                             |
Push display composition                          |
    |                                             |
    v                                             |
Push USB display endpoint                         |
                                                  |
macOS capture helper -----------------------------+
    ^
    |
ScreenCaptureKit / Bitwig visual region
```

### 1. DrivenByMoss integration

The project fork of DrivenByMoss owns:

- Push input handling and semantic modes;
- the current semantic display;
- visual restoration when an overlay disappears;
- validated raster application;
- external latest-frame intake;
- the sole Push display USB writer.

Pushwig deliberately keeps this fork narrow. Capture and platform-specific UI discovery stay outside it.

See [`integrations/drivenbymoss.md`](integrations/drivenbymoss.md).

### 2. Visual helper

The maintained macOS helper under `capture/macos/**` owns:

- macOS Screen Recording permission;
- ScreenCaptureKit display inventory/capture;
- crop and aspect mapping;
- source-validity checks;
- opaque BGRA normalization;
- publication through the local external-frame protocol.

It does **not** own Push MIDI, audio, bitmap memory, or USB transport.

The accepted V2 helper currently uses an explicitly configured display-relative crop. That is a proven real-pixel fixture, not automatic device localization.

### 3. External frame boundary

The helper publishes complete frames to the DrivenByMoss derivative over authenticated IPv4 loopback. The receiver keeps bounded storage and exposes only the newest complete publication. The display path adopts a frame without blocking on socket I/O.

If a frame is absent, stale, malformed, disconnected, or rejected, Push uses the newest current semantic display.

See [`PROTOCOLS.md`](PROTOCOLS.md).

## Ownership invariants

These boundaries are intentional:

- Bitwig owns the DAW/audio engine.
- DrivenByMoss owns semantic Push behavior.
- Exactly one component writes the Push display USB endpoint.
- Capture never blocks musical control/audio.
- The receiver thread never writes a Push bitmap.
- The display thread never accepts or reads a socket.
- Historical composed pixels are never restoration authority.
- Visual ambiguity/failure prefers semantic fallback over showing the wrong content.
- Platform-specific capture objects do not cross into the controller-extension contracts.

## Current portability model

V2 proves the complete path on macOS using a fixed display/crop configuration. The next product milestone is to make that crop relative to the Bitwig application window so the visual survives ordinary window movement, resize, and recreation.

Longer-term portability work includes:

- stronger Bitwig panel/device localization;
- saved visual profiles and bounded calibration;
- Linux/Steam Deck capture backends;
- direct generated/analyzer visual sources;
- additional operating-system backends.

Detailed future ideas live in the design documents indexed from [`docs/README.md`](README.md); they are not all accepted product behavior.

## Optional hardware directions

The core visual/controller software is intended to work with a normal computer connected to Push 3 Controller over USB.

A self-contained Linux appliance and Push internal-compute research are optional deployment/hardware tracks, not prerequisites for the software architecture. See [`HARDWARE.md`](HARDWARE.md).
