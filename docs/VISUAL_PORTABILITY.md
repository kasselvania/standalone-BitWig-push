# Visual Portability and Layout Adaptation

## Primary question

Can the hybrid DrivenByMoss + Bitwig visual experience work for ordinary users whose Bitwig windows, monitors, display profiles, UI scaling, and operating systems differ?

The project target is **yes, across supported configurations**, without treating one fixed Steam Deck or appliance layout as universal.

That target does not mean promising zero-configuration capture of every Bitwig device and every third-party editor forever. It means designing the system so that physical screen coordinates are not its identity model, adding automatic strategies in descending order of reliability, providing bounded calibration where automation cannot be guaranteed, and always retaining semantic-only fallback.

## Two visual operating modes

### Attached mode — adaptive desktop integration

Bitwig stays in the user's current desktop environment.

The visual system must tolerate:

- window movement;
- monitor changes;
- single- and multi-display Bitwig profiles;
- different window sizes;
- different supported UI scales;
- a user opening or closing panels;
- plug-in windows moving between monitors.

Attached mode is the main portability problem and the main open-source software value.

### Managed mode — controlled appliance geometry

The project controls a logical desktop, display profile, window placement policy, or remote desktop session.

Managed mode is appropriate for:

- Steam Deck or other headless appliances;
- unattended boot;
- reproducible acceptance tests;
- remote-only workflows;
- deterministic visual profiles.

A gamescope/Xwayland or other canonical surface may be useful here, but managed mode must remain an optional deployment profile rather than a requirement imposed on desktop users.

## Acquisition strategy ladder

The capture system should choose the highest-confidence available strategy.

### Strategy 1 — dedicated top-level window

Prefer a complete top-level window over a crop from the desktop.

Examples:

- a third-party VST/CLAP editor window;
- a floating/undocked Bitwig Expanded Device View;
- a project-owned analyzer or companion window.

Top-level window capture is largely independent of monitor position. Moving a window changes its desktop coordinates but not its identity or internal coordinate system.

This should be the first visual proof because it simultaneously proves useful pixels and the most portable source class.

### Strategy 2 — Bitwig window-relative panel resolver

Some native visuals remain embedded in Bitwig's main application window.

For these sources, resolve the region from a combination of:

- Bitwig semantic state from the controller extension;
- selected device identity;
- current Bitwig panel layout and panel visibility where the API exposes them;
- application-window bounds;
- normalized geometry;
- semantic-seeded pixel anchors such as panel dividers, headers, selection outlines, stable corners, and device-specific landmarks;
- an adapter declaration for the relevant Bitwig/device version.

Do not store a raw desktop rectangle such as `x=1180, y=760, width=630, height=210` as the primary identity.

### Semantic-seeded anchor constellations

DrivenByMoss/Bitwig semantic state can make visual matching dramatically simpler.

When the selected device is already known, the resolver does not need to classify an arbitrary desktop. It can select one adapter, restrict the search to plausible Bitwig windows/panel zones, and look for a small constellation of expected visual anchors.

```text
selected device / requested view
        -> adapter and anchor set
        -> bounded candidate window or panel zone
        -> coarse pixel/edge match
        -> second/third anchor geometry validation
        -> translation/scale lock
        -> validated source-relative crop
```

A constellation should use at least two stable anchors with expected relative geometry. One template match alone is not sufficient evidence for a production lock.

Methods worth benchmarking include:

- flattened normalized grayscale vectors;
- normalized cross-correlation;
- edge-map template matching;
- coarse-to-fine multi-scale matching;
- perceptual hashes for quick candidate rejection;
- feature descriptors only where simpler methods cannot tolerate supported scaling.

The resolver should search globally only after semantic/layout/source changes. Once locked, it should validate inside a small neighborhood at a bounded cadence rather than scanning every display frame.

The important metrics are wrong-lock rate, abstention rate, localization error, acquisition/reacquisition time, CPU time, memory, and confidence calibration. A wrong visual lock is worse than no visual source, so ambiguous matches must fall back to the semantic display.

See [`SEMANTIC_PIXEL_ANCHOR_RESOLVER.md`](SEMANTIC_PIXEL_ANCHOR_RESOLVER.md) for the detailed design and benchmark plan.

### Strategy 3 — bounded user calibration

When automatic resolution cannot prove the source region, provide a one-time or version-scoped calibration flow.

A calibration record may include:

- target window identity;
- UI scale and Bitwig version;
- normalized source rectangle;
- locally generated anchor templates/descriptors;
- expected minimum source dimensions;
- confidence score;
- invalidation rules.

Calibration is an acceptable fallback. Silent capture of the wrong region is not.

### Strategy 4 — direct visual source

Some integrations can publish frames directly rather than being screen-captured.

Examples:

- a waveform or spectrum sidecar;
- a plug-in with an explicit companion protocol;
- a custom patch/application exposing structured visual state;
- a future Bitwig-supported rendering or extension surface.

Direct sources are the most robust, but they cannot be assumed for arbitrary proprietary devices and plug-ins.

## Semantic coordination

The controller extension supplies intent; the capture service supplies pixels.

Useful semantic state includes:

- selected track and device;
- device name, type, vendor and plug-in/native classification;
- preset name;
- whether the device is expanded;
- whether a plug-in window is open;
- active Push mode;
- requested visual view;
- active Bitwig panel layout where available.

The visual resolver should not guess which window matters merely because it is visually prominent.

## Capture backend boundary

The compositor consumes a platform-neutral frame contract.

