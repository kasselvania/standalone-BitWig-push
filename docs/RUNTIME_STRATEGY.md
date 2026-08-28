# Runtime and Plug-in Strategy

## Purpose

The project must work first on the existing Steam Deck without confusing the core Push/display proof with every Linux plug-in compatibility problem.

This document separates:

- the Bitwig host runtime;
- native Linux plug-in formats;
- Windows plug-in bridging;
- standalone Linux audio/OSC services;
- the canonical visual surface used for capture;
- the physical monitor or remote client used to view that surface.

## Confirmed format boundary

Current Bitwig Studio documentation identifies these plug-in formats on Linux:

- VST2.4;
- VST3;
- CLAP.

Bitwig does not natively host LV2. Do not describe LV2 as a direct Bitwig plug-in path.

Project preference:

1. **CLAP** for native Linux plug-ins when available;
2. **VST3** when CLAP is unavailable or less mature;
3. **VST2.4** only where a legacy dependency requires it;
4. **standalone PipeWire/OSC/MIDI service** when hosting inside Bitwig offers no advantage;
5. **yabridge** only in a non-Flatpak host runtime.

References:

- Bitwig plug-in formats: <https://www.bitwig.com/modern-foundations/>
- Bitwig Flatpak plug-in guidance: <https://www.bitwig.com/support/technical_support/installing-bitwig-studio-on-linux-via-flatpak-52/>
- yabridge compatibility statement: <https://github.com/robbert-vdh/yabridge>

## Runtime A — Flatpak reference

The existing Steam Deck installation is the primary S0–S4 reference until evidence requires a change.

Advantages:

- already installed and activated;
- already known to run on SteamOS;
- already known to connect to Push;
- official Bitwig distribution path for modern Linux systems;
- PipeWire integration;
- low setup cost for the first display/compositor proof.

Constraints:

- plug-ins installed only under system paths such as `/usr/lib` are not visible inside the sandbox;
- native plug-ins should be placed in Flatpak-reachable user locations and added to Bitwig’s plug-in locations where necessary;
- controller/compositor IPC must use a path or transport visible to both the Bitwig sandbox and host services;
- yabridge explicitly does not support Flatpak DAWs;
- window capture behavior depends on the actual X11/Wayland/Xwayland session and permissions.

S0 must record:

```text
flatpak info <Bitwig app id>
flatpak info --show-permissions <Bitwig app id>
echo "$XDG_SESSION_TYPE"
echo "$WAYLAND_DISPLAY"
echo "$DISPLAY"
```

Do not abandon this runtime merely because Windows plug-ins are not yet available. It is sufficient for the first semantic/display/capture proofs and for a substantial native Linux instrument.

## Native plug-in baseline

A native plug-in baseline should include at least:

- one known-good CLAP instrument or effect;
- one known-good VST3 instrument or effect;
- plugdata as CLAP or VST3 where the tested build supports it;
- Bitwig native Sampler and one graphically useful native device.

For every candidate retain:

- exact version/build;
- installation path;
- whether Flatpak Bitwig discovers it;
- whether audio works;
- whether parameters are visible to Bitwig/DrivenByMoss;
- whether its editor can be opened, discovered and captured;
- whether project save/reload restores it.

## plugdata and Monome

plugdata can be built for Linux as standalone, VST3, LV2 and CLAP. For Bitwig:

- prefer the CLAP build when stable in the tested release;
- use VST3 as the direct fallback;
- use LV2 only with other LV2-capable hosts;
- use standalone plugdata when direct PipeWire/OSC routing is preferable.

Monome grid/arc devices use `serialosc`, which converts the USB serial device protocol to OSC. This is a good fit for the appliance because `serialosc` can run as a persistent user service independently of Bitwig and can serve plugdata/Pure Data or other applications.

Reference:

- plugdata: <https://github.com/plugdata-team/plugdata>
- serialosc: <https://github.com/monome/serialosc>
- Monome Linux setup: <https://monome.org/docs/serialosc/linux/>

Required future proof:

```text
Monome device -> serialosc -> plugdata/Pd patch -> Bitwig audio/MIDI path
```

The visual compositor may later render Monome/plugdata state as another visual source, but that is not required for the first Bitwig lens.

## Runtime B — non-Flatpak Windows plug-in laboratory

yabridge supports Windows VST2, VST3 and CLAP plug-ins under Wine, but its upstream documentation explicitly states that it does not work with Flatpak DAWs.

The leading experimental path on SteamOS is therefore:

```text
SteamOS host
   |
Distrobox / Podman
   |
Ubuntu 24.04 userspace
   +-- native Bitwig DEB
   +-- Wine Staging
   +-- yabridge
   +-- Windows plug-ins
```

