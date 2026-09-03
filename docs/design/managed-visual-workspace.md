# Managed visual workspace and frame-source model

## Purpose

This document recovers the product architecture originally intended by the Track V / Track A design.

The Mac was the first software-development fixture. It proved the Push display seam, semantic restoration, raster path, external frame ingress, and one concrete capture backend. It was never meant to define the final visual-source operating mode.

V4 preflight made that distinction concrete: continuous ScreenCaptureKit capture of the user's primary Bitwig window is technically capable but not acceptable as the current macOS attached-desktop product source because macOS sharing UI obstructs normal Bitwig window controls.

V5 therefore establishes a different source class: a **managed Bitwig workspace** whose compositor owns the canonical graphical surface and exposes it independently to Pushwig and to a full remote-desktop client.

This document is durable architecture vocabulary, not a second execution authority. `CURRENT_SLICE.md` and the owning issue define active work.

## Product model

One authoritative Bitwig session can have several consumers without making any one consumer the DAW authority.

```text
                         BITWIG SESSION
                    one authoritative DAW
                              |
              +---------------+----------------+
              |                                |
      semantic/control plane          managed visual workspace
      Bitwig API + DrivenByMoss       canonical compositor output
              |                                |
              |                      +---------+---------+
              |                      |                   |
              |                 raw frame stream    remote desktop
              |                      |                   |
              +----------+-----------+                   |
                         |                               |
                 Push presentation                  laptop/tablet/
                         |                          service client
                         v
                       Push 3
```

The Push presentation and the remote desktop serve different jobs.

### Push presentation

- immediate musical feedback;
- task-specific device/browser visuals;
- semantic labels and values;
- low-latency bounded composition;
- safe fallback when visual data disappears;
- no dependency on mouse/keyboard or a connected remote viewer.

### Full remote desktop

- complete Bitwig application UI;
- pointer and keyboard input;
- project editing and configuration;
- plug-in management;
- modal-dialog recovery;
- service/maintenance access.

The remote client is a viewer/controller of the canonical workspace. Its window size, codec, zoom, device type, or connection state does not define the workspace geometry used by Pushwig.

## Attached versus managed operating modes

Pushwig retains two product modes.

### Attached mode

The user's existing desktop remains authoritative.

A backend is eligible for attached use only when it can coexist with ordinary application operation. It must not materially obstruct host controls, require a project-owned desktop geometry, or silently capture the wrong content.

The accepted macOS ScreenCaptureKit primary-window backend currently has:

```text
captures usable pixels: yes
bounded and performant: yes
window lifecycle: yes
attached interaction-safe: no on the tested fixture
```

That makes it an engineering/reference backend, not the current attached product source.

Attached mode remains a product goal. It may later use a safer OS capture mechanism, direct/generated sources, independently exposed editor windows, or another supported strategy.

### Managed mode

Pushwig owns a logical graphical workspace used by Bitwig.

Managed mode may control:

- compositor/session;
- logical resolution and scale;
- Bitwig window-placement policy;
- raw frame output;
- remote-view service;
- process supervision and recovery.

This is appropriate for the future Steam Deck/Framework/compact-x86 appliance and for deterministic visual testing.

Managed mode is not imposed on ordinary attached-desktop users.

## Canonical workspace

The managed workspace is the stable visual coordinate system.

```text
ManagedWorkspace
    workspace_id
    generation
    logical_width
    logical_height
    scale
    refresh_target
    compositor/backend identity behind adapter boundary
```

The workspace geometry is chosen by the managed host. Remote-view clients scale the workspace for their own displays after the fact.

Therefore:

```text
remote laptop resizes
        -> remote encoding/view changes
        -> canonical Bitwig workspace does not
        -> Pushwig visual source identity does not
```

This separation is central to future device profiles, calibration, anchor resolution, and remote operation.

## Visual surface contract

A source backend exposes portable facts rather than operating-system objects.

Conceptual descriptor:

```text
VisualSurface
    surface_id
    generation
    role
        attached-window
        managed-workspace
        managed-window
        direct-renderer
        analyzer
    logical_width
    logical_height
    pixel_scale
    capabilities
        interaction_safe
        cursor_free_or_separable
        stable_geometry
        remote_accessible
        supports_subregions
        restartable
```

Conceptual frame:

```text
VisualSurfaceFrame
    surface_id
    surface_generation
    sequence
    monotonic_time
    width
    height
    pixel_format
    complete
    valid
    frame_bytes
```

Backend-specific identifiers such as `SCWindow`, PipeWire node IDs, Wayland objects, X11 windows, DRM outputs, Windows capture handles, or VNC/RDP state may exist inside a backend. They do not define the portable source contract.

