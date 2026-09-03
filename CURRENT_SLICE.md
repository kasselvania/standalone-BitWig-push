# Current Work — V5 managed Bitwig workspace

## Status

**ACTIVE**

Owning issue: [#50 — V5: Managed Bitwig workspace and PipeWire frame source](https://github.com/kasselvania/standalone-BitWig-push/issues/50)

Durable design: [`docs/design/managed-visual-workspace.md`](docs/design/managed-visual-workspace.md)

Blocked prior goal: [#49 — V4 Sampler device-page foundation](https://github.com/kasselvania/standalone-BitWig-push/issues/49)

Implementation branches begin from the current accepted `origin/main` containing this V5 activation.

## Why V5 comes before Sampler

V2/V3 proved the downstream engineering path:

```text
real pixels
        -> bounded capture/processing
        -> authenticated latest-frame ingress
        -> current semantic composition
        -> physical Push 3
```

V4 preflight then proved that continuous ScreenCaptureKit capture of the user's primary Bitwig window is not acceptable as the current macOS attached-desktop product source: macOS sharing UI obstructs normal Bitwig window controls on the tested fixture.

The Mac was the first software-development fixture, not the product definition.

V5 returns to the original managed-runtime/appliance model and proves a visual source that can become portable without designing every future OS backend now.

## Goal

Run one authoritative Bitwig session inside one controlled Linux graphical workspace and expose that workspace simultaneously as:

```text
canonical managed workspace
        +-> raw PipeWire frame stream -> Pushwig frame adapter -> V1D-2 -> Push
        +-> full remote desktop/input -> another computer/device
```

Remote-client size, zoom, connection state, or codec must not define the canonical workspace geometry or the Pushwig visual source identity.

## Reference implementation

Use Weston as the first managed compositor/workspace reference and PipeWire as the first raw-video transport.

Preferred proof topology:

```text
Bitwig (+ Xwayland when required)
        -> Weston managed output
             |                 |
             |                 +-> VNC or equivalent remote backend
             |
             +-> PipeWire secondary backend
                    -> committed Pushwig Linux frame adapter
                    -> unchanged V1D-2 raster ingress
```

Weston, VNC, PipeWire, Wayland, X11/Xwayland and Linux-specific handles are backend implementation details. They must not define the portable `VisualSurface` / `VisualSurfaceFrame` contract.

## Source ownership

### Central repository

V5 production work belongs in one product PR, likely under:

```text
workspace/linux/**
capture/linux/**
docs/design/managed-visual-workspace.md
docs/DEVELOPMENT.md
evidence/v5-managed-workspace/README.md
```

The exact source split is implementation-driven.

### DrivenByMoss

Do not add Linux/Weston/PipeWire logic to DrivenByMoss.

The accepted external raster ingress remains the final local frame sink. Existing control/audio/display ownership is unchanged.

## Acceptance

V5 succeeds when:

1. Bitwig runs and remains usable inside one controlled Weston workspace.
2. The workspace has explicit canonical geometry independent of the remote client.
3. A raw PipeWire video source exposes that canonical workspace.
4. A committed Pushwig Linux adapter consumes complete frames without an application FIFO or unbounded growth.
5. Real pixels from that source can be converted/published through unchanged V1D-2 to Push when the hardware fixture is available.
6. Another computer/device can see and control the complete Bitwig workspace through an independent remote-desktop path.
7. Remote client resize/zoom does not change workspace geometry or source identity.
8. Remote client disconnect/reconnect does not stop Bitwig, frame production, Push control or audio.
9. Restarting the frame adapter does not restart Bitwig.
10. Remote pointer/input remains usable remotely while ordinary pointer pixels do not contaminate the Push source.
11. Normal Bitwig window controls are usable in the managed workspace.
12. CPU/RSS/frame cadence and frame-processing latency are retained.
13. Platform-neutral source descriptors contain no Weston/PipeWire/Wayland/X11/DRM/VNC handles or transient IDs.
14. Existing accepted V1D-2 and DrivenByMoss contracts remain unchanged.

## Explicit non-goals

V5 does not implement:

- the blocked V4 Sampler page;
- semantic camera or device anchors;
- Browser redesign;
- gamescope production integration;
- Steam Deck battery/appliance packaging;
- XDG portal attached-mode capture;
- a replacement macOS attached capture backend;
- Windows capture;
- a public adapter SDK.

These can consume the managed-workspace/source contract later.

## Stable boundaries

- Bitwig remains the DAW/audio-engine authority.
- DrivenByMoss remains controller-semantic authority and sole Push USB display writer.
- V1D-2 remains the final bounded local raster ingress.
- The managed workspace is a source/runtime layer upstream of that sink.
- Remote desktop is a separate consumer of the same Bitwig workspace, not the Push visual transport.
- The Mac remains a useful development fixture but no longer defines the visual-source architecture.
- V4 remains blocked until a viable source mode exists; V5 does not silently waive that blocker.
