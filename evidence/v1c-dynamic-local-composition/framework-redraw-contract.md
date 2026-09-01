# Framework redraw contract

## Date, machine state, and authority

- Evidence date: 2026-09-01 PDT.
- Machine state: source inspection and proof on the accepted macOS arm64 fixture.
- Actual central basis/tree: `4265dc7b6f1cabf2dcbad1b827d002bd9062cf4f` / `2af6b4757e5906ce74a3b52c5ee82323f5e32406`.
- DrivenByMoss basis/tree: `1ae0b74f383314d170a5960ca763bdf9c319e787` / `a81e5c4330b31f36845c25e98e322990d62f0c67`.
- Source PR/head/tree: [kasselvania/DrivenByMoss#3](https://github.com/kasselvania/DrivenByMoss/pull/3), `4b3326eddcf2d890de3baa10b93f6e80842d41e1`, tree `d03a372e2efcf41b22cef46501e08efbfb0c0036`.

## Production ownership rule

`AbstractGraphicDisplay.send()` now performs this ordered operation:

1. Read the current notification under the existing synchronization.
2. Construct one `ModelInfo` from the current notification, components, and overlays.
3. Compare it with the previously retained model for the ordinary dirty-render decision.
4. Assign the new `ModelInfo` unconditionally before any render decision.
5. Render when the ordinary model changed or a specialized display requests current-model redraw.
6. Clear the transient component and overlay lists in the existing `finally` block.
7. Send the same persistent `IBitmap`.

The exact production source has the assignment at `AbstractGraphicDisplay.java:188` and the combined render condition at line 192. The protected `shouldRedrawCurrentModel()` hook defaults to `false`, so every display except an explicit subclass retains accepted dirty-render behavior.

`Push2Display` returns its construction-time `redrawCurrentModel` field from that hook. The field is true only when `pushwig.dynamicLocalVisual=true`. The default and V1B-static paths therefore keep ordinary dirty-render behavior.

## Current semantics, not previous output

The dynamic path redraws from the newest retained `ModelInfo` into the existing persistent bitmap immediately before the frame pipeline runs. It never restores from:

- previous composed output;
- a saved region;
- a semantic snapshot;
- a second bitmap;
- a stale generation;
- raw transport bytes.

Accordingly, visual A cannot contaminate B, C, D, or absence. A semantic update that occurs while a visual covers a region becomes part of the newest retained model and is redrawn before the next composed output.

## Overlay and notification ownership

`ModelInfo.equals()` deliberately excludes its overlay list. Unconditional assignment before the redraw decision is therefore material: an overlay-only update becomes the current retained model even when ordinary component/notification equality is unchanged.

Notifications remain part of `ModelInfo` and are read through the existing counter synchronization. No notification timer, counter, or scheduler was added or changed by V1C.

## Bitmap and writer ownership

- `AbstractGraphicDisplay` continues to own one persistent bitmap.
- Dynamic composition calls `IBitmap.render(false, renderer)` only for A/B/C/D.
- The pipeline returns the exact input reference.
- NONE, STALE, and INVALID invoke no renderer and return that reference unchanged.
- `Push2Display.send` preserves the shutdown/null guard, invokes the selected pipeline once, and invokes the existing `PushUsbDisplay.send` once.
- `PushUsbDisplay` remains the sole extension-owned Push USB writer and is source- and byte-identical to the accepted basis.

## Bytecode and harness readback

`javap -c -p` against the exact proposed-head artifact showed:

- `AbstractGraphicDisplay.send` creates the new `ModelInfo`, compares it, stores it before the hook/render branch, and preserves the list cleanup.
- The default hook is `iconst_0; ireturn`.
- `Push2Display` reads each startup property once during construction.
- The send method retains one pipeline `process` invocation followed by one `PushUsbDisplay.send`.
- `DynamicLocalPushFramePipeline.process` contains no `new` instruction and returns `aload_1`.
- Four renderers are initialized once in the class initializer.

The external harness additionally proved:

```text
default first render count: 1
default equal-model count:  1
default changed-model count: 2
forced equal-model count:   2
same output reference:      true
renderer identity reused:   true
```

## Commands and tools

Tools included source inspection with `rg`, `sed`, and numbered-line readback; exact base/head builds; `javap -c -p`; extracted-class hashing; and the temporary external Java 21 harness.

## What this proves

- The production rule is `compose(currentSemanticFrame, optionalCurrentVisual)`, not mutation of previous output.
- Ordinary displays preserve dirty rendering while the V1C Push path requests current-model redraw.
- Overlay-only and notification state become current retained authority before redraw.
- The design preserves one persistent bitmap and one extension-owned USB writer.

## What this does not prove

- The hook is not a public external-frame contract.
- It does not define future freshness, source metadata, capture, IPC, or adapter behavior.
- It does not remove existing framework/host-adapter allocations.
