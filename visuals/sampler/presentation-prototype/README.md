# Sampler touch-led screen — offline design preview

2026-09-10. Prepared while the maintainer was away. **Not a live producer, DrivenByMoss implementation, physical acceptance, or production context protocol.**

Question: can the user immediately connect a physical encoder number, its actual target/value, and its visible location without moving the device image or losing the other seven assignments?

## Open when back at the desk

From the central worktree root:

```sh
node visuals/sampler/presentation-prototype/build-preview.mjs --open
```

This builds a private, self-contained HTML file in the OS temporary directory and opens it in the ordinary browser. There is no server, app installation, Screen Recording prompt, Bitwig launch, socket, capability, or background producer. It works offline and makes no network requests. The file can be deleted after review; rebuilding reproduces it. `node` must be available. No packages are installed by this command.

Hold the simulated knobs or keys 1–8. Enter/Space on a focused knob latches/releases its simulated touch for multitouch comparison. Value buttons simulate a separate value change. Controls underneath exercise same-label reassignment, unavailable/ambiguous markers, mode change, and source loss. Full fixture state and each annotation decision are exposed beneath the screen. The optional short scenario changes only generated in-memory state.

Two structurally different variants share one page; arrows or `?variant=A` / `?variant=B` select them:

- **A, proposed starting point:** eight aligned name/value legends stay visible. A stable device diagram is fitted at bottom center. Touch gives a large value in the side space and a numbered outline at the associated **marker**, not a fabricated control center.
- **B, comparison:** a semantic/value-first resting page reveals the device only on touch. This protects resting numeric prominence but makes the device less continuously available. It is an alternative for review, not the chosen product contract.

Both keep values visible, distinguish touch from rotation, support simultaneous touch, and withhold an unestablished location. Two enlarged side readouts are shown at most; all touched encoder legends remain highlighted. There is no camera animation, zoom, pan, or last-touched-only selection.

This is a literal 960×160 canvas. Browser/OS zoom still affects physical size. The schematic has deliberately generated waveform/controls and no proprietary pixels. Labels/initial values reproduce the earlier documented observations, but the marker-to-slot assignments, source IDs, and binding revisions are **test inputs**. Only generated Speed/Pitch associations are supplied. No assumption maps other targets or assigns encoders from RGB.

The device diagram omits modulators **by construction**; the real locator still includes the modulator area and depends on Expressions. This is not a modulator-exclusion result. Native menu/button labels, device-chain navigation and complete DrivenByMoss semantic equivalence are not designed into this preview; they must not be silently removed in a production port. The fallback diagram is not a screenshot or reimplementation of DrivenByMoss.

## Files and ownership

- `geometry.mjs`: one fit and marker transform. Pure presentation geometry, no identity inference.
- `fixture.mjs`: explicitly generated state; not an attempted replacement for Bitwig callbacks.
- `presentation.mjs`: the canvas renderer used by both the page and native render check.
- `demo.mjs`, `index.html`: throwaway interaction controls and layout comparison.
- `build-preview.mjs`: dependency-free static packaging; no server.
- `geometry.test.mjs`: checks the actual transform/association functions.
- `verify-ffmpeg.mjs`: actual FFmpeg crop/scale/pad/opaque-BGRA conversion of generated input, entirely through pipes.
- `render-check.mjs`: executes the same renderer with native Canvas and saves generated review PNGs outside Git.

The prototype skill influenced the delivery: explicitly throwaway, generated/read-only, no installation, two review alternatives, one command. Tests were retained because the maintainer asked to take the work through automated preparation before human testing. No production package imports this directory. After review, remove the losing layout and simulator; port only a deliberately chosen presentation to its proper owner. Do not promote this fixture model into a context API.

## Automated preparation

```sh
node --test visuals/sampler/presentation-prototype/geometry.test.mjs
node visuals/sampler/presentation-prototype/verify-ffmpeg.mjs
node --check visuals/sampler/presentation-prototype/demo.mjs
node --check visuals/sampler/presentation-prototype/presentation.mjs
```

For native execution of the actual renderer, `@napi-rs/canvas` must already be available to Node. The development run used the pre-existing Codex workspace dependency bundle via `NODE_PATH`; it did not install anything:

```sh
NODE_PATH=/path/to/existing/node_modules node visuals/sampler/presentation-prototype/render-check.mjs
```

Results on September 10:

- Node 26.0.0; Apple Swift 6.3.1. Existing locator and marker suites rerun unchanged: 85 and 10 checks pass. No Java build or DrivenByMoss change was needed.
- Nine coordinate/association tests pass: nonzero origins, translation/uniform scale, bounds/nonfinite refusal, unchanged image/marker transform, same-label remap, stale observation, ambiguity, slot mismatch, and copied geometry.
- Twenty-three native render cases pass. Touch does not mutate values; touch/multitouch leave image geometry fixed; value changes alter output; unavailable/ambiguous/old marker associations draw no marker; pending rebinding draws no device image; source reacquisition does not resolve a pending binding; Track/Mix/Master/other-device states suppress the diagram; source loss suppresses it; supplied replacement observations resume; release fully removes highlights. Every rendered output pixel is opaque.
- Source translation/scale is a generated fixture test, **not** real OCR/tracker/resize proof.
- The initial generated rest, one-touch, and two-touch PNGs were visually inspected locally at 960×160. Native Canvas is not a browser: interactive browser verification was not completed because the automation browser refused the local-file URL. No alternate browser or security workaround was used. Human browser/physical readability remains pending.
- Actual FFmpeg 9.0.1 accepts `crop=1200:300:90:82:exact=1,scale=464:116:flags=neighbor,pad=960:160:248:40:color=black,setsar=1,format=bgra`. Generated input: 1400×500 RGBA, source `(90,82,1200,300)`. Output: exactly 614400 bytes. This checker uses nearest-neighbor to make exact generated colors countable; it does not choose final video interpolation.
- Projected generated marker `(308.32,120.4266666667,10.8266666667,10.8266666667)`; measured output red rectangle inclusive x308–318/y120–130, 121 pixels. Center error under one output pixel. Outside-source magenta leakage **0**, outside-destination colored pixels **0**, nonopaque pixels **0**. BGRA output SHA-256: `efc76896ad81e3aa28850138455788bf979464ea429943bbdf9675bf3ea4c5d1`.
- Native renderer RGBA hashes: rest `2fd2b4e533243da1fdf2b39f3955e3d5bc658691dea9fcd43251ebd8c43a883b`; one touch `3704c00ef5ae6b0c558712f98df133169e4e1eccaaf13e566aaa0e99f2efe80c`; two touches `8e9d10db8cf45ecab21a7d10474ede1df82e960f5f00bdbb28918884306e78dc`. These are generated renderer results, not captured Push frames; fonts/raster backends may differ in a browser.
- Final self-contained HTML SHA-256 `12e1c512a2b0a1bdea5395cedb0fd3e0517b6314c6293ee3a348d39973cdc9d9`; bundled JavaScript parses and has no external module imports. This is packaging/syntax proof, not a completed browser interaction test.

No live performance, CPU/RSS, Bitwig binding coherence, or Push acceptance claim follows from these tests. The browser simulator has ordinary canvas allocations. It is not a qualified real-time frame pipeline.

## Exact boundary before live integration

Central starting head `4a6a707274484398fc41d2b3853a53e58116997b`, tree `dfca2e640332c569d9d407424e0ab9774cd5a11a`; unchanged branch `codex/sampler-context-lens`. This work does not modify DrivenByMoss. Its diagnostic head remains `a645fcb9e70e4b28a4d7a2ec7f46aaf0f13dfb59`, tree `a038e0beda4ebccd041c7779573417afb8fea6fa`, with the two pre-existing untracked native-identity prototype files preserved. Accepted integration remains `997158b0a4ddd932a0a985c8b74ffff1e631120f`.

The previous trace contains new mode + old cached hardware target in the same observation. It supplies neither an atomic binding revision nor a proven native target ID/marker association. Giving independently arriving fields a fresh JSON ID would not fix that. The live association and device identity are therefore **gaps**, not implementation details that this preview claims resolved.

Required live construction stays: actual DrivenByMoss context/binding owner → supported native device/current instance → current source observation and verified association → stable image + value presentation → existing composition/sole USB writer. Context exit must be enforced locally in DrivenByMoss, not only by a producer's eventual CLEAR. This turn deliberately did not introduce a context protocol, another receiver, a live producer, or an unsafe label-matching bridge.

At the desk, first judge the screen at its real dimensions, including unresolved location and same-label remap. No extension swap is needed to judge it. A live test should be prepared only once the missing live authority is supplied, not by asking the maintainer to validate the simulator as if it were Bitwig.

**Review verdict: pending.** This branch retains preparatory work at the maintainer's request; there is no mergeable product PR or finished Sampler interaction claim.

Fixture readback during preparation: Bitwig application/audio-engine and TCP45291 listener absent; runtime contains only dormant `owner.lock`; exactly one DrivenByMoss extension in the canonical Extensions directory, SHA-256 `98dc3195ad8d911526e18b1005f09f69a1aedcb965b080565474104654345c5a`. The official artifact was never replaced in this work. No project was opened, edited, saved, discarded, or closed. Superseded generated preview copies were removed; only the final private HTML/generated review images remain outside Git. No proprietary image was acquired.
