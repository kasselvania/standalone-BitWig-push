# V1C Dynamic Local Visual Composition

## Purpose

V1C turns the V1C-0 architecture decision into production source.

V1B proved that one fixed bounded visual can be painted into the live Push bitmap without altering pixels outside its bounds.

V1C-0 proved the restoration model required for changing visuals:

```text
newest retained semantic model
        -> complete semantic redraw
        -> current valid visual, or no visual
        -> same persistent bitmap
        -> unchanged Push USB transport
```

V1C implements that model with a bounded locally generated lifecycle. It does not yet introduce an external process or captured pixels.

## Accepted starting point

Central accepted evidence:

```text
commit: c6ccc72c315bac85af53a0c2942a191a1e40e0d3
tree:   9b1dddab50519a06b54ea873f5c07f18197238c6
```

DrivenByMoss integration:

```text
branch: pushwig/main
commit: 1ae0b74f383314d170a5960ca763bdf9c319e787
tree:   a81e5c4330b31f36845c25e98e322990d62f0c67
```

Accepted V1C-0 research result:

```text
candidate: retained current semantic redraw
local research commit: 3e8df95e9cc489e69da72b9acb82f2d06c90dd00
tree:                  f448eeda923232346037074a75b71c485e56ebe8
```

The research commit is not production authority. Production V1C is implemented cleanly from the accepted integration branch.

## Product invariant

Every V1C output must satisfy:

```text
output = compose(
    redraw(newestRetainedSemanticModel),
    optionalCurrentValidLocalVisual
)
```

It must never satisfy:

```text
output = mutate(previousOutput, maybeNewVisual)
```

The prior composed bitmap can exist physically, but it can never be restoration authority. Each enabled dynamic send first replaces it with a complete current semantic redraw.

## Why this model was selected

Candidate A passed all V1C-0 gates:

- exact movement and replacement;
- exact disappearance;
- semantic-only stale and invalid fallback;
- semantic update beneath covered pixels;
- zero outside-region mismatch;
- zero old-region restoration mismatch;
- zero full-frame mismatch after absence;
- green synchronous performance;
- no second bitmap;
- no raw copy;
- no snapshot generation;
- no transport modification;
- one real Push USB writer.

The selected path measured:

```text
p50       0.275166 ms
p95       0.413209 ms
maximum   7.356958 ms
```

on the accepted Mac + Bitwig + Push fixture.

## Source ownership

### AbstractGraphicDisplay

`AbstractGraphicDisplay` continues to own:

- one persistent `IBitmap`;
- the newest retained `ModelInfo`;
- semantic rendering;
- the ordinary dirty-render policy;
- temporary component and overlay collection lifecycle.

V1C adds one protected question:

```java
protected boolean shouldRedrawCurrentModel ()
{
    return false;
}
```

Conceptually, `send()` becomes:

```text
capture notification
construct newest ModelInfo
compare newest model with prior model
retain newest model unconditionally
if changed or shouldRedrawCurrentModel()
    render current retained model
clear temporary component/overlay lists
send persistent bitmap
```

Retaining the newest model unconditionally is critical because `ModelInfo.equals/hashCode` do not currently include overlays.

The hook remains default false. No unrelated controller should be forced into continuous redraw.

### Push2Display

`Push2Display` owns startup selection among exactly one pipeline.

It:

- reads startup properties once;
- selects the pipeline once;
- remembers whether dynamic current-model redraw is required;
- overrides the protected redraw hook only for that selected mode;
- preserves the existing guarded one-pipeline/one-transport send path.

### DynamicLocalPushFramePipeline

The production class is package-private and one instance per display.

It owns only:

- a fixed bounded diagnostic state machine;
- a fixed send counter or equivalent deterministic state;
- reusable renderer objects.

It does not own:

- semantic restoration;
- a bitmap;
- a prior output;
- a copied frame;
- USB;
- scheduling;
- a producer process;
- capture;
- an external frame contract.

## Startup selection

Properties:

```text
pushwig.syntheticOverlay
pushwig.dynamicLocalVisual
```

Selection precedence:

| Dynamic local | Static synthetic | Selected path |
|---|---|---|
| false | false | pass-through |
| false | true | accepted V1B static overlay |
| true | false | V1C dynamic local |
| true | true | V1C dynamic local |

The dynamic path has deliberate precedence. Diagnostic outputs are never stacked.

Only the dynamic-local path requests full current-model redraw on each eligible send.

Properties are not polled per frame and are not user-facing configuration.

## Local visual lifecycle

The production diagnostic sequence proves different failure classes.

### A — initial visual

- bounded opaque visual;
- initial size and position;
- unique content/color identity.

### B — moved and enlarged

- different position;
- larger bounds;
- partial overlap with A.

This proves both overlap and restoration of the non-overlapping remainder of A.

### C — moved and reduced

- different position;
- smaller bounds.

This proves the system does not retain pixels from B's larger extent.

### D — replacement

- different geometry;
- different content/color identity.

This proves replacement rather than simple translation.

### NONE

- no visual render after semantic redraw.

### STALE

- no visual render after semantic redraw.

### INVALID

- no visual render after semantic redraw.

The three semantic-only states are visually equivalent by design. Their distinct state transitions are proven through deterministic instrumentation.

## Frame lifetime

### Persistent bitmap

One bitmap exists for the display lifetime.

On a dynamic send:

1. it is fully repainted from current semantics;
2. it receives zero or one current local visual;
3. it is sent once;
4. no object retains it as a historical restoration source.

