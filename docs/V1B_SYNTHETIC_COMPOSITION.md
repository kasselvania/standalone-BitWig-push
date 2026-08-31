# V1B Synthetic Composition Design

## Purpose

V1A established a lawful synchronous frame seam:

```text
complete semantic IBitmap
        -> PushFramePipeline
        -> exact same IBitmap
        -> unchanged PushUsbDisplay
```

V1B asks the first visible-pixel question:

> Can project-owned drawing be applied to DrivenByMoss's persistent semantic bitmap without clearing or damaging the semantic frame?

The answer is not assumed from the existence of `IBitmap.render`. The Bitwig bitmap API documents a render callback for painting, but it does not explicitly promise that a later render callback preserves all existing pixels. V1B therefore treats preservation as the experiment's central claim.

## Accepted V1A result

DrivenByMoss `pushwig/main` contains the exact accepted V1A tree:

```text
integration commit: 033ccef8c64f08e8d8d41fa90d48fa06b326a1a1
integration tree:   9aec7429ff093addee001a62a5a07309708fd592
reviewed source:    6e1e4cbd2e725a7951e5b4dc1278fbb6e7b5d61c
```

The accepted path is:

```text
Push2Display.send(IBitmap)
        -> PassThroughPushFramePipeline.INSTANCE.process(image)
        -> same reference
        -> PushUsbDisplay.send(image)
```

`PushUsbDisplay` remains the sole endpoint owner and is outside V1B's source envelope.

## The persistent-bitmap constraint

`AbstractGraphicDisplay` creates one bitmap for the lifetime of the display. It re-renders the semantic image only when its `ModelInfo` changes, but it calls the protected display send method on each update opportunity.

This matters because composition directly onto the same bitmap is stateful:

- drawing a fixed mark repeatedly is idempotent;
- moving a mark without restoring the old area can leave trails;
- disabling a mark without forcing semantic re-render can leave stale pixels;
- changing opacity or crop bounds can expose similar damage-tracking problems.

V1B therefore uses one fixed opaque mark and a process restart as the removal boundary. It does not claim runtime animation or hot switching.

## Chosen experiment

### Default path

The exact V1B artifact remains ordinary when no diagnostic activation is supplied:

```text
property absent/false
        -> PassThroughPushFramePipeline.INSTANCE
```

This keeps the project fork safe as an ordinary controller extension.

### Enabled path

The preferred startup activation is:

```text
-Dpushwig.syntheticOverlay=true
```

or an equivalent Java system-property injection supplied before Bitwig starts.

The property is read once when `Push2Display` is constructed. The selected pipeline is retained for that display lifetime.

```text
property true
        -> SyntheticOverlayPushFramePipeline.INSTANCE
```

The enabled pipeline:

1. receives the completed semantic `IBitmap`;
2. invokes one synchronous `IBitmap.render(false, renderer)` callback;
3. draws a fixed two-color mark inside one declared rectangle;
4. returns the same `IBitmap` reference;
5. passes that object to the unchanged USB display.

## Fixed diagnostic mark

Preferred geometry:

```text
frame:        960 × 160
outer:        x=856, y=4, width=96, height=16
inner:        x=860, y=8, width=88, height=8
outer color:  ColorEx.PINK
inner color:  ColorEx.WHITE
```

The mark is deliberately:

- small enough to preserve most semantic information;
- high-contrast enough to verify physically;
- fully opaque, avoiding alpha/compositing ambiguity;
- fixed, avoiding damage restoration in this slice;
- bounded away from frame edges enough to expose coordinate errors.

The renderer should be a class-initialized reusable object. V1B does not allocate a lambda, renderer, bitmap, byte array, or frame object per send.

## Source shape

Expected production delta:

```text
Push2Display.java
SyntheticOverlayPushFramePipeline.java
```

`Push2Display` selects between the accepted pass-through singleton and the new synthetic-overlay singleton.

No factory hierarchy, transport abstraction, user setting, capture object, alternate bitmap type, or configuration panel is needed.

## Why not use DrivenByMoss's existing overlay list?

The existing semantic overlay list belongs to the semantic renderer and is part of its model lifecycle. The project is proving a post-semantic visual pipeline that can later accept arbitrary validated source pixels.

