# AGENTS.md — Repository Execution Rules

## Mission

Build an open, inspectable adaptive visual/controller layer for Ableton Push 3 and Bitwig Studio, then reuse that software in optional portable-appliance and native-compute projects.

The repository coordinates three independent tracks:

1. universal visual/controller integration;
2. all-in-one appliance packaging;
3. CM11EB connector and native-compute research.

The current Track V reference fixture is the maintainer's macOS Bitwig/DrivenByMoss/Push system because it provides the shortest software loop. The Steam Deck remains the first Track A appliance host and named Linux portability fixture. Neither host defines the universal product.

## Authority order

When instructions conflict, use this order:

1. `AGENTS.md`
2. `CURRENT_SLICE.md`
3. `docs/V2_MACOS_DISPLAY_CROP_LENS.md`
4. `docs/PROJECT_TRACKS.md`
5. `docs/ARCHITECTURE.md`
6. `docs/MAC_FIRST_DEVELOPMENT.md`
7. `docs/DRIVENBYMOSS_DERIVATIVE_STRATEGY.md`
8. `docs/V1D2_EXTERNAL_FRAME_INGRESS.md`
9. `docs/V1D20_EXTERNAL_FRAME_INGRESS.md`
10. `docs/V1D1_LOCAL_RASTER_COMPOSITION.md`
11. `docs/VISUAL_PORTABILITY.md`
12. `docs/SEMANTIC_PIXEL_ANCHOR_RESOLVER.md`
13. `docs/ROADMAP.md`
14. issue / PR scope
15. implementation convenience

A contributor or coding agent must stop and surface a conflict rather than quietly widening scope.

## Core invariants

- Bitwig remains the DAW and audio-engine authority.
- DrivenByMoss remains the semantic Push/controller authority through the current slices.
- Exactly one component owns the Push USB display endpoint in steady state.
- The accepted DrivenByMoss derivative owns final semantic redraw, raster application, and Push USB transport.
- Visual capture is visualization first. Do not replace reliable controller-API operations with fragile mouse automation.
- Capture-backend and operating-system objects do not enter the DrivenByMoss raster or ingress contracts.
- macOS objects such as `SCDisplay`, `SCStream`, `CMSampleBuffer`, `CVPixelBuffer`, and CoreGraphics display identifiers remain inside the macOS helper/backend.
- Semantic fallback means restoring the exact current semantic pixels, not merely stopping future visual drawing.
- Historical composed output is never restoration authority.
- Raster validation completes before destination mutation; rejected input causes zero partial writes.
- The external receiver thread never renders into or writes a Push bitmap.
- The display/composition thread never performs socket accept/read/write or blocks waiting for a producer.
- External publication is complete-frame only and latest-frame-wins; there is no application FIFO of visual frames.
- Local monotonic receipt time, not producer wall clock, determines external-frame staleness.
- Controller input and audio never wait for capture or an external producer.
- Wrong visual content is worse than semantic fallback.
- Attached-mode portability remains the product goal, but a bounded fixture-specific capture is allowed as an earlier proof when its limitations are stated honestly.
- V2 may use an explicitly selected physical display and a normalized display-relative crop as fixture configuration. That coordinate is not universal device identity and must not be represented as such.
- Main-window placement, Bitwig panel layout, display scaling, and crop geometry are operator-owned fixture state in V2.
- Automatic device/panel identity, layout adaptation, pixel anchors, calibration, and dedicated plug-in-window identity remain later uncertainty domains.
- Display capture may never silently auto-select the first display or transmit the whole display when a bounded crop was requested.
- The V2 helper must stop or CLEAR when its exact selected display or declared validity conditions are no longer satisfied.
- The ordinary rear Push USB path remains a first-class architecture.
- Track A and Track H do not block Track V progress.
- Do not redistribute proprietary Ableton/Bitwig binaries, firmware, activation data, private assets, or committed proprietary UI screenshot fixtures.
- Prefer hashes, geometry, recipes, descriptors, generated fixtures, and local-only inspection for evidence.
- Every implementation/research slice names exact accepted source and central commits/trees.
- `pushwig/upstream-26.4.1` remains the immutable accepted DrivenByMoss upstream basis.
- DrivenByMoss project source PRs target `pushwig/main` only.