### Semantic model

One newest copied `ModelInfo` is retained for the current send.

It is installed before the redraw decision. A forced redraw therefore uses the newest available:

- component list;
- overlay list;
- notification.

### Local visual state

State is fixed and bounded.

No queue, frame history, or unbounded sequence exists.

### Renderers

Reusable renderers are constructed once.

No renderer/lambda array or `Enum.values()` result is created per send.

## Overlay equality issue

`ModelInfo.equals/hashCode` include components and notification but omit overlays.

The old behavior could therefore decline a semantic redraw when only overlays changed.

V1C does not modify `ModelInfo`. Instead:

```text
new ModelInfo with current overlays
        -> install as retained model
        -> dynamic forced redraw
        -> render newest overlays
```

The production evidence must include an overlay-only update while equality-covered fields remain stable.

## Notification lifecycle

Notifications are part of current semantic authority.

V1C must prove:

```text
current notification appears
        -> visual moves or disappears
        -> notification remains current
        -> notification is replaced or expires
        -> underlying current semantics return
```

No stale notification background or visual pixels may remain.

The notification check is bounded; V1C does not redesign notification scheduling.

## One-writer rule

Composition remains in the controller extension.

```text
Push2Display
        -> one selected PushFramePipeline
        -> one PushUsbDisplay.send
```

`PushUsbDisplay` remains unchanged and sole-owned.

No process, helper, or test tool claims the Push display endpoint in steady state.

## Allocation rule

V1C adds no per-send:

- bitmap;
- frame object;
- byte array;
- renderer;
- collection;
- queue;
- task;
- future;
- thread;
- executor;
- timer.

The existing semantic/Bitwig host render path may allocate adapter objects. V1C measures rather than denies that cost.

## Performance budget

On the accepted Mac:

```text
green:
    p95 <= 2 ms
    max <= 10 ms

review:
    p95 <= 5 ms
    max <= 15 ms

stop:
    p95 > 5 ms
    or max > 15 ms
```

Measure:

- default pass-through;
- accepted V1B static overlay;
- forced semantic redraw with no visual;
- forced redraw plus current visual.

Do not add concurrency to hide synchronous cost.

## Correctness matrix

The exact production head must prove all of these:

| Case | Required result |
|---|---|
| move A to B | A-only pixels return to current semantics |
| partial overlap | overlap contains B; old non-overlap restores |
| shrink B to C | former larger extent restores |
| replace C with D | only D remains |
| NONE | full current semantic frame |
| STALE | full current semantic frame |
| INVALID | full current semantic frame |
| semantic change while covered | newest semantic value appears after movement/removal |
| overlay-only change | newest overlay appears |
| notification appears | current notification visible with visual lifecycle |
| notification expires/replaces | current underlying semantics return |
| default path | accepted dirty render behavior |
| V1B path | accepted fixed mark without dynamic selection |

All unexplained mismatch counts must be zero.

## Pixel evidence

Use the exact 960×160 bitmap and accepted aggregate BGRA8888 observation layout.

At least 1,000 complete state cycles are required.

Retain:

- current semantic hash;
- output hash;
- current visual bounds;
- previous visual bounds;
- target hash;
- outside hash;
- old-region restoration count;
- full semantic-only mismatch count;
- semantic-update count and mismatch result;
- overlay-only mismatch result;
- notification lifecycle mismatch result.

Do not retain proprietary frames.

## Source envelope

Expected production paths:

```text
AbstractGraphicDisplay.java
Push2Display.java
DynamicLocalPushFramePipeline.java
```

Not modified:

```text
PushUsbDisplay.java
PushFramePipeline.java
PassThroughPushFramePipeline.java
SyntheticOverlayPushFramePipeline.java
ModelInfo.java
BitmapImpl.java
GraphicsContextImpl.java
IBitmap.java
pom.xml
```

An envelope change requires review before editing.

## Build and artifact proof

Build exact base and exact head using the same explicit Java 21/Maven environment.

The executable delta must be bounded to the approved source responsibilities.

`PushUsbDisplay.class` must be byte-identical.

The accepted V1A/V1B pipeline classes should remain byte-identical.

## Real fixture phases

### Default

- no Pushwig properties;
- no dynamic visual;
- ordinary baseline;
- normal quit.

### V1B regression

- `pushwig.syntheticOverlay=true`;
- fixed accepted mark;
- no dynamic selection;
- ordinary baseline;
- normal quit.

### V1C

- `pushwig.dynamicLocalVisual=true`;
- complete lifecycle;
- representative semantic modes;
- overlay-only update;
- notification lifecycle;
- controls and audio;
- no trail, stale block, clear, lag, or xrun;
- normal quit.

### Rollback

Restore and verify the accepted official extension exactly.

## Boundaries for V1D

V1D may later replace the local diagnostic state reader with a latest-frame-wins external source.

It may not replace V1C restoration ownership.

External absence, stale timestamps, invalid metadata, producer crash, permission denial, and resolver abstention must map to:

```text
current semantic redraw
        -> no visual draw
        -> semantic-only output
```

## Non-goals

V1C does not add:

- external process ingress;
- IPC or shared memory;
- `VisualSourceFrame`;
- capture;
- window discovery;
- source resolution;
- anchors;
- calibration;
- transport replacement;
- appliance or hardware work.

## Result

Once accepted, V1C establishes the complete local visual lifecycle needed for safe external frames:

```text
current semantics are always recoverable
        +
current visual is optional
        +
historical pixels have no authority
```
