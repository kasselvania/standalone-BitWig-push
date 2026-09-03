# Architecture

## Product thesis

Pushwig combines semantic control/state from Bitwig/DrivenByMoss with visual information from an optional source when graphics improve a Push task.

The controller path remains useful when the visual source is absent, unsupported, or broken.

## Proven downstream system

```text
Push controls
    -> DrivenByMoss semantic state/frame
    -> optional newest valid opaque-BGRA visual
    -> context-gated composition
    -> sole Push USB display writer
```

A separate process can publish complete latest frames over the accepted bounded V1D-2 loopback protocol. The receiver never owns musical control/audio and the display thread never blocks on source I/O.

This downstream system is proven on physical Push hardware.

## The source problem

The maintained Mac helper proved raw capture, crop/scale, window lifecycle, and V1D-2 delivery. Its tested ScreenCaptureKit desktop-independent primary-Bitwig-window source is not product-valid for ordinary attached use because macOS sharing UI obstructs Bitwig window controls.

Therefore:

```text
proven Push frame substrate
        !=
selected product frame source
```

The source must be selected by product behavior, not API availability or benchmark speed.

## Portable frame-source layer

The current target architecture is:

```text
platform source backend
        -> backend-neutral RawFrame
        -> shared bounded crop / scale / format path
        -> V1D-2
        -> DrivenByMoss composition
        -> Push
```

Conceptual common facts include source identity/generation, role, dimensions, stride, pixel format, completeness, monotonic time, and capabilities such as interaction safety, cursor separation, subregions, restart, and Linux path.

ScreenCaptureKit, AVFoundation/CoreGraphics, GStreamer objects, FFmpeg/libav objects, X11, PipeWire, Wayland, and other backend handles remain private.

A cross-platform media framework is not itself a source. V5 evaluates the actual macOS acquisition backend plus its common Mac/Linux processing path.

## Device-aware presentation

The post-source product model remains:

```text
context router
semantic context
experience profile
visual resolver
semantic camera
presentation composer
source backend
```

The blocked Sampler V4 page will resume only after V5 selects a viable source mode. Existing track/mixer/session/transport/performance screens remain ordinary DrivenByMoss by default.

## Attached and managed modes

### Attached

Use the user's existing Bitwig desktop. A backend is eligible only when it preserves ordinary application operation and does not silently show wrong or contaminated visuals.

### Managed

A future appliance may own a canonical Bitwig workspace and expose it both to Pushwig and a remote full-desktop client. This remains a Track A/runtime option; no compositor or remote stack is selected in V5.

## Ownership invariants

- Bitwig owns DAW/audio.
- DrivenByMoss owns semantic Push behavior and final USB display transport.
- Frame-source/media backends own acquisition and backend-local lifecycle only.
- Capture/media failures return to current semantics.
- Platform-specific objects do not define portable source/device/presentation identity.
- A technically valid source is not product-valid if it makes Bitwig materially unusable.

See [portable frame-source bakeoff](design/portable-frame-source-bakeoff.md), [protocols](PROTOCOLS.md), and [device-aware presentation](design/device-aware-presentation-layer.md).
