# Runtime and Capture Strategy

## Purpose

The core visual/controller product must not be defined by the maintainer's Steam Deck, Flatpak installation, plug-in collection, Monome tooling, or prior yabridge experiments.

This document separates:

- the maintainer's first tested runtime;
- universal attached-mode visual behavior;
- managed appliance runtimes;
- optional plug-in compatibility experiments;
- operating-system capture backends.

## Reference fixture, not normative platform

S0 uses:

- Steam Deck / SteamOS-derived Linux;
- Flatpak Bitwig Studio;
- Push 3 Controller over external USB;
- DrivenByMoss.

This fixture is valuable because it exists and already works. Its job is to prove the first display seam and provide real hardware evidence.

It does **not** establish that:

- all users should run SteamOS;
- Bitwig must be Flatpak-packaged;
- the product requires a fixed virtual desktop;
- the user's monitor should match the Deck;
- yabridge, plugdata, Pure Data, Monome, or serialosc are core dependencies.

## Bitwig plug-in format boundary

Current Bitwig Linux builds directly host:

- VST2.4;
- VST3;
- CLAP.

Bitwig does not directly host LV2.

Native plug-ins are useful visual test sources, but the universal visual architecture must remain source-format-neutral after semantic selection/window discovery.

References:

- Bitwig plug-in formats: <https://www.bitwig.com/modern-foundations/>
- Bitwig Flatpak guidance: <https://www.bitwig.com/support/technical_support/installing-bitwig-studio-on-linux-via-flatpak-52/>

## Runtime R-A — maintainer Flatpak fixture

Use the existing Flatpak installation for S0 and early Linux proofs until evidence requires another runtime.

Record:

```text
flatpak info <Bitwig app id>
flatpak info --show-permissions <Bitwig app id>
echo "$XDG_SESSION_TYPE"
echo "$WAYLAND_DISPLAY"
echo "$DISPLAY"
```

Relevant constraints:

- sandbox-visible IPC paths must be chosen deliberately;
- host capture permissions differ between X11, Xwayland, and Wayland/portal paths;
- plug-ins must be visible inside the Flatpak sandbox;
- direct USB display ownership may remain in a host-side process.

These are fixture constraints, not universal architecture.

## Runtime R-B — ordinary desktop/laptop Bitwig

This is the primary product deployment class.

The project attaches to a user's existing Bitwig session without taking over their display geometry.

Requirements:

- discover Bitwig and editor windows through the operating-system backend;
- use semantic state and source-relative geometry rather than physical desktop coordinates;
- tolerate monitor/window/display-profile changes;
- request only the capture permissions required by the platform;
- keep semantic fallback available when capture is denied or unsupported.

Supported packaging may eventually include Flatpak, native Linux packages, Windows, and macOS. Packaging-specific code belongs in adapters, not the compositor.

## Runtime R-C — managed appliance

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
- visual services can restart without disrupting music/control.

## Capture backend families

### Linux X11/XComposite

Useful where Bitwig/editor windows are X11 or Xwayland windows and individual-window enumeration/capture is available.

### Linux Wayland portal/PipeWire

Use the XDG ScreenCast/RemoteDesktop portal and PipeWire streams where the compositor/security model requires user authorization.

The permission and stream-restoration lifecycle is part of the backend contract.

### Managed nested compositor

Useful for appliance/testing geometry, not required for attached desktop use.

### Windows

A future Windows backend may use Windows Graphics Capture or another supported window-capture API.

### macOS

A future macOS backend may use ScreenCaptureKit or another supported application/window capture API.

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

The compositor consumes this contract. It does not know whether the source came from XComposite, PipeWire, Windows, macOS, a nested surface, or a direct producer.

## Attached versus managed geometry

### Attached mode

- user's desktop remains authoritative;
- source windows are discovered dynamically;
- source-relative/normalized regions are used;
- calibration is scoped and invalidated by compatibility context;
- no fixed monitor resolution is required.

### Managed mode

- project may choose a logical resolution/UI scale/window policy;
- useful for appliances and automated tests;
- remote clients scale/view that managed desktop;
- not imposed on ordinary users.

See [`VISUAL_PORTABILITY.md`](VISUAL_PORTABILITY.md).

## Windows plug-in bridging

Wine/yabridge is optional compatibility research.

The maintainer has already observed substantial usability and UI problems with yabridge on the Steam Deck. Those observations should be retained if this track is reopened rather than replaced by an assumption that a container solves them.

Facts/boundaries:

- yabridge does not support Flatpak DAW hosts;
- another Bitwig runtime would be required for that experiment;
- Distrobox/Podman/native installation are candidates to test, not prescribed architecture;
- GUI behavior, project restore, capture, latency, update burden, and plugin-specific quirks must all be characterized;
- failure of Windows plug-in bridging does not invalidate the visual extension or all-in-one appliance.

Reference: <https://github.com/robbert-vdh/yabridge>

## Independent ecosystem integrations

The maintainer has separate work involving:

- a custom Steam Deck serialosc build and native Monome support;
- plugdata/Pure Data and Monome devices.

These projects may later implement optional visual-source or semantic adapters, but this repository must not present them as unproven future requirements, duplicate their roadmaps, or use them as acceptance gates for core work.

A stable integration boundary may eventually look like:

```text
external integration
      -> semantic/visual-source adapter
      -> project broker/compositor
```

## Runtime acceptance records

For each supported runtime/backend combination, publish a matrix containing only claims actually tested:

| Capability | Reference fixture | Attached desktop | Managed appliance |
|---|---|---|---|
| Bitwig launch | required | required | required |
| Push semantic control | required | required | required |
| Push display | required | required | required |
| Push audio | fixture evidence | supported profile | supported profile |
| dedicated-window discovery | later | required | required |
| embedded-panel resolver | later | supported matrix | supported matrix |
| arbitrary monitor geometry | not proved by fixture | primary requirement | not applicable/managed |
| remote desktop | not required | optional | required |
| yabridge | optional/problematic | optional | optional |

## Decision rule

Do not let a particular computer, packaging format, plug-in bridge, or external music-tool project define whether the adaptive Push visual software succeeds.

The core release is successful when it can:

- receive semantic intent from DrivenByMoss/Bitwig;
- discover or resolve supported visual sources without hard-coded physical coordinates;
- validate and composite those sources on Push;
- adapt across its declared desktop/layout test matrix;
- fall back safely when a visual source is unavailable.
