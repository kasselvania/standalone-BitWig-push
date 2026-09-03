# Device-aware presentation operating model

## Purpose

This document gives Pushwig one shared vocabulary for the product phase after V3.

It is **not** a second authority hierarchy, a release roadmap, or a substitute for an active issue. `CURRENT_SLICE.md` and the owning issue define the work being executed. This document only explains how the major product concepts fit together so device work does not collapse back into ad hoc screen crops.

The current device inventory and priorities live in [`native-device-behavior-matrix.md`](native-device-behavior-matrix.md).

## Product decision

Pushwig does not replace every DrivenByMoss screen.

```text
track / mixer / session / transport / performance
        -> preserve DrivenByMoss

supported object + supported Push context + verified visual
        -> deliberate Pushwig presentation

unsupported object, unsupported task, ambiguity, stale visual, or failure
        -> preserve / restore DrivenByMoss
```

A visual is shown because it improves a particular task—not merely because pixels are available.

The intended product combines:

- controller semantics and current physical bindings from DrivenByMoss;
- native Bitwig pixels when their visual identity or graphical information is useful;
- Push-specific labels, values, highlighting, framing, and task views;
- exact semantic fallback when Pushwig cannot prove the right presentation.

## The seven operating concepts

### 1. Context router — when Pushwig participates

The context router answers:

> Is the current Push screen and selected object one for which Pushwig has a supported experience?

Its inputs may include:

- active Push mode;
- selected device or browser state;
- selected parameter page;
- current task or submode;
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
- tested Bitwig versions, UI scales and layout variants;
- the object surface and named visual regions;
- parameter-to-region mappings;
- resting, touched, editing, multi-touch and task-specific presentations;
- fallback and compatibility limits.

A profile is not merely a normalized crop. Complex devices may have several task views rather than one permanent camera.

### 4. Visual resolver — where the intended subject is

The resolver turns semantic expectation plus captured source pixels/layout facts into a verified object surface and named regions.

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

A corner may be one landmark. The center is useful for framing. The resolver still needs enough evidence to establish the subject's boundaries and distinguish the selected instance from similar neighboring devices.

On resize or Bitwig layout change, the device lock is revalidated or reacquired. The system does not assume that internal device geometry scales proportionally with the outer window.

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

Camera motion must never conceal uncertainty in the resolver. If the object surface or mapping is invalid, Pushwig falls back rather than animating over the wrong pixels.

### 6. Presentation composer — how semantics and pixels share 960×160

The composer owns the intentional Push screen:

- stable physical encoder legends;
- device, page and task identity;
- current/touched values;
- captured native visual regions;
- generated highlights, borders, gradients and relationship cues;
- temporary system/DrivenByMoss overlays;
- fallback.

The image may move or zoom while encoder-aligned labels remain physically stable.

The V2/V3 `560×160` right-hand raster rectangle was an engineering fixture. It is not a permanent product layout.

### 7. Capture backend — how pixels are obtained

A platform backend owns operating-system capture and pixel processing.

The current macOS backend owns ScreenCaptureKit, window discovery, Core Image crop/scale, permission handling and opaque-BGRA publication. Future Linux or Windows backends will differ.

Platform-specific types do not define device identity, semantic context, experience profiles or camera intent.

## Current process placement

For the present architecture:

### DrivenByMoss owns

- active Push mode;
- selected device and current parameter bank/page;
- current encoder bindings, values and touch state;
- normal musical control behavior;
- semantic display generation;
- whether a Pushwig presentation is eligible in the current context;
- final composition into the semantic bitmap;
- the sole Push USB display writer.

### The platform helper owns

- source-window discovery and capture;
- helper-local object crop/scale once a visual region is known;
- source validity and generation fencing;
- external visual-frame publication.

### The external raster boundary owns

- capability-authenticated complete frames;
- latest-frame adoption;
- bounded freshness and failure behavior;
- raster application into the same semantic bitmap.

This placement is not permanent dogma. It is the smallest split that preserves the proven one-writer/controller boundaries while the first device experiences are built.

A later touch-driven camera will likely require a narrow latest-state semantic/visual-intent channel from DrivenByMoss to the helper. Do not introduce that protocol before a concrete experience requires it, and do not encode the semantic model in macOS-only types.

## Coherence and generations

Device-aware presentation has two truths that must agree:

1. controller semantics: current mode, device, page and bindings;
2. visual source: current object surface and pixels.

A frame from the previous device is wrong even when it is fresh by transport time.

Supported presentations therefore need generation fencing around context changes. At minimum:

```text
context becomes eligible
        -> prior visual authority is not immediately trusted
        -> require a frame / lock current to the eligible context
        -> compose only coherent semantics + visual

context leaves eligibility
        -> revoke visual authority immediately
        -> ordinary current DrivenByMoss screen
```

The exact generation mechanism belongs to the implementation that first needs it; the operating model does not prescribe a new network protocol by itself.

## Resize and layout policy

Treat these as distinct events:

- outer window move;
- content-size change with stable layout;
- Bitwig internal panel/device reflow;
- UI-scale/theme/version change;
- subject hidden, clipped, scrolled away or replaced.

Only the first is already broadly solved by V3.

A supported device experience may begin with one or two validated layout envelopes. Outside them it should abstain and restore ordinary semantics. Automatic layout adaptation and anchor-based reacquisition can follow after the first complete device experience proves what must be located.

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

One device may use several behaviors. Sampler can have an overview, boundary editing and slicing task views. Browser is a cross-cutting workflow with its own results/filter/preview/commit behavior.

## Current product sequence

This is not a roadmap; it records the order chosen for the present design phase:

1. establish one complete Sampler Device-page foundation;
2. redesign the Browser as a semantic results-first experience;
3. add Sampler waveform/boundary and sliced task views after capability verification;
4. use Polymer as the first device-overview generalization test;
5. expand proven behavior families to other native devices.

Issue-level decisions may change this order when fixture evidence reveals a real blocker.

## V4 boundary

[V4 / issue #49](https://github.com/kasselvania/standalone-BitWig-push/issues/49) is intentionally smaller than the final semantic-camera vision but larger than a plumbing experiment.

It must deliver:

- context routing that leaves good DrivenByMoss screens untouched;
- activation only for one supported native Sampler Device-page state;
- a deliberate hybrid semantic/native page;
- a tightly bounded Sampler visual without adjacent Bitwig clutter;
- current encoder names and values from the actual parameter bindings;
- one-encoder touch emphasis while original control behavior remains intact;
- exact fallback for wrong device, wrong page, unsupported layout or missing visual;
- committed tests and real Push acceptance.

V4 does **not** yet implement automatic device anchors, touch-driven camera zoom, multi-touch union framing, waveform-marker task views, slicing or Browser redesign.

Those are visible next capabilities built on the same operating model—not hidden prerequisites required before the first screen can improve.