## Accepted source posture

Accepted DrivenByMoss integration:

```text
repository: kasselvania/DrivenByMoss
branch:     pushwig/main
commit:     7e3416a1bdddbcbeec4e35e6531652e1618723de
tree:       c8bc3f9e052e8f0b7b5dd256657697349d303740
```

That merge contains exact accepted V1D-2 source head:

```text
830b778b720a06f56de08861d27052228c82c63b
```

Immutable upstream basis:

```text
branch: pushwig/upstream-26.4.1
commit: fd03245ab38fa5149c45934051d937ee9fda6d08
tree:   edd2ad636b0aa1f39919f0ffd05c968015450075
```

Accepted central V1D-2 evidence:

```text
commit: 198b44a838009dac0df83464501004b6e6b59d9d
tree:   76d9f92ae8ec7369790b0b8dd325cd4a602e3dbb
```

Official DrivenByMoss artifact used for rollback:

```text
$HOME/Documents/Bitwig Studio/Extensions/DrivenByMoss.bwextension
SHA-256: 98dc3195ad8d911526e18b1005f09f69a1aedcb965b080565474104654345c5a
```

## Accepted visual path

```text
DrivenByMoss current semantic redraw
        -> optional current opaque BGRA raster
        -> validated absolute bulk write
        -> same semantic IBitmap
        -> one unchanged PushUsbDisplay.send
```

External producer path:

```text
producer
        -> capability-authenticated TCP 127.0.0.1 protocol v1
        -> one receiver thread
        -> fixed latest publication
        -> display tryLock adoption into fixed consumer bytes
        -> accepted raster writer
        -> same IBitmap
        -> unchanged Push USB writer
```

Accepted external-ingress properties include the 80-byte network-order protocol header, HELLO/FRAME/CLEAR messages, 614,400-byte opaque-BGRA payload ceiling, capability-file authentication, session/generation/sequence/freshness rules, fixed storage, nonblocking display adoption, and exact semantic fallback on absence or failure.

## V2 strategy correction

The original V2 authority assumed that Bitwig native-device Expanded Device Views and ordinary plug-in editors would appear as independently capturable ScreenCaptureKit windows.

On the accepted macOS 26.4.1 / Bitwig Studio 6.1 fixture, reconnaissance did not expose those device/editor surfaces as usable independent capture targets. The pushed branch:

```text
capture/v2-macos-dedicated-window-lens
f5bd7fd990ee74956aa1168ba8b747f0f63286ab
```

is quarantined archaeology. It has no PR, is not accepted source, and must not be merged or used as the production branch.

A temporary override proved a different path:

```text
explicit SCDisplay
        -> bounded normalized display crop containing the Bitwig device chain
        -> helper-local raster mapping
        -> accepted V1D-2 ingress
        -> real Sampler pixels on Push
```

The temporary proof is strategy evidence only. It was uncommitted, used a rough mapping that visibly distorted the image, and does not satisfy production V2.

## Slice discipline

Do not merge adjacent uncertainty domains:

- display-crop capture is separate from automatic embedded-panel resolution;
- fixture crop configuration is separate from universal source identity;
- capture is separate from the public visual-source/adapter SDK;
- aspect-preserving raster mapping is separate from semantic pixel-anchor recognition;
- dedicated-window/VST identity is deferred rather than silently claimed;
- macOS proof is separate from Linux/Steam Deck portability;
- attached desktop integration is separate from managed appliance geometry;
- software capture is separate from appliance and CM11EB hardware work.

## V2 production rules — macOS display-crop visual lens

