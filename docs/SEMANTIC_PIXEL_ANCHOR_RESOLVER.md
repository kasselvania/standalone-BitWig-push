# Semantic-Seeded Pixel Anchor Resolver

## Purpose

This document captures a specific visual-resolution hypothesis:

> DrivenByMoss/Bitwig semantic state can reduce visual discovery from an open-ended computer-vision problem to a bounded registration problem.

When the controller integration already knows that the selected device is, for example, Bitwig Sampler, the resolver does not need to ask, "What device is somewhere on this desktop?" It can ask:

> "Within the plausible Bitwig source window and panel zones, where is the expected Sampler visual representation, and does the evidence meet a safe confidence threshold?"

A small set of stable pixel anchors, corners, headers, separators, icons, or other local patterns may be sufficient to locate and lock the relevant visual region at low compute cost.

This is called a **semantic-seeded anchor constellation**.

The method is promising, not yet proven. It must be benchmarked for accuracy, false locks, resize/scale tolerance, and compute cost before it becomes an architectural dependency.

## Why semantics change the problem

Without semantic state, visual recognition may need to search every window for every known device.

With semantic state, the search can be narrowed by:

- selected track/device identity;
- native-device versus plug-in classification;
- device name/vendor/type;
- preset and expansion state where useful;
- whether a dedicated editor window is open;
- active Bitwig panel layout and visibility where observable;
- active Push mode and requested named visual view;
- candidate Bitwig process/window identity.

The semantic seed selects one adapter and one small anchor set. The visual engine then performs registration and validation rather than general classification.

```text
DrivenByMoss selected-device state
        |
        v
semantic visual adapter
        |
        +--> expected source role/window family
        +--> expected anchor constellation
        +--> expected relative geometry
        |
        v
bounded pixel search and validation
        |
        v
validated source-relative visual region
```

## Primary use cases

### Embedded native-device visuals

A native Bitwig device may be selected semantically while its waveform, graph, or expanded representation remains embedded inside a larger Bitwig application window.

The anchor engine may locate:

- the device header or stable corner;
- a panel divider;
- a stable icon cluster;
- the top-left and bottom-right boundaries of the expanded view;
- a device-specific visual landmark outside animated content.

### Sub-views inside dedicated windows

A plug-in or floating Expanded Device View already has a stable top-level window identity, but a Push view may need only one subsection.

Anchors can locate the desired oscillator, waveform, spectrum, modulation, or browser region relative to that window.

### Validation of a geometry-based resolver

Even when panel geometry predicts a region, anchor matching can validate that the region contains the expected device rather than unrelated pixels.

## Non-goals

The first implementation is not intended to:

- recognize arbitrary unknown applications;
- read every label through OCR;
- classify every Bitwig device from pixels alone;
- continuously scan every monitor at display frame rate;
- use mouse automation as the primary control path;
- introduce a trained neural model before deterministic methods are measured;
- silently display a low-confidence or wrong region.

Wrong visual content is more harmful than temporary semantic-only fallback. The resolver must prefer abstention over a false lock.

## Anchor selection rules

A useful anchor should be:

- visually stable across normal parameter changes;
- outside animated waveforms, meters, cursors, and playheads where possible;
- distinctive among the adapter's plausible negative candidates;
- small enough to search cheaply;
- large enough to survive capture noise and scaling;
- tied to a meaningful boundary or landmark;
- versioned against the Bitwig/device/UI configuration actually tested.

Avoid relying on:

- preset text that changes constantly;
- track/device colors chosen by the user;
- animated content;
- transient selection highlights as the only evidence;
- one isolated pixel or one color value;
- physical desktop coordinates.

## Anchor constellations

A single template match is not sufficient evidence for a production lock.

An anchor constellation contains two or more observations with expected relative geometry.

Example:

```text
anchor A: stable device-header corner
anchor B: stable panel-divider intersection
anchor C: stable lower icon cluster

expected:
  B is approximately dx/dy from A
  C is approximately dx/dy from A
  all anchors imply the same scale
```

The resolver can solve a simple translation and uniform scale from the constellation. Rotation and perspective should not normally exist in a desktop UI, so a full homography is unnecessary unless evidence proves otherwise.

The constellation provides:

- stronger discrimination than one patch;
- a geometry consistency check;
- a way to reject similar-looking but incorrect regions;
- source scale estimation;
- a natural confidence score.

