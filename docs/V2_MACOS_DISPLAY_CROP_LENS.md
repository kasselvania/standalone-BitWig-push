# V2 — macOS Display-Crop Visual Lens

## Purpose

V2 is the first production Track V slice to put **real Bitwig application pixels** on Push.

The accepted V1 foundation already provides:

```text
current semantic frame
        + optional validated opaque BGRA raster
        -> one DrivenByMoss-owned Push output
```

and:

```text
external local producer
        -> authenticated complete latest-frame ingress
        -> nonblocking display adoption
        -> exact semantic fallback
```

V2 does not redesign composition, transport, or Push ownership. It adds a normal macOS helper that captures a bounded region of an explicitly selected display, maps it without distortion, and publishes it through the accepted external boundary.

## Strategy correction

The original V2 plan assumed that floating Bitwig native-device views and plug-in editors would be independently available as useful ScreenCaptureKit windows.

On the accepted fixture, that assumption did not hold. Device/editor surfaces were not exposed as independently capturable source windows in the way required by the original authority.

The incomplete dedicated-window implementation is retained only as archaeology:

```text
branch:
capture/v2-macos-dedicated-window-lens

commit:
f5bd7fd990ee74956aa1168ba8b747f0f63286ab
```

It has no PR and is not an implementation basis.

A temporary maintainer-authorized override then captured the Bitwig device-chain region from a selected `SCDisplay`. That proof delivered live Sampler pixels to Push through unchanged V1D-2 while controls and audio remained normal.

The temporary proof used:

```text
display id:           5
display size:         3430x1447
normalized crop:      0.14,0.68,0.45,0.305
computed source rect: 480.2,983.96,1543.5,441.335
Push destination:     400,0,560,160
format:               opaque BGRA8888
queue depth:          2
requested cadence:    30 fps
frames sent:          7192
sequence:             1..7193
CLEAR on exit:        1
```

The pipeline worked, but the rough mapping visibly distorted the image. The temporary source and app were removed. V2 therefore begins from a proven acquisition tactic but still requires a clean production implementation.

## Product claim

```text
explicitly selected SCDisplay
        -> bounded normalized display crop
        -> explicit aspect-preserving mapping
        -> opaque BGRA8888
        -> accepted V1D-2 protocol v1
        -> current semantic Push frame + real captured visual
```

The required real source is the Bitwig main-window device-chain region with useful live Sampler content.

This is a **fixture visual lens**, not yet a universal resolver.

## What V2 proves

V2 proves:

- a normal stable-identity macOS helper can obtain Screen Recording permission;
- an explicitly selected display can be captured at bounded cadence;
- a normalized display-relative crop can be validated and mapped to a Push destination;
- source pixels can be aspect-preserved and normalized to opaque BGRA;
- the helper can publish through accepted V1D-2 without modifying DrivenByMoss;
- real Sampler pixels can coexist with current semantic/controller behavior;
- permission, configuration, guard, helper, and Bitwig loss can return to semantic-only output;
- processing and memory remain bounded.

## What V2 does not prove

V2 does not prove:

- dedicated native-device window capture;
- dedicated VST/VST3/CLAP editor identity;
- automatic selected-device localization;
- Bitwig-window-relative crop tracking;
- arbitrary monitor-layout portability;
- automatic response to window move, resize, panel rearrangement, or UI scaling;
- semantic pixel anchors;
- persistent calibration;
- a public visual-source/adapter SDK;
- Linux capture.

Those remain later Track V work.

## Accepted bases

Central V1D-2 evidence:

```text
commit: 198b44a838009dac0df83464501004b6e6b59d9d
tree:   76d9f92ae8ec7369790b0b8dd325cd4a602e3dbb
```

DrivenByMoss V1D-2 integration:

```text
branch: pushwig/main
commit: 7e3416a1bdddbcbeec4e35e6531652e1618723de
tree:   c8bc3f9e052e8f0b7b5dd256657697349d303740
```

Exact accepted V1D-2 source head:

```text
830b778b720a06f56de08861d27052228c82c63b
```

No DrivenByMoss source change is authorized.

