# Runtime and source strategy

## Current decision

macOS remains Pushwig's active development fixture for the foreseeable work.

The Mac was chosen for its fast Bitwig/DrivenByMoss/Push development loop. It does not define portable contracts, and one failed macOS source configuration does not move the project to Linux.

## Current runtime sequence

```text
Mac fixture
    -> prove Push composition and select a product-usable frame source

Linux fixture later
    -> prove the selected common media/frame path and a Linux source backend

Steam Deck / compact x86 later
    -> package the proven software into a managed portable appliance
```

Windows is not a current product requirement.

## Attached macOS mode

V5 evaluates materially different source/media stacks on the current Mac.

The rejected baseline is continuous ScreenCaptureKit desktop-independent capture of the user's primary Bitwig window. It remains useful engineering evidence but not an attached product source.

Candidate frameworks may include GStreamer, FFmpeg/libav, direct cross-platform capture libraries, WebRTC desktop capture, OBS/libobs, remote-desktop/game-streaming capture components, and lower-level platform paths. Their actual macOS acquisition backend must be audited.

## Linux compatibility requirement

The selected framework/common processing path must build and operate on Linux later, and at least one concrete Linux source backend must exist. V5 does not implement that backend.

The common source/frame and image-processing contract must not contain Apple types or assumptions.

## Future managed appliance

A later appliance may run Bitwig in a controlled graphical workspace and expose:

```text
curated Push presentation
        +
full Bitwig desktop on another device
```

This may use Weston, gamescope, another compositor, PipeWire, VNC/RDP/WebRTC, or another stack. No one stack is selected before source bakeoff results and a real Linux fixture.

## Direct/generated sources

Not every Push experience must screen-capture Bitwig. Browser, analyzers, waveforms, and parameter graphs may use semantic, audio, or direct-rendered sources when those are more robust and useful.

All sources ultimately feed the same bounded Push presentation path or semantic fallback.

## Decision rule

Do not let one computer, OS API, popular framework, packaging format, or appliance host define the architecture. Select source mechanisms by actual usability, frame behavior, lifecycle, performance, future Linux path, and compatibility with the proven Push sink.
