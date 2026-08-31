# V1C-0 Dynamic Raster Composition Research

## Purpose

V1B proved that the accepted DrivenByMoss frame seam can paint one fixed bounded project-owned mark into the live 960×160 semantic bitmap while preserving every pixel outside the mark.

The next product requirement is stronger:

> A visual source must be allowed to change, move, disappear, become stale, or be replaced without leaving any of its previous pixels behind and without losing a newer semantic update underneath it.

This document explains why external-frame IPC is not yet the next safe implementation step and defines the candidate architectures V1C-0 must compare.

## Accepted starting point

DrivenByMoss integration authority:

```text
branch: pushwig/main
commit: 1ae0b74f383314d170a5960ca763bdf9c319e787
tree:   a81e5c4330b31f36845c25e98e322990d62f0c67
```

Central evidence authority:

```text
commit: 95d93e262c33163783e23a8d3e66f6f92746918d
tree:   b1f97701801a015c075d09369860f4986403b9a9
```

Accepted visible path:

```text
persistent semantic IBitmap
        -> project-owned PushFramePipeline
        -> optional static bounded render callback
        -> same IBitmap
        -> unchanged PushUsbDisplay
```

The USB transport remains solved and outside this research.

## Why static composition is not dynamic composition

The semantic display is not rebuilt from scratch for every USB send.

`AbstractGraphicDisplay`:

1. owns one persistent bitmap;
2. creates a new `ModelInfo` from the current display components;
3. runs `renderImage()` only when that model differs from the previous model;
4. clears the temporary component lists;
5. sends the persistent bitmap regardless of whether a semantic redraw occurred.

V1B can therefore draw the same fixed mark repeatedly without creating a trail. The mark always covers the same pixels.

A changing visual does not have that property:

```text
frame 1: visual occupies R1
frame 2: visual occupies R2
frame 3: no visual
```

Painting frame 2 at `R2` does not restore the semantic pixels overwritten at `R1`. Sending no visual in frame 3 does not restore either region. The same problem appears when a capture helper stops, a selected device changes, a plug-in editor closes, or confidence falls below the resolver threshold.

Semantic fallback is therefore not merely “stop drawing.” It is an exact restoration operation.

## Relevant accepted source facts

### Persistent semantic model

`ModelInfo` copies the component and overlay lists. The accepted display therefore retains enough structured state to attempt a full semantic redraw after the temporary input lists are cleared.

This makes full redraw a plausible candidate, not an accepted guarantee. Component mutability, current-value fidelity, notification lifetime, mode transitions, and cost must be measured.

### Bitmap abstraction

The project `IBitmap` currently exposes:

```text
render(boolean, IRenderer)
encode(IEncoder)
```

It has no host-neutral:

```text
copyFrom(bitmap)
drawBitmap(bitmap)
readRegion(...)
writeRegion(...)
restore(...)
```

### Bitwig adapter

`BitmapImpl` wraps Bitwig’s `Bitmap`. Its `render` method creates a `GraphicsContextImpl` for each host callback. Its `encode` method exposes the bitmap memory to an encoder.

`GraphicsContextImpl.drawImage(IImage, ...)` currently casts to `ImageImpl`. The wrapper therefore does not yet establish a generic bitmap-to-bitmap blit even if the underlying Bitwig API can draw a bitmap as an image.

These are implementation facts to test, not excuses to leak Bitwig types into the future `VisualSourceFrame` contract.

## Candidate A — current semantic redraw before each dynamic layer

### Shape

```text
retained ModelInfo
        -> clear and redraw semantic bitmap
        -> render current dynamic visual
        -> send same bitmap
```

### Advantages

- no second bitmap;
- no raw pixel copy;
- exact semantic restoration in principle;
- uses existing semantic components and drawing implementation;
- keeps USB and encoding unchanged.

### Risks

- full semantic drawing happens at visual cadence rather than semantic-change cadence;
- retained components may not reproduce all current values safely;
- the required method is currently private and generic-framework owned;
- forcing redraw for all graphic controllers would be an unacceptable scope expansion;
- existing host graphics allocations may become material at higher cadence.

### Required production shape if selected

The production design must expose a narrow Push-only or explicitly reusable “render retained current model now” operation. It must not make every DrivenByMoss graphic display redraw continuously by accident.

## Candidate B — pristine semantic bitmap plus reusable final bitmap

### Shape

```text
semantic renderer -> persistent semantic bitmap
                           |
                           v
                  reusable full-frame copy/blit
                           |
                           v
                    reusable final bitmap
                           |
                  dynamic visual composition
                           |
                           v
                  unchanged PushUsbDisplay
```