## Repository ownership

The first production macOS backend lives under:

```text
capture/macos/**
```

Expected responsibilities:

```text
Package.swift
Resources/Info.plist
scripts/build-app.sh
Sources/PushwigCaptureHelper/main.swift
Sources/PushwigCaptureHelper/CaptureConfiguration.swift
Sources/PushwigCaptureHelper/DisplayDiscovery.swift
Sources/PushwigCaptureHelper/DisplayCropCapture.swift
Sources/PushwigCaptureHelper/AspectMapping.swift
Sources/PushwigCaptureHelper/SourceValidityGate.swift
Sources/PushwigCaptureHelper/ExternalRasterProtocolClient.swift
```

A different file split is acceptable only when all production source remains inside `capture/macos/**` and the same responsibilities remain explicit.

## Helper identity

Preferred development identity:

```text
bundle id:
com.kasselvania.pushwig.capture-helper

bundle:
PushwigCaptureHelper.app
```

Preferred build:

```text
SwiftPM
        -> release executable
        -> deterministic .app wrapper
        -> Info.plist
        -> ad-hoc signature
```

The helper must be the TCC/Screen Recording authority. Terminal or an IDE must not accidentally own the permission proof.

No release signing or notarization claim is made.

## Display selection

The helper must list available `SCDisplay` targets and require explicit configuration.

No implicit first-display selection is allowed.

The selected display is identified for the run by:

```text
displayID
expected width
expected height
```

All three values must agree with one current `SCDisplay`.

The helper must revoke visual authority when the selected display is absent, its dimensions do not match the declared fixture, the capture stream fails, or capture permission is unavailable.

Display ID is a fixture coordinate, not durable universal visual identity.

## Fixture geometry

The first fixture begins from:

```text
display id:          5
display dimensions: 3430x1447
normalized crop:    x=0.14 y=0.68 width=0.45 height=0.305
Push destination:   x=400 y=0 width=560 height=160
```

The final implementation may correct the normalized crop after retaining exact evidence.

The Bitwig main-window placement, device-chain panel placement, panel dimensions, display mode, and UI scale are fixed fixture state while V2 is active.

## Source-validity guard

A display crop can capture unrelated content if another application occupies the same pixels.

V2 must use a bounded public-API guard that proves the intended Bitwig application is running and is the active capture context. The simplest acceptable first guard is an exact frontmost application bundle-identifier check.

When the guard is false:

```text
one CLEAR
        -> no FRAME publication
        -> semantic-only Push
```

The guard may resume capture when the condition becomes valid again.

It does not claim to identify Sampler or the device panel.

## Crop coordinate contract

Normalized values:

```text
x, y, width, height
```

must be finite and satisfy:

```text
0 <= x < 1
0 <= y < 1
0 < width <= 1
0 < height <= 1
x + width <= 1
y + height <= 1
```

The helper computes the source rectangle against the selected `SCDisplay` capture dimensions.

Destination values must form a positive rectangle wholly inside 960x160.

The helper crops before transmission. It never transmits the full display and asks DrivenByMoss to crop it.

## Aspect mapping

The temporary experiment's visible distortion is a known V2 defect to close.

Production must use uniform scaling.

The implementation chooses exactly one:

### Centered cover

Adjust the effective source rectangle to the destination aspect ratio, then scale uniformly to fill the destination.

### Uniform contain

Scale the entire source rectangle uniformly to fit the destination and fill unused destination pixels with opaque black.

The selected method must retain exact math and must not stretch axes independently.

No general fit-policy system is added.

## ScreenCaptureKit contract

- exact selected `SCDisplay`;
- cursor excluded;
- complete frames only;
- BGRA pixel format;
- queue depth 2 unless evidence justifies another bounded value;
- requested 30 fps by default;
- no application visual-frame FIFO;
- no historical replay;
- source loss clears authority;
- bounded reusable output storage.

The helper must inspect frame status, pixel format, dimensions, and bytes per row before publication.

## Pixel contract

Protocol output is:

```text
row order: top-to-bottom
bytes:     B, G, R, A
alpha:     0xFF for every transmitted pixel
```