Distrobox is preferred over an isolated raw Docker setup because its project explicitly integrates graphical applications, audio, the user home, external storage and external USB devices with the host.

This path remains **experimental** until it proves all of the following on the actual Deck:

- Bitwig GUI and child plug-in windows render correctly;
- PipeWire audio reaches acceptable buffers without recurring xruns;
- Push USB/MIDI/audio/display access works from the chosen process boundary;
- DrivenByMoss USB access works;
- Wine and yabridge plug-in processes survive project reload;
- the capture service can discover the plug-in windows;
- filesystem and project paths are portable between Runtime A and Runtime B;
- shutdown and update behavior are maintainable.

Do not move the whole project into a container merely to satisfy one plug-in. Runtime B is an optional compatibility profile, not the basis of S0.

Reference: <https://distrobox.it/>

## Runtime C — host-native services

Some components should run outside Bitwig regardless of Runtime A or B:

- display compositor;
- capture backend where sandbox rules permit;
- state/intent broker;
- remote desktop/management service;
- diagnostics and watchdogs;
- `serialosc`;
- optional waveform/spectrum analysis sidecars.

These services must communicate through explicit IPC rather than relying on process memory or undocumented Bitwig internals.

## Canonical visual surface

The visual system must not depend on the shape or resolution of a user’s physical monitor.

Bitwig should be rendered into a controlled **canonical logical desktop**, for example:

```text
1920x1080 logical surface
fixed Bitwig UI scaling
known panel layout
known plug-in window placement policy
```

The physical Steam Deck screen, an ultrawide desktop monitor, a tablet and a browser client then become viewers of that logical surface rather than authorities over its geometry.

### Leading backend candidate: gamescope

Valve’s gamescope can run nested on a normal desktop, provide an application with its own Xwayland sandbox and spoof a desired virtual resolution/refresh rate while scaling the output independently.

That makes it a strong Steam Deck candidate for:

- deterministic Bitwig geometry;
- isolation from arbitrary desktop layouts;
- fixed capture coordinates;
- different remote-client aspect ratios;
- GPU-accelerated composition.

This remains a test hypothesis because Bitwig is a multi-window desktop application, not a conventional single-window game. We must prove behavior with Bitwig child windows and plug-in editors.

Reference: <https://github.com/ValveSoftware/gamescope>

### Capture backend abstraction

Do not make the compositor depend directly on one window system.

Define an interface equivalent to:

```text
VisualSource
  - source identity
  - source pixel dimensions
  - timestamp / sequence
  - validity / stale state
  - frame data
  - optional window metadata
```

Potential backends:

- X11/XComposite window or ROI capture;
- Xwayland capture inside a controlled nested surface;
- PipeWire/XDG Desktop Portal capture;
- direct plug-in/application-provided frames;
- custom analyzer frames.

The compositor receives frames, not desktop implementation details.

## Resolution-independent visual adapters

A device or plug-in profile must not rely only on absolute monitor coordinates.

Profiles should support:

- window identity rules: PID, application ID, class and title patterns;
- normalized crop rectangles (`0.0`–`1.0`);
- optional pixel crops for a named canonical source size;
- expected UI scale/version;
- semantic anchors supplied by the controller integration;
- fit mode: contain, cover or exact;
- minimum useful source size;
- stale-frame and missing-window behavior;
- optional calibration checksum/screenshot.

Example:

```yaml
source:
  application: bitwig
  window_role: plugin-editor
  title_pattern: "Vital*"
  canonical_size: [1280, 720]

views:
  oscillator:
    normalized_crop: [0.02, 0.10, 0.96, 0.30]
    fit: contain
    max_fps: 20
```

The first native Bitwig profile should use a controlled canonical desktop before attempting arbitrary user layouts.

## Runtime acceptance matrix

Each supported runtime should publish a retained matrix:

| Capability | Flatpak reference | Native/container lab | Headless appliance |
|---|---|---|---|
| Bitwig launch | required | required before support | required |
| Push controls | required | required | required |
| Push display | required | required | required |
| Push audio | required | required | required |
| Native CLAP/VST3 | required | required | required |
| plugdata/serialosc | target | target | required for Monome profile |
| yabridge | unsupported by design | experimental/target | optional |
| canonical visual surface | target | target | required |
| wireless full desktop | later | later | required |

## Decision rule

Do not let the most difficult Windows plug-in become the gate for the project.

The first useful release can be built entirely from:

- Bitwig native devices;
- native Linux CLAP/VST3 plug-ins;
- plugdata/Pure Data;
- Monome/serialosc;
- DrivenByMoss;
- the project compositor and remote visual surface.

Windows plug-in support raises compatibility coverage; it does not define whether the instrument succeeds.