## Capability gating

Being able to return pixels is not enough.

A source advertises what operating modes it is safe for. Examples:

```text
macOS primary-window ScreenCaptureKit
    role: attached-window
    captures_pixels: true
    stable_geometry: true
    interaction_safe: false on accepted fixture

managed Weston output
    role: managed-workspace
    interaction_safe: expected/prove in V5
    stable_geometry: expected/prove in V5
    remote_accessible: expected/prove in V5
```

The presentation layer must never infer product suitability from backend existence alone.

## V5 reference stack

V5 uses current Linux components to prove this model, not to permanently select a distro or compositor.

Reference topology:

```text
Bitwig (+ Xwayland when required)
        -> Weston canonical output
             |                  |
             |                  +-> VNC/remote backend -> remote client
             |
             +-> PipeWire backend -> Pushwig Linux frame adapter
                                    -> opaque BGRA / V1D-2
                                    -> DrivenByMoss compositor
                                    -> Push
```

Current Weston supports PipeWire and VNC as secondary backends. PipeWire exposes video buffers through its public stream API. V5 should use stable output/node properties rather than treating a transient numeric PipeWire node ID as source identity.

Weston is a reference implementation. A later appliance may use Weston, gamescope, another Wayland compositor, Xwayland, or another managed environment if it satisfies the same source/workspace contract.

## Cursor and remote input

The full remote desktop needs a useful pointer. The Push source generally does not.

Managed mode therefore treats pointer presentation as a separate capability:

```text
remote desktop
    -> pointer visible / controllable as appropriate

raw Pushwig frame stream
    -> cursor excluded, separate metadata, or explicitly filtered
```

Cursor separation must be proven by the backend rather than inferred from the remote-view configuration.

## Process independence

The managed workspace contains several restart domains:

```text
Bitwig / audio engine
compositor / workspace
raw-frame adapter
remote desktop backend
Pushwig external-frame receiver
remote client
```

V5 should prove useful independence:

- remote client disconnect does not stop Bitwig;
- frame adapter restart does not stop Bitwig;
- remote-client resize does not resize the canonical workspace;
- visual-source restart does not require restarting the audio engine;
- loss of Push visuals returns to current semantic output.

The compositor itself may be a stronger failure domain. Its shutdown/restart impact on Bitwig must be characterized honestly.

## Relationship to Track A appliance

The eventual portable appliance is not merely “Push with a hidden screen.”

It is:

```text
Push 3 Controller
        + managed Linux Bitwig host
        + battery / power / boot / recovery
        + curated Push presentation
        + full wireless Bitwig desktop when needed
```

The first appliance may continue using Push's stock rear USB controller/audio path. Internal CM11EB/native-bay work is optional later hardware refinement.

## Relationship to device-aware presentation

The device-aware operating model remains valid:

```text
context router
semantic context
experience profile
visual resolver
semantic camera
presentation composer
source backend
```

V5 replaces the accidental assumption that `source backend == ScreenCaptureKit primary Bitwig window`.

After a managed source is proven, the blocked Sampler V4 goal can be reconsidered against a source that does not compromise the host UI. Device anchors, camera behavior, Browser redesign, Polymer, and other experience work remain upstream product design—not responsibilities of PipeWire or Weston.

## Direct/generated sources

Managed workspace capture is one source family, not the only one.

Direct sources remain first-class for tasks where structured data is better than pixels:

- Browser results and filters;
- project-owned waveform rendering when audio/sample data is available;
- analyzers;
- parameter graphs;
- companion applications.

A presentation may combine direct and captured sources as long as semantic/device coherence remains explicit.

## V1D-2 boundary

The accepted external raster ingress remains the final local frame boundary into DrivenByMoss for V5.

It is not the visual workspace protocol.

V1D-2 intentionally carries final bounded raster frames. It does not need to know about:

- PipeWire;
- remote desktop;
- device identity;
- workspace IDs;
- source capabilities;
- anchor evidence;
- camera intent.

The new workspace/source model exists upstream of that proven sink.

## V5 boundary

[V5 / issue #50](https://github.com/kasselvania/standalone-BitWig-push/issues/50) proves:

- one authoritative Bitwig session in a controlled Linux workspace;
- canonical geometry independent of the remote client;
- one raw PipeWire output consumed by a committed Pushwig adapter;
- one independent full remote-desktop path with pointer/keyboard control;
- actual raw frames delivered through unchanged V1D-2;
- restart/disconnect independence and bounded performance;
- platform-neutral source descriptors with Linux implementation details kept behind the backend.

V5 does not implement the custom Sampler page, device anchors, Browser redesign, Steam Deck packaging, or attached-mode portal capture.