## Candidate processing pipeline

### 1. Semantic seed

Create a semantic key such as:

```text
host = bitwig
kind = native-device
name = Sampler
view = expanded-waveform
panel_layout = arrange
expanded = true
```

The key selects the adapter, source preference, expected anchors, scale range, and fallback behavior.

### 2. Candidate source restriction

Search only plausible source windows or zones:

1. a matching dedicated/floating device window;
2. the identified Bitwig application window;
3. panel zones predicted from Bitwig layout state;
4. a bounded user-calibrated source region;
5. no source.

Do not begin from a full composite desktop unless no window-level capture API is available.

### 3. Cheap preprocessing

Candidate transforms to benchmark include:

- luminance/grayscale conversion;
- local contrast normalization;
- downsampling;
- Sobel/Canny-style edge maps;
- small image pyramids for a bounded scale range;
- optional masking of unstable pixels.

The first benchmark should avoid expensive preprocessing that does not materially improve rejection accuracy.

### 4. Coarse acquisition

Run a coarse anchor search on a downsampled candidate source or predicted panel zone.

Algorithms to benchmark:

- flattened normalized pixel vectors with cosine similarity;
- mean absolute/squared pixel error after normalization;
- normalized cross-correlation template matching;
- edge-map template matching;
- perceptual/difference hashes for candidate rejection;
- ORB/AKAZE-style feature matching only when simpler methods fail to handle supported scaling.

A perceptual hash can reject an obviously wrong candidate but generally does not provide location by itself. Template/feature methods provide localization.

### 5. Fine constellation validation

After anchor A produces a candidate location:

- search for anchor B/C only near their expected transformed offsets;
- verify relative geometry and common scale;
- validate minimum source dimensions;
- optionally validate a low-resolution descriptor of the intended visual region;
- compute confidence and competing-candidate margin.

### 6. Lock

Return a source-relative region only when the adapter's confidence and margin thresholds are met.

```text
AnchorLock
  adapter_id
  source_id
  source_role
  transform
  resolved_region
  confidence
  evidence[]
  acquired_at
  revalidate_by
```

### 7. Low-cost maintenance

Once locked, do not rerun a global search for every display frame.

Maintain the lock by:

- listening for semantic selection/layout/window events;
- checking anchors inside a small search neighborhood;
- revalidating at a bounded cadence, such as 2-5 Hz;
- retaining the last valid frame briefly when permitted by the adapter;
- performing full reacquisition only after invalidation.

The Push compositor may run at a higher frame cadence than the resolver. Resolver cadence and display cadence are separate latency classes.

## Resolver state machine

```text
UNRESOLVED
    |
    v
PROBING -- ambiguous --> UNRESOLVED / semantic fallback
    |
    v
LOCKED -- weak evidence --> DEGRADED
    |                        |
    | valid                  | recovers
    +------------------------+
    |
    +-- source/layout/device changed --> PROBING
    |
    +-- invalid/lost ------------------> LOST --> semantic fallback
```

State transitions should be observable in diagnostics.

## Adapter representation

A future adapter may declare an anchor set like:

```yaml
id: bitwig.sampler.expanded.waveform

semantic_match:
  host: bitwig
  device_kind: native
  device_name: Sampler
  requested_view: waveform

source_preference:
  - role: floating-expanded-device
  - role: embedded-expanded-device

anchors:
  - id: header-left
    representation: local-template
    preprocess: grayscale-edge
    scale_range: [0.80, 1.60]
    search_zone: predicted-header

  - id: lower-divider
    representation: local-template
    preprocess: grayscale-edge
    expected_from: header-left
    normalized_offset: [0.00, 0.72]
    tolerance: [0.04, 0.05]

lock_policy:
  minimum_anchors: 2
  confidence_min: 0.94
  competitor_margin_min: 0.08
  revalidate_hz: 4

region:
  derive_from: anchor-constellation
  normalized_rect: [0.03, 0.12, 0.94, 0.60]

fallback:
  mode: semantic
```

Exact thresholds are empirical and adapter-specific.

## Proprietary UI assets

The project must not casually redistribute proprietary Bitwig or third-party plug-in screenshots as template files.

Preferred approaches:

- generate local templates from the user's installed application during calibration;
- store anchor recipes, coordinates, masks, hashes, or feature descriptors where legally appropriate;
- use synthetic/open test fixtures for unit tests;
- retain public benchmark metrics without publishing private or proprietary captured frames;
- include UI crops in the repository only when redistribution rights are clear.

A community profile may describe how to acquire an anchor locally without shipping the underlying proprietary pixels.

## Accuracy and compute benchmark

The first implementation should be an offline/diagnostic benchmark before it is placed in the live display path.

### Test corpus dimensions

For at least three native Bitwig devices, capture locally controlled fixture cases across relevant combinations of:

- selected device;
- correct and incorrect candidate windows;
- Bitwig version;
- UI scale;
- application window size;
- display profile/panel arrangement;
- panel width/height;
- selected/unselected highlight state;
- parameter changes;
- animated content at multiple moments;
- window move and resize;
- source close/reopen;
- capture backend/color format where relevant.

The corpus should include strong negative cases: visually similar devices, blank panels, browser panels, mixer panels, and stale frames.

### Algorithms to compare

At minimum:

1. flattened grayscale vector similarity;
2. grayscale normalized cross-correlation;
3. edge-map normalized cross-correlation;
4. coarse-to-fine multi-scale matching;
5. optional ORB/AKAZE comparison if scale tolerance remains insufficient.

### Required metrics

- correct-lock rate;
- abstention rate;
- wrong-lock rate;
- localization error in pixels and normalized coordinates;
- time to first lock;
- time to reacquire after selection/resize;
- lock persistence under animation;
- CPU time per acquisition and validation;
- peak working memory;
- optional host power delta on the Steam Deck fixture;
- confidence calibration and competitor margin.

### Provisional performance targets

These are experiment targets, not current claims:

- **zero wrong locks** in the retained acceptance matrix; abstention is allowed;
- p95 initial acquisition at or below 250 ms on the Steam Deck fixture for a bounded 1080p-class candidate source;
- p95 locked-state validation at or below 10 ms per check;
- validation cadence no higher than 5 Hz unless evidence requires it;
- no resolver work on the audio or MIDI/control thread;
- semantic fallback within one validation interval after lock loss.

If these targets are not met, reduce search zones, improve semantic/layout priors, use more distinctive anchor constellations, or move difficult adapters to calibration/direct-source tiers.

## Diagnostics

A resolver diagnostic view should be able to show:

- candidate source windows;
- predicted search zones;
- anchor heatmaps or top candidate scores;
- accepted/rejected anchor points;
- inferred transform and final region;
- confidence and competitor margin;
- state-machine transitions;
- per-stage timing;
- reason for fallback.

This tooling is important for community profile development and for proving that the resolver is not merely lucky on one screenshot.

## Relationship to DrivenByMoss

DrivenByMoss should provide semantic facts and visual intent, not perform general image processing on its controller thread.

Preferred split:

```text
DrivenByMoss derivative
  selected device / window state / panel state / requested view
        |
        v
state-intent broker
        |
        v
semantic-seeded anchor resolver service
        |
        v
capture backend -> validated visual frame/region
        |
        v
Push compositor
```

This keeps image processing outside the controller extension's latency-sensitive path and allows the same resolver to serve Linux, Windows, macOS, attached, and managed deployment profiles.

## Initial acceptance slice

A future Track V slice should prove:

1. semantic selection among at least three native Bitwig devices;
2. adapter selection from the semantic key;
3. correct anchor-constellation lock on the intended device representation;
4. automatic reacquisition after device selection and source resize;
5. no wrong locks across the retained negative corpus;
6. explicit abstention and semantic fallback for ambiguous/unsupported cases;
7. retained timing, CPU, memory, and confidence results on the Steam Deck fixture;
8. a clear decision on which simple algorithm becomes the first live implementation.

This slice may run entirely against captured fixture frames before integration with the Push display.

## Long-term possibilities

If deterministic matching proves useful, later tooling can add:

- an adapter recorder that samples stable anchor candidates automatically;
- community-submitted anchor recipes and compatibility matrices;
- per-version anchor regeneration;
- online adaptation from successful calibration;
- source-event-driven validation rather than polling;
- optional lightweight learned descriptors for only the adapters that need them.

A trained model is an escalation path, not the default starting point. The semantic prior and stable desktop geometry may make simple pixel/edge matching sufficient.