Also, prior source inspection found that `ModelInfo.equals/hashCode` does not include the overlays list. Depending on that path would mix a known semantic dirty-tracking limitation into the first project-owned composition claim.

V1B must exercise the accepted post-render seam instead.

## Why not animate yet?

A moving rectangle would test at least three claims at once:

1. second-render preservation;
2. damage restoration of the previous rectangle;
3. scheduling/animation cadence independent of semantic dirty state.

That would make a failure ambiguous. A static mark proves the minimum useful fact: project-owned drawing can coexist with the semantic frame.

Animation can be introduced only after there is a deliberate representation for base-frame restoration or a complete composed output frame.

## Why startup-scoped activation?

A runtime toggle would need to answer how stale overlay pixels are removed immediately when the toggle turns off. The current persistent bitmap does not expose a generic semantic redraw request through the V1A pipeline boundary.

A process restart provides a clean, deterministic transition:

```text
overlay-enabled process exits
        -> display bitmap is destroyed
        -> next process starts with pass-through selected
        -> fresh semantic bitmap is rendered
```

This is sufficient for the V1B experiment and avoids prematurely changing the controller configuration model.

## Preservation evidence

The evidence must distinguish “a mark appeared” from “composition worked.”

Required questions:

- Did only the intended region change?
- Were the mark coordinates correct?
- Did the second render callback preserve the rest of the frame?
- Were colors transmitted as expected through the existing conversion path?
- Did repeated draws expand or accumulate?
- Did subsequent semantic renders remain correct?
- Did property-off restart remove all project-owned pixels?

Preferred local proof:

1. Use a stable non-playing Bitwig state with no animated meters.
2. Capture or inspect the exact DrivenByMoss debug bitmap with property off.
3. Repeat with the same exact V1B artifact and property on.
4. Normalize only the known capture framing if necessary.
5. Compare the declared target region and outside-region pixels separately.
6. Retain hashes, dimensions, mismatch counts, and masks—not proprietary screenshots.

A temporary observation-only patch may use `IBitmap.encode` to inspect raw bytes if the debug-window method cannot establish exact preservation. That patch must remain uncommitted, be identified by hash, and be removed before building and testing the exact source PR head.

## Performance posture

The overlay pipeline adds one render callback on each eligible send while enabled. This is real work and must be measured.

The committed implementation should contain no permanent timing or logging loop. Use temporary instrumentation, a profiler, or an external observation method to retain:

- sample count;
- p50 processing time;
- p95 processing time;
- maximum processing time;
- property-off comparison;
- project-owned allocation behavior;
- any audible/control/display regression.

The first Mac review band is:

```text
p95 <= 2 ms
max <= 10 ms
```

These are review thresholds for the accepted fixture, not universal performance promises. Linux/Steam Deck performance remains a later portability claim.

## Failure interpretation

### Whole-frame clear or corruption

If the second render callback clears or unpredictably alters the semantic image, the in-place direct-render approach is disproven for the current API/runtime. Restore the official artifact and retain the failure.

Do not respond by silently:

- copying the raw semantic bitmap;
- rewriting `PushUsbDisplay`;
- adding a second USB writer;
- creating an unbounded frame queue;
- coupling to Bitwig implementation classes;
- moving the claim into transport encoding.

A later design decision would then compare alternatives such as a project-owned final bitmap, a render-stage hook, or a controlled raw-frame representation.

### Property not reaching the extension process

If the startup system property cannot be observed inside the controller extension, stop and document the process-launch evidence. A different activation mechanism requires an explicit authority update; V1B must not hide a hard-coded always-on overlay in the proposed integration head.

### Excessive cost

If the overlay render exceeds the review band or produces audio/control/display regression, retain the measurements and stop. Do not optimize by widening the slice before review.

## What V1B proves when successful

```text
semantic renderer owns musical/UI meaning
        +
project pipeline can paint bounded pixels after semantics
        +
existing Push USB transport remains authoritative
        ↓
first real hybrid semantic + project-owned visual frame
```

That is the first direct proof of the project's central visual thesis.

## What V1B does not prove

V1B does not establish:

- animation;
- runtime mode switching;
- prior-overlay damage restoration;
- an immutable semantic snapshot;
- external frame ingestion;
- crop/scale of arbitrary images;
- capture permissions or window discovery;
- source freshness or confidence;
- cross-platform behavior;
- headless/appliance operation.

Those remain separate slices.