# Runtime and visual-source strategy

## Purpose

Pushwig's core visual/controller product must not be defined by one maintainer computer, operating system, packaging format, plug-in collection, or appliance enclosure.

This document separates:

- development fixtures;
- attached-desktop operation;
- managed/appliance operation;
- raw visual-source backends;
- full remote-desktop access;
- direct/generated sources;
- portability checkpoints.

The active implementation scope lives in `CURRENT_SLICE.md` and the owning issue.

## Development fixture versus product runtime

### macOS fixture

The Mac was selected because it provided the fastest source/build/install/measurement loop for:

- tracing and modifying DrivenByMoss;
- proving the Push frame seam;
- implementing semantic restoration;
- implementing the raster sink and external ingress;
- proving real host pixels could be processed and displayed on Push;
- testing one concrete window-capture backend.

It was never the normative product platform.

The macOS helper uses AppKit/CoreGraphics/ScreenCaptureKit/CoreMedia/CoreVideo/Core Image internally. Those types do not define the portable source, resolver, presentation, or controller-extension contracts.

V4 preflight showed that the current primary-window ScreenCaptureKit source is not interaction-safe enough for ordinary attached use because macOS sharing UI obstructs normal Bitwig window controls.

### Linux fixture

Linux is the named second-host portability and managed-runtime fixture.

Its jobs include:

- prove the source/runtime contracts are not accidentally macOS-specific;
- provide a controlled compositor/workspace for Bitwig;
- expose raw video frames through a Linux-native media path;
- provide full remote desktop/input independently of the Push visual path;
- later support the Steam Deck/Framework appliance packaging.

V5 uses a general Linux host first when practical so the source architecture can be proven without simultaneously solving SteamOS/Flatpak/power constraints.

## Operating mode A — attached desktop

Bitwig remains in the user's existing desktop environment.

Requirements:

- ordinary host-application controls remain usable;
- source discovery does not require project-owned desktop geometry;
- monitor and window placement are not source identity;
- capture permissions and platform UI are acceptable for ordinary use;
- visual failure returns to current semantics;
- direct/generated sources can substitute for capture when capture is unsuitable.

The accepted macOS ScreenCaptureKit primary-window implementation currently fails the interaction-safety requirement on the tested fixture.

That does not remove attached mode from the product. It removes that backend from the currently supported attached-source set.

## Operating mode B — managed Bitwig workspace

Pushwig controls the logical graphical workspace in which Bitwig runs.

Managed mode may own:

- compositor/session;
- workspace dimensions and scale;
- Bitwig window placement policy;
- raw video output;
- remote-desktop service;
- process supervision and recovery.

Managed mode is appropriate for:

- future Steam Deck/Framework/compact-x86 appliances;
- headless/remote-only use;
- deterministic visual profiles;
- automated acceptance fixtures.

### Canonical geometry

The workspace has one canonical geometry independent of the remote client.

```text
canonical workspace
        +-> raw frame adapter -> Push
        +-> encoded/scaled remote desktop -> client
```

Remote-client resize or zoom does not change the managed workspace's logical dimensions or source identity.

## V5 reference runtime

Use Weston as the first managed compositor reference and PipeWire as the raw-video path.

Current Weston supports backends including DRM, Wayland, X11, RDP, headless and PipeWire, and supports PipeWire and VNC as secondary backends. This allows one renderer/output model to expose multiple consumers in supported configurations.

Reference topology:

```text
Bitwig (+ Xwayland when required)
        -> Weston canonical workspace
             +-> PipeWire secondary output -> Pushwig Linux adapter
             +-> VNC or equivalent remote output -> remote client
```

The exact runnable topology depends on the Weston build and host graphics environment. V5 may use DRM, nested Wayland/X11, or headless as the primary backend as long as it preserves one canonical workspace and independent raw-frame/remote consumers.

Weston is not a permanent product dependency. It is the first reference implementation of the managed-workspace contract.

## Raw frame backend — PipeWire

The V5 Linux adapter consumes video from a PipeWire node using the public stream API.

Responsibilities:

- discover the intended managed-workspace output using stable properties/name;
- negotiate video format, dimensions and framerate;
- dequeue complete current buffers;
- use no application FIFO or historical replay;
- convert/crop/scale only as needed for the current Push proof;
- keep cursor pixels separate/excluded for the Push path;
- publish bounded opaque BGRA through unchanged V1D-2;
- stop/reconnect boundedly on stream loss.

PipeWire node IDs are transient backend state, not portable source identity.

## Full remote access

The managed workspace also exposes the complete Bitwig UI to another computer/device.

Required capabilities:

- see the complete Bitwig desktop;
- pointer and keyboard input;
- normal Bitwig window controls;
- disconnect/reconnect without stopping the DAW;
- remote-client resize/zoom without changing canonical workspace geometry;
- trusted-network authentication/binding appropriate to the development fixture.

The remote desktop is a service/control plane, not a source of Push frames.

## Source backend families

The portable source layer may later have backends such as:

### Managed compositor output

- Weston + PipeWire;
- gamescope or another compositor;
- dedicated Xwayland/Wayland output;
- future appliance-specific workspace backend.

### Linux attached mode

- X11/XComposite;
- XDG ScreenCast portal + PipeWire;
- compositor-specific capture where appropriate.

### macOS

- ScreenCaptureKit for engineering/reference use;
- a future safer attached source if one is found;
- managed/direct sources where applicable.

### Windows

- Windows Graphics Capture or another supported backend later.

### Direct/generated sources

- Browser semantic renderer;
- waveform/analyzer sidecar;
- project-owned visual application;
- structured companion protocol.

The Push compositor must not contain backend-specific window or stream handles.

## Portable source contract

Conceptual source descriptor:

```text
VisualSurface
    surface_id
    generation
    role
    logical_width
    logical_height
    pixel_scale
    capabilities
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
    frame_data
```

Capability flags describe properties such as interaction safety, cursor separation, stable geometry, remote accessibility, subregion support and restartability.

## Relationship to V1D-2

V1D-2 remains the final raster ingress into DrivenByMoss.

```text
source backend / resolver / presentation upstream
        -> final opaque BGRA Push region
        -> V1D-2
        -> semantic bitmap
        -> sole Push USB writer
```

Do not expand V1D-2 into a compositor/session/remote-desktop protocol merely because V5 introduces richer upstream source concepts.

## Track A — appliance runtime

The eventual appliance uses the same managed-workspace concept:

```text
managed Linux Bitwig host
        +-> Push curated interface
        +-> full wireless Bitwig desktop
        +-> local audio/MIDI/Push USB
        +-> battery / boot / recovery
```

The Steam Deck remains the first named appliance fixture. Framework/compact-x86 hosts remain alternatives. Internal CM11EB/native-bay work is optional later packaging.

## Acceptance records

For each runtime/backend combination, retain only claims actually tested:

| Capability | Mac fixture | V5 Linux managed fixture | Future attached release | Future appliance |
|---|---|---|---|---|
| Push semantic control | accepted | prove/retain | required | required |
| final Push raster path | accepted | reuse/prove | required | required |
| attached interaction-safe source | blocked for current SCK path | not V5 | required per backend | n/a/optional |
| managed canonical workspace | not current product source | V5 | optional | required |
| raw compositor video | not tested | V5 PipeWire | backend-dependent | required/source-dependent |
| full remote desktop/input | not core proof | V5 | optional | required |
| remote resize independent of source geometry | not applicable | V5 | backend-dependent | required |
| Linux/Flatpak/portal attached capture | not applicable | later | later | optional |

## Decision rule

Do not let a particular computer, operating system, compositor, remote protocol, plug-in format, or packaging choice define whether Pushwig succeeds.

The core system succeeds when it can:

- receive semantic intent from DrivenByMoss/Bitwig;
- obtain a product-valid visual/direct source for a declared operating mode;
- keep source identity independent of incidental physical client geometry;
- validate and compose useful visuals on Push;
- provide full Bitwig access where the managed appliance requires it;
- fall back safely when a visual source is unavailable.
