# Current Slice: V1C-0 — Dynamic Raster Replacement and Exact Restoration Feasibility

## Status

Ready to start from current `main` after V1B source merge `1ae0b74f383314d170a5960ca763bdf9c319e787` and central evidence merge `95d93e262c33163783e23a8d3e66f6f92746918d`.

## Primary claim

Determine and prove the smallest technically sound frame-restoration strategy that can support a changing or disappearing project-owned visual layer while preserving the **current** DrivenByMoss semantic image exactly and retaining one Push USB writer.

V1B proved that one fixed bounded mark can be painted into the persistent semantic bitmap with zero changes outside its declared region. That does **not** yet prove a dynamic visual system.

A moving, changing, stale, or removed visual layer creates a different problem:

```text
semantic bitmap contains frame S
        -> visual A overwrites region R1
        -> next visual B uses region R2
        -> visual source disappears
```

Unless the pixels under `R1` and `R2` are restored from the **current semantic frame**, old visual pixels can remain as trails or stale content. External-frame IPC must not be designed before that lifecycle has a lawful restoration primitive.

V1C-0 is an evidence-first research gate. It selects the production representation and seam for dynamic composition. It does not merge a production compositor, external-frame protocol, capture helper, or transport change.

See [`docs/V1C0_DYNAMIC_RASTER_COMPOSITION.md`](docs/V1C0_DYNAMIC_RASTER_COMPOSITION.md).

## Accepted authorities and bases

### Central authority repository

```text
Repository: kasselvania/standalone-BitWig-push
Commit:     95d93e262c33163783e23a8d3e66f6f92746918d
Tree:       b1f97701801a015c075d09369860f4986403b9a9
```

### DrivenByMoss implementation repository

```text
Repository:       kasselvania/DrivenByMoss
Immutable basis:  pushwig/upstream-26.4.1
Integration base: pushwig/main
Commit:           1ae0b74f383314d170a5960ca763bdf9c319e787
Tree:             a81e5c4330b31f36845c25e98e322990d62f0c67
```

The integration commit contains the exact accepted V1B source head:

```text
a2e0341b7bccfa4e6b13614f4adffc2235f785f4
```

The immutable upstream basis remains:

```text
commit: fd03245ab38fa5149c45934051d937ee9fda6d08
tree:   edd2ad636b0aa1f39919f0ffd05c968015450075
```

Official extension SHA-256 to restore after any real-fixture prototype:

```text
98dc3195ad8d911526e18b1005f09f69a1aedcb965b080565474104654345c5a
```

## Accepted V1B result

V1B established all of the following on the accepted Mac + Bitwig 6.1 + Push 3 fixture:

- the property-off artifact retained the accepted V1A pass-through path;
- startup activation selected one reusable synthetic pipeline;
- one additional `IBitmap.render(false, renderer)` callback drew a fixed two-color mark;
- the pipeline returned the exact same `IBitmap` reference;
- the concrete 960×160 comparison observed 1,529 target-region changes and **zero outside-region changes**;
- repeated sends and representative semantic modes produced no clear, expansion, smear, or trail;
- property-off restart removed the mark;
- enabled p95/max pipeline cost was 54.542 µs / 194 µs;
- `PushUsbDisplay.class` remained byte-identical;
- the real Push baseline, normal shutdown, and exact official rollback passed.

V1B proves the in-place static painting primitive. It does not prove movement, replacement, erasure, stale-source fallback, or semantic restoration.

## Source constraints that create this gate

The accepted source currently has these relevant properties:

1. `AbstractGraphicDisplay` owns one persistent semantic `IBitmap` created at construction.
2. `AbstractGraphicDisplay.send()` creates a new `ModelInfo`, calls `renderImage()` only when that model changes, clears the temporary component lists, and then sends the persistent bitmap on every eligible call.
3. `ModelInfo` retains copied component and overlay lists, so a current semantic redraw may be possible, but that behavior and its cost are not yet accepted as a dynamic-composition contract.
4. `IBitmap` exposes `render(...)` and `encode(...)`; it exposes no generic copy, blit, write-region, or restore-region operation.
5. `BitmapImpl.encode(...)` can observe the Bitwig bitmap memory, but the production wrapper has no accepted generic write-back contract.
6. `IGraphicsContext.drawImage(...)` exists, but the current Bitwig adapter accepts the project's `ImageImpl`; it does not yet establish that an `IBitmap` can be drawn into another `IBitmap` through the host-neutral abstraction.
7. `PushUsbDisplay` remains the accepted sole USB transport owner and is outside this research gate.

Do not assume one of these observations is the final architecture. Prove the smallest adequate option.

## Repository and PR topology

### Central evidence work

Create a clean central branch directly from the accepted central basis:

```text
codex/v1c0-dynamic-raster-composition-evidence
```

The final reviewable output is one ordinary, non-draft, open, unmerged central evidence PR containing only:

```text
evidence/v1c0-dynamic-raster-composition/**
```

The PR must include `Addresses #<active V1C-0 issue>`.

### DrivenByMoss experimental work

Use clean temporary worktrees rooted at exact `origin/pushwig/main`.

