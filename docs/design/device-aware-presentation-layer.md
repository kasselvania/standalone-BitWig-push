# Device-aware presentation operating model

## Purpose

This document gives Pushwig one shared vocabulary for the product phase after V3.

It is **not** a second authority hierarchy, a release roadmap, or a substitute for an active issue. `CURRENT_SLICE.md` and the owning issue define executable work. This document only explains how the major product concepts fit together so device work does not collapse into ad hoc crops or ad hoc semantics.

The current device inventory and priorities live in [`native-device-behavior-matrix.md`](native-device-behavior-matrix.md).

## Product decision

Pushwig does not replace every DrivenByMoss screen.

```text
track / mixer / session / transport / performance
        -> preserve DrivenByMoss

supported object + supported Push context + viable verified visual source
        -> deliberate Pushwig presentation

unsupported object, unsupported task, ambiguity, stale visual, source incompatibility, or failure
        -> preserve / restore DrivenByMoss
```

A visual is shown because it improves a particular task—not merely because pixels are technically available.

## Prerequisite zero — the visual source must be usable

Before context routing, device resolution, camera behavior, or composition can matter, the source itself must be acceptable in the intended operating mode.

A source is not product-valid merely because it can deliver correct pixels at good speed. It must also preserve ordinary use of the host application and avoid unacceptable incidental desktop state.

For attached-desktop use, this includes:

- normal Bitwig window controls remain usable;
- no unacceptable sharing UI obstructs the primary application;
- ordinary pointer, hover, tooltip, or unrelated desktop content does not become the resting Push visual;
- the user is not required to surrender the primary Bitwig UI to feed Push;
- source failure or revocation restores ordinary semantics.

The current macOS desktop-independent Bitwig-window capture fails this prerequisite on the accepted fixture because the system sharing badge obstructs normal Bitwig window controls. V4 is therefore blocked before device-page implementation.

The rest of this operating model remains the intended design vocabulary once a viable attached, managed, direct, or hybrid source mode is selected.

## The seven operating concepts

### 1. Context router — when Pushwig participates

The context router answers:

> Is the current Push screen and selected object one for which Pushwig has a supported experience and a viable source?

Its inputs may include:

- active Push mode;
- selected device or browser state;
- selected parameter page;
- current task or submode;
- selected source operating mode;
- whether a compatible visual source is current and valid.

The router is conservative. A track containing Sampler does not activate a Sampler visual while the user is on a track, mixer, session, transport, or performance page.

### 2. Semantic context — what the controls mean now

The semantic context is the latest coherent controller snapshot needed by the presentation:

```text
active Push mode
selected object kind / identity
selected device instance and page
current eight encoder bindings
parameter names, displayed values, values and modulation where available
which encoders are touched or actively changing
relevant modifiers / fine-edit state
semantic generation
```

DrivenByMoss is the authority for these facts.

Encoder number alone is not parameter identity. A device profile maps the **current binding** to a visual region or behavior. If the binding is unknown, Pushwig may still present the semantic name/value but must not invent a graphical target.

### 3. Experience profile — what a supported object does on Push

An experience profile describes one supported object or workflow. It may declare:

- semantic match and supported modes/pages;
- source operating mode and compatibility limits;
- tested Bitwig versions, UI scales, and layout variants;
- the object surface and named visual regions;
- parameter-to-region mappings;
- resting, touched, editing, multi-touch, and task-specific presentations;
- fallback behavior.

A profile is not merely a normalized crop. Complex devices may have several task views rather than one permanent camera.

### 4. Visual resolver — where the intended subject is

The resolver turns semantic expectation plus source pixels/layout facts into a verified object surface and named regions.

```text
selected semantic object
        + bounded candidate source / panel zone
        + supported layout facts
        + validated landmarks or calibration
        -> resolved object surface
        -> named visual regions
        -> confidence / generation
```

One corner, center point, or raw percentage rectangle is not a complete device model.

A corner may be one landmark. The center is useful for framing. The resolver still needs enough evidence to establish subject boundaries and distinguish the selected instance from similar neighboring devices.

On resize or Bitwig layout change, the device lock is revalidated or reacquired. The system does not assume internal device geometry scales proportionally with the outer window.

### 5. Semantic camera — what deserves attention

The camera operates **inside a verified object surface**. It does not locate the object.

Candidate states include:

```text
OVERVIEW
TOUCHED
EDITING
MULTI_TOUCH
TASK_VIEW
RELEASE_DWELL
```

Examples:

- overview frames the complete supported device surface;
- one touched binding gently emphasizes its mapped region;
- active editing gives the current value and visual subject more prominence;
- multiple verified regions produce one bounded union frame;
- a waveform-marker task may replace the overview with a full-width task view.

Camera motion must never conceal uncertainty in the resolver. If the object surface or mapping is invalid, Pushwig falls back rather than animating over wrong pixels.

### 6. Presentation composer — how semantics and visuals share 960×160

The composer owns the intentional Push screen:

- stable physical encoder legends;
- device, page, and task identity;
- current/touched values;
- captured or direct visual regions;
- generated highlights, borders, gradients, and relationship cues;
- temporary system/DrivenByMoss overlays;
- fallback.

The image may move or zoom while encoder-aligned labels remain physically stable.

The V2/V3 `560×160` right-hand raster rectangle was an engineering fixture. It is not a permanent product layout.

### 7. Source backend — how visual information is obtained

A source backend may provide:

- platform capture from an acceptable attached-desktop source;
- a managed or dedicated visual surface;
- direct/generated visuals from semantics, analysis, or audio/sample data;
- a hybrid of these.

The current macOS helper owns ScreenCaptureKit, window discovery, Core Image crop/scale, permission handling, and opaque-BGRA publication. That implementation remains useful engineering infrastructure, but its primary-window capture mode is not currently accepted as an end-user attached source.

Platform-specific types do not define device identity, semantic context, experience profiles, or camera intent.

## Current process placement

For the present architecture:

### DrivenByMoss owns

- active Push mode;
- selected device and current parameter bank/page;
- current encoder bindings, values, and touch state;
- normal musical control behavior;
- semantic display generation;
- whether a Pushwig presentation is eligible in the current context;
- final composition into the semantic bitmap;
- the sole Push USB display writer.

### A source/helper owns

- source acquisition or direct visual generation;
- platform-specific source validity;
- helper-local pixel processing when applicable;
- visual-frame publication.

### The external raster boundary owns

- capability-authenticated complete frames;
- latest-frame adoption;
- bounded freshness and failure behavior;
- raster application into the same semantic bitmap.

This placement is not permanent dogma. It is the smallest split that preserves the proven one-writer/controller boundaries while source and experience design evolve.

## Coherence and generations

Device-aware presentation has two truths that must agree:

1. controller semantics: current mode, device, page, and bindings;
2. visual source: current object surface and pixels/data.

A frame from the previous device is wrong even when fresh by transport time.

Supported presentations therefore need generation fencing around context changes. At minimum:

```text
context becomes eligible
        -> prior visual authority is not immediately trusted
        -> require visual state current to the eligible context
        -> compose only coherent semantics + visual

context leaves eligibility
        -> revoke visual authority immediately
        -> ordinary current DrivenByMoss screen
```

The exact generation mechanism belongs to the implementation that first needs it; this operating model does not prescribe a new network protocol by itself.

## Resize and layout policy

Treat these as distinct events:

- outer window move;
- content-size change with stable layout;
- Bitwig internal panel/device reflow;
- UI-scale/theme/version change;
- subject hidden, clipped, scrolled away, or replaced.

Only the first is broadly solved by V3. A supported device experience may begin with one or two validated layout envelopes. Outside them it should abstain and restore ordinary semantics.

## Behavior families

The initial catalog uses a small set of reusable product behaviors:

- `waveform-boundary`;
- `analyzer`;
- `graph-control`;
- `device-overview`;
- `structure-navigation`;
- `sequence-note-flow`;
- `drum-voice`;
- `semantic-status`;
- `patch-canvas`.

These are design families, not mandatory source-code inheritance trees.

One device may use several behaviors. Sampler can have an overview, boundary editing, and slicing task views. Browser is a cross-cutting workflow with its own results/filter/preview/commit behavior.

## Current status

[V4 / issue #49](https://github.com/kasselvania/standalone-BitWig-push/issues/49) stopped at its required attached-desktop preflight.

No Sampler page was implemented. No semantic bridge or DrivenByMoss production source changed. The current capture structure failed prerequisite zero before the device-aware presentation work could begin.

The next decision is not “how do we make the Sampler page prettier?” It is “which visual-source operating mode can support the intended experience without making Bitwig itself worse to use?”
