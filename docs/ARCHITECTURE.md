# Architecture

## Product thesis

Pushwig combines two information sources without confusing their responsibilities:

- **semantic control/state** from Bitwig's controller API and DrivenByMoss;
- **visual information** from an optional source when it improves a specific Push task.

The controller path remains useful when the visual path is absent, unsupported, or broken.

The project has proven that real-time pixels can be captured, processed, transported, and composed on Push with good performance. It has **not** yet established a visual-source mode that is acceptable for ordinary attached-desktop use on macOS.

## Proven downstream system

```text
Push controls
    |
    v
DrivenByMoss fork <---------------- Bitwig controller API
    |
    | current mode, device, parameters, and semantic Push frame
    |
    +<--------- newest valid visual frame --------+
    |                                             |
    v                                             |
context-gated presentation + display composition  |
    |                                             |
    v                                             |
Push USB display endpoint                         |
                                                  |
visual-source process ----------------------------+
```

### DrivenByMoss integration

The project fork owns:

- Push input handling and semantic modes;
- current device, parameter-page, and encoder-binding semantics;
- the current semantic display;
- validated raster application and semantic restoration;
- bounded external latest-frame intake;
- the sole Push display USB writer.

Pushwig keeps musical control and audio independent from visual-source availability.

### External frame boundary

A source process can publish complete opaque-BGRA frames over capability-authenticated IPv4 loopback. The receiver keeps bounded storage and exposes only the newest complete publication. The display path adopts a frame without blocking on socket I/O.

If a frame is absent, stale, malformed, disconnected, or rejected, Push uses current semantic output.

See [`PROTOCOLS.md`](PROTOCOLS.md).

## Proven macOS capture experiment

The maintained helper under `capture/macos/**` can:

- obtain normal Screen Recording permission;
- identify a unique Bitwig main window;
- capture its complete desktop-independent window surface;
- apply an explicit helper-local crop and aspect-preserving scale;
- follow ordinary movement, supported resize, loss, and recreation;
- publish real-time pixels through the accepted frame boundary.

That path established capture and delivery feasibility. It is **not currently a supported attached-desktop source architecture**.

## Attached-desktop blocker

On the tested macOS fixture, continuous desktop-independent capture of Bitwig's primary window causes macOS to place a sharing badge over Bitwig's normal window controls. The maintainer could not access the ordinary minimize and full-screen controls while capture was active. The controls returned when capture stopped.

The helper already sets cursor and click-indicator exclusion and does not opt into the content-sharing picker. Inspection did not identify a public ScreenCaptureKit configuration that removes this obstruction while preserving the same window-capture path.

Pointer pixels, Bitwig-rendered hover state, and tooltips are separate source-contamination concerns and must not be declared solved merely because `showsCursor` is false.

Therefore the current architecture distinguishes:

```text
accepted downstream visual substrate
        !=
accepted end-user visual source
```

The V4 Sampler page is blocked before production implementation because its required source mode is not usable enough for the intended product.

## Visual-source operating modes — unresolved

The next architecture decision must establish at least one viable source mode.

Candidate categories include:

### Attached desktop

A source that can coexist with the user's primary Bitwig session without obstructing normal controls or contaminating the Push visual.

No such replacement has yet been accepted on macOS.

### Managed or dedicated visual surface

A controlled display/window/session used specifically as a visual source, so capture does not compromise the user's primary Bitwig UI.

This may be relevant to a future appliance or a dedicated secondary/virtual-display workflow, but it is not yet proven.

### Direct/generated visual source

A renderer built from controller semantics, audio/sample data, analysis output, or other direct state rather than desktop capture.

This is likely appropriate for Browser, analyzers, parameter graphs, and some waveform tasks when the required data is available.

### Hybrid

Generated semantics and direct visuals by default, with captured native graphics used only in operating modes where capture is both useful and acceptable.

None of these is selected merely by being listed here.

## Device-aware presentation model

The post-V3 product vocabulary remains:

```text
context router
semantic context
experience profile
visual resolver
semantic camera
presentation composer
platform/source backend
```

See [`design/device-aware-presentation-layer.md`](design/device-aware-presentation-layer.md).

This model describes how a useful device experience should work **after a viable visual source exists**. It must not be used to disguise or bypass a source-mode failure.

- Context routing preserves existing DrivenByMoss screens by default.
- Semantic context comes from current controller/device/parameter bindings.
- Experience profiles describe supported behavior, not only crop geometry.
- A visual resolver establishes the actual object and named regions.
- A semantic camera frames a verified subject.
- A presentation composer combines native/direct visuals with stable Push semantics.
- A source backend supplies pixels or direct visual data without defining musical authority.

## V4 status

[V4 / issue #49](https://github.com/kasselvania/standalone-BitWig-push/issues/49) is blocked at preflight.

No custom Sampler page, semantic bridge, helper profile, or DrivenByMoss source change was implemented. The blocker evidence is retained at commit `52f6f41f4fc7285d652453a3530b9764e0295cc5` on `capture/v4-sampler-device-page`.

V4 must not resume on the same primary-window capture structure unless a supported configuration removes the desktop-usability failure. The window-control requirement is not optional acceptance wording.

## Ownership invariants

- Bitwig owns the DAW and audio engine.
- DrivenByMoss owns semantic Push behavior and the sole Push display USB endpoint.
- Visual capture or rendering never blocks musical control or audio.
- The receiver thread never writes a Push bitmap.
- The display thread never accepts or reads a socket.
- Historical composed pixels are never restoration authority.
- Visual ambiguity, unsupported context, or failure prefers semantic fallback.
- Platform-specific source objects do not define portable device behavior.
- Current encoder binding—not encoder number alone—is semantic control identity.
- A technically valid source is not product-valid if it makes the host application materially unusable.

## Portability model

The downstream semantic/raster/transport architecture is not macOS-specific. The existing capture helper is.

Future source work must preserve platform-neutral semantic context, device-experience, resolved-region, and presentation concepts. Different operating systems may use different capture, portal, virtual-display, or direct-rendering backends.

## Optional hardware directions

The core controller and downstream visual system work with a normal computer connected to Push 3 Controller over USB.

A self-contained Linux appliance and Push internal-compute research remain optional deployment/hardware tracks. A managed visual surface may be easier to provide in those environments, but that has not yet been accepted as the desktop product answer. See [`HARDWARE.md`](HARDWARE.md).
