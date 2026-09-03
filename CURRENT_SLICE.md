# Current Work — Design discussion after V3

## Status

**NO ACTIVE IMPLEMENTATION SLICE**

V3 is accepted and merged.

- Merge commit: `8689d1b3cbc89e9c3923fd19cb741e594c0ba445`
- Accepted tree: `e5cdbeadd178c4cc9c7a3d2e78ab13cb99f89846`
- Closed issue: [#45 — V3: Adaptive Bitwig window-relative visual lens](https://github.com/kasselvania/standalone-BitWig-push/issues/45)
- Accepted design: [`docs/design/window-relative-visual-lens.md`](docs/design/window-relative-visual-lens.md)
- Fixture evidence: [`evidence/v3-window-relative-lens/README.md`](evidence/v3-window-relative-lens/README.md)

## What V3 established

Pushwig can now:

```text
unique Bitwig main window
        -> human-readable visual profile
        -> normalized window-relative crop
        -> explicit helper-local crop and centered-cover scale
        -> accepted external frame ingress
        -> current DrivenByMoss semantics + live Bitwig pixels
        -> physical Push 3
```

The maintained macOS helper follows ordinary window movement, recomputes the crop after supported resize, revokes stale generations, falls back on missing or ambiguous sources, and reacquires a recreated Bitwig window. The normalized crop was proven with a generated native quadrant fixture and a focused real-Push test. V2 explicit-display mode remains available as a diagnostic path.

## Current product limitation

V3 follows a region of the Bitwig window. It does **not** know which Bitwig device occupies that region.

Bitwig may reflow Sampler, the device chain, and neighboring panels while the outer window resizes. The capture remains correctly attached to the window and correctly cropped, but the useful device can move outside the profiled region.

That limitation is now the central product-design question—not another transport, bitmap, or ScreenCaptureKit ownership question.

## Current design work

No implementation issue or branch should be opened until the maintainer and technical lead have agreed on the intended device-aware experience.

The first concrete design artifact is now:

- [Issue #47 — native Bitwig devices × DrivenByMoss behavior matrix](https://github.com/kasselvania/standalone-BitWig-push/issues/47)
- [`docs/design/native-device-behavior-matrix.md`](docs/design/native-device-behavior-matrix.md)
- [`docs/design/native-device-behavior-matrix.csv`](docs/design/native-device-behavior-matrix.csv)
- [`docs/reference/manuals/`](docs/reference/manuals/) — pinned official manual references and local fetcher

This catalog separates four questions: what Bitwig exposes, what DrivenByMoss currently controls, what visual region Pushwig can verify, and what presentation Pushwig has actually designed.

The discussion should decide at least:

- what visual information is genuinely useful on Push;
- which existing DrivenByMoss screens should remain unchanged;
- where a native-device overview should replace or augment the current eight-parameter display;
- how current encoder bindings, touch, rotation, and multiple touches should influence framing;
- how Sampler overview, playback/loop markers, and sliced workflows should differ;
- how the Browser should be redesigned around results, filters, preview, commit, and cancel;
- whether internal Bitwig panel localization should use layout constraints, calibration, semantic hints, pixel anchors, or another approach;
- what configuration should be automatic versus user-authored;
- what would make the result pleasant enough to use rather than merely technically functional.

## Stable boundaries

- Bitwig remains the DAW and audio-engine authority.
- DrivenByMoss remains semantic/controller authority and the sole Push display transport owner.
- The helper owns platform discovery, capture, and helper-local pixel processing only.
- Visual failure returns to current semantic output.
- Wrong or ambiguous visual selection must abstain.
- The accepted raster sink and external-frame protocol remain stable unless a concrete product blocker requires change.
- Stable deterministic behavior belongs in committed tests; real fixture evidence stays concise.

## Repository housekeeping

Historical branch/worktree cleanup remains tracked by [#41](https://github.com/kasselvania/standalone-BitWig-push/issues/41). It must not be confused with product design or used to create another chain of feature-blocking governance slices.
