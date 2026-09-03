# Window-relative visual lens

**Status:** accepted V3 product baseline. [Issue #45](https://github.com/kasselvania/standalone-BitWig-push/issues/45) is complete.

This document describes the maintained V3 design. The current design discussion is about what should follow it—not reopening the accepted window/crop, protocol, or Push ownership boundaries.

## Product result

V2 proved that live Bitwig pixels can be captured on macOS and composed onto Push without taking ownership away from DrivenByMoss. V3 removed its dependence on a fixed physical display crop:

```text
Bitwig main window
        -> explicit visual profile
        -> crop relative to the current window
        -> helper-local aspect-preserving crop and scale
        -> accepted external frame ingress
        -> live visual on Push
```

A user can move, resize within supported bounds, lose, and recreate the Bitwig main window without manually recalculating desktop coordinates.

## Source identity

The helper uses public macOS capture/window APIs. A profile identifies an eligible Bitwig source with bounded facts:

- owning bundle identifier, normally `com.bitwig.studio`;
- on-screen state;
- optional title substring when bundle identity alone is not unique;
- optional minimum window dimensions.

Selection is fail-closed:

- exactly one eligible window -> capture;
- no eligible window -> semantic-only output;
- more than one eligible window -> semantic-only output.

The helper does not silently choose the first or largest candidate. The current `SCWindow.windowID` is instance identity while that window exists; it is not durable profile identity.

## Visual profile

V3 maintains a small human-readable JSON profile. The product fields are:

```json
{
  "schemaVersion": 1,
  "id": "bitwig-device-chain",
  "window": {
    "ownerBundleIdentifier": "com.bitwig.studio",
    "titleContains": null,
    "minimumWidthPoints": 800,
    "minimumHeightPoints": 500
  },
  "crop": {
    "x": 0.14,
    "y": 0.68,
    "width": 0.45,
    "height": 0.305
  },
  "destination": {
    "x": 400,
    "y": 0,
    "width": 560,
    "height": 160
  },
  "fps": 30,
  "aspectPolicy": "centered-cover"
}
```

Port, token-file path, protocol session, window ID, and physical desktop position do not belong to profile identity.

Profile validation rejects unknown schema versions and keys, nonfinite or out-of-bounds crops, invalid destinations, unsupported aspect policies, invalid frame rates, and unusable window selectors before capture authority is established.

The maintained example is [`../../capture/macos/Profiles/bitwig-device-chain.json`](../../capture/macos/Profiles/bitwig-device-chain.json).

## Coordinate and crop model

A profile crop is normalized to the **current captured Bitwig window content**, not to a physical monitor.

On each acquisition or supported resize:

```text
normalized profile crop
        -> current window/filter content bounds
        -> bounded full-window ScreenCaptureKit pixel buffer
        -> helper-local normalized pixel crop
        -> uniform centered-cover mapping
        -> Push destination pixels
```

Global desktop x/y does not enter profile identity or crop math. Moving the same window requires no profile change. Resizing recomputes the crop from the same normalized profile.

Apple documents that `SCStreamConfiguration.sourceRect` is not referenced for single-window capture. The maintained implementation therefore does not rely on it. ScreenCaptureKit supplies one bounded full-window buffer, and the helper performs the authoritative crop itself.

The stream requests native backing resolution when it fits, with hard limits of 2560×1600 and 4,096,000 pixels. Integer stream dimensions define the observed point-to-pixel scales. The helper then:

```text
profile crop + current full-window buffer
        -> top-left pixel crop
        -> maximal centered-cover source rectangle
        -> Core Image lower-left Y translation
        -> edge-clamped uniform Lanczos scale
        -> reusable opaque-BGRA destination
```

Core Image renders into the existing reusable destination array. A final in-place alpha pass enforces `0xFF`. The ScreenCaptureKit queue remains depth 2; the existing serial sample/output queue is the only project-owned frame path; no full-window payload crosses protocol v1.

A generated native four-quadrant fixture proved that two non-overlapping normalized crops produce reproducible, distinct expected output pixels and do not produce a miniature of the full window.

## Lifecycle

The helper maintains one current window generation.

### Initial acquisition

Discover candidates, require one eligible Bitwig main window, compute the profile crop, establish bounded full-window capture, and begin publishing current frames.

### Move

A global-origin-only change does not alter the capture signature or profile geometry. Independent-window capture remains attached to the same Bitwig window.

### Resize

When the same window's usable dimensions change, the helper revokes the old generation, sends at most one `CLEAR`, stops the old stream, recomputes full-window sizing and crop geometry, and starts one bounded replacement generation.

The implementation uses a 500 ms main-actor discovery loop and bounded stream recreation. It does not add a frame FIFO, worker pool, or second output queue.

### Missing or ambiguous source

The helper revokes visual authority, sends one `CLEAR` when a live protocol session exists, stops publishing `FRAME`, and leaves the current semantic DrivenByMoss display visible.

### Reopen or recreation

When the profile selector again resolves to exactly one eligible window, the helper assigns a new local generation, recomputes geometry, and resumes current capture. Old-generation callbacks are rejected before pixel work and cannot become current output.

### Occlusion and frontmost behavior

Window-profile mode uses desktop-independent capture. Another application becoming frontmost or obscuring Bitwig does not by itself revoke capture or replace the selected pixels. The V2 explicit-display frontmost guard remains confined to V2 mode.

## Runtime interface

The primary invocation is:

```text
PushwigCaptureHelper \
  --profile /path/to/profile.json \
  --port 45291 \
  --token-file /path/to/private-token
```

Bounded discovery is available through:

```text
PushwigCaptureHelper --list-windows --owner-bundle-id com.bitwig.studio
```

The V2 explicit-display mode remains available as a diagnostic/reference path and cannot be accidentally mixed with profile mode.

## Ownership and failure boundaries

V3 preserves the established architecture:

- DrivenByMoss remains semantic/controller authority and sole Push display USB writer.
- The macOS helper owns window discovery, capture, crop, and helper-local scaling only.
- The accepted external frame protocol remains unchanged.
- Capture, selection, profile, protocol, or helper failure returns to current semantic output.
- No mouse or keyboard automation is introduced.
- No Apple capture object crosses into DrivenByMoss.

## Tests and evidence

Stable deterministic behavior is committed Swift test coverage:

- profile decoding and validation;
- unique/missing/ambiguous selection;
- normalized crop geometry;
- two non-overlapping generated crop outputs;
- nonzero source stride and crop bounds;
- centered-cover scaling and alpha normalization;
- stable destination storage;
- resize recomputation;
- generation loss/recreation fencing;
- V2 explicit-display and protocol regressions.

Real macOS/Bitwig/Push behavior is retained concisely in [`../../evidence/v3-window-relative-lens/README.md`](../../evidence/v3-window-relative-lens/README.md).

## Accepted fixture result

The accepted implementation:

- followed the Bitwig main window through substantial movement;
- recomputed a current, proportionally correct crop after supported resize;
- continued through ordinary occlusion;
- returned to semantic output on source loss;
- reacquired a recreated Bitwig window without old-generation pixels;
- remained within visual cadence at 30 fps;
- preserved pads, pressure/MPE, encoders, transport, Push audio, and headphones;
- restored the exact official DrivenByMoss artifact after testing.

## Known limitation and next design question

V3 follows a region of the Bitwig window. It does **not** identify or anchor to Sampler or another internal Bitwig device.

Bitwig can reflow the device chain and adjacent panels inside the correctly tracked window. The outer capture can therefore remain technically correct while the useful device leaves the profile region.

The next product design must decide how Pushwig should become useful and device-aware: through stronger semantic integration, layout rules, calibration, confidence-checked pixel anchors, purpose-built renderers, or some combination. That decision is intentionally not made by this accepted V3 document.
