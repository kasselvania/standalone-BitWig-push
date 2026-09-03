# Architecture

## Product thesis

Pushwig combines two information sources without confusing their responsibilities:

- **semantic control/state** from Bitwig's controller API and DrivenByMoss;
- **visual pixels** from an optional platform helper or direct visual source when graphical information improves a specific task.

The controller path remains useful when the visual path is absent, unsupported or broken.

Pushwig does not replace every controller page merely because pixels are available. Existing DrivenByMoss track, mixer, session, transport and performance screens remain the default unless a deliberate Pushwig experience is better for that context.

## Current system

```text
Push controls
    |
    v
DrivenByMoss fork <---------------- Bitwig controller API
    |
    | current mode, device, parameters and semantic Push frame
    |
    +<--------- newest valid visual frame --------+
    |                                             |
    v                                             |
context-gated presentation + display composition  |
    |                                             |
    v                                             |
Push USB display endpoint                         |
                                                  |
macOS capture helper -----------------------------+
    ^
    |
ScreenCaptureKit / Bitwig window / helper-local crop and scale
```

### 1. DrivenByMoss integration

The project fork of DrivenByMoss owns:

- Push input handling and semantic modes;
- current device, parameter-page and encoder-binding semantics;
- the current semantic display;
- deciding whether a Pushwig presentation is eligible in the current Push context;
- visual restoration when an overlay disappears;
- validated raster application;
- external latest-frame intake;
- the sole Push display USB writer.

Pushwig deliberately keeps platform capture outside the extension. Device-aware pages may change how semantics are arranged without replacing the established musical control model.

See [`integrations/drivenbymoss.md`](integrations/drivenbymoss.md).

### 2. macOS visual helper

The maintained helper under `capture/macos/**` owns:

- macOS Screen Recording permission;
- ScreenCaptureKit display/window inventory and capture;
- source validity and window-generation handling;
- helper-local crop and aspect-preserving scale;
- opaque BGRA normalization;
- publication through the local external-frame protocol.

It does **not** own Push MIDI, audio, semantic parameter bindings, bitmap memory or USB transport.

V3 established a human-readable profile that follows one unique Bitwig window through ordinary movement, supported resize, source loss and recreation. The helper explicitly applies a normalized crop to the complete captured window because ScreenCaptureKit does not honor `sourceRect` for single-window capture.

That profile is still device-unaware. It can follow the correct Bitwig window while Bitwig moves the desired device inside its internal layout.

### 3. External frame boundary

The helper publishes complete frames to the DrivenByMoss derivative over capability-authenticated IPv4 loopback. The receiver keeps bounded storage and exposes only the newest complete publication. The display path adopts a frame without blocking on socket I/O.

If a frame is absent, stale, malformed, disconnected or rejected, Push uses current semantic output.

See [`PROTOCOLS.md`](PROTOCOLS.md).

### 4. Device-aware presentation operating layer

The post-V3 product phase is organized by seven concepts:

```text
context router
semantic context
experience profile
visual resolver
semantic camera
presentation composer
platform capture backend
```

This is design vocabulary, not another authority hierarchy.

- **Context routing** decides when Pushwig should participate and preserves existing screens elsewhere.
- **Semantic context** describes the current mode, selected object, parameter page, eight encoder bindings and touch/edit state.
- **Experience profiles** describe supported device/workflow behavior rather than only crop geometry.
- **Visual resolution** locates a verified device surface and named regions inside a captured source.
- **The semantic camera** frames overview, touched, editing, multi-touch and task-specific subjects inside a verified surface.
- **The presentation composer** combines stable Push semantics with native pixels and generated emphasis.
- **Capture backends** supply pixels without defining object identity or controller behavior.

The operating model is [`design/device-aware-presentation-layer.md`](design/device-aware-presentation-layer.md). The native-device inventory and priorities are in [`design/native-device-behavior-matrix.md`](design/native-device-behavior-matrix.md).

## Semantic/visual coherence

Transport freshness alone does not prove that pixels belong to the current device or parameter page.

A supported device presentation must prevent this mismatch:

```text
current Sampler labels
        + fresh pixels from a previous device/page
```

Context changes therefore revoke or gate prior visual authority until the implementation can establish coherent semantic and visual generations.

The exact mechanism may be local shared state inside the DrivenByMoss derivative, helper-side source invalidation, or a later narrow semantic-intent channel. It should be introduced only when a concrete experience requires it and must not encode the semantic model in platform-specific types.

## Current V4 placement

V4 delivers the first device-aware screen for one supported Bitwig 6.1 Sampler fixture.

For this first vertical:

- DrivenByMoss owns Device-mode eligibility, current parameter semantics, the custom semantic layout, touch emphasis, raster gating and fallback;
- the macOS helper owns one tightly bounded Sampler visual and a narrow supported-layout guard;
- the existing raster protocol remains unchanged;
- track/mixer/session/transport/performance and unsupported-device pages remain ordinary DrivenByMoss;
- automatic anchors, camera zoom, slicing, Browser redesign and other devices remain later capabilities.

See [issue #49](https://github.com/kasselvania/standalone-BitWig-push/issues/49).

## Ownership invariants

- Bitwig owns the DAW and audio engine.
- DrivenByMoss owns semantic Push behavior and the sole Push display USB endpoint.
- The platform helper owns source discovery/capture and helper-local pixel processing.
- Capture never blocks musical control or audio.
- The receiver thread never writes a Push bitmap.
- The display thread never accepts or reads a socket.
- Historical composed pixels are never restoration authority.
- Visual ambiguity, unsupported context or failure prefers semantic fallback over showing the wrong content.
- Platform-specific capture objects do not cross into the controller-extension semantic model.
- Current encoder binding—not encoder number alone—is the semantic control identity.

## Portability model

The current capture backend is macOS-specific. The semantic context, experience-profile, resolved-region and presentation concepts must remain platform-neutral so later Linux or Windows backends can supply equivalent source frames without redefining product behavior.

Longer-term work includes:

- verified device/panel localization;
- bounded calibration and semantic-seeded anchors;
- generated waveform/analyzer sources where direct data is available;
- Linux/Steam Deck capture;
- additional operating-system backends;
- a public adapter model only after internal behavior families stabilize.

## Optional hardware directions

The core visual/controller software works with a normal computer connected to Push 3 Controller over USB.

A self-contained Linux appliance and Push internal-compute research are optional deployment/hardware tracks, not prerequisites for the device-aware presentation architecture. See [`HARDWARE.md`](HARDWARE.md).
