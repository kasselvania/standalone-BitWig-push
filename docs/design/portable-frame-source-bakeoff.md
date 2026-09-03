# Portable frame-source bakeoff

## Purpose

Pushwig has proved the hard downstream integration:

```text
complete raw pixels
        -> bounded image processing
        -> authenticated latest-frame ingress
        -> current DrivenByMoss semantic composition
        -> one Push USB display writer
```

The open question is whether Pushwig can obtain those pixels from a source that is acceptable for ordinary use and can form part of a macOS/Linux product rather than one operating-system experiment.

V5 is a Mac-first bakeoff of frame-source and media-pipeline implementations. It must select a product-usable path or return a justified no-winner decision. Issue #50 is the executable scope.

## Corrected premise

The rejected source was specific:

```text
ScreenCaptureKit
+ desktop-independent continuous capture
+ the user's primary Bitwig window
```

That path was fast and technically correct, but macOS placed sharing UI over Bitwig's normal title-bar controls.

This disqualifies that source configuration. It does not abandon macOS, select Linux, or select Weston/PipeWire.

macOS remains the active development fixture. Any selected capture/media substrate must also provide a credible Linux path.

## Framework, backend, and operating mode are different

GStreamer, FFmpeg, OBS, WebRTC, Sunshine, RustDesk, and similar systems may run on several operating systems. Their actual screen source still delegates to a platform backend.

The evaluation unit is:

```text
framework or library
        + actual macOS acquisition backend
        + source type
        + operating mode
```

A generic wrapper around the rejected ScreenCaptureKit primary-window path is not a materially different candidate.

A candidate may use a different source plugin on Linux. The shared frame representation, crop/scale/format path, lifecycle, and delivery model should remain common.

## Why unconventional projects matter

Pushwig resembles projects that project a live computer onto unusual second-screen hardware more than a screenshot utility.

The bakeoff must inspect:

- `drc-sim` / `libdrc`, relevant as Wii U GamePad simulation/streaming systems with distinct source, media, device-transport, and returned-input concerns;
- Weylus, for cross-platform desktop-to-tablet visual/input architecture;
- Sunshine, for low-latency cross-platform capture/backend selection, frame pacing, cursor handling, and restart behavior;
- ScreenCaptureLite, as a smaller direct raw-capture candidate;
- WebRTC desktop capture, as a mature cross-platform raw-frame abstraction;
- RustDesk capture components, as production remote-desktop source/lifecycle precedent;
- OBS/libobs, for source/filter/compositor architecture and platform plugins;
- GStreamer and FFmpeg/libavdevice/libavfilter, as cross-platform media substrates;
- direct-framebuffer projects such as Looking Glass, as examples of consuming a machine-oriented frame surface rather than recapturing a human desktop.

These are a research floor, not predetermined dependencies. Current source code wins over project descriptions.

## Leading substrate families

### GStreamer

Potential strengths:

- macOS and Linux support;
- replaceable source plugins;
- raw `appsink` / `appsrc` integration;
- crop, scale, color conversion, rate control, and tee elements;
- future encoding/streaming without changing the upstream frame graph.

The actual macOS source plugin determines product behavior. V5 must identify whether it uses ScreenCaptureKit, AVFoundation, CoreGraphics, or another API and test its operating-system side effects.

### FFmpeg / libavdevice / libavfilter

Potential strengths:

- macOS and Linux support;
- platform input devices;
- raw frames through libav APIs;
- crop, scale, colorspace, pixel-format, and frame-rate filters;
- optional future encoding.

The actual macOS input device determines product behavior. A CLI probe is acceptable for reconnaissance; a selected long-term path should use a bounded embedded interface rather than a fragile screenshot shell pipeline.

### Direct cross-platform raw-capture libraries

ScreenCaptureLite, WebRTC desktop capture, and capture components from cross-platform remote-desktop projects may offer lower-level raw callbacks and a smaller frame path. Their maintenance, license, actual macOS backend, Linux backend, source identity, cursor handling, and build burden must be audited.

### Architectural references

OBS, Sunshine, Weylus, RustDesk, drc-sim/libdrc, and Looking Glass may become direct candidates or remain architectural references. Selection is based on measured product behavior, not popularity.

## Backend-neutral seam

V5 should introduce only the common model needed to compare candidates:

```text
FrameSourceDescriptor
    source_id
    generation
    role
    width / height
    pixel_format
    capabilities
        interaction_safe
        cursor_free_or_separable
        supports_subregions
        restartable
        linux_path_available

RawFrame
    source_id + generation
    sequence
    monotonic capture or receipt time
    width / height / stride / pixel format
    complete
    buffer view or bytes
```

