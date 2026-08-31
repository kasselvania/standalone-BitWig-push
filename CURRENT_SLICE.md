# Current Slice: V1B — Startup-Scoped Static Synthetic Overlay

## Status

Ready to start from current `main` after V1A source merge `033ccef8c64f08e8d8d41fa90d48fa06b326a1a1` and central evidence merge `3ef7d84fe2c1586babbf49658664585118ed5ddd`.

## Primary claim

Prove that the accepted `PushFramePipeline` can add a small project-owned visual layer to the persistent semantic Push bitmap without clearing, corrupting, or unpredictably changing pixels outside the declared overlay bounds.

V1B is the first visible-pixel slice. It is deliberately a **static, startup-scoped diagnostic proof**, not the final compositor.

With diagnostic activation absent, the exact V1B source must preserve the accepted V1A path:

```text
complete semantic IBitmap
        -> PassThroughPushFramePipeline
        -> exact same IBitmap object
        -> unchanged PushUsbDisplay
        -> existing Push USB writer
```

With diagnostic activation enabled before Bitwig starts, the same artifact must perform:

```text
complete semantic IBitmap
        -> SyntheticOverlayPushFramePipeline
        -> one synchronous IBitmap.render callback
        -> fixed bounded synthetic mark
        -> exact same IBitmap object
        -> unchanged PushUsbDisplay
        -> existing Push USB writer
```

The slice must establish whether a second `IBitmap.render` callback paints over the existing persistent bitmap as required. That behavior is a hypothesis to test, not an API guarantee to assume.

## Why the first overlay is static and startup-scoped

DrivenByMoss owns one persistent 960×160 semantic bitmap. Its semantic renderer runs only when `ModelInfo` changes, while the display send path runs on each eligible update. A moving or runtime-disabled overlay could therefore leave stale pixels or trails when no semantic re-render occurs.

V1B avoids conflating that lifecycle problem with the first composition proof:

- the synthetic mark is fixed in one declared rectangle;
- activation is selected once at display construction;
- disabling it means restarting Bitwig without the diagnostic activation;
- the fresh display bitmap and normal semantic render provide the recovery boundary;
- animation, hot switching, damage tracking, frame snapshots, and external pixels remain later claims.

See [`docs/V1B_SYNTHETIC_COMPOSITION.md`](docs/V1B_SYNTHETIC_COMPOSITION.md).

## Accepted authorities and bases

### Central authority repository

```text
Repository: kasselvania/standalone-BitWig-push
Commit:     3ef7d84fe2c1586babbf49658664585118ed5ddd
Tree:       3fec2724e71ca32772f8f61fc870efa06571fb10
```

### DrivenByMoss implementation repository

```text
Repository:       kasselvania/DrivenByMoss
Immutable basis:  pushwig/upstream-26.4.1
Integration base: pushwig/main
Commit:           033ccef8c64f08e8d8d41fa90d48fa06b326a1a1
Tree:             9aec7429ff093addee001a62a5a07309708fd592
```

The integration commit merges the exact accepted V1A source head `6e1e4cbd2e725a7951e5b4dc1278fbb6e7b5d61c`. The immutable upstream basis remains at `fd03245ab38fa5149c45934051d937ee9fda6d08` and must not move.

Official artifact SHA-256 to restore:

```text
98dc3195ad8d911526e18b1005f09f69a1aedcb965b080565474104654345c5a
```

## Required branch and PR topology

### DrivenByMoss source work

Create a clean feature branch directly from `origin/pushwig/main`:

```text
pushwig/v1b-static-synthetic-overlay
```

The source PR must:

- be opened in `kasselvania/DrivenByMoss`;
- target `pushwig/main`;
- contain one final implementation commit;
- remain ordinary, non-draft, open, and unmerged for technical-lead review.

### Central evidence work

Create a clean central branch from the exact central basis established by the status merge:

```text
codex/v1b-static-synthetic-overlay-evidence
```

The central PR must:

- contain only retained V1B evidence;
- reference the exact source PR/head/tree;
- include `Addresses #<active V1B issue>`;
- remain ordinary, non-draft, open, and unmerged.

Do not place DrivenByMoss source or generated extension artifacts in the central repository.

## Preferred activation contract

Use one startup-scoped Java system property:

```text
pushwig.syntheticOverlay=true
```

The production artifact must read this property once during `Push2Display` construction.

- Property absent or false: select `PassThroughPushFramePipeline.INSTANCE`.
- Property true: select `SyntheticOverlayPushFramePipeline.INSTANCE`.
- Do not poll the property per frame.
- Do not expose a user-facing setting or alter `PushConfiguration` in V1B.
- Do not add a macOS-specific type or path to the controller extension.

The real fixture must prove that the property can be supplied to the Bitwig controller-extension process. If the preferred property cannot reach that process, stop and document the exact failure before proposing another activation mechanism. Do not silently hard-code the overlay on or widen into settings/configuration work.

## Authorized DrivenByMoss source envelope

