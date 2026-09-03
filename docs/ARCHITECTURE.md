# Architecture

## Product thesis

Pushwig combines:

- **semantic control/state** from Bitwig's controller API and DrivenByMoss;
- **visual information** from a source backend when graphics improve a specific Push task;
- **a curated Push presentation** that remains useful when visual data is absent.

The project is not a Mac screen-capture utility. The Mac was the first development fixture used to prove the downstream display path and one concrete capture backend.

## Proven downstream system

```text
Push controls
    |
    v
DrivenByMoss fork <---------------- Bitwig controller API
    |
    | current semantic Push frame
    |
    +<--------- newest valid final raster --------+
    |                                             |
    v                                             |
Push display composition                          |
    |                                             |
    v                                             |
sole Push USB display writer                      |
                                                  |
visual-source adapter ----------------------------+
```

The accepted V1D-2 boundary provides a bounded capability-authenticated local raster ingress. It remains the final frame sink in the current architecture.

If a frame is absent, stale, malformed, disconnected, or rejected, current DrivenByMoss semantics remain authoritative.

See [`PROTOCOLS.md`](PROTOCOLS.md).

## What the Mac proved

The maintained macOS helper proved that Pushwig can:

- obtain real host-application pixels;
- identify and follow a Bitwig window;
- crop and scale frames explicitly inside a helper;
- keep CPU, memory and processing bounded;
- publish frames through V1D-2;
- preserve Push controls and audio;
- restore semantics on source loss.

That work proved the **downstream visual substrate** and one source implementation.

It did not make macOS or ScreenCaptureKit the product architecture.

## Attached macOS source blocker

On the tested fixture, continuous ScreenCaptureKit capture of Bitwig's primary window causes macOS sharing UI to occupy Bitwig's normal window-control area. The maintainer could not use the ordinary minimize and full-screen controls while capture was active.

Therefore the accepted ScreenCaptureKit primary-window implementation is:

```text
engineering/reference source: yes
current attached-desktop product source: no
```

V4 Sampler device-page work remains blocked at this source prerequisite. See [issue #49](https://github.com/kasselvania/standalone-BitWig-push/issues/49).

## Managed visual workspace

V5 establishes the next source/runtime architecture.

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

The Push path and remote desktop are independent consumers of the same Bitwig session.

### Canonical workspace

Managed mode owns one logical graphical workspace with stable dimensions and scale.

Remote-client resize, zoom and encoding happen after that workspace and must not redefine the geometry used by Pushwig.

### Raw frame source

A compositor/backend exposes complete video frames through a platform-specific adapter. V5 uses Weston + PipeWire as the first Linux reference.

### Full remote desktop

A remote backend exposes the complete managed Bitwig UI and pointer/keyboard input for deep editing, configuration, recovery, and maintenance.

Disconnecting the remote client must not stop Bitwig or the Push path.

See [`design/managed-visual-workspace.md`](design/managed-visual-workspace.md).

## Portable visual-source contract

The source layer exposes portable meaning rather than operating-system handles.

Conceptually:

```text
VisualSurface
    surface_id
    generation
    role
    logical_width / logical_height
    pixel_scale
    capabilities
        interaction_safe
        cursor_free_or_separable
        stable_geometry
        remote_accessible
        supports_subregions
        restartable

VisualSurfaceFrame
    surface_id
    surface_generation
    sequence
    monotonic_time
    width / height
    pixel_format
    complete / valid
    frame_bytes
```

Backend values such as `SCWindow`, PipeWire node IDs, Wayland/X11 objects, DRM outputs, VNC/RDP state, or Windows capture handles do not define the portable contract.

A source must advertise product-relevant capabilities. “Returns pixels” is not sufficient to qualify a backend for attached or managed operation.

## Device-aware presentation layer

Above the source layer, the current product vocabulary remains:

```text
context router
semantic context
experience profile
visual resolver
semantic camera
presentation composer
source backend
```

- DrivenByMoss supplies current musical/controller semantics.
- Experience profiles describe supported object/task behavior.
- A resolver establishes a verified visual subject and regions.
- A semantic camera frames verified regions according to user attention/task.
- The presentation composer combines native/direct visuals with Push-specific semantics.
- The source backend supplies frames/data without defining controller authority.

See [`design/device-aware-presentation-layer.md`](design/device-aware-presentation-layer.md).

V5 does not implement the device-aware layer; it provides a viable managed source for later device work.

## Direct/generated sources

Managed compositor capture is one source family, not the only source family.

Direct/generated sources remain first-class for tasks such as:

- Browser results and filters;
- waveforms when underlying audio/sample data is available;
- analyzers;
- parameter graphs;
- project-owned companion applications.

The Push presentation may combine direct and captured sources when semantic coherence is explicit.

## Attached versus managed modes

### Attached

The user's existing desktop is authoritative. A backend must coexist with normal application use and cannot require project-owned desktop geometry.

The current macOS primary-window ScreenCaptureKit backend is not accepted for attached use on the tested fixture.

Attached mode remains a product goal and may later use a safer OS mechanism, dedicated source window, direct renderer, portal/backend, or another supported approach.

### Managed

Pushwig controls the graphical workspace. This is appropriate for:

- the future Steam Deck/Framework/compact-x86 appliance;
- deterministic testing;
- remote-only/headless workflows;
- stable device-profile geometry.

Managed mode is not imposed on ordinary attached-desktop users.

## Track A relationship

The eventual appliance is:

```text
Push 3 Controller
        + managed Linux Bitwig host
        + battery / boot / recovery
        + curated Push presentation
        + full wireless Bitwig desktop when needed
```

The first appliance may continue to use Push's stock rear USB controller/audio path. Internal CM11EB/native-bay work remains optional hardware refinement.

## Ownership invariants

- Bitwig owns the DAW and audio engine.
- DrivenByMoss owns semantic Push behavior and the sole Push display USB endpoint.
- V1D-2 remains a bounded final-raster boundary, not the workspace/source protocol.
- Visual capture/rendering never blocks musical control or audio.
- The remote desktop is not the Push transport.
- Historical composed pixels are never restoration authority.
- Wrong, unsupported or ambiguous visuals prefer semantic fallback.
- Platform-specific source objects do not define device or presentation behavior.
- Current encoder binding—not encoder number alone—is semantic control identity.
- A source that is technically capable but materially disrupts host use is not product-valid for that operating mode.

## Current V5 placement

[V5 / issue #50](https://github.com/kasselvania/standalone-BitWig-push/issues/50) proves one managed Linux Bitwig workspace with:

- canonical geometry;
- raw PipeWire frames;
- a committed Linux frame adapter feeding unchanged V1D-2;
- independent full remote desktop/input;
- restart/disconnect independence;
- platform-neutral source descriptors.

It does not resume the custom Sampler page or solve attached capture on macOS.
