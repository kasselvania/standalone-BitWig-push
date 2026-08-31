# V1C-0 architecture decision

## Status: SELECTED

## Date, machine state, and authorities

- Evidence date: 2026-08-31 PDT.
- Machine state: accepted macOS 26.4.1 arm64 Mac, Bitwig Studio 6.1, DrivenByMoss 26.4.1, and real Push 3 fixture.
- Actual central basis: `24431c70eb720235b9c7836d9b2842a798d81d54`, tree `bb72673d2b3ce01ed6525a6ab7f2096dde1ac7bf`.
- DrivenByMoss basis: `1ae0b74f383314d170a5960ca763bdf9c319e787`, tree `a81e5c4330b31f36845c25e98e322990d62f0c67`.
- Selected research commit/tree: `3e8df95e9cc489e69da72b9acb82f2d06c90dd00` / `f448eeda923232346037074a75b71c485e56ebe8`.
- Selected prototype artifact SHA-256: `22b37222aa9242f822c4717168ecde0d66cab10488caaabec9fe481cffba4c72`.
- Harness source SHA-256: `4dc4ea733ba7b46e3dc9db542cfe0567e7c6059ab6d042260e9956535a4e382c`.
- No production DrivenByMoss PR exists for this research slice.

## Selected candidate

**Candidate A — full current-semantic redraw from the newest retained `ModelInfo` immediately before synchronous local visual composition.**

The selected conceptual rule is:

```text
output = compose(redraw(newestRetainedSemanticModel), optionalCurrentValidVisual)
```

The rejected rule is:

```text
output = mutate(previousComposedOutput, maybeNewVisual)
```

## Exact production ownership model

1. `AbstractGraphicDisplay` continues to own one persistent `IBitmap` for the lifetime of the display.
2. Every `send()` constructs and retains the newest copied `ModelInfo` before its render decision.
3. Ordinary graphic displays retain the current dirty-render behavior through a protected redraw-request hook whose default is `false`.
4. When dynamic local Push composition is selected, `Push2Display` requests a full semantic redraw on every eligible send.
5. That redraw rebuilds the persistent bitmap from the newest retained semantic model before the frame pipeline sees it.
6. The synchronous pipeline reads one current local visual state. For valid state it draws that layer; for absent, stale, or invalid state it draws nothing.
7. The pipeline returns the exact same `IBitmap` reference.
8. `Push2Display` calls the existing `PushUsbDisplay.send` once. `PushUsbDisplay` remains the sole transport/USB writer.

The persistent bitmap contains a composed output after a send, but that historical output is never restoration authority. The next eligible dynamic send first replaces it with a complete current semantic redraw.

## Exact V1C source seam and expected envelope

V1C should implement the production form in exactly these production paths:

```text
src/main/java/de/mossgrabers/framework/controller/display/AbstractGraphicDisplay.java
src/main/java/de/mossgrabers/controller/ableton/push/controller/Push2Display.java
src/main/java/de/mossgrabers/controller/ableton/push/controller/DynamicLocalPushFramePipeline.java
```

Expected responsibilities:

- `AbstractGraphicDisplay.java`: retain the newest `ModelInfo` on every send and add the protected, default-false redraw request used immediately before the existing private semantic render.
- `Push2Display.java`: select the package-private dynamic local pipeline for a bounded startup-gated V1C fixture path and override the redraw request only for that path; preserve the existing send guard and single pipeline/single transport call.
- `DynamicLocalPushFramePipeline.java`: hold only fixed/bounded local generated-state and class-initialized renderers; synchronously draw the current valid generated layer or draw nothing for absent/stale/invalid; return the same bitmap.

The internal generated state/validity enum should be nested in `DynamicLocalPushFramePipeline` so V1C does not prematurely define the V1D public frame contract or add a fourth production path. Any need for another production file is an envelope change that must be justified before editing.

V1C should not modify:

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

## Public and internal interface boundary

- No new public interface is required for V1C.
- Existing internal `PushFramePipeline` remains `IBitmap -> IBitmap`.
- The redraw request is a protected framework hook with default `false`, not a public user API.
- `DynamicLocalPushFramePipeline` and its generated state are package-private.
- No Bitwig `Bitmap`, `MemoryBlock`, `ByteBuffer`, macOS type, capture handle, socket, or external frame type crosses this boundary.
- V1D may later introduce a host-neutral immutable `VisualSourceFrame`; it must enter by adapting to the selected current-semantic-plus-current-visual rule, not by changing restoration ownership.

## Bitmap, model, and frame lifetime

- Persistent semantic/output bitmap: one per `AbstractGraphicDisplay`, created once and reused.
- Retained semantic model: replaced with the newest copied `ModelInfo` every send.
- Local generated visual state: fixed and bounded for V1C; no unbounded queue and no historical final-frame store.
- Renderer instances: class-initialized and reused.
- Per-send bitmap/byte-array allocation: none added by V1C.
- Second final bitmap, raw full-frame copy, and region snapshot: none.