V2 is the first production slice to place real Bitwig pixels on Push.

Primary claim:

```text
explicitly selected SCDisplay
        -> bounded normalized display-relative crop
        -> explicit aspect-preserving helper-local mapping
        -> opaque BGRA8888
        -> accepted V1D-2 protocol v1
        -> current semantic frame + captured visual
        -> real Push
```

V2 must prove one real source:

- the Bitwig main-window device-chain region showing useful live Sampler content on the accepted fixture.

V2 does not require a dedicated native-device window or a plug-in editor. It makes no VST/VST3/CLAP identity claim.

### Source repository and custody

The production helper lives in this central repository under:

```text
capture/macos/**
```

Create a fresh branch from the accepted authority basis:

```text
capture/v2-macos-display-crop-lens
```

Do not base it on, merge, or cherry-pick the quarantined dedicated-window branch. Generic code may be inspected and reimplemented only after its assumptions are reviewed.

Do not modify DrivenByMoss in V2. Any required receiver/sink change is a blocker and authority decision.

### Helper identity and permission

- Build a normal macOS `.app` bundle with stable development identity.
- Preferred bundle identifier: `com.kasselvania.pushwig.capture-helper`.
- SwiftPM plus a retained app-bundle/ad-hoc-sign script is preferred.
- No Developer ID, notarization, App Store, or release-signing claim is required.
- Use public Screen Recording permission APIs only.
- Permission denial/unavailability publishes no frame, clears current authority when possible, emits one bounded actionable error, and leaves Bitwig/Push semantics operational.

### Exact display and crop configuration

The helper must support a bounded display inventory mode and explicit selection.

Production V2 requires:

```text
display id
expected display width
expected display height
normalized crop x,y,width,height
Push destination x,y,width,height
requested fps
V1D-2 port
V1D-2 token-file path
source-validity guard configuration
```

Rules:

- never auto-select the first display;
- exactly one `SCDisplay` must match the supplied display identifier;
- observed dimensions must match the declared fixture dimensions;
- the normalized crop must be finite, positive, and contained in `[0,1]`;
- the computed source rectangle must be positive and contained in the selected display;
- destination must be positive and contained in 960x160;
- display disappearance or unexpected dimension change clears visual authority and stops boundedly;
- no full-display pixel payload may be sent when a crop was requested.

The first accepted fixture is expected to reproduce the successful reconnaissance geometry unless final evidence justifies a corrected crop:

```text
display:              5
display dimensions:   3430x1447
normalized crop:      0.14,0.68,0.45,0.305
reconnaissance rect:  480.2,983.96,1543.5,441.335
Push destination:     400,0,560,160
```

These values are fixture coordinates, not universal source identity.

### Source-validity guard

Display cropping can otherwise capture unrelated pixels when another application replaces or covers the intended region.

V2 must use one bounded public-API guard, selected and documented before the final source commit, that at minimum proves the intended Bitwig application is running and is the active source context. A frontmost-application bundle-ID gate is acceptable.

When the guard is false:

```text
send one CLEAR when connected
stop FRAME publication
preserve semantic-only Push output
```

This guard is not the future embedded-panel resolver and must not be represented as exact device identity.

### Capture and pixel contract

- Capture the explicitly selected `SCDisplay` through ScreenCaptureKit.
- Cursor excluded.
- Complete frames only.
- BGRA capture.
- Queue depth 2 unless measured evidence requires another bounded value.
- Default requested cadence 30 fps.
- No unbounded application frame queue.
- Crop and scale inside the helper before protocol transmission.
- Output rows top-to-bottom, bytes B/G/R/A, alpha forced to `0xFF`.
- Reuse bounded output storage; do not allocate a full frame per callback when avoidable.

### Aspect mapping

The reconnaissance proved the pipeline but visibly distorted the visual.

Production V2 must:

