# Window-relative visual lens

This is the active design for [V3 — Adaptive Bitwig window-relative visual lens](https://github.com/kasselvania/standalone-BitWig-push/issues/45).

## Product goal

V2 proved that live Bitwig pixels can be captured on macOS and composed onto Push without taking ownership away from DrivenByMoss. Its remaining usability problem is that the source is tied to a fixed physical display crop.

V3 removes that limitation:

```text
Bitwig main window
        -> explicit visual profile
        -> crop relative to the current window
        -> aspect-preserving capture
        -> accepted external frame ingress
        -> live visual on Push
```

The user should be able to move, resize, close, and reopen the Bitwig main window without manually recalculating desktop coordinates.

## Source identity

Use public macOS capture/window APIs. The profile identifies an eligible Bitwig source with bounded facts such as:

- owning bundle identifier, normally `com.bitwig.studio`;
- on-screen state;
- optional title substring when bundle identity alone is not unique;
- optional minimum window dimensions.

Selection is fail-closed:

- exactly one eligible window -> capture;
- no eligible window -> semantic-only output;
- more than one eligible window -> semantic-only output.

Do not silently choose the first or largest candidate. V3 is allowed to require an explicit title constraint on a fixture where Bitwig exposes multiple otherwise-indistinguishable windows.

The current `SCWindow.windowID` is instance identity while that window exists. It is not durable profile identity.

## Visual profile

V3 introduces a small human-readable JSON profile. The stable product fields are:

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
    "x": 0.0,
    "y": 0.7,
    "width": 1.0,
    "height": 0.3
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

The example values above are illustrative, not acceptance geometry.

Port, token-file path, and protocol session state are runtime plumbing and do not belong to profile identity.

Profile validation must reject unknown schema versions, nonfinite/out-of-bounds normalized crops, invalid destinations, unsupported aspect policies, invalid frame rates, and unusable window selectors before capture authority is established.

## Coordinate model

A profile crop is normalized to the **current captured Bitwig window content**, not to a physical monitor.

On each source acquisition or supported resize:

```text
normalized profile crop
        -> current window/filter content rect
        -> bounded full-window ScreenCaptureKit pixel buffer
        -> helper-local normalized pixel crop
        -> uniform centered-cover mapping
        -> Push destination pixels
```

Global desktop x/y must not enter profile identity or crop math.

Moving the same window should therefore require no crop change. Resizing recomputes the source rect from the same normalized profile.

The profile identifies a region of the Bitwig window, not a Bitwig device or panel object. If Bitwig reflows its internal layout during resize, the pictured device can move within the correctly recomputed region. Locating and anchoring to an internal device would require a separate visual-semantic design and is not part of V3.

On the accepted macOS fixture, `SCContentFilter(desktopIndependentWindow:)`
reports `contentRect` with the current global window origin. [Apple documents
that `SCStreamConfiguration.sourceRect` is not referenced for single-window
capture](https://developer.apple.com/documentation/screencapturekit/scstreamconfiguration/sourcerect),
so assigning the profile crop there cannot establish crop authority. The
maintained path deliberately leaves that property unset.

The stream instead captures the complete independent window at native backing
scale when it fits, with hard limits of 2560x1600 and 4,096,000 pixels. The
integer stream dimensions define the observed point-to-pixel scales. The helper
applies the profile normalization again against those actual full-window pixel
bounds and computes a maximal fractional centered-cover rectangle with exactly
the destination aspect.

This explicit translation is what removes desktop position from capture identity:

```text
profile crop + current contentRect size and pointPixelScale
        -> bounded full-window stream dimensions
        -> profile crop in actual top-left pixel coordinates
        -> maximal centered-cover source rectangle
        -> Core Image lower-left crop translation
        -> edge-clamped uniform Lanczos scale
        -> fixed destination pixels
```

Core Image renders directly into the existing reusable destination array and a
final in-place alpha pass enforces `0xFF`. The ScreenCaptureKit queue still has
depth 2, the existing serial sample/output queue remains the only
project-owned frame path, and no full-window payload crosses protocol v1. The
helper logs the point geometry, full-window pixel dimensions, point-to-pixel
scales, and final pixel crop so this contract can be read back on another
fixture.

## Lifecycle

The helper maintains one current window generation.

### Initial acquisition

Discover candidates, require one eligible Bitwig main window, build the capture filter, compute the profile crop, and begin publishing current frames.

### Move

If the same window instance moves without changing its captured content dimensions, capture continues without changing profile geometry.

### Resize

When the same window's usable dimensions change, recompute the profile crop and aspect mapping against the new content size. Update or recreate the ScreenCaptureKit stream using the simplest public API path that remains bounded and race-safe.

The V3 implementation uses bounded stream recreation. One main-actor discovery loop polls at 500 ms; the existing single serial sample/output queue remains the only project-owned frame path. A resize revokes the old generation before stopping its stream, sends at most one `CLEAR`, and activates a newly configured generation. Global-origin-only changes do not recreate the stream.

### Close / missing / ambiguity

Revoke visual authority, send one CLEAR when a live protocol session exists, stop publishing FRAME messages, and leave the current semantic DrivenByMoss display visible.

### Reopen / recreation

When the profile selector again resolves to exactly one eligible window, acquire the new window instance, increment the helper-local generation, recompute geometry, and resume current capture. Old-generation callbacks must not publish after authority moves to the new window.

Generation acceptance is enforced on the serial output queue before pixel access and checked again before publication accounting. Discovery, selection, and stream replacement remain on the main actor; they add no frame FIFO, worker pool, or second output queue.

## Runtime interface

The primary V3 invocation should be ordinary and short:

```text
PushwigCaptureHelper \
  --profile /path/to/profile.json \
  --port 45291 \
  --token-file /path/to/private-token
```

A bounded `--list-windows` or equivalent discovery mode should help a user construct the selector without dumping unrelated personal window titles by default.

The maintained form requires an owner filter:

```text
PushwigCaptureHelper --list-windows --owner-bundle-id com.bitwig.studio
```

The example profile is [`../../capture/macos/Profiles/bitwig-device-chain.json`](../../capture/macos/Profiles/bitwig-device-chain.json).

The existing V2 explicit-display mode remains a supported diagnostic/reference path during V3 unless a concrete conflict requires its removal.

## Ownership and failure boundaries

V3 does not change the established architecture:

- DrivenByMoss remains the semantic/controller authority and sole Push display USB writer.
- The macOS helper owns window discovery/capture only.
- The accepted external frame protocol remains unchanged.
- Capture or profile failure returns to current semantic output.
- No mouse or keyboard automation is introduced.
- No Apple capture object crosses into DrivenByMoss.

## Testing

Stable deterministic behavior belongs in committed Swift tests:

- profile decoding and validation;
- unique/missing/ambiguous selector results;
- normalized window-relative crop math;
- generated-pixel proof for two non-overlapping normalized crops;
- nonzero source stride, crop bounds, opaque alpha, and stable destination storage;
- resize recomputation;
- centered-cover aspect behavior;
- generation/recreation authority transitions;
- single-CLEAR behavior on loss;
- V2 explicit-display mode regressions affected by shared code.

Use retained evidence only for behavior that genuinely requires the real macOS/Bitwig/Push fixture: window move/resize/recreation, visible crop correctness, capture cadence, controls/audio, and recovery.

## Delivery shape

V3 should land as **one implementation PR**, not a source PR plus a separate evidence PR. The implementation PR may include:

- `capture/macos/**` source and committed tests;
- one example visual profile;
- narrow contributor documentation required to run it;
- concise evidence under `evidence/v3-window-relative-lens/` for the real fixture claims that cannot be automated.

Prefer one evidence README unless the result genuinely needs a second document. Do not reproduce the V1 pattern of many per-stage evidence files.

## Acceptance

V3 succeeds when one maintained profile follows the Bitwig main window through move, supported resize, and recreation on the accepted macOS fixture; useful real pixels remain correctly mapped on Push; missing or ambiguous sources fall back cleanly to semantics; deterministic profile/selection/geometry behavior is covered by committed tests; performance stays comfortably within the visual cadence; and normal Push controls/audio remain operational.

V3 does not need automatic Sampler recognition, pixel anchors, Linux capture, a public adapter SDK, or general plug-in-window identity.
