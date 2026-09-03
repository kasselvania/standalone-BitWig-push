# Current Work — V5 portable frame-source bakeoff

## Status

**ACTIVE — MAC-FIRST SOURCE SELECTION**

Owning issue: [#50 — V5: Mac-first portable frame-source bakeoff](https://github.com/kasselvania/standalone-BitWig-push/issues/50)

Design: [`docs/design/portable-frame-source-bakeoff.md`](docs/design/portable-frame-source-bakeoff.md)

Blocked product goal: [#49 — V4 Sampler device-page foundation](https://github.com/kasselvania/standalone-BitWig-push/issues/49)

## What is already solved

V1 through V3 proved the downstream visual path:

```text
complete raw visual frame
        -> bounded crop / scale / format conversion
        -> authenticated latest-frame ingress
        -> current semantic composition
        -> one Push USB display writer
        -> physical Push 3
```

That path is fast, accurate, bounded, and preserves Push control and audio.

## What failed

The tested ScreenCaptureKit desktop-independent stream of the user's primary Bitwig window is not an acceptable product source on the current Mac fixture. macOS sharing UI obstructs ordinary Bitwig window controls while capture is active.

That result disqualifies the tested source path. It does not disqualify macOS, select Linux, or select another framework by default.

## V5 goal

Stay on macOS and compare materially different frame-source/media stacks until one path either:

1. passes the attached-use, raw-frame, performance, Push, and future-Linux gates; or
2. produces a justified no-winner decision.

```text
candidate macOS frame source
        -> backend-neutral raw-frame seam
        -> shared crop / scale / opaque-BGRA path
        -> unchanged V1D-2
        -> physical Push
```

The selected framework/common media path must support Linux later. V5 does not implement Linux, Steam Deck, a managed compositor, or remote desktop.

## Candidate floor

The implementation agent must audit actual source backends—not merely project marketing—for:

- `drc-sim` / `libdrc` and similar unusual second-screen projects;
- Weylus;
- Sunshine;
- ScreenCaptureLite;
- WebRTC desktop capture;
- RustDesk capture components;
- OBS/libobs;
- GStreamer;
- FFmpeg/libavdevice/libavfilter.

A wrapper around the rejected ScreenCaptureKit primary-window path is not a new candidate.

## Selection gates

A winner must preserve normal Bitwig controls, avoid an unacceptable persistent capture overlay, provide clean or separable pointer behavior, expose complete bounded raw frames, reach unchanged V1D-2 and the physical Push, remain comfortably inside a 30-fps budget, and have a real Linux implementation path without leaking backend-specific handles into the common frame contract.

Private APIs, Bitwig injection, disabled security controls, and mouse automation are outside scope.

## Delivery

Preferred branch:

```text
capture/v5-portable-frame-source-bakeoff
```

One ordinary non-draft PR against `main`, containing source audits, candidate probes, committed generated-frame tests, measurements, one selected implementation or explicit no-winner decision, and concise fixture evidence.

No separate authority or evidence PR.

## Stable boundaries

- macOS remains the active development fixture for the foreseeable work;
- Bitwig remains DAW/audio authority;
- DrivenByMoss remains semantic/controller authority and sole Push USB writer;
- V1D-2 remains the accepted final raster sink;
- a cross-platform media framework is not the same thing as its macOS capture backend;
- V4 remains blocked until V5 selects a viable visual-source mode.
