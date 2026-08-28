# Architecture

## Product thesis

A better Push-for-Bitwig experience does not require choosing between a controller extension and a miniature desktop.

Use both:

- **semantic rendering** for information the Bitwig controller API exposes cleanly;
- **visual capture** for information whose authoritative representation already exists in Bitwig or a plug-in UI;
- **composition** to select the best representation for the 960×160 Push display;
- **remote desktop** for the exceptional operations that do not belong on a 160-pixel-high screen.

This architecture is useful before any internal compute modification. The external Linux host is the first-class reference implementation.

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
             |                  headless / virtual Linux desktop
             |                              |
             |                              v
             |                   +--------------------------+
             |                   | Bitwig + plug-in windows |
             |                   +------------+-------------+
             |                                |
             |                                v
             |                   +--------------------------+
             +------------------>| capture service          |
                                 | window + ROI frame cache |
                                 +------------+-------------+
                                              |
semantic base frame --------------------------+
custom analyzers -----------------------------+
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

DrivenByMoss is the initial basis. We should minimize the fork delta and prefer a narrow integration seam over invasive rewrites.

### State / intent broker

A small local IPC contract connecting semantic control to visual services.

Initial events may include:

- selected track/device identity;
- device/plugin classification;
- plug-in window desired/open state;
- active Push mode;
- requested visual source and region;
- transient overlay/notification requests;
- compositor health.

The broker must not sit on the audio path.

### Capture service

Responsibilities:

- discover Bitwig and plug-in windows deterministically;
- capture a named window or region of interest;
- retain the last valid frame;
- publish new frames at a bounded cadence;
- report missing/changed windows without blocking control operation.

The first implementation should target X11 because window enumeration, placement, capture and recovery are comparatively observable. GPU-backed headless Xorg can replace Xvfb where plug-in acceleration requires it.

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
- diagnostics and service recovery.

The Push experience must remain useful without this surface during ordinary play.

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

A frozen VST window must never freeze pads, encoders, transport, or the semantic display fallback.

## Repository topology

Planned original components:

```text
controller-integration/   # integration seam / patches around upstream controller code
broker/                   # semantic state and visual-intent IPC
capture/                  # X11 window and ROI capture
compositor/               # Push framebuffer ownership and composition
visual-adapters/          # Bitwig/native/plugin-specific profiles
remote/                   # remote desktop/management integration
appliance/                # boot/service packaging for tested Linux targets
hardware/                 # carrier/breakout documentation and tooling
diagnostics/              # USB, ALSA, frame and latency inspection tools
evidence/                 # retained experimental evidence
```

Upstream projects should be forked under their own repositories unless there is a compelling reason to use a submodule. Do not bury upstream history inside this repo.

## Hardware transition

The software architecture must survive host replacement:

```text
Steam Deck over external USB
        -> Steam Deck through internal carrier USB breakout
        -> alternate internal x86 host or CM11EB Compute Element
        -> optional battery-capable appliance
```

Host replacement is successful only if the same software acceptance suite continues to pass.