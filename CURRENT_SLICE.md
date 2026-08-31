# Current Slice: V1C-0 — Dynamic Raster Replacement and Exact Restoration Feasibility

## Status

Ready to execute from the current `origin/main` containing this authority card and from DrivenByMoss `origin/pushwig/main` at the exact accepted V1B integration state.

Active issue: [#19 — V1C-0: Select dynamic raster restoration architecture](https://github.com/kasselvania/standalone-BitWig-push/issues/19).

Before work begins, fetch central `origin/main` and verify that its history contains:

```text
95d93e262c33163783e23a8d3e66f6f92746918d  # accepted V1B evidence
1e5767552838a5bf97ee6197ff2f5ac7bfb541a7  # V1C-0 status authority
```

The active central evidence branch must be created directly from the then-current `origin/main`. If `origin/main` has moved, inspect every intervening commit and stop if it changes V1C-0 authority or scope. Do not hard-code a pre-status ancestor as the evidence basis.

## Primary claim

Determine and prove the smallest technically sound frame-restoration strategy that can support a changing or disappearing project-owned visual layer while preserving the **current** DrivenByMoss semantic image exactly and retaining one Push USB writer.

V1B proved that one fixed bounded mark can be painted into the persistent semantic bitmap with zero changes outside its declared region. It did not prove movement, replacement, disappearance, stale-source fallback, or exact restoration.

A dynamic visual creates this lifecycle:

```text
semantic bitmap contains frame S
        -> visual A overwrites R1
        -> visual B overwrites R2
        -> visual becomes absent, stale, or invalid
```

Unless the old bounds are rebuilt from the **current semantic frame**, historical visual pixels can remain. External-frame IPC is therefore deferred until exact local replacement and fallback are proven.

V1C-0 is an evidence-first research gate. It selects one production representation and source seam. It does not merge a production compositor, external-frame protocol, capture helper, or transport change.

See [`docs/V1C0_DYNAMIC_RASTER_COMPOSITION.md`](docs/V1C0_DYNAMIC_RASTER_COMPOSITION.md).

## Accepted source authorities

DrivenByMoss integration:

```text
repository: kasselvania/DrivenByMoss
branch:     pushwig/main
commit:     1ae0b74f383314d170a5960ca763bdf9c319e787
tree:       a81e5c4330b31f36845c25e98e322990d62f0c67
```

That merge contains exact accepted V1B source head:

```text
a2e0341b7bccfa4e6b13614f4adffc2235f785f4
```

Immutable upstream basis remains:

```text
branch: pushwig/upstream-26.4.1
commit: fd03245ab38fa5149c45934051d937ee9fda6d08
tree:   edd2ad636b0aa1f39919f0ffd05c968015450075
```

Official extension SHA-256 to restore after any real-fixture prototype:

```text
98dc3195ad8d911526e18b1005f09f69a1aedcb965b080565474104654345c5a
```

## Accepted V1B result

V1B established:

- default startup retained the V1A pass-through path;
- startup activation selected one reusable synthetic pipeline;
- one additional `IBitmap.render(false, renderer)` callback drew a fixed two-color mark;
- the pipeline returned the same `IBitmap` reference;
- 1,529 target pixels changed and all 152,064 outside pixels remained identical;
- repeated sends and representative semantic modes produced no clear, expansion, smear, or trail;
- property-off restart removed the mark;
- enabled p95/max processing was 54.542 µs / 194 µs;
- `PushUsbDisplay.class` remained byte-identical;
- real Push controls/audio/display, normal shutdown, recovery, and exact official rollback passed.

## Source facts that create this gate

1. `AbstractGraphicDisplay` owns one persistent semantic `IBitmap`.
2. `send()` calls `renderImage()` only when `ModelInfo` changes, then always sends the persistent bitmap.
3. `ModelInfo` copies and retains component/overlay lists, making on-demand semantic redraw plausible but unproven.
4. `IBitmap` exposes `render(...)` and `encode(...)`, but no generic copy, blit, read-region, write-region, or restore operation.
5. `BitmapImpl.encode(...)` can observe bitmap memory, but the accepted wrapper has no generic write-back contract.
6. `IGraphicsContext.drawImage(...)` currently accepts the project `ImageImpl`; bitmap-to-bitmap blitting is not yet an accepted host-neutral operation.
7. `PushUsbDisplay` remains the sole transport owner and is outside this research.

## Topology

### Central evidence

From the current accepted `origin/main`, create:

```text
codex/v1c0-dynamic-raster-composition-evidence
```

The final reviewable output is one ordinary, non-draft, open, unmerged PR containing only:

```text
evidence/v1c0-dynamic-raster-composition/**
```

The PR must include `Addresses #19` and state its exact basis/head/tree.

### DrivenByMoss experiments

Use clean temporary worktrees rooted at exact `origin/pushwig/main` commit `1ae0b74f383314d170a5960ca763bdf9c319e787`.

Temporary branches, commits, patches, instrumentation, and harnesses are allowed locally. They must not be merged into `pushwig/main`, and no production DrivenByMoss PR is expected from V1C-0.

Retain patch/source/harness hashes, changed paths, build commands/results, artifact hashes, and removal state. Do not copy source into the central repository.

## Candidate order

Evaluate in order and stop when one candidate satisfies all correctness, lifecycle, one-writer, portability, and performance requirements.

### A — redraw retained current semantic model

```text
retained current ModelInfo
        -> full semantic redraw into persistent bitmap
        -> current generated visual
        -> unchanged PushUsbDisplay
```

Prove current-value fidelity, exact movement/removal, semantic changes under active bounds, Push-specific scope, timing, and allocations.

### B — pristine semantic bitmap plus reusable final bitmap

```text
pristine semantic bitmap
        -> reusable full-frame copy/blit
        -> one reusable final bitmap
        -> current generated visual
        -> unchanged PushUsbDisplay
```

Prove exact copy/blit on the accepted Bitwig API, a host-neutral wrapper boundary, one-time allocation, exact fallback, and practical cost.

### C — semantic-generation-aware region restore

Test only if A and B fail. A snapshot taken before a semantic change may never be restored over newer semantics. A trustworthy semantic-generation rule is mandatory.

### D — narrow backend memory copy

Test only if higher-level candidates fail. Keep dimensions, pixel format, stride, bounds, buffer lifetime, and backend memory objects behind a host-neutral adapter.

## Required lifecycle experiment

Use deterministic generated visual states:

```text
A at R1
B at R2
C at R3
D at R4
none
```

Repeat at least 1,000 composition cycles offline or an equivalent instrumented run. Also trigger a semantic model change beneath a previously covered region.

The selected candidate must prove:

1. Each visual appears only in its current bounds.
2. Previous bounds are restored to exact current semantic values.
3. After `none`, the full 960×160 output equals the current semantic reference.
4. Pixels outside current bounds equal the semantic reference.
5. No trail, smear, expansion, duplicate, stale block, full clear, scale error, or coordinate offset occurs.
6. Semantic updates under previous visual bounds survive.
7. Stale, invalid, or unavailable input produces semantic-only output.
8. Representative mode, track, device, and parameter changes remain coherent.

## Correctness evidence

Retain only sanitized aggregate evidence:

- candidate/prototype hash;
- semantic-reference hash;
- target-region hashes;
- outside-region mismatch count;
- old-region restoration mismatch count;
- full-frame mismatch count after absence;
- semantic-update-under-overlay mismatch count;
- dimensions, pixel format, masks, tools, commands, and representative mismatch coordinates.

Do not commit screenshots, raw frames, UI crops, or extension binaries.

No candidate with unexplained nonzero restoration or outside-region mismatches can be selected.

## Performance evidence

Measure at least 1,000 post-warmup cycles for each serious candidate:

- p50, p95, and maximum restore-plus-compose time;
- semantic-only baseline;
- fixed construction-time allocations;
- project-owned per-cycle allocations;
- existing host-adapter allocations;
- working-set behavior;
- control/display/audio observations.

Review bands:

```text
green:  p95 <= 2 ms and max <= 10 ms
review: p95 <= 5 ms and max <= 15 ms
stop:   p95 > 5 ms or max > 15 ms
```

Do not add concurrency or buffering to hide a slow result. No candidate may use a second USB writer, unbounded queue, or per-frame thread/task creation.

## Build and real-fixture evidence

For every executed candidate:

- begin from exact accepted source commit/tree;
- record temporary patch/source hash and changed paths;
- use the accepted explicit Java 21/Maven environment;
- retain build result and artifact hash;
- inspect executable delta;
- keep `PushUsbDisplay.class` byte-identical for any candidate reaching fixture use;
- remove temporary timing/frame-dump instrumentation before a live check;
- never commit generated extension binaries.

The leading safe candidate must receive a bounded Mac + Bitwig 6.1 + Push 3 check:

- exact prototype artifact/patch hashes;
- sole scanned extension;
- moving/replacing/absent sequence;
- Track, Device Parameters, and Session or Browser updates;
- semantic change under a previously covered region;
- coherent controls and semantic display;
- Push audio device and audible headphone output;
- no trail, stale content, lag, xrun, or relevant error;
- normal quit;
- exact official rollback and physical restored-display confirmation.

If no candidate is safe enough, retain the precise blocker and do not install it.

## Decision output

The final evidence selects exactly one outcome.

### SELECTED

Name:

- production ownership model;
- exact source seam and expected changed paths for V1C;
- public/internal interface boundary;
- bitmap/frame lifetime rules;
- semantic-generation/redraw rules;
- stale/absent behavior;
- timing/allocation budget;
- rejected-candidate rationale.

### BLOCKED

Name the smallest missing API/capability, experiments performed, and next bounded research.

## Expected evidence

```text
evidence/v1c0-dynamic-raster-composition/
├── README.md
├── accepted-source-analysis.md
├── candidate-a-semantic-redraw.md
├── alternative-candidates.md
├── pixel-restoration.md
├── performance.md
├── real-fixture-and-rollback.md
└── decision.md
```

Files may be omitted only when `decision.md` explains why the corresponding candidate was not reached.

## Non-goals

No production source PR/merge, external-frame IPC, socket/shared memory, ScreenCaptureKit, window capture, `VisualSourceFrame` wire format, source discovery, resolver, calibration, pixel anchors, transport rewrite, second USB owner, user-facing setting, Push 2 claim, Steam Deck/Linux, yabridge, Monome, plugdata, appliance, battery, connector, or NUC work.

## Acceptance

V1C-0 is complete only when:

1. Research starts from current accepted central `origin/main` and exact DrivenByMoss integration commit/tree.
2. Exact source lifecycle/API constraints are retained.
3. Candidate A is tested first or explicitly rejected from source evidence.
4. At least one candidate proves moving, replacing, absent, stale, and semantic-update-under-overlay states.
5. Selected candidate has zero outside-region, old-region restoration, and post-absence full-frame mismatches.
6. Stale/unavailable input produces semantic-only output.
7. Performance/allocation evidence is retained.
8. `PushUsbDisplay` remains unchanged and sole-owned.
9. The leading candidate receives bounded real-fixture validation or a precise safety blocker.
10. Exact official rollback passes after any fixture prototype.
11. `decision.md` selects one production seam or one precise blocker.
12. No temporary prototype/instrumentation is merged.
13. The central evidence PR is open, non-draft, unmerged, and identifies exact basis/head/tree.
14. Accepted branches and ordinary worktrees are clean and synchronized.

## Handoff

If selected, **V1C — Dynamic Local Composition Lifecycle** implements only the chosen restoration/composition primitive with generated local frames.

**V1D — External Generated-Frame Ingress** follows only after dynamic replacement, removal, and semantic fallback are proven locally.

## Review standard

Correct restoration outranks minimal line count, raw speed, or novelty. Do not accept a candidate that can paint changing pixels but cannot restore the exact current semantic output when the visual moves, disappears, becomes invalid, or becomes stale.