## Semantic generation and redraw rule

V1C does not need an explicit numeric semantic generation. The ownership boundary itself is the generation rule:

```text
capture newest ModelInfo for this send
        -> retain it
        -> synchronously redraw it completely
        -> synchronously read current local visual validity/state
        -> compose at most that current valid visual
        -> send once
```

Because the full semantic redraw occurs after the newest model is retained, a semantic update under covered pixels becomes the base for the next output. No older pixel snapshot can overwrite it.

## Stale, absent, and invalid fallback

All three states run the same complete current-semantic redraw and then perform no visual render. Their output is therefore semantic-only and exact. They do not reuse, fade, restore, or inspect the prior composed frame.

## One-writer rule

`Push2Display` remains the only object that hands the selected output bitmap to the existing `PushUsbDisplay`. Composition creates no USB object, device claim, endpoint, transfer executor, thread, or second writer. `PushUsbDisplay.class` was byte-identical across the serious candidate build at SHA-256 `288b576b3f2ed064f8d9a0c6f6d384fb3516a0858cc22e7879bee896df83dec3`.

## Timing and allocation budget

The accepted real-Bitwig restore-plus-compose result was:

```text
samples: 1,000
p50: 0.275166 ms
p95: 0.413209 ms
max: 7.356958 ms
```

V1C must retain:

- green target: p95 `<= 2 ms`, maximum `<= 10 ms`;
- review band: p95 `<= 5 ms`, maximum `<= 15 ms`, with explicit technical review;
- stop: p95 `> 5 ms` or maximum `> 15 ms`;
- zero new project-owned per-cycle bitmap, frame, byte-array, queue, task, or renderer allocation;
- no unbounded working-set growth;
- no asynchronous workaround to hide synchronous cost.

Existing semantic/host-adapter allocation sites are not falsely claimed absent; V1C must measure their exact proposed-head behavior again.

## Alternative disposition

- Candidate B was not reached because A was exact and green. B would add a second bitmap plus wrapper/blit and filtering/copy proof without solving a remaining blocker.
- Candidate C was not reached because A needs no semantic-generation snapshot authority. C would add region history and stale-snapshot risk.
- Candidate D was not reached because A succeeds above the memory backend. D would add pixel-format/stride/write-lifetime complexity without a missing capability.

These alternatives are bounded fallbacks, not secretly tested or declared impossible.

## Exact V1C acceptance proposal

The production V1C slice should be accepted only when its exact proposed source head proves all of the following:

1. The three-path envelope above, or an explicitly reviewed pre-edit correction.
2. Moving, replacing, resizing, none, stale, and invalid local generated states.
3. At least 1,000 complete deterministic cycles at 960x160 with zero outside, old-region, post-absence, stale/invalid, and semantic-update-under-overlay mismatches.
4. A real-Bitwig aggregate observation with at least one semantic update while covered and all required zero mismatch counts.
5. Same-reference synchronous pipeline bytecode and zero new project-owned per-cycle allocation sites.
6. Same-toolchain base/head build and extracted payload comparison bounded to the approved source envelope.
7. Byte-identical `PushUsbDisplay.class` and exactly one steady-state USB writer.
8. Green timing on the accepted Mac, or a review/stop result handled exactly by the budget above.
9. Full real Push control/display/audio acceptance across Track, Device Parameters, and Session or Browser.
10. Exact official-artifact rollback and physical official-display confirmation.
11. No external ingress, IPC, capture API, final `VisualSourceFrame`, queue, worker, or transport change.

## Explicit unresolved questions

- The production local generated-state naming and startup fixture property must be fixed by the V1C issue, without becoming a user-facing setting.
- The accepted fixture did not exhaust every DrivenByMoss component, notification, and overlay combination; V1C should include a bounded notification/overlay check because `ModelInfo.equals` omits overlays even though newest-model retention makes forced redraw current.
- Existing mutable component references are redraw inputs; V1C must preserve synchronous same-context ownership and must not introduce an asynchronous redraw race.
- No Push 2 hardware behavior is claimed.
- External immutable-frame lifetime, sequence, staleness timing, and ingress remain V1D work.

## Commands and tools

The decision rests on accepted-source inspection, direct API 21 `javap`, the local Candidate A commit/build, bytecode disassembly, extracted payload comparison, the deterministic raster harness, real-Bitwig aggregate pixel/timing instrumentation, RSS/heap readback, real Push control/display/audio acceptance, exact process checks, and exact official rollback.

## What this proves

This is a precise production ownership decision with an implementable V1C seam and measurable acceptance contract.

## What this does not prove

No production source was merged or proposed in V1C-0, and no external generated-frame protocol or capture path exists yet.
