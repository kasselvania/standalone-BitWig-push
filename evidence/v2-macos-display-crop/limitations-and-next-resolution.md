# Limitations and next bounded resolution

## Date, machine state, and authority

- Date: 2026-09-02 PDT.
- Machine state: accepted macOS 26.4.1 arm64, one display measured as
  `3430x1447` ScreenCaptureKit points, fixed Bitwig Studio 6.1
  main-window/device-chain layout, and real Push 3.
- Central basis/tree:
  `7c15abaf55c0080b2f80971e845b4ee6f1bfcc46` /
  `730726784b57016714c0a44c8f0f8caf1c5b0141`.
- Source PR/head/tree:
  [PR #43](https://github.com/kasselvania/standalone-BitWig-push/pull/43) /
  `03fb8c8824714e4bbefd7224848ca9cdad069088` /
  `f1f68bc6f0ba6527bb146a7ee93fd4333ffaf796`.

## Exact V2 boundary

V2 is intentionally a fixed-layout display-crop proof. Its authority is:

```text
the configured display still has the exact expected identity and geometry
AND Bitwig is running and frontmost
AND Screen Recording remains granted
AND a complete correctly shaped sample is available
```

That is enough to publish a current raster. It is not enough to prove which
application pixels occupy the configured coordinates.

The physical experiment made this distinction visible. When the maintainer
placed Bitwig's Sampler panel inside the crop, Push showed useful live Sampler
pixels. When Bitwig moved away, the same crop showed other desktop content.
Bitwig could remain frontmost in both cases, so the current guard correctly
preserved its stated application-level rule but could not identify the panel.

## Explicitly unresolved

- automatic location of the Bitwig main window or embedded device-chain panel;
- tracking window movement, resize, device-panel height, display change,
  resolution/scaling, or Bitwig UI-scale change;
- proving that Sampler, a particular native device, or a selected device is in
  the crop;
- native-device panel identity versus VST/VST3/CLAP editor identity;
- a user-facing crop configuration/calibration flow;
- a notarized/distributed helper and long-lived permission-management UX;
- physical display hot-unplug and forced ScreenCaptureKit-service failure;
- isolation of Apple's internal crop/scale timing beyond available public
  display-time samples;
- additional display/Mac configurations, Push 2, endurance, and thermal/power
  behavior.

No authority gap is softened into a claim: V2 knows display coordinates and
frontmost application identity, not Bitwig layout or content identity.

## Recommended next resolution

The next bounded slice should address one localization problem without changing
the proven transport, pixel, or one-writer boundaries:

1. retain the existing explicit display identity and normalized-crop fallback;
2. determine the narrowest public, stable way to resolve the Bitwig main-window
   frame or operator-selected device-panel rectangle;
3. keep selection/calibration separate from capture and V1D-2 publication;
4. revoke visual authority when the resolved rectangle becomes stale or cannot
   be proven;
5. test VST/editor child-window behavior later as a separate source-identity
   problem, as directed by the maintainer.

The successful V2 code should not be widened into a window/plugin SDK merely
because localization remains unsolved. The stable facts worth preserving are
the explicit point-space display contract, maximal centered-cover math, opaque
BGRA conversion, bounded ScreenCaptureKit path, public permission identity,
current-only publication, and unchanged DrivenByMoss writer.

## Commands and tools

This boundary was established through source/API inspection, exact display and
bundle readback, the guard-loss experiment, operator-driven Bitwig movement,
two locally inspected but uncommitted photo references, deterministic invalid
configuration/display tests, aggregate metrics, and direct physical Push
observation.

## Exact result

The fixed-layout V2 claim passes. Automatic Bitwig/Sampler localization remains
unimplemented and unproven by design; it is the principal next-resolution
boundary rather than a hidden V2 success claim.

## What this proves

- The limitations are bounded to source localization/configuration, not the
  already proven capture, aspect, pixel, protocol, controller, audio, or
  rollback path.
- A future locator can be layered before the existing helper capture contract
  without moving USB or semantic authority out of DrivenByMoss.

## What this does not prove

- This document does not select or authorize an Accessibility, Computer Vision,
  private WindowServer, plug-in API, or manual-calibration implementation.
- It does not broaden V2 to dedicated windows, plug-ins, or dynamic tracking.