Expected production changes are limited to:

```text
src/main/java/de/mossgrabers/controller/ableton/push/controller/Push2Display.java
src/main/java/de/mossgrabers/controller/ableton/push/controller/SyntheticOverlayPushFramePipeline.java
```

The accepted V1A files remain present:

```text
PushFramePipeline.java
PassThroughPushFramePipeline.java
```

They should not require behavioral change. Any additional production path requires an explicit stop and technical justification before editing.

The following are not authorized for modification:

```text
PushUsbDisplay.java
pom.xml
PushConfiguration.java
PushControllerSetup.java
AbstractGraphicDisplay.java
BitmapImpl.java
IBitmap.java
```

## Required overlay behavior

The preferred mark is a fixed two-color rectangle in the top-right of the 960×160 frame:

```text
outer bounds: x=856, y=4, width=96, height=16
inner bounds: x=860, y=8, width=88, height=8
outer color: ColorEx.PINK
inner color: ColorEx.WHITE
```

Equivalent dimensions may be proposed only before editing and only to avoid a proven hardware/display conflict. The exact bounds and colors must be retained as evidence.

The implementation must:

1. Use one class-initialized renderer or equivalent reusable object; do not allocate a renderer/lambda per send.
2. Call `semanticFrame.render(false, renderer)` exactly once for each eligible overlay-enabled send.
3. Draw only inside the declared outer rectangle.
4. Return the exact same `IBitmap` reference.
5. Retain no frame after `process` returns.
6. Leave `PushUsbDisplay` and the sole USB writer unchanged.
7. Add no raw pixel copy, off-screen bitmap, queue, thread, executor, timer, IPC, capture dependency, or platform-specific type.
8. Keep the ordinary property-off path on the accepted pass-through singleton.

A source comment must state that this is a static diagnostic proof and not the final visual compositor.

## Required preservation proof

The exact V1B head must be tested in one stable semantic state with the diagnostic property off and on.

Retain evidence that:

- the declared overlay rectangle changes as expected;
- pixels outside the declared rectangle are identical, or every mismatch is precisely characterized and reviewed;
- the overlay does not cause a whole-frame clear, background replacement, coordinate offset, scaling error, or color-space surprise;
- repeated sends while semantic state is unchanged do not expand the mark or produce trails;
- switching among at least three representative DrivenByMoss modes causes the semantic frame to update normally while the mark remains bounded;
- restarting without the property restores an unmarked semantic display.

Preferred proof order:

1. exact-source and bytecode inspection;
2. local analysis of the existing DrivenByMoss debug bitmap window in a stable non-animated state; or
3. temporary, uncommitted, observation-only raw-bitmap instrumentation derived from the exact head.

Do not commit proprietary screenshots or raw Bitwig/Push frame captures. Retain only hashes, mismatch counts, coordinates, locally generated masks, aggregate results, and sanitized methodology.

Any temporary instrumentation must be removed before the source commit. The exact committed artifact must also pass the real Push test without instrumentation.

## Required timing and allocation evidence

V1B introduces actual pixel work, so retain a bounded performance observation.

- Measure property-off and property-on pipeline cost using temporary external or uncommitted instrumentation.
- Record sample count, p50, p95, maximum, and measurement method.
- Record whether any new project-owned object is allocated per send.
- Exercise at least an idle semantic view and repeated mode/parameter changes.
- Record any audio xrun, control lag, display lag, or abnormal CPU observation.

Provisional review band on the accepted M1 Max fixture:

```text
p95 pipeline processing <= 2 ms
maximum pipeline processing <= 10 ms
```

Exceeding a band is not permission to optimize outside the slice. Stop and surface the result for review.

Do not add permanent per-frame logging, counters, hashing, or profiler code to the committed production source.

## Build and artifact proof

Use the explicit accepted Java 21/Maven environment.

Build both:

1. accepted integration base `033ccef8c64f08e8d8d41fa90d48fa06b326a1a1`;
2. exact V1B source head;

under the same toolchain.

Retain:

- source parent/head/tree;
- one-commit topology;
- exact changed paths;
- build commands and results;
- artifact sizes and SHA-256 values;
- extracted class/resource comparison;
- bytecode for property selection and overlay process;
- proof that `PushUsbDisplay.class` remains byte-identical;
- proof that unrelated payloads remain byte-identical or are precisely characterized.

Expected executable differences are limited to `Push2Display.class` and the new synthetic-overlay pipeline class.

## Real-fixture sequence

Use the accepted Mac + Bitwig 6.1 + Push 3 fixture and the exact proposed source-head artifact.

### Phase A — default-off derivative

1. Install the exact V1B artifact as the sole scanned DrivenByMoss extension.
2. Launch Bitwig without the diagnostic property.
3. Confirm the normal semantic display and the accepted eleven-row baseline.
4. Confirm no synthetic mark is visible.
5. Quit Bitwig normally.

### Phase B — overlay-enabled derivative

