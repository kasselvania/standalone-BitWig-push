# Runtime and Capture Strategy

## Purpose

The core visual/controller product must not be defined by one maintainer computer, packaging format, plug-in collection, or appliance enclosure.

This document separates:

- the active macOS development fixture;
- the later Steam Deck/Linux portability and appliance fixture;
- universal attached-mode visual behavior;
- managed appliance runtimes;
- optional plug-in compatibility experiments;
- operating-system capture backends.

## Active reference fixture, not normative platform

S0 now uses:

- the maintainer's macOS computer;
- Bitwig Studio;
- Push 3 Controller over external USB;
- DrivenByMoss.

This fixture is valuable because it is currently available and already works. Its job is to prove the display seam and provide a fast source-level development loop.

It does **not** establish that:

- all users should run macOS;
- the visual contracts may contain Apple-specific handles or image types;
- the appliance will use a Mac;
- Linux or Steam Deck support is optional forever;
- one monitor arrangement defines visual portability.

The Steam Deck remains:

- the maintainer's first Track A appliance host;
- a later Linux/Flatpak runtime fixture;
- the named second-host portability checkpoint for the core visual contracts.

## Runtime R-A — macOS development fixture

Use the existing Mac installation for S0, V1, and the first dedicated-window visual proof.

Record:

```text
sw_vers
uname -a
uname -m
system_profiler SPHardwareDataType
system_profiler SPUSBDataType
system_profiler SPAudioDataType
system_profiler SPDisplaysDataType
```

Relevant properties:

- no Flatpak boundary exists between Bitwig and the installed DrivenByMoss extension;
- final Push USB transport can initially remain in the DrivenByMoss derivative;
- a native helper can own macOS capture permissions and window enumeration;
- a Unix-domain socket and shared-memory or memory-mapped frame path are available implementation candidates;
- capture permission state must be observable and revocable;
- semantic fallback must work when the helper is absent or denied.

These are fixture constraints, not universal architecture.

## macOS capture backend

The leading macOS backend uses ScreenCaptureKit through a normal bundled helper application.

Responsibilities:

- enumerate shareable Bitwig and editor windows;
- match a requested semantic/window role;
- capture a dedicated window or bounded source-relative region;
- handle Screen Recording permission lifecycle;
- report missing, denied, stale, resized, and recreated-window state;
- publish only platform-neutral frame data and metadata.

The helper may internally use Apple types such as `SCWindow`, `SCContentFilter`, and `CVPixelBuffer`. Those types must not cross into:

- the DrivenByMoss integration contract;
- the resolver interface;
- visual adapters;
- the compositor frame protocol.

The first capture target should be a dedicated/floating native-device view or plug-in editor. Embedded-panel recognition remains a later resolver problem.

## Runtime R-B — ordinary attached desktop/laptop Bitwig

This is the primary product deployment class.

The project attaches to a user's existing Bitwig session without taking over display geometry.

Requirements:

- discover Bitwig and editor windows through the operating-system backend;
- use semantic state and source-relative geometry rather than physical desktop coordinates;
- tolerate monitor, window, UI-scale, and display-profile changes;
- request only permissions required by the platform;
- keep semantic fallback available when capture is denied or unsupported;
- allow the same visual adapter to operate across backends without compositor changes.

Supported platforms may include macOS first, Linux next, and Windows later. Packaging-specific code belongs in adapters/helpers, not the compositor.

## Runtime R-C — Steam Deck/Linux fixture

When the Steam Deck is available, it becomes the explicit second-host portability and appliance fixture.

Its jobs are different from the Mac fixture:

- prove the frame, resolver, and adapter contracts were not accidentally macOS-specific;
- characterize Flatpak-visible IPC and plug-in paths;
- implement the Linux X11/Xwayland or Wayland/portal capture backend;
- measure Steam Deck CPU/power cost for the compositor and anchor resolver;
- prepare the managed/headless Track A appliance profile.

Relevant evidence may include:

```text
flatpak info <Bitwig app id>
flatpak info --show-permissions <Bitwig app id>
echo "$XDG_SESSION_TYPE"
echo "$WAYLAND_DISPLAY"
echo "$DISPLAY"
lsusb
aconnect -l
wpctl status
```

The Linux port is a named acceptance checkpoint, not something silently assumed from platform-neutral interfaces.

## Runtime R-D — managed appliance

A portable/headless appliance may control its own graphical session.

Possible implementations include:

- nested gamescope/Xwayland;
- dedicated Xorg/Xwayland session;
- Wayland compositor with portal/PipeWire capture;
- another controlled desktop/session manager.

Managed geometry can make window placement and remote viewing deterministic, but it remains a deployment optimization. It must use the same visual-source/resolver/compositor contracts as attached mode.

A managed appliance must prove:

- Bitwig main and child windows work;
- audio and Push USB remain stable;
- remote-view scaling does not change source identity;
- modal dialogs are recoverable;
- visual services restart without disrupting music/control;
- safe shutdown and project retention work.

## Capture backend families

### macOS ScreenCaptureKit