Temporary prototype branches, commits, patch files, instrumentation, or harnesses are permitted locally only when needed to test a candidate. They must not be merged into `pushwig/main`, and no DrivenByMoss source PR is expected from V1C-0.

Retain exact source/patch hashes, changed-path summaries, build artifact hashes, and commands. Remove or abandon temporary prototype branches after evidence is safely retained. Leave the accepted integration branch unchanged.

Do not copy DrivenByMoss source into the central repository.

## Candidate order

Evaluate candidates in this order. Stop when one candidate satisfies every correctness, lifecycle, one-writer, and performance criterion strongly enough to authorize a production slice.

### Candidate A — redraw the retained current semantic model, then compose

Prototype a narrow Push-only path equivalent to:

```text
retained current ModelInfo
        -> full semantic redraw into the existing persistent bitmap
        -> draw current dynamic visual layer
        -> send through unchanged PushUsbDisplay
```

Questions to prove:

- Can the current retained `ModelInfo` reproduce the correct current semantic frame on demand?
- Can this occur on each eligible dynamic visual update without stale data or unintended model mutation?
- Does a visual move or disappear with exact semantic restoration?
- What are p50/p95/max time and allocation behavior?
- Can the necessary production seam remain Push-specific rather than imposing unconditional redraw on every graphic controller?

Candidate A is preferred only if its correctness is exact and its cost remains practical.

### Candidate B — reusable final/output bitmap with semantic blit

Prototype a two-bitmap ownership model:

```text
persistent pristine semantic bitmap
        -> copy/blit into one reusable final bitmap
        -> compose current visual layer into final bitmap
        -> send final bitmap through unchanged PushUsbDisplay
```

Questions to prove:

- Can the Bitwig host bitmap be drawn or copied into another bitmap through a narrow, host-neutral abstraction?
- Does the current Bitwig graphics API treat a bitmap as a drawable image in the exact accepted API version?
- Can the wrapper be extended without leaking Bitwig implementation types into the generic frame contract?
- Can the final bitmap be allocated once and reused?
- Does the full-frame copy remain within the performance band?

A separate final bitmap is the preferred long-term ownership model if it can be implemented cleanly and cheaply.

### Candidate C — bounded region snapshot/restore with semantic generation

Prototype only if A and B are not acceptable.

A region strategy must prove that snapshots are refreshed whenever the semantic image under an active visual changes. Restoring an old region over a newer semantic frame is an automatic rejection.

Any viable design therefore needs an explicit, trustworthy semantic-generation signal or equivalent ownership rule. Pixel heuristics are not sufficient.

### Candidate D — backend memory copy

Prototype only if the higher-level candidates fail.

A backend-specific memory copy may be selected only behind a narrow host adapter with explicit dimensions, pixel format, bounds checks, and one reusable buffer. It must not expose Bitwig memory objects or platform handles in the public compositor/frame contract.

## Required dynamic lifecycle experiment

For each serious candidate, use a deterministic generated visual sequence over a stable semantic base:

```text
A at R1
B at R2
C at R3
none
```

The sequence must include at least four non-overlapping or partially overlapping positions and an absent state.

Repeat the sequence for at least 1,000 composition cycles offline or for a sufficient equivalent instrumented run. Then repeat a bounded live demonstration on the real Push where practical.

The candidate must prove:

1. Every visual state appears only in its current declared bounds.
2. Pixels under the previous visual are restored to the exact current semantic value before the next frame is sent.
3. After the absent state, the complete 960×160 frame is pixel-identical to the current semantic reference.
4. Pixels outside the union of the current visual bounds remain identical to the current semantic reference.
5. No trail, smear, expansion, duplication, stale block, whole-frame clear, scale error, or coordinate offset occurs.
6. A semantic model change beneath a previously covered region is reproduced correctly before the next visual state and after removal.
7. A simulated stale or unavailable visual source produces semantic-only output, not the last valid visual forever.
8. Repeated semantic mode/track/device/parameter changes remain coherent.

## Pixel correctness evidence

Use local, non-committed raw-frame observation or host debug output that can be validated as the exact 960×160 bitmap.

Retain only sanitized aggregate evidence:

- candidate name and prototype hash;
- semantic-reference hash;
- each generated visual state's target-region hash;
- outside-region mismatch count;
- old-region restoration mismatch count;
- full-frame mismatch count after the absent state;
- semantic-update-under-overlay mismatch count;
- dimensions, pixel format, mask method, and comparison command;
- representative mismatch coordinates if any.

Do not commit proprietary screenshots, full frames, Bitwig UI crops, or binary artifacts.

A candidate cannot be selected with unexplained nonzero restoration or outside-region mismatches.

## Performance and allocation evidence

Measure at least 1,000 post-warmup cycles for each serious candidate.

Retain:

- sample count;
- p50, p95, and maximum end-to-end restore-plus-compose time;
- semantic-only baseline time;
- fixed construction-time allocation;
- project-owned per-cycle allocation count/bytes where observable;
- any existing host-adapter allocation that remains;
- working-set behavior across the run;
- any controller lag, display lag, audio xrun/dropout, or abnormal CPU observation.

