# Current Work — attached visual-source architecture blocked

## Status

**BLOCKED — NO ACTIVE IMPLEMENTATION SLICE**

V4 stopped at its required preflight before any production Sampler-page source was written.

- Owning issue: [#49 — V4 Sampler device-page foundation](https://github.com/kasselvania/standalone-BitWig-push/issues/49)
- Blocker evidence branch: `capture/v4-sampler-device-page`
- Blocker evidence commit: `52f6f41f4fc7285d652453a3530b9764e0295cc5`
- Evidence: [`evidence/v4-sampler-device-page/README.md`](https://github.com/kasselvania/standalone-BitWig-push/blob/52f6f41f4fc7285d652453a3530b9764e0295cc5/evidence/v4-sampler-device-page/README.md)

No V4 production helper, custom page, semantic bridge, or DrivenByMoss source change exists.

## What the accepted work actually proved

V1 through V3 answered the original engineering question:

```text
computer pixels
        -> bounded capture and helper-local processing
        -> authenticated latest-frame ingress
        -> current semantic composition
        -> physical Push 3
```

On the accepted fixture, this path is fast, responsive, bounded, accurate, and does not disturb Push control or audio ownership.

V3 also proved that a captured Bitwig window can be followed through ordinary movement, supported resize, loss, and recreation.

Those are important infrastructure results. They do **not** establish that the current macOS capture source is acceptable for normal attached-desktop use.

## Product blocker

The exact accepted desktop-independent Bitwig-window capture causes macOS to place a sharing badge over Bitwig's normal window controls on the tested Mac. During capture, the maintainer could not access the normal minimize and full-screen controls. Stopping capture removed the badge.

The accepted public ScreenCaptureKit configuration already excludes cursor pixels, click indicators, child windows, and the content-sharing picker. Inspection did not identify a supported public setting that removes this obstruction while preserving the same window-capture architecture.

Pointer, Bitwig-rendered hover state, and tooltip contamination are separate concerns and were not accepted as solved.

Therefore:

> **Continuous ScreenCaptureKit capture of the user's primary Bitwig window is an engineering proof source, not a supported attached-desktop product source.**

The V4 requirement must not be waived merely to continue the Sampler page. A device-aware interface built on an unusable source mode would still be unusable.

## Current design decision

The device-aware presentation model remains useful, but implementation is paused before its capture backend.

The next technical-lead/maintainer decision must choose and prove a viable visual-source operating mode, such as:

- a supported attached-desktop source that preserves ordinary Bitwig use;
- a managed or dedicated visual surface that does not interfere with the user's primary Bitwig window;
- direct/generated visuals from semantic or audio data where capture is unnecessary;
- a hybrid in which capture is used only in contexts where its operating cost is acceptable.

These are candidate directions, not selected architecture.

## Rules while blocked

- Do not continue V4 production implementation.
- Do not relax the window-control requirement.
- Do not claim V2/V3 as an end-user-ready attached-desktop capture mode.
- Do not add device anchors, semantic-camera behavior, or more crop logic before the source mode is chosen.
- Do not modify DrivenByMoss merely to hide the macOS source problem.
- Preserve the accepted downstream raster, ingress, semantic-restoration, control, audio, and one-writer boundaries.

The native-device matrix and device-aware presentation vocabulary remain design references, not active implementation authority.