- identify the exact coordinate/aspect cause;
- use one explicit aspect-preserving mapping;
- never independently stretch width and height;
- document whether it uses a centered cover crop or uniform contain scaling with opaque padding;
- retain the source aspect, effective source rectangle, destination aspect, scale, and any padding/cropping;
- produce no unexplained visible aspect distortion.

A general fit-policy SDK is not part of V2.

### Protocol producer

The helper must use accepted V1D-2 protocol v1 exactly.

- Connect only to configured IPv4 loopback.
- Read the private capability file without logging its value.
- One nonzero session per connection.
- HELLO once.
- Positive strictly increasing FRAME/CLEAR sequence.
- Send complete opaque BGRA frames only.
- Send one CLEAR when leaving valid capture authority.
- Receiver loss/failure stops boundedly and does not accumulate historical frames.
- No protocol change and no second Push path.

### Fixture lifecycle

V2 proves the configured fixture lifecycle, not arbitrary layout adaptation:

- permission denied/unavailable -> semantics;
- permission granted and same helper build relaunched when required -> capture;
- exact display/crop/guard valid -> live Sampler pixels;
- selected device/sample visual changes -> live captured changes;
- guard false -> CLEAR/semantics;
- helper exit/crash -> semantics through accepted V1D-2;
- Bitwig quit -> guard failure or disconnect -> semantics;
- restart with the same valid fixture -> capture resumes;
- invalid display/crop/destination configuration -> no visual authority.

Moving/resizing the Bitwig main window, changing display scaling, cross-display migration, automatic device discovery, and crop recalibration are not V2 claims.

### Performance

At 30 fps retain at least 1,000 complete frames where practical and separate capture callback cadence from helper processing.

Measure callback interval, sample-status acceptance, pixel-buffer access, crop/aspect mapping, BGRA/alpha copy, protocol preparation, socket send, and complete accepted-sample-to-send processing.

Targets:

```text
helper processing p95 <= 10 ms
copy/map/normalize/send p95 <= 2 ms
no unbounded backlog or frame-memory growth
```

Test 15 and 30 fps. 60 fps is optional.

Retain CPU, RSS/resident start/end/peak, incomplete/dropped frame counts, protocol sequence/CLEAR counts, and source-guard transitions.

### Real fixture and rollback

Use an exact build from accepted DrivenByMoss `pushwig/main`; do not modify it.

Prove Push connection, pads, pressure/MPE, encoders, transport, audio/headphones, current semantics, live Sampler pixels only in the declared destination, no full-display transmission, no visible aspect distortion, semantic fallback on permission/configuration/guard/helper loss, no trail/torn frame/control lag/display lag/xrun/dropout, normal shutdown, and exact official DrivenByMoss rollback.

## V2 PR topology

Source:

```text
branch: capture/v2-macos-display-crop-lens
paths:  capture/macos/**
commit: V2: add macOS display-crop capture helper
PR:     V2: add macOS display-crop visual lens
```

Evidence:

```text
branch: codex/v2-macos-display-crop-evidence
paths:  evidence/v2-macos-display-crop/**
```

Both remain open, non-draft, and unmerged for technical-lead review.

## Evidence rules

Retain exact source/build/helper identity, app/TCC identity, selected display identity/dimensions, crop math, aspect mapping, destination geometry, pixel format/stride, hashes, protocol sequence and CLEAR counts, guard behavior, timing, CPU/memory, real Push checks, and rollback.

Do not commit helper build products, proprietary screenshots/raw captured frames, capability tokens/files, private project/preset data, full logs, hostnames, serials, UUIDs, or unsanitized personal paths.

## Current posture

S0, V1A-0, V1A, V1B, V1C-0, V1C, V1D-0, V1D-1, V1D-2-0, and V1D-2 are accepted.

V2 is active as a macOS display-crop visual lens. Dedicated-window/VST identity, automatic embedded-panel resolution, pixel anchors, public adapter SDK, and Linux portability remain later work.
