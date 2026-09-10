# Sampler screen — actions, eight values, and image

September 10, 2026. **Throwaway layout review, not a live Bitwig/Push implementation.** Supersedes the earlier touch-to-reveal comparison. The maintainer requires the existing button-action words and all eight remote assignments/current values to remain available alongside the device image. Touch adds emphasis; it must not be necessary to discover a value.

Question: at 960×160, can we retain that information while leaving a useful device image? Two alternatives share the existing offline preview:

- **A — four readouts per side:** slots 1–4 at left, 5–8 at right. Each has a color/number, alias and formatted value. Labels use 11 px text, values 15 px. Proposed starting point.
- **B — one eight-item list:** all slots on the left, device to the right. Labels use 11 px, values 12 px. Compare the denser list and longer eye movement, not a different color scheme.

Both always show the image when the supplied fixture permits it, even without touch. Both retain the same action row and lower device/page navigation row. No eight-column mini-parameter panels occupy the device-image area. The old touch-to-reveal variant is removed, not another pending option.

## Open the review

From the repository root:

```sh
node visuals/sampler/presentation-prototype/build-preview.mjs --open
```

This builds a private self-contained HTML file in the OS temporary directory and opens it in the ordinary browser. No server, installation, permissions prompt, Bitwig launch, socket, capability, MIDI or Push output. State is in memory; reset/reload restores the fixture. Without `--open`, it prints the file path and hash. The automated browser's URL policy prohibits opening local files; do not work around that restriction. A user can open the generated file directly for interaction review.

Use the floating arrows or `?variant=A` / `?variant=B`. Hold simulated knobs or keys 1–8; keyboard Enter/Space on a knob toggles a latched touch. All readouts stay visible with one or many touches; the device does not move. Value controls simulate changes independently of touch. Browser focus loss releases touches. Clicking a colored upper button exercises a **simulated device action**, not a remote-parameter change.

## Actual semantic words, generated state

Source inspected: DrivenByMoss `cf0e70ea9f2144a45c1dc6039a25c9b90a06b92b`, `DeviceParamsMode.java`, specifically `MENU`, constructor capability filtering, `onSecondRow`, `getTopMenuEnablement` and `updateDisplay2`.

The top row is `On`, `Parameters`, `Expanded`, `Chains`, `Banks`, `Pin Device`, `Window`, `Up`, in eight fixed 120-pixel columns. The real mode suppresses labels for unsupported capabilities; this fixture supplies the labels and sample states, not a live capability readback. Active states have a neutral underline, separate from the remote-color LED. The bottom row represents the existing device/page selection slots; the generated Banks toggle switches between Sampler and example page names. It does not implement real device navigation.

Remote values/aliases start from the prior documented Sampler observation: Speed, Pitch, Start, Glide time, Pan, Vel Sens., Gain, Output. Color families follow the approved physical LED reference: red/orange/yellow/lime/green/blue/purple/pink. RGB values are illustrative, not a calibrated hardware/monitor match. Actual target names remain exposed in the state panel; aliases are not treated as target IDs. Generated same-alias reassignment and marker association remain explicit fixture inputs.

No live state is inferred from this mockup. Missing source/binding data withholds the schematic; other modes show an explicitly labeled placeholder, not an imitation or acceptance proof of DrivenByMoss fallback. The live product must restore actual current semantics locally in DrivenByMoss.

## Geometry and limits

Top action strip: y0–21. Bottom navigation strip: y142–159. The center must fit between them.

For the generated 1200×300 device body, one uniform scale produces a **456×114** image:

- A: viewport `(238,25,484,114)`, effective image `(252,25,456,114)`; 230-pixel side columns with four 29-pixel readout rows each.
- B: viewport `(298,25,650,114)`, effective image `(395,25,456,114)`; 286-pixel left list with eight 14.5-pixel rows.

This exposes the real height constraint: extra horizontal space in B does not enlarge a 4:1 image once height limits the uniform fit. Touch only changes emphasis/verified-fixture marker outlines. Multiple touches never hide another value or select a single winner by event order. The schematic omits modulators by construction; it is **not** a passed modulator-exclusion detector or a captured native Sampler. Real image density, device identity, context coherence and continuous capture/tracking remain unproved.

## Verification and review status

Reused existing checks, with the B resting-image expectation updated for the new always-visible requirement:

```sh
node --test visuals/sampler/presentation-prototype/geometry.test.mjs
node visuals/sampler/presentation-prototype/verify-ffmpeg.mjs
node --check visuals/sampler/presentation-prototype/demo.mjs
node --check visuals/sampler/presentation-prototype/presentation.mjs
NODE_PATH=/path/to/existing/node_modules node visuals/sampler/presentation-prototype/render-check.mjs
```

The last command uses pre-existing `@napi-rs/canvas`; it installs nothing. September 10 local results: 9 geometry/association checks and 23 existing native-render cases pass. Generated FFmpeg coordinate/opaque-BGRA check passes; no new capture backend or fixture test was run. Native renders of A and B were visually inspected at 960×160. The browser tool refused the local URL, so browser interaction and physical readability remain **pending human review**.

Current native RGBA hashes: A rest `a810449b33afb1d96d18baf8e9235f1741b340bd12c4cceebdfaa363facde1fe`; A touch `e0f6213189d70a88742d94b84f169c19bcd9e0f29b59ff7f369b73add418232b`. These are renderer results from generated inputs, not captured Push frames. The build command prints the current packaged HTML hash. No image is committed. No live performance or hardware acceptance follows from these checks.

Only this existing prototype, its readme and the owning design references change. No DrivenByMoss source/artifact, app installation or Bitwig fixture change. The prototype skill keeps this a disposable, generated, in-memory comparison. After the user chooses, retain the design answer, remove the losing variant/simulator, and implement only the chosen presentation in its proper owner. Do not promote fixture IDs or simulated actions into a production API.