Provisional accepted-Mac bands:

```text
green:  p95 <= 2 ms and max <= 10 ms
review: p95 > 2 ms but <= 5 ms, or max > 10 ms but <= 15 ms
stop:   p95 > 5 ms or max > 15 ms
```

A review-band result requires an explicit technical recommendation; it is not automatic permission to optimize or add concurrency.

No candidate may use an unbounded queue, per-frame thread/task creation, or a second Push USB owner.

## Build and source evidence

For every candidate that reaches execution:

- begin from exact `1ae0b74f383314d170a5960ca763bdf9c319e787` / tree `a81e5c4330b31f36845c25e98e322990d62f0c67`;
- record the temporary patch/source SHA-256 and changed paths;
- use the accepted explicit Java 21/Maven environment;
- build successfully or retain the exact blocker;
- hash the resulting artifact;
- inspect the executable delta;
- prove `PushUsbDisplay.class` remains byte-identical unless the candidate is rejected before fixture use;
- remove all temporary timing, pixel-dump, and comparison instrumentation from any candidate artifact used for a final live check;
- do not commit generated extension binaries.

## Real-fixture gate

The leading candidate must receive a bounded real Mac + Bitwig 6.1 + Push 3 check before selection.

At minimum retain:

- exact temporary prototype artifact hash and patch hash;
- sole scanned extension state;
- moving/replacing/absent visual sequence on the physical Push;
- Track, Device Parameters, and Session or Browser mode changes;
- selected track/device/parameter updates, including an update under a previously covered visual region;
- coherent controls and semantic display;
- Push audio-device presence and audible headphone output;
- no observed trail, stale content, lag, xrun, or relevant error;
- normal Bitwig quit;
- exact official-artifact rollback and physical restored-display confirmation.

If no candidate is safe enough for the real fixture, retain the blocker and stop without installation.

## Required decision output

The final evidence must select exactly one of these outcomes:

### SELECTED

Name one candidate and specify:

- exact production ownership model;
- exact source seam and expected changed-path envelope for the next implementation slice;
- public/internal interface boundary;
- bitmap/frame lifetime rules;
- semantic-generation or redraw rules;
- stale/absent visual behavior;
- allocation and timing budget;
- why rejected candidates are inferior.

### BLOCKED

State the smallest missing capability or API fact, the experiments performed, and the next bounded research required. Do not hide a blocker behind a vague recommendation.

V1C-0 is not complete merely because one moving rectangle appears.

## Expected central evidence

Use a structure equivalent to:

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

Files may be omitted only when the decision document explains why the corresponding candidate was not reached.

Every file must state what it proves and what it does not prove.

## Explicit non-goals

- no production DrivenByMoss source PR;
- no merge into `pushwig/main`;
- no external-frame IPC, socket, shared memory, or helper process;
- no ScreenCaptureKit or window capture;
- no `VisualSourceFrame` wire format;
- no visual-source discovery, adapter, calibration, or pixel-anchor implementation;
- no second USB owner or `PushUsbDisplay` redesign;
- no unbounded queue, worker pool, timer, or async composition path;
- no user-facing configuration;
- no arbitrary plug-in or native-device visual;
- no Push 2 hardware claim;
- no Steam Deck/Linux validation;
- no yabridge, Monome, plugdata, appliance, battery, connector, or NUC work.

## Acceptance criteria

V1C-0 is complete only when all of the following are true:

1. Research begins from the exact accepted central and DrivenByMoss integration bases.
2. The accepted source lifecycle and bitmap API constraints are retained from exact source inspection.
3. Candidate A is tested first or explicitly rejected from source evidence.
4. At least one candidate proves changing, moving, absent, and semantic-update-under-overlay states.
5. Selected-candidate outside-region mismatches are zero.
6. Selected-candidate old-region restoration mismatches are zero.
7. Selected-candidate full-frame mismatches after visual absence are zero.
8. Stale/unavailable visual state produces semantic-only output.
9. Performance/allocation evidence is retained against the defined bands.
10. `PushUsbDisplay` remains unchanged and sole-owned.
11. The leading candidate receives a bounded real-fixture check or a precise safety blocker is retained.
12. The exact official artifact is restored after any fixture prototype.
13. The decision names one production representation and source seam, or one precise blocker.
14. No temporary prototype or instrumentation is merged into either repository.
15. The central evidence PR is open, non-draft, unmerged, and points to the exact retained evidence head.
16. Relevant accepted branches and ordinary worktrees are clean and synchronized.

## Expected handoff

If V1C-0 selects a design, the next production slice is **V1C — Dynamic Local Composition Lifecycle**. It will implement only the selected restoration/composition primitive with generated local frames.

External generated-frame ingress moves to **V1D**. That slice may begin only after dynamic replacement, removal, and semantic fallback are proven locally.

## Review standard

Correct restoration outranks minimal line count, raw benchmark speed, or architectural novelty. Do not accept a candidate that can paint a changing visual but cannot restore the exact current semantic pixels when that visual moves, disappears, or becomes stale.