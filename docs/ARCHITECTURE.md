# Architecture

## Product thesis

A better Push-for-Bitwig experience does not require choosing between a controller extension and a miniature desktop.

Use both:

- **semantic rendering** for information the Bitwig controller API exposes cleanly;
- **visual capture** for information whose authoritative representation already exists in Bitwig or a plug-in UI;
- **composition** to select the best representation for the 960×160 Push display;
- **remote desktop** for the exceptional operations that do not belong on a 160-pixel-high screen.

The software product is useful on an ordinary desktop, on the existing Steam Deck portable rig, in a Framework-based dock and eventually on a native NUC Compute Element. The host changes; the control/visual contracts do not.

## Product layers

### Desktop/controller layer

Any Linux host can use the hybrid semantic/visual experience while Push remains an ordinary tethered controller.

### Portable reference appliance

The first all-in-one physical system is deliberately conventional:

```text
battery / power distribution
          |
          +--> Steam Deck
          +--> Push barrel power through tested PD trigger cable

Steam Deck USB host
          |
          +--> Push rear USB device port

Steam Deck + battery + cables
          |
          +--> protected by the existing angled wooden base
```

This is already a legitimate standalone instrument once it boots headlessly and exposes the full desktop wirelessly. It does not require opening Push.

### Compute-dock layer

A Framework mainboard or another documented x86 host may later replace the Steam Deck inside the base while preserving the same external USB device contract.

### Native-bay research layer

A custom CM11EB-compatible development edge card can expose the internal carrier safely. A used NUC Compute Element plus a suitable battery is the native-bay endgame only after carrier, BIOS, thermal and power behavior are proven.

## Logical system

```text
Push pads/buttons/encoders
          |
          v
+-------------------------+
| controller integration  |
| DrivenByMoss derivative |
+------------+------------+
             | semantic state + visual intent
             v
+-------------------------+          +--------------------------+
| state / intent broker   |<---------| Bitwig controller API    |
+------------+------------+          +--------------------------+
             |
             |                    canonical logical desktop
             |                              |
             |                              v
             |                   +--------------------------+
             |                   | Bitwig + plug-in windows |
             |                   +------------+-------------+
             |                                |
             |                                v
             |                   +--------------------------+
             +------------------>| capture backend          |
                                 | window/portal/direct      |
                                 +------------+-------------+
                                              |
semantic base frame --------------------------+
custom analyzers -----------------------------+
plugdata/Monome visual sources ---------------+
                                              v
                                 +--------------------------+
                                 | display compositor       |
                                 | final 960x160 frame      |
                                 +------------+-------------+
                                              |
                                              v
                                 Push USB display endpoint
```

## Component boundaries

### Controller integration

Responsibilities:

- observe Bitwig project/track/device/parameter state;
- map Push inputs to Bitwig operations;
- maintain musical modes, sequencers, browsing and transport;
- render or expose a semantic Push base frame;
- publish visual intent, such as selected device and requested visual mode.

DrivenByMoss is the initial basis. Minimize the fork delta and prefer a narrow integration seam over invasive rewrites.

### State / intent broker

A small local IPC contract connecting semantic control to visual services.

Initial events may include:

- selected track/device identity;
- device/plugin classification;
- plug-in window desired/open state;
- active Push mode;
- requested visual source and region;
- transient overlay/notification requests;
- compositor health;
- canonical desktop geometry and UI scale;
- active runtime profile.

The broker must not sit on the audio path.

### Canonical visual surface

Bitwig should render into a controlled logical desktop whose dimensions and UI scaling are independent of the physical screen or remote client.

This solves two distinct problems:

1. visual profiles are not invalidated by every monitor aspect ratio;
2. the headless appliance and desktop product use the same source geometry.

A candidate initial contract is:

```text
logical resolution: 1920x1080
fixed Bitwig UI scale
known panel arrangement
known plug-in window placement policy
```

Valve gamescope is a leading Steam Deck experiment because it can run nested, provide a private Xwayland desktop and spoof a desired virtual resolution while independently scaling the output. It must still be proven with Bitwig’s multi-window behavior.

The canonical surface is not necessarily the capture implementation. It is the geometry authority.

### Capture service

Responsibilities:

- discover Bitwig and plug-in windows deterministically;
- capture a named window or region of interest;
- retain the last valid frame;
- publish new frames at a bounded cadence;
- report missing/changed windows without blocking control operation;
- abstract X11, Xwayland, portal/PipeWire and direct-frame sources behind one frame contract.

The first implementation may target X11/Xwayland because enumeration, placement and capture are observable. Do not bake X11-specific types into the compositor protocol.