### Advantages

- semantic ownership and output ownership are explicit;
- visual movement/removal is naturally handled by rebuilding final from pristine semantic state;
- helper absence and stale-frame fallback are simple;
- external frame cadence can be independent of semantic model changes;
- the final bitmap can later support multiple visual layers.

### Risks

- current wrapper has no accepted bitmap-to-bitmap copy operation;
- a generic graphics-interface change may affect more than Push;
- full-frame BGRA copy/blit cost and host allocations must be measured;
- implementation must not expose Bitwig API objects in platform-neutral contracts.

### Required production shape if selected

Allocate the final bitmap once. Each output cycle copies or draws the current semantic bitmap into it, composes validated visual layers, and sends the final bitmap. No historical final frame becomes semantic authority.

## Candidate C — target-region snapshot and restore

### Shape

```text
capture semantic pixels under visual bounds
        -> draw visual
        -> restore old bounds before next visual
```

### Attraction

This can minimize copied pixels when the visual region is small.

### Central correctness problem

The semantic image may change while the visual is active. Restoring a snapshot taken before that semantic change would overwrite newer semantic content.

A region strategy is viable only with an explicit semantic-generation rule that refreshes the snapshot from the new semantic frame before composition. Timing guesses or visual checksums are not enough.

This candidate should be selected only if it is demonstrably simpler and equally exact after semantic updates under the visual.

## Candidate D — backend memory copy

A Bitwig-specific memory-copy adapter may be appropriate if no safe higher-level blit exists.

The public design must still remain host-neutral:

```text
FrameCopyBackend
  copyFullFrame(source, destination)
  or
  copyRegion(source, destination, bounds)
```

The Bitwig implementation may use exact memory-block semantics internally, but it must declare:

- source/destination pixel format;
- dimensions and stride;
- readable/writable behavior;
- bounds and overflow checks;
- buffer ownership;
- fixed allocation behavior.

Raw memory access is a fallback, not a default preference.

## Correctness model

The semantic frame is always the recoverable base.

A valid dynamic compositor must behave as a pure conceptual function:

```text
output = compose(currentSemanticFrame, optionalCurrentVisual)
```

It must not behave as:

```text
output = mutate(previousOutput, maybeNewVisual)
```

The second form creates hidden historical state and makes fallback unsafe.

Required states include:

```text
visual A
visual B
visual moved
visual resized
visual absent
visual stale
visual invalid
semantic changed while visual active
```

Every state must resolve from current semantic authority plus current valid visual authority.

## Selection criteria

Order of importance:

1. exact current-semantic restoration;
2. deterministic stale/absent fallback;
3. single USB writer and unchanged transport;
4. bounded fixed memory ownership;
5. no unbounded queue or asynchronous mutation race;
6. host-neutral compositor/frame contracts;
7. measured performance on the accepted fixture;
8. minimal and upstream-maintainable source delta.

A faster candidate with ambiguous restoration loses to a slower candidate with exact behavior, provided the exact candidate remains within a practical frame budget.

## Evidence philosophy

V1C-0 is allowed to fail productively.

A valid result may be:

- full semantic redraw is exact and cheap enough;
- separate final bitmap is cleaner and measurable;
- the Bitwig wrapper lacks one narrow blit capability that must be added;
- every tested approach has a precise blocker.

An invalid result is “the moving rectangle looked okay.”

Retained evidence must include pixel mismatch counts, restoration after absence, semantic updates under previous visual bounds, timing, allocation observations, exact prototype hashes, and the resulting production seam.

## Relationship to later slices

### V1C — Dynamic Local Composition Lifecycle

Implements the selected restoration and composition primitive using generated local frames only.

It must prove:

- movement;
- replacement;
- disappearance;
- stale fallback;
- semantic changes under the visual;
- bounded cost;
- real Push behavior.

### V1D — External Generated-Frame Ingress

Only after V1C, add a process boundary and immutable/latest-frame-wins `VisualSourceFrame` ingress.

The external producer must be optional. Its absence, crash, malformed frame, stale sequence, or permission failure must resolve to semantic-only output through the already-proven V1C lifecycle.

### V2 — Real Window Capture

ScreenCaptureKit and dedicated Bitwig/editor window capture consume V1D. Capture APIs do not belong in the compositor or controller extension.

## Result

V1B proved that the semantic bitmap is a lawful place to paint one bounded static layer.

V1C-0 determines how that proof becomes a real visual system in which frames can change and disappear safely. This is the necessary bridge between “we drew pixels” and “we can display arbitrary live Bitwig visuals without corrupting DrivenByMoss.”