# Current Slice: V1C-0 — Dynamic Raster Replacement and Exact Restoration Feasibility

## Status

Ready to execute from central status merge `1e5767552838a5bf97ee6197ff2f5ac7bfb541a7` and DrivenByMoss integration merge `1ae0b74f383314d170a5960ca763bdf9c319e787`.

Active issue: [#19 — V1C-0: Select dynamic raster restoration architecture](https://github.com/kasselvania/standalone-BitWig-push/issues/19).

## Primary claim

Determine and prove the smallest technically sound frame-restoration strategy that can support a changing or disappearing project-owned visual layer while preserving the **current** DrivenByMoss semantic image exactly and retaining one Push USB writer.

V1B proved that one fixed bounded mark can be painted into the persistent semantic bitmap with zero changes outside its declared region. That does not yet prove a dynamic visual system.

A moving, changing, stale, or removed visual creates a separate lifecycle problem:

```text
semantic bitmap contains frame S
        -> visual A overwrites region R1
        -> visual B overwrites region R2
        -> visual becomes absent or stale
```

Unless `R1` and `R2` are restored from the **current semantic frame**, old visual pixels can remain as trails or stale content. External-frame IPC must not be designed before that lifecycle has an exact restoration primitive.

V1C-0 is an evidence-first research gate. It selects the production representation and source seam for dynamic composition. It does not merge a production compositor, external-frame protocol, capture helper, or transport change.

See [`docs/V1C0_DYNAMIC_RASTER_COMPOSITION.md`](docs/V1C0_DYNAMIC_RASTER_COMPOSITION.md).

## Accepted authorities and execution bases

### Central repository

Accepted V1B evidence merge:

```text
commit: 95d93e262c33163783e23a8d3e66f6f92746918d
tree:   b1f97701801a015c075d09369860f4986403b9a9
```

Current V1C-0 execution basis, containing this authority card:

```text
commit: 1e5767552838a5bf97ee6197ff2f5ac7bfb541a7
tree:   c7537a1dbaf62f7e0c00353bd3ac837cbde349e2
```

The central evidence branch must start directly from the current execution basis, not from the pre-status V1B evidence merge.

### DrivenByMoss implementation repository

```text
repository:       kasselvania/DrivenByMoss
integration base: pushwig/main
commit:           1ae0b74f383314d170a5960ca763bdf9c319e787
tree:             a81e5c4330b31f36845c25e98e322990d62f0c67
```

That integration merge contains exact accepted V1B source head:

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

V1B established on the accepted Mac + Bitwig 6.1 + Push 3 fixture:

- property-off retained the accepted V1A pass-through path;
- startup activation selected one reusable synthetic pipeline;
- one additional `IBitmap.render(false, renderer)` callback drew a fixed two-color mark;
- the pipeline returned the exact same `IBitmap` reference;
- the concrete 960×160 comparison observed 1,529 target-region changes and zero outside-region changes;
- repeated sends and representative semantic modes produced no clear, expansion, smear, or trail;
- property-off restart removed the mark;
- enabled p95/max pipeline cost was 54.542 µs / 194 µs;
- `PushUsbDisplay.class` remained byte-identical;
- real Push controls/audio/display, normal shutdown, recovery, and exact official rollback passed.

V1B proves the in-place static painting primitive. It does not prove movement, replacement, erasure, stale-source fallback, or exact semantic restoration.

## Source constraints that create this gate

The accepted source currently has these relevant properties:

1. `AbstractGraphicDisplay` owns one persistent semantic `IBitmap` created at construction.
2. `AbstractGraphicDisplay.send()` creates a new `ModelInfo`, calls `renderImage()` only when that model changes, clears the temporary component lists, and then sends the persistent bitmap on every eligible call.
3. `ModelInfo` copies and retains component and overlay lists, so a current semantic redraw may be possible, but its current-value fidelity and cost are not yet accepted as a dynamic-composition contract.
4. `IBitmap` exposes `render(...)` and `encode(...)`; it exposes no generic copy, blit, write-region, or restore-region operation.
5. `BitmapImpl.encode(...)` can observe bitmap memory, but the production wrapper has no accepted generic write-back contract.
6. `IGraphicsContext.drawImage(...)` exists, but the current Bitwig adapter accepts `ImageImpl`; it does not yet establish host-neutral bitmap-to-bitmap blitting.
7. `PushUsbDisplay` remains the accepted sole USB transport owner and is outside this research gate.

Do not assume any candidate is already the answer.

## Repository and PR topology

### Central evidence work

Create directly from central execution basis `1e5767552838a5bf97ee6197ff2f5ac7bfb541a7`:

```text
codex/v1c0-dynamic-raster-composition-evidence
```

The final reviewable output is one ordinary, non-draft, open, unmerged central evidence PR containing only:

```text
evidence/v1c0-dynamic-raster-composition/**
```

The PR must include `Addresses #19`.

### DrivenByMoss experimental work

Use clean temporary worktrees rooted at exact `origin/pushwig/main` commit `1ae0b74f383314d170a5960ca763bdf9c319e787`.

Temporary prototype branches, commits, patches, instrumentation, and external harnesses are allowed locally when needed. They must not be merged into `pushwig/main`, and no production DrivenByMoss source PR is expected from V1C-0.

Retain exact patch/source/harness hashes, changed-path summaries, build artifact hashes, and commands. Remove or abandon temporary prototype branches after evidence is retained. Leave the accepted integration branch unchanged.

Do not copy DrivenByMoss source into the central repository.

## Candidate order

Evaluate in order. Stop when one candidate satisfies every correctness, lifecycle, one-writer, portability, and performance criterion strongly enough to authorize a production slice.

### Candidate A — redraw retained current semantic model, then compose

Prototype:

```text
retained current ModelInfo
        -> full semantic redraw into persistent bitmap
        -> current generated visual
        -> unchanged PushUsbDisplay
```

Prove:

- retained `ModelInfo` reproduces the correct current semantic frame;
- movement and disappearance restore exact semantics;
- a semantic change beneath an active visual survives;
- the production seam can remain Push-specific or explicitly reusable rather than forcing every graphic controller to redraw continuously;
- p50/p95/max and allocation behavior are practical.

Candidate A is tested first because it may be the smallest exact restoration path.

### Candidate B — pristine semantic bitmap plus reusable final bitmap

Prototype:

```text
persistent pristine semantic bitmap
        -> reusable full-frame copy/blit
        -> one reusable final bitmap
        -> current generated visual
        -> unchanged PushUsbDisplay
```

Prove:

- exact bitmap-to-bitmap copy/blit on the accepted Bitwig API;
- a narrow host-neutral wrapper boundary;
- one-time final-bitmap allocation and reuse;
- exact fallback and semantic preservation;
- practical copy/composition cost.

Candidate B is the preferred long-term ownership model if it can be implemented cleanly and cheaply.

### Candidate C — generation-aware target-region snapshot/restore

Prototype only if A and B are unacceptable.

A region strategy is invalid unless snapshots are refreshed whenever the semantic image underneath changes. Restoring a snapshot captured before a semantic change over newer semantics is an automatic rejection.

Any viable design needs an explicit, trustworthy semantic-generation signal. Pixel heuristics are insufficient.

### Candidate D — narrow backend memory copy

Prototype only if higher-level candidates fail.

A backend copy path must remain behind a host-neutral interface and declare dimensions, pixel format, stride, bounds, buffer lifetime, and fixed allocation behavior. It must not leak Bitwig memory objects into public compositor/frame contracts.

## Required dynamic lifecycle experiment

For each serious candidate, use a deterministic generated visual sequence over a stable semantic base:

```text
A at R1
B at R2
C at R3
D at R4
none
```

Use non-overlapping or partially overlapping bounds and an explicit absent state.

Repeat at least 1,000 composition cycles offline or an equivalent instrumented run. Then perform a bounded live demonstration on the real Push where safe.

The selected candidate must prove:

1. Each visual state appears only in its current declared bounds.
2. Pixels under the previous visual are restored to the exact current semantic value before the next output is sent.
3. After the absent state, the complete 960×160 output is pixel-identical to the current semantic reference.
4. Pixels outside the current visual bounds remain identical to the current semantic reference.
5. No trail, smear, expansion, duplication, stale block, whole-frame clear, scale error, or coordinate offset occurs.
6. A semantic model change beneath a previously covered region is correct before the next visual and after removal.
7. Simulated stale, invalid, or unavailable visual input produces semantic-only output.
8. Representative mode, track, device, and parameter changes remain coherent.

## Pixel correctness evidence

Use local, non-committed raw-frame observation or validated host debug output representing the exact 960×160 bitmap.

Retain only sanitized aggregate evidence:

- candidate and prototype hash;
- semantic-reference hash;
- each visual state's target-region hash;
- outside-region mismatch count;
- old-region restoration mismatch count;
- full-frame mismatch count after absence;
- semantic-update-under-overlay mismatch count;
- dimensions, pixel format, mask method, and comparison command;
- representative mismatch coordinates if any.

Do not commit proprietary screenshots, full frames, Bitwig UI crops, or binary artifacts.

A candidate cannot be selected with unexplained nonzero restoration or outside-region mismatches.

## Performance and allocation evidence

Measure at least 1,000 post-warmup cycles for every serious candidate.

Retain:

- sample count;
- p50, p95, and maximum restore-plus-compose time;
- semantic-only baseline time;
- fixed construction-time allocation;
- project-owned per-cycle allocation count/bytes where observable;
- existing host-adapter allocation that remains;
- working-set behavior;
- any control lag, display lag, audio xrun/dropout, or abnormal CPU observation.

Provisional accepted-Mac bands:

```text
green:  p95 <= 2 ms and max <= 10 ms
review: p95 > 2 ms but <= 5 ms, or max > 10 ms but <= 15 ms
stop:   p95 > 5 ms or max > 15 ms
```

A review-band result requires explicit technical justification. It is not permission to add concurrency or buffering.

No candidate may use an unbounded queue, per-frame thread/task creation, or a second Push USB owner.

## Build and source evidence

For every candidate that reaches execution:

- begin from exact DrivenByMoss integration commit/tree;
- record temporary patch/source SHA-256 and changed paths;
- use the accepted explicit Java 21/Maven environment;
- build successfully or retain the exact blocker;
- hash the resulting artifact;
- inspect the executable delta;
- prove `PushUsbDisplay.class` remains byte-identical unless the candidate is rejected before fixture use;
- remove temporary timing, frame-dump, and comparison instrumentation before any final live check;
- do not commit generated extension binaries.

## Real-fixture gate

The leading candidate must receive a bounded real Mac + Bitwig 6.1 + Push 3 check before selection, unless a precise safety blocker prevents installation.

At minimum retain:

- exact temporary prototype artifact and patch hashes;
- sole scanned extension state;
- moving/replacing/absent visual sequence on physical Push;
- Track, Device Parameters, and Session or Browser mode changes;
- track/device/parameter changes, including a semantic update under a previously covered visual region;
- coherent controls and semantic display;
- Push audio-device presence and audible headphone output;
- no trail, stale content, lag, xrun, or relevant error;
- normal Bitwig quit;
- exact official-artifact rollback and physical restored-display confirmation.

If no candidate is safe enough for the fixture, retain the blocker and stop without installation.

## Required decision output

The final evidence must select exactly one outcome.

### SELECTED

Name:

- exact production ownership model;
- exact source seam and expected changed-path envelope for V1C;
- public/internal interface boundary;
- bitmap/frame lifetime rules;
- semantic-generation or redraw rules;
- stale/absent visual behavior;
- allocation and timing budget;
- rejected-candidate rationale.

### BLOCKED

State the smallest missing capability or API fact, experiments performed, and next bounded research. Do not hide a blocker behind a vague recommendation.

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

Files may be omitted only when `decision.md` explains why the corresponding candidate was not reached.

Every file must state what it proves and what it does not prove.

## Explicit non-goals

- no production DrivenByMoss source PR or merge;
- no external-frame IPC, socket, shared memory, or helper process;
- no ScreenCaptureKit or window capture;
- no `VisualSourceFrame` wire format;
- no visual-source discovery, adapter, calibration, or pixel anchors;
- no second USB owner or `PushUsbDisplay` redesign;
- no unbounded queue, worker pool, timer, or asynchronous composition path;
- no user-facing configuration;
- no arbitrary plug-in/native-device visual;
- no Push 2 hardware claim;
- no Steam Deck/Linux validation;
- no yabridge, Monome, plugdata, appliance, battery, connector, or NUC work.

## Acceptance criteria

V1C-0 is complete only when:

1. Research starts from the exact accepted central execution and DrivenByMoss integration bases.
2. Exact source lifecycle and bitmap API constraints are retained from source inspection.
3. Candidate A is tested first or explicitly rejected from source evidence.
4. At least one candidate proves changing, moving, absent, stale, and semantic-update-under-overlay states.
5. Selected-candidate outside-region mismatches are zero.
6. Selected-candidate old-region restoration mismatches are zero.
7. Selected-candidate full-frame mismatches after absence are zero.
8. Stale/unavailable input produces semantic-only output.
9. Performance/allocation evidence is retained against the defined bands.
10. `PushUsbDisplay` remains unchanged and sole-owned.
11. The leading candidate receives a bounded real-fixture check or a precise safety blocker is retained.
12. The exact official artifact is restored after any fixture prototype.
13. The decision names one production representation/source seam or one precise blocker.
14. No temporary prototype or instrumentation is merged.
15. The central evidence PR is open, non-draft, unmerged, and points to the exact retained head/tree.
16. Accepted branches and ordinary worktrees are clean and synchronized.

## Expected handoff

If V1C-0 selects a design, the next production slice is **V1C — Dynamic Local Composition Lifecycle**. It implements only the selected restoration/composition primitive with generated local frames.

External generated-frame ingress is **V1D** and may begin only after dynamic replacement, removal, and semantic fallback are proven locally.

## Review standard

Correct restoration outranks minimal line count, raw benchmark speed, or architectural novelty. Do not accept a candidate that can paint changing pixels but cannot restore the exact current semantic frame when the visual moves, disappears, becomes invalid, or becomes stale.