The helper copies only useful row bytes and excludes capture-buffer padding.

The output payload remains within V1D-2's 614,400-byte cap.

## V1D-2 client

The helper implements protocol v1 exactly:

```text
TCP IPv4 loopback
magic 0x50575852
version 1
80-byte big-endian header
HELLO=1
FRAME=2
CLEAR=3
NONE=0
OPAQUE_BGRA8888=1
```

The helper reads the private token file without logging its contents, creates one nonzero session per connection, sends HELLO once, sends positive strictly increasing FRAME/CLEAR sequences, sends only complete valid frames, sends one CLEAR when valid visual authority is lost, does not queue historical frames, and stops boundedly on receiver failure.

No protocol change enters V2.

## Permission lifecycle

Use public macOS APIs.

Required:

```text
permission unavailable
        -> no frame
        -> semantic-only Push
        -> one actionable message

permission granted
        -> relaunch same exact helper build when required
        -> capture succeeds
```

No private TCC access or global permission reset is permitted.

## Real visual proof

Use Bitwig Sampler.

The operator configures a stable device-chain layout and the helper captures the declared crop.

Prove live Sampler pixels appear, meaningful Sampler visual content changes are reflected, the visual is confined to the Push destination, semantic UI remains current, no entire-display pixels are transmitted, aspect is visually correct, rows/channels/alpha are correct, and guard/permission/helper/Bitwig loss leaves no stale raster.

An ordinary plug-in may be observed through the same crop but is not required and does not create a plug-in identity claim.

## Lifecycle

Required transitions:

```text
invalid permission/configuration/display/guard
        -> semantic only

valid fixture
        -> live capture

guard becomes false
        -> one CLEAR
        -> semantic only

guard becomes true
        -> current capture resumes

helper exits normally
        -> CLEAR where possible
        -> semantic only

helper crashes/disconnects
        -> accepted V1D-2 fallback
        -> semantic only

Bitwig quits
        -> guard or connection fallback
        -> semantic only
```

V2 makes no claim that the crop follows a moved/resized Bitwig window.

## Performance

At 30 fps, retain at least 1,000 frames where practical.

Measure callback interval, frame-status check, pixel-buffer access, crop/source-rect computation, aspect mapping/scaling, BGRA/alpha normalization, protocol header preparation, socket send, and accepted-sample-to-send total.

Targets:

```text
processing p95 <= 10 ms
copy/map/normalize/send p95 <= 2 ms
```

Test 15 and 30 fps. 60 fps is optional.

Retain CPU, resident-memory start/end/peak, incomplete/dropped frames, frame and CLEAR counts, and source-guard transitions.

## Real Push acceptance

Using exact accepted V1D-2:

- Push connects;
- pads, pressure/MPE, encoders, and transport work;
- Push audio/headphones work;
- semantic UI remains current;
- live Sampler visual appears only in the declared destination;
- no aspect distortion remains;
- invalid/lost source conditions return to semantics;
- no trail, torn frame, stale display crop, full-display leak, control lag, abnormal display lag, xrun, or dropout;
- helper and Bitwig quit normally.

Restore the exact official DrivenByMoss artifact afterward.

## Branches and evidence

Source:

```text
capture/v2-macos-display-crop-lens
```

Evidence:

```text
codex/v2-macos-display-crop-evidence
```

Evidence directory:

```text
evidence/v2-macos-display-crop/
```

Suggested files:

```text
README.md
source-topology.md
helper-build-and-identity.md
display-selection-and-guard.md
crop-aspect-and-pixel-contract.md
sampler-result.md
permission-and-fallback.md
performance.md
real-fixture-and-rollback.md
limitations-and-next-resolution.md
```

Both PRs remain open, non-draft, and unmerged for technical-lead review.

## Completion

V2 is complete only when production source and evidence exist at exact reviewable heads; stable app/TCC identity, exact display selection, crop validation, aspect-preserving mapping, Sampler pixels, fallback, bounded performance, Push controls/audio, and exact official rollback all pass.

Dedicated-window/VST identity remains deferred.