First implementation backend for the available Mac fixture. Use a dedicated helper and a platform-neutral output contract.

### Linux X11/XComposite

Useful where Bitwig/editor windows are X11 or Xwayland windows and individual-window enumeration/capture is available.

### Linux Wayland portal/PipeWire

Use the XDG ScreenCast/RemoteDesktop portal and PipeWire streams where the compositor/security model requires user authorization.

The permission and stream-restoration lifecycle is part of the backend contract.

### Managed nested compositor

Useful for appliance/testing geometry, not required for attached desktop use.

### Windows

A future Windows backend may use Windows Graphics Capture or another supported window-capture API.

### Direct sources

Project-owned analyzers or companion applications may publish frames directly and bypass screen capture.

## Platform-neutral frame boundary

```text
VisualSourceFrame
  source_id
  source_role
  width
  height
  pixel_format
  sequence
  timestamp
  validity
  stale_reason
  confidence
  frame_data
  optional_metadata
```

The compositor consumes this contract. It does not know whether the source came from ScreenCaptureKit, XComposite, PipeWire, Windows, a managed surface, or a direct producer.

## First display/composition process boundary

The first Mac implementation should keep final composition and USB transmission in the DrivenByMoss derivative:

```text
macOS capture helper
        -> VisualSourceFrame snapshot over IPC
        -> in-process PushFramePipeline
        -> existing Push USB transport
```

This avoids competing USB owners while the frame seam is being proven.

The implementation sequence is:

1. no-op frame pipeline;
2. synthetic in-process overlay;
3. external generated-frame ingress;
4. macOS window capture;
5. semantic/pixel-anchor resolution.

A later architecture may move USB transport out of process only if evidence shows a clear benefit.

## Attached versus managed geometry

### Attached mode

- user's desktop remains authoritative;
- source windows are discovered dynamically;
- source-relative/normalized regions are used;
- calibration is scoped and invalidated by compatibility context;
- no fixed monitor resolution is required.

### Managed mode

- project may choose a logical resolution, UI scale, or window policy;
- useful for appliances and automated tests;
- remote clients scale/view that managed desktop;
- not imposed on ordinary users.

See [`VISUAL_PORTABILITY.md`](VISUAL_PORTABILITY.md).

## Bitwig plug-in format boundary

Plug-in formats differ by platform and runtime, but the visual architecture should become source-format-neutral after semantic selection and window discovery.

For later Linux work, current Bitwig Linux builds directly host:

- VST2.4;
- VST3;
- CLAP.

Bitwig does not directly host LV2.

References:

- Bitwig plug-in formats: <https://www.bitwig.com/modern-foundations/>
- Bitwig Flatpak guidance: <https://www.bitwig.com/support/technical_support/installing-bitwig-studio-on-linux-via-flatpak-52/>

## Windows plug-in bridging

Wine/yabridge is optional compatibility research.

The maintainer has already observed substantial usability and UI problems with yabridge on the Steam Deck. Those observations should be retained if this track is reopened rather than replaced by an assumption that a container solves them.

Boundaries:

- yabridge does not support Flatpak DAW hosts;
- another Bitwig runtime would be required for that experiment;
- Distrobox/Podman/native installation are candidates to test, not prescribed architecture;
- GUI behavior, project restore, capture, latency, update burden, and plug-in-specific quirks must all be characterized;
- failure of Windows plug-in bridging does not invalidate the visual extension or appliance.

Reference: <https://github.com/robbert-vdh/yabridge>

## Independent ecosystem integrations

The maintainer has separate work involving:

- a custom Steam Deck serialosc build and native Monome support;
- plugdata/Pure Data and Monome devices.

These projects may later implement optional visual-source or semantic adapters, but this repository must not present them as unproven future requirements, duplicate their roadmaps, or use them as acceptance gates for core work.

## Runtime acceptance records

For each supported runtime/backend combination, publish a matrix containing only claims actually tested:

| Capability | Mac fixture | Linux/Deck fixture | Attached release | Managed appliance |
|---|---|---|---|---|
| Bitwig launch | required | required later | required | required |
| Push semantic control | required | required later | required | required |
| Push display | required | required later | required | required |
| Push audio | fixture evidence | fixture evidence | supported profile | supported profile |
| no-op frame seam | required | portability check | required | required |
| dedicated-window discovery | first backend | second backend | required | required |
| embedded-panel resolver | later | later | supported matrix | supported matrix |
| arbitrary monitor geometry | fixture sample only | fixture sample only | primary requirement | not applicable/managed |
| remote desktop | not required | later | optional | required |
| yabridge | unrelated | optional/problematic | optional | optional |

## Decision rule

Do not let a particular computer, operating system, packaging format, plug-in bridge, or external music-tool project define whether the adaptive Push visual software succeeds.

The core release is successful when it can:

- receive semantic intent from DrivenByMoss/Bitwig;
- discover or resolve supported visual sources without hard-coded physical coordinates;
- validate and composite those sources on Push;
- adapt across its declared platform/layout test matrix;
- fall back safely when a visual source is unavailable.