### Visual adapters

A visual adapter translates semantic intent into a source selection and crop policy.

Adapters should prefer:

- application/window identity rather than desktop coordinates;
- normalized regions where possible;
- a named canonical source size where pixel-perfect crops are required;
- explicit Bitwig/plugin version and UI-scale compatibility;
- graceful fallback when a source is missing.

The same adapter model should work for:

- Bitwig Sampler and native devices;
- VST/CLAP editors;
- plugdata/Pure Data patches;
- custom spectrum/waveform sidecars;
- future Monome-oriented visualizations.

### Display compositor

The steady-state design has exactly one owner of Push USB display interface 0 / endpoint 0x01.

Responsibilities:

- accept a semantic base frame;
- accept one or more visual layers;
- crop, scale and place layers;
- apply final 960×160 formatting;
- convert/send frames using the Push display protocol;
- remain responsive if capture stalls or disappears.

Initial modes:

1. **Semantic** — controller-native UI only.
2. **Lens** — semantic UI plus selected captured region.
3. **Focus** — captured/native visualization dominates the display.
4. **Recovery** — compositor-local diagnostics independent of Bitwig UI.

### Remote desktop / management

A separate surface for setup and exceptional operations:

- Bitwig activation and settings;
- plug-in installation/configuration;
- difficult dialogs;
- Grid or detailed editing;
- diagnostics and service recovery;
- runtime switching where supported.

The remote client may have any aspect ratio. It views/scales the canonical logical desktop rather than redefining its geometry.

The Push experience must remain useful without this surface during ordinary play.

### Runtime profiles

The controller/compositor architecture must not assume one packaging format.

Initial profiles:

- **Flatpak reference:** current Steam Deck baseline, native CLAP/VST3 and Bitwig devices;
- **non-Flatpak compatibility lab:** native Bitwig plus Wine/yabridge, probably in Distrobox/Podman if real-device tests pass;
- **host-native services:** compositor, broker, serialosc, remote service and diagnostics.

See [`RUNTIME_STRATEGY.md`](RUNTIME_STRATEGY.md).

## Display protocol basis

Existing independent reverse engineering and DrivenByMoss establish a practical Push 3 display path:

- USB VID `0x2982`, PID `0x1969`;
- interface `0`;
- OUT endpoint `0x01`;
- 960×160 frame;
- 16-byte fixed header;
- 2-byte pixel representation with per-scanline padding;
- XOR signal shaping before transfer.

The first implementation should reuse proven protocol behavior rather than re-reverse-engineer it.

## Latency classes

Keep four latency domains separate:

1. **audio** — highest priority, never dependent on this project’s visual code;
2. **musical control/MIDI** — immediate and independent of capture;
3. **semantic display state** — interactive, typically tens of frames per second;
4. **captured visuals** — opportunistic, may run at 10–30 fps depending on source.

A frozen VST window must never freeze pads, encoders, transport, plugdata/serialosc services or the semantic display fallback.

## Repository topology

Planned original components:

```text
controller-integration/   # integration seam / patches around upstream controller code
broker/                   # semantic state and visual-intent IPC
capture/                  # visual-source backends and ROI capture
compositor/               # Push framebuffer ownership and composition
visual-adapters/          # Bitwig/native/plugin/plugdata profiles
remote/                   # remote desktop/management integration
appliance/                # boot/service packaging for tested Linux targets
hardware/                 # dock, power, carrier/breakout documentation and tooling
diagnostics/              # USB, ALSA, frame and latency inspection tools
evidence/                 # retained experimental evidence
```

Upstream projects should be forked under their own repositories unless there is a compelling reason to use a submodule. Do not bury upstream history inside this repo.

## Hardware transition

The software architecture must survive these packaging transitions:

```text
ordinary Linux desktop over external USB
        -> portable Steam Deck/base/battery appliance over external USB
        -> Framework or compact x86 dock over external USB
        -> same host through internal CM11EB USB breakout
        -> used NUC Compute Element + selected internal battery
```

The external rear USB path is first-class, not an embarrassing temporary hack. It is the known-good behavioral contract and remains a valid product configuration.

Host replacement is successful only if the same software acceptance suite continues to pass.

## Battery requirement

Portable standalone operation requires a battery. Distinguish two scopes:

- **reference battery integration:** use an existing complete protected battery and tested power cables to power the Steam Deck/host and Push early;
- **native-bay battery engineering:** select or design the final internal battery, charging and power-path system for a NUC/Framework final form.

The first is part of the early portable appliance. The second remains safety-critical hardware research.
