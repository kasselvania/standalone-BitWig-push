# Current Slice: V1C — Dynamic Local Visual Composition Lifecycle

## Status

Ready to execute from the current accepted central `origin/main` containing this authority card and from DrivenByMoss `origin/pushwig/main` at the exact accepted V1B integration state.

Active issue: [#23 — V1C: Implement dynamic local visual composition lifecycle](https://github.com/kasselvania/standalone-BitWig-push/issues/23).

Before work begins, fetch central `origin/main` and verify that its history contains:

```text
c6ccc72c315bac85af53a0c2942a191a1e40e0d3  # accepted V1C-0 evidence
```

Create the central evidence branch directly from the then-current accepted `origin/main`. If `origin/main` has moved, inspect every intervening commit and stop if it changes V1C authority or scope.

## Primary claim

Implement the production form of the accepted V1C-0 Candidate A decision:

```text
newest copied ModelInfo
        -> retain before render decision
        -> complete current-semantic redraw when dynamic-local mode is selected
        -> current valid locally generated visual, or no visual
        -> same persistent IBitmap
        -> one existing PushUsbDisplay.send
```

The previous composed output is never restoration authority.

V1C must prove that a bounded local visual can move, overlap, resize, be replaced, disappear, become stale, or become invalid while every old visual pixel is replaced by the exact newest DrivenByMoss semantic output.

V1C is a production source slice. It does not introduce an external producer, IPC, ScreenCaptureKit, window capture, or the final `VisualSourceFrame` contract.

See [`docs/V1C_DYNAMIC_LOCAL_COMPOSITION.md`](docs/V1C_DYNAMIC_LOCAL_COMPOSITION.md).

## Accepted authorities

### Central authority and evidence

```text
repository: kasselvania/standalone-BitWig-push
V1C-0 merge: c6ccc72c315bac85af53a0c2942a191a1e40e0d3
tree:          9b1dddab50519a06b54ea873f5c07f18197238c6
```

### DrivenByMoss implementation

```text
repository: kasselvania/DrivenByMoss
branch:     pushwig/main
commit:     1ae0b74f383314d170a5960ca763bdf9c319e787
tree:       a81e5c4330b31f36845c25e98e322990d62f0c67
```

That integration contains exact accepted V1B source head:

```text
a2e0341b7bccfa4e6b13614f4adffc2235f785f4
```

Immutable upstream basis remains:

```text
branch: pushwig/upstream-26.4.1
commit: fd03245ab38fa5149c45934051d937ee9fda6d08
tree:   edd2ad636b0aa1f39919f0ffd05c968015450075
```

Official extension SHA-256 to restore:

```text
98dc3195ad8d911526e18b1005f09f69a1aedcb965b080565474104654345c5a
```

## Accepted V1C-0 decision

V1C-0 selected **Candidate A — retained current semantic redraw**.

It proved:

- the newest copied `ModelInfo` can be retained before the render decision;
- a protected default-false redraw hook can preserve ordinary dirty rendering;
- the dynamic Push path can request a complete current-semantic redraw on each eligible send;
- the current valid local visual can then be drawn synchronously into the same bitmap;
- `NONE`, `STALE`, and `INVALID` can produce exact semantic-only output;
- 1,000 offline cycles / 7,000 transitions produced zero outside, old-region, absence, stale, invalid, or semantic-update mismatches;
- 1,000 real-Bitwig samples with two semantic changes under coverage produced the same zero mismatch result;
- restore-plus-compose measured p95 `0.413209 ms` and maximum `7.356958 ms`;
- the real Push control, display, audio, movement, disappearance, and rollback checks passed;
- `PushUsbDisplay.class` remained byte-identical and sole-owned.

The accepted research commit is evidence only:

```text
local commit: 3e8df95e9cc489e69da72b9acb82f2d06c90dd00
tree:         f448eeda923232346037074a75b71c485e56ebe8
```

Do not merge or cherry-pick that research commit as production source. Reimplement the accepted production model cleanly from exact `origin/pushwig/main`.

## Source and PR topology

### DrivenByMoss source work

Create a clean feature branch directly from exact accepted `origin/pushwig/main`:

```text
pushwig/v1c-dynamic-local-composition
```

The source PR must:

- target `pushwig/main`;
- contain one final implementation commit;
- remain ordinary, non-draft, open, and unmerged for technical-lead review;
- identify its exact parent/head/tree and changed paths;
- link issue #23 and the paired central evidence PR.

### Central evidence work

From current accepted central `origin/main`, create:

```text
codex/v1c-dynamic-local-composition-evidence
```

The final central PR must contain only:

```text
evidence/v1c-dynamic-local-composition/**
```

It must include `Addresses #23`, identify the exact source PR/head/tree, and remain ordinary, non-draft, open, and unmerged.

## Authorized production envelope

Expected production changes are exactly:

```text
src/main/java/de/mossgrabers/framework/controller/display/AbstractGraphicDisplay.java
src/main/java/de/mossgrabers/controller/ableton/push/controller/Push2Display.java
src/main/java/de/mossgrabers/controller/ableton/push/controller/DynamicLocalPushFramePipeline.java
```

Any additional production path requires a stop and explicit technical justification before editing.

The following are not authorized for modification:

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

Do not change extension version, IDs, MIDI discovery, USB matching, endpoint, encoding, line padding, XOR shaping, transfer scheduling, or shutdown ownership.

## Required framework behavior

`AbstractGraphicDisplay.send()` must:

1. construct the newest copied `ModelInfo`;
2. install that newest model before deciding whether to render;
3. compute whether equality-covered semantic state changed;
4. render when state changed or a protected redraw hook requests current-model redraw;
5. preserve the existing list-clearing and send lifecycle;
6. continue using the same persistent bitmap.

Add one protected redraw-request hook whose ordinary implementation returns `false`.

The hook:

- is not public API;
- does not expose the bitmap;
- does not force unrelated displays to redraw continuously;
- is evaluated synchronously in the existing display send path.

Newest-model retention must occur even when `ModelInfo.equals()` returns true because overlay lists are not currently part of equality.

## Required Push selection behavior

Use the startup property:

```text
pushwig.dynamicLocalVisual=true
```

Read startup properties once during `Push2Display` construction.

Selection precedence is exact:

```text
neither property
    -> PassThroughPushFramePipeline.INSTANCE

pushwig.syntheticOverlay=true only
    -> SyntheticOverlayPushFramePipeline.INSTANCE

pushwig.dynamicLocalVisual=true
    -> DynamicLocalPushFramePipeline

both properties true
    -> DynamicLocalPushFramePipeline
```

Dynamic-local mode deliberately wins. The two diagnostic pipelines must never be stacked.

Only dynamic-local mode requests the full current-model redraw hook.

`Push2Display.send(IBitmap)` must preserve:

```text
shutdown/null guard
        -> exactly one pipeline.process
        -> exactly one PushUsbDisplay.send
```

## Required dynamic local pipeline

`DynamicLocalPushFramePipeline` must be package-private and instantiated once per display.

It may retain only fixed, bounded diagnostic state and reusable renderers.

Required lifecycle:

```text
A — initial visual
B — moved and enlarged, partially overlapping A
C — moved and reduced
D — replacement content and geometry
NONE
STALE
INVALID
```

The valid states must differ in position, size, overlap, and visual content.

For `NONE`, `STALE`, and `INVALID`, the pipeline performs no visual drawing after the complete semantic redraw.

The pipeline must:

- return the exact input `IBitmap` reference;
- retain no bitmap, raw frame, semantic snapshot, or historical output;
- use no second bitmap;
- allocate no bitmap, frame, byte array, renderer, collection, queue, task, or future per send;
- add no thread, executor, scheduler, timer, socket, shared memory, USB object, or capture type;
- avoid per-send `Enum.values()` or equivalent hidden array creation;
- use class-initialized reusable renderers where practical.

## Required regression matrix

The exact source head must prove:

### Ordinary default path

```text
no Pushwig properties
        -> pass-through pipeline
        -> existing dirty semantic render behavior
        -> no forced redraw
```

### Accepted V1B path

```text
pushwig.syntheticOverlay=true
        -> fixed static overlay pipeline
        -> no dynamic forced-redraw selection
```

### V1C path

```text
pushwig.dynamicLocalVisual=true
        -> newest ModelInfo retained
        -> full semantic redraw every eligible send
        -> current valid local visual or semantic-only output
```

Also prove that an ordinary test subclass using the default hook retains the accepted dirty-render count and behavior.

## Overlay and notification lifecycle

V1C must explicitly prove two remaining semantic cases.

### Overlay-only update

With equality-covered component and notification state otherwise stable:

1. change the overlay list;
2. perform the next dynamic send;
3. prove the newest overlay is present;
4. prove no older overlay or visual pixels remain.

### Notification lifecycle

While the dynamic visual is active:

1. display a notification;
2. move or remove the visual;
3. prove the current notification is restored correctly;
4. replace or expire the notification;
5. prove current underlying semantics return without stale notification or visual pixels.

## Pixel correctness

Use exact 960×160 aggregate comparison with the accepted BGRA8888 observation layout.

Run at least 1,000 complete deterministic cycles containing:

```text
A
B
C
D
NONE
STALE
INVALID
```

Include:

- partial overlap;
- enlargement and reduction;
- replacement visual content;
- a semantic update beneath covered pixels;
- an overlay-only update;
- notification appearance and removal.

Required zero mismatch counts:

```text
outside-current-region
old-region restoration
post-NONE full frame
STALE full frame
INVALID full frame
semantic-update-under-overlay
overlay-only update
notification-lifecycle restoration
```

Positive target-region mismatches must confirm that valid visuals actually changed pixels.

Do not commit frames, screenshots, UI crops, or extension binaries. Retain dimensions, masks, hashes, counts, methods, commands, and representative mismatch coordinates only.

## Source, build, and bytecode proof

Use the accepted explicit Java 21/Maven environment.

Build:

1. exact accepted base `1ae0b74f383314d170a5960ca763bdf9c319e787`;
2. exact proposed V1C source head;

under the same toolchain.

Retain:

- exact parent/head/tree and one-commit topology;
- exact changed-path envelope;
- source and patch hashes;
- build commands/results;
- artifact size and SHA-256;
- extracted payload comparison;
- bytecode proving newest-model retention, hook default, Push override and pipeline selection, same-reference return, bounded state, one pipeline call, and one USB send;
- byte-identical `PushUsbDisplay.class`;
- byte-identical accepted V1A/V1B pipeline classes unless an explicit reviewed reason exists.

## Performance and memory

Measure at least 1,000 post-warmup sends for:

```text
default pass-through
V1B static overlay
V1C forced redraw with no visual
V1C redraw plus visual
```

Retain p50, p95, maximum, project-owned allocation sites, existing host-render allocations, and bounded RSS/heap observations.

Review bands:

```text
green:  p95 <= 2 ms and max <= 10 ms
review: p95 <= 5 ms and max <= 15 ms
stop:   p95 > 5 ms or max > 15 ms
```

A review-band result requires an explicit technical recommendation. A stop-band result halts the slice.

Do not introduce asynchronous work or extra buffering to hide synchronous cost.

## Real-fixture sequence

Use the exact proposed source-head artifact on the accepted Mac + Bitwig 6.1 + Push 3 fixture.

### Phase A — default derivative

Launch without Pushwig properties and confirm:

- accepted controller/audio/display baseline;
- no dynamic visual;
- ordinary dirty-render behavior;
- normal quit.

### Phase B — V1B static regression

Launch with:

```text
pushwig.syntheticOverlay=true
```

Confirm:

- the accepted fixed mark appears;
- dynamic redraw mode is not selected;
- representative modes and baseline remain correct;
- normal quit.

### Phase C — V1C dynamic lifecycle

Launch with:

```text
pushwig.dynamicLocalVisual=true
```

Confirm:

- connection, pads, pressure/MPE, encoders, transport;
- coherent semantic display;
- Push audio device and audible headphone output;
- A/B/C/D movement, overlap, resize, and replacement;
- previous regions restore exactly;
- `NONE`, `STALE`, and `INVALID` are semantic-only;
- Track, Device Parameters, and Session or Browser work;
- semantic update beneath previous coverage appears;
- overlay-only update appears;
- notification appearance, movement restoration, replacement/expiration work;
- no clear, trail, stale block, scale error, lag, xrun, or relevant exception;
- normal quit.

### Phase D — exact rollback

Restore the untouched official artifact at the canonical filename, verify accepted SHA-256, verify exactly one scanned extension, relaunch, and physically confirm the ordinary official display.

## Expected central evidence

```text
evidence/v1c-dynamic-local-composition/
├── README.md
├── source-topology.md
├── framework-redraw-contract.md
├── lifecycle-and-pixel-restoration.md
├── overlay-and-notification.md
├── regression-paths.md
├── performance.md
├── build-artifact-comparison.md
├── real-fixture-and-rollback.md
└── manual-acceptance.md
```

Every file must state what it proves and what it does not prove.

## Explicit non-goals

- no external frame ingress;
- no IPC, socket, shared memory, memory-mapped file, or producer process;
- no final `VisualSourceFrame` type or wire format;
- no ScreenCaptureKit or Screen Recording permission;
- no Bitwig/editor window discovery or capture;
- no visual adapter, resolver, calibration, or pixel-anchor implementation;
- no second bitmap, region snapshot, backend raw-copy architecture, or transport rewrite;
- no second USB writer;
- no user-facing setting;
- no POM/dependency/test-framework change;
- no Push 2 hardware claim;
- no Steam Deck/Linux, yabridge, Monome, plugdata, appliance, battery, connector, or NUC work.

## Acceptance

V1C is complete only when:

1. the source PR is one implementation commit directly above exact accepted `pushwig/main`;
2. source changes remain within the three-path envelope;
3. newest-model retention and default-false redraw behavior are exact;
4. dynamic-local selection and property precedence are exact;
5. default and V1B paths do not gain dynamic redraw behavior;
6. the local lifecycle covers move, overlap, resize, replacement, none, stale, and invalid;
7. every required restoration/outside/semantic/overlay/notification mismatch count is zero;
8. the pipeline returns the same bitmap and adds no prohibited per-send state or allocation;
9. `PushUsbDisplay` remains byte-identical and sole-owned;
10. exact base/head builds and bounded artifact delta pass;
11. performance is green or explicitly reviewed within the review band;
12. the exact source head passes all real-fixture phases;
13. normal shutdown and exact official rollback pass;
14. both paired PRs are open, non-draft, unmerged, and identify exact heads;
15. relevant worktrees are clean and synchronized.

## Handoff

After V1C is accepted, **V1D — External Generated-Frame Ingress** may define an immutable latest-frame-wins input contract and process boundary.

V1D must consume the V1C lifecycle rather than replacing its restoration ownership.
