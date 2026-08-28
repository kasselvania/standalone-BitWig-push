# Architecture

## Product thesis

A better Push-for-Bitwig experience does not require choosing between a controller extension and a miniature desktop.

Use the strongest source for each job:

- **semantic state and control** from Bitwig's controller API and DrivenByMoss;
- **live visual sources** when Bitwig or a plug-in already renders information the controller API does not expose;
- **composition** to place the right information on Push's 960×160 display;
- **semantic fallback** whenever a visual source is missing, stale, or unsupported.

The primary software product must work for ordinary users on their existing computers. The Steam Deck appliance and the CM11EB/native-compute work are consumers of the same software contracts, not definitions of those contracts.

See [`PROJECT_TRACKS.md`](PROJECT_TRACKS.md).

## Deployment modes

### Attached mode — universal desktop integration

Bitwig remains in the user's existing desktop environment.

The project adapts to:

- different physical monitor arrangements;
- different Bitwig window sizes and positions;
- supported UI scales;
- Bitwig display profiles and panel arrangements;
- dedicated plug-in/device windows moving between displays;
- windows being closed and recreated.

Attached mode must not require a Steam Deck, a fixed virtual resolution, or project ownership of the full desktop.

### Managed mode — appliance and test geometry

The project controls a logical desktop, window policy, or remote session.

Managed mode is useful for:

- a headless Steam Deck/Framework/NUC appliance;
- deterministic automated tests;
- remote-only operation;
- systems where a fixed geometry is desirable.

A canonical virtual surface is one possible managed-mode implementation. It is not the universal portability mechanism.

## Parallel product tracks

### Track V — visual/controller software

Adaptive semantic + visual integration for Push/Bitwig users on supported computers.

### Track A — all-in-one appliance

Package Track V with a host, battery, boot/recovery services, and wireless desktop access. The maintainer's Steam Deck/base/battery rig is the first development appliance, not the only host profile.

### Track H — connector/native compute

Characterize Push's internal CM11EB carrier, publish development hardware, and eventually evaluate a native-bay Compute Element installation.

The tracks share acceptance contracts but do not block one another.

## Logical system

```text
Push pads/buttons/encoders
          |
          v
+---------------------------+
| controller integration    |
| DrivenByMoss derivative   |
+-------------+-------------+
              | semantic state + visual intent
              v
+---------------------------+          +--------------------------+
| state / intent broker     |<---------| Bitwig controller API    |
+-------------+-------------+          +--------------------------+
              |
              | requested source / selected device / layout state
              v
+---------------------------+
| visual source resolver    |
| identity + confidence     |
+------+------+-------------+
       |      |
       |      +---------------- embedded Bitwig panel resolver
       |
       +----------------------- dedicated/floating editor discovery
                               |
                               v
                    +---------------------------+
                    | capture backend           |
                    | OS/window/direct adapter  |
                    +-------------+-------------+
                                  |
semantic base frame -------------+
optional direct/analyzer frames --+
                                  v
                    +---------------------------+
                    | display compositor        |
                    | final 960x160 frame        |
                    +-------------+-------------+
                                  |
                                  v
                    Push USB display endpoint
```

## Component boundaries

### Controller integration

Responsibilities:

- observe project, track, device, parameter, preset, and application state;
- map Push inputs to Bitwig operations;
- maintain modes, sequencing, browsing, and transport;
- render or expose the semantic Push base frame;
- publish visual intent, including selected device and requested visual view;
- expose relevant application/device state where Bitwig's API provides it, such as panel layout, expansion, or plug-in-window state.

DrivenByMoss is the initial basis. Minimize the fork delta and prefer a narrow integration seam over invasive rewrites.

### State / intent broker

A local IPC contract connecting semantic control to visual services.

Candidate events include:

- selected track/device identity;
- native-device versus plug-in classification;
- device/preset/vendor identity;
- active Push mode;
- requested visual source and named view;
- plug-in/device-window desired/open state;
- Bitwig panel layout and visibility state where observable;
- transient overlay/notification requests;
- compositor, resolver, and capture health;
- active deployment and runtime profiles.

The broker must not sit on the audio path.

### Visual source resolver

The resolver converts semantic intent into a validated source window/region.

It uses an acquisition ladder:

1. dedicated top-level plug-in or floating native-device window;
2. Bitwig-main-window-relative embedded panel resolution;
3. bounded stored calibration;
4. direct project-owned frame source;
5. semantic-only fallback.

The resolver returns:

```text
source identity
source role
source-relative region
confidence
validation anchors
compatibility context
fallback behavior
```

It must revalidate after source recreation, resize, monitor move, UI-scale change, display-profile change, or Bitwig update.

### Attached-mode Bitwig resolver

Embedded native-device visuals require more than window capture.

Inputs may include:

- Bitwig application-window bounds;
- display profile and panel layout where observable;
- selected-device semantic state;
- normalized panel geometry;
- panel separators, headers, selection outlines, and device-specific visual anchors;
- adapter compatibility declarations.

The primary identity must never be a physical desktop rectangle.

### Managed visual surface

A managed deployment may run Bitwig inside controlled logical geometry with known UI scaling and window placement.

This reduces calibration for appliances and testing, but must remain behind the same resolver/capture contracts used by attached mode.

Gamescope, nested Xwayland, dedicated Xorg, or another implementation may be evaluated. No one backend is architectural authority.

### Capture backend

Responsibilities:

- enumerate/discover source windows or authorized screen streams;
- capture a complete source window or source-relative region;
- retain the last valid frame;
- publish frames at a bounded cadence;
- report stale/missing/permission-denied state;
- keep platform details behind a common contract.

Core frame contract:

```text
VisualSourceFrame
  source_id
  source_role
  width / height / pixel_format
  sequence / timestamp
  validity / stale_reason
  confidence
  frame_data
  optional metadata
```

Potential backend families:

- Linux X11/XComposite;
- Linux Wayland portal/PipeWire;
- managed Xwayland/nested compositor;
- Windows Graphics Capture;
- macOS ScreenCaptureKit;
- direct project-owned sources.

The compositor must not contain operating-system window handles.

### Visual adapters

A visual adapter combines semantic matching, source preferences, crop policy, compatibility, validation, and fallback.

Adapters should support:

- native-device/plug-in semantic identity;
- process/application/window-role matching;
- normalized source-relative regions;
- optional geometry for a named tested source size;
- Bitwig/plugin version and UI-scale declarations;
- anchor validation and confidence thresholds;
- fit policy and frame-rate limits;
- bounded calibration records;
- explicit semantic fallback.

See [`VISUAL_PORTABILITY.md`](VISUAL_PORTABILITY.md).

### Display compositor

The steady-state design has exactly one owner of Push USB display interface `0`, endpoint `0x01`.

Responsibilities:

- accept a semantic base frame;
- accept zero or more visual layers;
- crop, scale, and place layers;
- apply final 960×160 formatting;
- convert/send frames using the Push display protocol;
- remain responsive if capture or resolution fails;
- switch immediately to semantic/recovery output when confidence is insufficient.

Initial modes:

1. **Semantic** — controller-native UI only.
2. **Lens** — semantic UI plus a selected visual region.
3. **Focus** — selected visual source dominates the screen.
4. **Recovery** — compositor-local diagnostics independent of Bitwig visuals.

### Remote desktop / management

This is required for an appliance but not for the desktop visual extension.

It handles exceptional tasks:

- activation/settings;
- difficult dialogs;
- detailed editing;
- diagnostics and recovery;
- runtime/service management.

In managed mode, a remote client views the appliance desktop. In attached mode, the user's existing desktop remains authoritative.

## Display protocol basis

Existing independent implementations establish the practical Push 3 display path:

- USB VID `0x2982`, PID `0x1969`;
- interface `0`;
- OUT endpoint `0x01`;
- 960×160 frame;
- fixed 16-byte header;
- two-byte pixel representation with scan-line padding;
- XOR signal shaping before transfer.

Reuse proven protocol behavior rather than re-reverse-engineering it.

## Latency classes

Keep these domains separate:

1. **audio** — highest priority, never dependent on visual code;
2. **musical control/MIDI** — immediate and independent of capture;
3. **semantic display state** — interactive;
4. **captured/direct visuals** — opportunistic and bounded;
5. **remote desktop** — management latency, not musical-control latency.

A frozen or denied visual source must never freeze pads, encoders, transport, audio, or semantic display fallback.

## Repository topology

Planned original components:

```text
controller-integration/   # narrow DrivenByMoss/Bitwig integration seam
broker/                   # semantic state and visual-intent IPC
resolver/                 # source discovery, validation, calibration
capture/                  # OS/window/direct frame backends
compositor/               # Push framebuffer ownership and composition
visual-adapters/          # tested source/profile declarations
remote/                   # appliance desktop/management integration
appliance/                # optional host/boot/power packaging profiles
hardware/                 # optional connector/dock research
platform-tests/           # layout/backend compatibility matrices
diagnostics/              # USB, source, frame and latency tooling
evidence/                 # retained experimental evidence
```

Independent tracks may later split into dedicated repositories when contributor, safety, build-system, or release boundaries justify it.

## Host and hardware transitions

The visual/controller contracts must survive:

```text
ordinary desktop/laptop over external USB
        -> maintainer Steam Deck appliance over external USB
        -> Framework/compact-x86 appliance over external USB
        -> external host through internal CM11EB diagnostic path
        -> used NUC Compute Element native-bay appliance
```

Host replacement succeeds only when the same relevant acceptance suite continues to pass.