Backend-specific handles remain private:

```text
SCStream / AVCapture / CGDisplayStream
GstElement / GstSample
AVFormatContext / AVFrame
X11 / PipeWire / DRM / Wayland handles
WebRTC capturer objects
```

The common processing path should own, where practical:

```text
source frame
        -> bounded normalized crop
        -> one aspect-preserving scale
        -> opaque BGRA
        -> latest-frame handoff
        -> existing V1D-2 producer
```

V5 does not create a public adapter SDK.

## Candidate audit

For every investigated source path retain:

| Area | Required fact |
|---|---|
| Project | repository, license, release/maintenance state |
| macOS backend | actual acquisition API and source type |
| Linux path | actual or documented source implementation |
| Raw access | callback/buffer type, format, stride, copy ownership |
| Source identity | display/window/surface identity and generation behavior |
| Cursor | absent, composited, metadata-separated, or uncontrollable |
| System UI | permission and persistent capture indicators |
| Interaction | close/minimize/full-screen and ordinary Bitwig operation |
| Processing | crop, scale, colorspace, frame-rate control, tee capability |
| Lifecycle | source loss, restart, geometry change, errors |
| Cost | build/dependencies, CPU/RSS/latency, licensing |
| Future projection | whether the same graph can feed a later remote encoder/client |

## Mac-first fixture matrix

Start with generated imagery, then Bitwig, then the physical Push.

### Generated source

Use a nonproprietary moving test surface with colored quadrants, fixed markers, motion, pointer movement, resize, and source loss. Prove raw pixel selection, row order, channels, crop, aspect, cadence, generation, and cursor behavior.

### Bitwig attached-use test

For each live candidate:

1. launch Bitwig normally on the Mac;
2. capture the selected source through that candidate;
3. operate close/minimize/full-screen controls;
4. move the pointer and trigger ordinary hover/tooltip behavior;
5. move, resize, lose, and recreate the source where supported;
6. stop and restart capture;
7. record any macOS capture UI;
8. decide whether the source is acceptable for ordinary attached use.

The rejected ScreenCaptureKit primary-window path is the comparison baseline, not another candidate.

### Existing Push sink

Candidates that pass generated and Bitwig usability gates publish through unchanged V1D-2. Only the final candidate needs the complete physical Push acceptance unless an A/B result remains ambiguous.

## Selection criteria

A winner must satisfy all of these:

- product-usable on the current Mac fixture;
- ordinary Bitwig controls remain available;
- no unacceptable persistent capture UI over Bitwig;
- pointer behavior is absent, separate, or deliberately acceptable;
- complete current raw frames and bounded source restart/generation;
- no unbounded queue or full-frame allocation growth;
- bounded crop/scale/opaque-BGRA conversion;
- physical Push proof with normal control/audio;
- comfortably inside a 30-fps visual budget;
- the same framework/common media path operates on Linux;
- a concrete future Linux source backend exists;
- future tee/encoding is not precluded;
- no private API, Bitwig injection, disabled security, or mouse automation.

Performance does not outrank usability. ScreenCaptureKit already showed that excellent performance can coexist with an unacceptable product source.

## Deprecated and private mechanisms

Older CoreGraphics or AVFoundation paths may be measured as comparisons when current SDKs expose them. Deprecation and support horizon must be explicit.

A deprecated source cannot become the long-term substrate solely because it avoids one UI indicator. Private WindowServer/TCC mechanisms are outside scope.

## Relationship to Linux

V5 does not implement Linux.

Linux viability means the selected framework builds on Linux, the common raw-frame/transform path is reusable, at least one concrete Linux source backend exists for later evaluation, and the portable seam contains no Apple types.

The Steam Deck remains the first appliance fixture, not V5's development host.

## Relationship to remote access and managed mode

The future appliance still needs the full Bitwig desktop on another device. A selected media substrate should allow a future tee into an encoder or remote-view path without letting the remote client define Pushwig source geometry.

V5 does not build remote desktop or a managed compositor. [`managed-visual-workspace.md`](managed-visual-workspace.md) remains a future Track A/runtime concept.

## V5 result

V5 returns one of two honest outcomes.

### Selected

One macOS source path passes usability, raw-frame, performance, Push, and Linux-path gates. Its implementation becomes the capture substrate for resuming device-aware work.

### No winner

No candidate passes. Retain exact failures and choose the next source class deliberately.

Do not select a framework because it is popular, standardized, or easiest to document. Select it because its actual macOS source behavior works and its architecture can continue to Linux.