```text
VisualSourceFrame
  source_id
  source_role
  width / height / pixel_format
  sequence / timestamp
  validity / stale_reason
  confidence
  frame_data
  optional source metadata
```

Operating-system backends are separate adapters.

Candidate families:

- Linux X11/XComposite;
- Linux Wayland through XDG Desktop Portal and PipeWire;
- Windows Graphics Capture;
- macOS ScreenCaptureKit;
- managed Xwayland/nested-compositor capture;
- direct project-owned frame sources.

The Push compositor must not contain X11, Wayland, Windows, or macOS window handles.

## Bitwig-aware resolver

Bitwig has a structured panel model rather than an arbitrary pile of pixels. A resolver can exploit that structure without assuming one physical screen.

Inputs:

```text
Bitwig application window(s)
Bitwig display profile / panel layout where observable
window dimensions and scale
selected-device semantic identity
candidate floating device/plugin windows
visual adapter and anchor rules
```

Outputs:

```text
source window identity
source-relative region
confidence
anchor evidence / inferred transform
fallback behavior
```

The resolver should revalidate after:

- window resize;
- display-profile change;
- UI-scale change;
- monitor move;
- selected-device change;
- Bitwig update;
- plug-in editor recreation.

## Visual adapter format

Adapters are community-extensible data plus optional resolver code.

A profile should support:

```yaml
id: bitwig.sampler.expanded.waveform
semantic_match:
  host: bitwig
  device_kind: native
  device_name: Sampler

source_preference:
  - role: floating-expanded-device
  - role: embedded-expanded-device

window_match:
  process: bitwig-studio
  title_patterns:
    - "*Sampler*"

anchors:
  - id: sampler-header
    representation: local-template
    preprocess: grayscale-edge
    search_zone: predicted-header
    scale_range: [0.80, 1.60]

  - id: waveform-divider
    representation: local-template
    preprocess: grayscale-edge
    expected_from: sampler-header
    normalized_offset: [0.00, 0.72]
    tolerance: [0.04, 0.05]

views:
  waveform:
    crop:
      mode: anchor-derived
      normalized_rect: [0.03, 0.12, 0.94, 0.60]
    fit: contain
    max_fps: 20

compatibility:
  bitwig_versions: ["tested ranges"]
  ui_scales: ["tested values"]

validation:
  minimum_size: [640, 240]
  minimum_anchors: 2
  confidence_min: 0.94
  competitor_margin_min: 0.08

fallback:
  mode: semantic
```

Exact anchor thresholds are empirical and adapter-specific.

Profiles must declare what has actually been tested. They must not imply universal support from one screenshot.

The repository should prefer local template generation, anchor recipes, masks, hashes, or legally distributable descriptors rather than casually shipping proprietary Bitwig or plug-in UI screenshots.

## Support tiers

### Tier A — window-native automatic

The target is a discoverable top-level editor or floating expanded view.

Expected experience:

- automatic discovery;
- independent of monitor arrangement;
- no crop calibration unless a sub-view is desired;
- strongest cross-platform potential.

### Tier B — layout-adaptive automatic

The target is embedded in Bitwig, but the resolver can locate it from semantic state, panel geometry, and confidence-validated anchor constellations.

Expected experience:

- no fixed desktop coordinates;
- compatible across tested display profiles, window sizes, and UI scales;
- low-cost reacquisition after selection/layout changes;
- confidence validation and semantic fallback.

### Tier C — assisted calibration

The target requires the user to identify or confirm a region once.

Expected experience:

- calibration stored by Bitwig/device/version/UI-scale identity;
- local anchor generation where helpful;
- automatic reuse and invalidation;
- no repeated manual cropping during ordinary use.

### Tier D — unsupported visual / semantic fallback

DrivenByMoss continues to work normally. Lack of a visual adapter must never make the controller unusable.

## Cross-platform acceptance matrix

A visual profile is not called portable until it is tested against a matrix appropriate to its source class.

Minimum dimensions:

- operating system and capture backend;
- Bitwig version;
- Bitwig display profile;
- UI scale;
- application window size;
- single/dual/multi-monitor placement;
- source window resized and moved;
- source hidden/reopened;
- selected device changed;
- compositor restart;
- capture permission restart where applicable;
- wrong/negative candidate windows;
- anchor confidence and competitor margin.

The first Linux implementation may precede Windows/macOS backends, but the core interfaces must not prevent those backends.

## First proof targets

The preferred first portable visual target is a Bitwig native device with an Expanded Device View that can be made into a floating window, such as Sampler, followed by one ordinary native Linux plug-in editor.

That path avoids solving embedded-panel segmentation before proving the end-to-end product:

```text
DrivenByMoss selected-device intent
        -> discover dedicated device/editor window
        -> capture source-relative frame
        -> crop/scale profile
        -> composite with semantic Push UI
        -> send to Push
```

In parallel or immediately afterward, the semantic-seeded anchor engine can be benchmarked offline against captured fixture frames. That benchmark can compare simple flattened-pixel, grayscale, edge, and multi-scale methods before any one algorithm is placed in the live path.

After dedicated-window capture and the anchor benchmark work, the embedded Bitwig panel resolver becomes the next major research slice.

## Honest product claim

The intended open-source claim is:

> The project can provide automatic or bounded-calibration visual adapters that are independent of physical monitor coordinates across supported Bitwig layouts, scales, operating systems, and source types.

The project should not claim:

> Every visual region in every Bitwig or plug-in version works automatically on every computer without profiles, permissions, compatibility testing, or fallback.

The first claim would already be a substantial and broadly useful extension to DrivenByMoss and Push.