1. Launch the same exact artifact with `pushwig.syntheticOverlay=true` supplied before process start.
2. Confirm the fixed two-color mark appears at the declared bounds.
3. Exercise at least Track, Device Parameters, and one additional representative mode.
4. Leave a stable semantic frame displayed long enough to observe repeated sends.
5. Confirm all semantic content outside the mark remains coherent and interactive.
6. Repeat the eleven-row baseline, including audio through Push headphones.
7. Record any error, lag, xrun, unexpected clear, expansion, or trail.
8. Quit Bitwig normally.

### Phase C — property-off recovery

1. Relaunch the same exact artifact without the property.
2. Confirm the overlay is absent and the normal semantic display is restored.
3. Quit Bitwig normally.

### Phase D — exact official rollback

1. Move the derivative outside the scan path.
2. Restore the untouched official artifact.
3. Reverify SHA-256 `98dc3195ad8d911526e18b1005f09f69a1aedcb965b080565474104654345c5a`.
4. Confirm exactly one scanned extension.
5. Relaunch sufficiently to confirm the official extension remains loadable.
6. Leave the ordinary environment on the official artifact unless the maintainer explicitly directs otherwise.

## Expected central evidence

Retain a structure equivalent to:

```text
evidence/v1b-static-synthetic-overlay/
├── README.md
├── source-topology.md
├── activation-and-rendering.md
├── pixel-preservation.md
├── performance.md
├── build-artifact-comparison.md
├── install-rollback.md
└── manual-acceptance.md
```

Every file must state what it proves and what it does not prove.

Do not commit:

- official or derivative `.bwextension` files;
- proprietary screenshots, full frames, or UI crops;
- temporary instrumentation source/binaries;
- full Bitwig logs;
- user projects;
- account/license data;
- serial numbers, hardware UUIDs, hostnames, IP addresses, or unsanitized personal paths.

## Explicit non-goals

- no moving or animated overlay;
- no runtime hot toggle;
- no overlay erasure/damage-tracking system;
- no alternate output bitmap or immutable frame representation;
- no semantic bitmap copy or snapshot;
- no raw external frame;
- no `PushDisplayTransport` abstraction;
- no `PushUsbDisplay` modification;
- no queue, worker, executor, timer, latest-frame store, IPC, socket, or shared memory;
- no ScreenCaptureKit or Screen Recording permission;
- no Bitwig/editor window discovery or capture;
- no visual adapter, resolver, calibration, or pixel-anchor implementation;
- no POM/dependency/test-framework change;
- no version, extension-ID, controller-ID, USB matcher, endpoint, encoder, padding, XOR, or transfer change;
- no Push 2 hardware claim;
- no Steam Deck/Linux, yabridge, Monome, plugdata, appliance, battery, connector, or NUC work.

## Acceptance criteria

V1B is complete only when all of the following are true:

1. The source PR is one commit directly above accepted `pushwig/main` at `033ccef8c64f08e8d8d41fa90d48fa06b326a1a1` / tree `9aec7429ff093addee001a62a5a07309708fd592`.
2. Source changes remain within the authorized envelope.
3. The default startup path selects the accepted pass-through pipeline.
4. The enabled startup path selects one static synthetic-overlay pipeline.
5. The overlay pipeline performs exactly one bounded render callback and returns the same `IBitmap` reference.
6. The mark appears at the declared location and no pixels outside its bounds change without a precise accepted explanation.
7. Repeated sends and representative semantic-mode changes produce no whole-frame clear, expansion, or trail.
8. The property-off relaunch restores an unmarked semantic display.
9. Timing/allocation evidence is retained and remains within the provisional review band, or work stops for review.
10. `PushUsbDisplay` and all transport behavior remain unchanged and sole-owned.
11. The exact source head builds and the artifact delta is bounded to intended classes.
12. The same exact artifact passes default-off, enabled-overlay, and property-off-recovery real-fixture phases.
13. The accepted eleven-row baseline passes while the overlay is enabled.
14. The exact official artifact is restored and reverified.
15. The source PR and paired central evidence PR are open, non-draft, unmerged, and identify exact heads.
16. Relevant repositories and worktrees are clean and synchronized.

If a second render callback clears or unpredictably damages the semantic frame, V1B is not complete. Stop, restore the official artifact, retain the failure, and do not paper over it by widening into raw bitmap copying or transport replacement.

## Expected V1C handoff

V1C may begin only after V1B is reviewed and merged.

V1C will answer the next separate question:

> How can a process outside Bitwig publish a generated, immutable, latest-frame-wins `VisualSourceFrame` for the in-process pipeline without blocking control/audio or introducing a second Push USB owner?

V1B must prove only the local pixel-composition primitive and its lifecycle limits.

## Review standard

Do not accept V1B merely because a colored rectangle appears once. The exact source head must prove default-off safety, bounded static composition, outside-region preservation, repeated-send stability, representative semantic updates, measured cost, real Push behavior, startup-scoped recovery, one-writer preservation, and exact official rollback.