# Current Slice: V2 — macOS Display-Crop Visual Lens

## Status

Ready to execute from the current accepted central `origin/main` after this authority correction is merged.

Active issue: [#38 — V2: macOS display-crop visual lens](https://github.com/kasselvania/standalone-BitWig-push/issues/38).

Create fresh V2 source and evidence branches directly from the merged authority basis. Do not use the quarantined dedicated-window branch as the implementation basis.

## Why the V2 authority changed

The original V2 authority assumed that Bitwig native-device Expanded Device Views and ordinary plug-in editors would appear as independent ScreenCaptureKit windows.

On the accepted macOS 26.4.1 / Bitwig Studio 6.1 fixture, the reconnaissance implementation did not expose those device/editor surfaces as useful independently capturable system windows.

That source remains quarantined at:

```text
branch:
capture/v2-macos-dedicated-window-lens

commit:
f5bd7fd990ee74956aa1168ba8b747f0f63286ab
```

It has no pull request, is not accepted source, and must not be merged or used as the new production branch.

The maintainer then authorized a temporary display-crop override. That experiment succeeded:

```text
ScreenCaptureKit SCDisplay 5
display dimensions 3430x1447
normalized crop 0.14,0.68,0.45,0.305
computed source rect 480.2,983.96,1543.5,441.335
Push destination 400,0,560,160
opaque BGRA8888
queue depth 2
requested 30 fps
7192 FRAME messages
protocol sequence 1..7193
one CLEAR on exit
zero incomplete/format/dimension/alpha failures
approximately 1% helper CPU
34320 KB helper RSS
```

Real Sampler pixels reached the physical Push through unchanged V1D-2, controls remained responsive, and fallback was clean.

The proof was temporary and uncommitted. It selected the tactic but did not complete production V2. Its rough source-to-destination mapping visibly distorted the image, and the helper source/app/evidence were removed.

## Primary claim

Implement and prove the first production real-pixel visual source:

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

- the Bitwig main-window device-chain region showing useful live Sampler content on the accepted Mac fixture.

V2 does not require:

- a dedicated native-device top-level window;
- an ordinary plug-in editor;
- VST/VST3/CLAP source identity;
- automatic device or panel localization.

No DrivenByMoss source change is authorized. The accepted V1D-2 receiver, V1D-1 raster sink, semantic redraw, and Push USB transport are fixed consumer authority.

## Accepted authorities

### Central

```text
repository: kasselvania/standalone-BitWig-push
accepted V1D-2 evidence:
198b44a838009dac0df83464501004b6e6b59d9d

tree:
76d9f92ae8ec7369790b0b8dd325cd4a602e3dbb
```

### DrivenByMoss

```text
repository: kasselvania/DrivenByMoss
branch:     pushwig/main
commit:     7e3416a1bdddbcbeec4e35e6531652e1618723de
tree:       c8bc3f9e052e8f0b7b5dd256657697349d303740
```

That integration contains exact accepted V1D-2 source head:

```text
830b778b720a06f56de08861d27052228c82c63b
```

Immutable upstream basis:

```text
branch: pushwig/upstream-26.4.1
commit: fd03245ab38fa5149c45934051d937ee9fda6d08
tree:   edd2ad636b0aa1f39919f0ffd05c968015450075
```

Official rollback artifact:

```text
$HOME/Documents/Bitwig Studio/Extensions/DrivenByMoss.bwextension
SHA-256:
98dc3195ad8d911526e18b1005f09f69a1aedcb965b080565474104654345c5a
```

## Repository and branch topology

Production helper source belongs under:

```text
capture/macos/**
```

Create a fresh source branch from the merged V2 authority basis:

```text
capture/v2-macos-display-crop-lens
```

Commit subject:

```text
V2: add macOS display-crop capture helper
```

Source PR title:

```text
V2: add macOS display-crop visual lens
```

Create a separate evidence branch from the same basis:

```text
codex/v2-macos-display-crop-evidence
```

Evidence belongs only under:

```text
evidence/v2-macos-display-crop/**
```

Both PRs target `main` and remain open, non-draft, and unmerged for technical-lead review.

Do not:

- merge the quarantined branch;
- cherry-pick its commit;
- base the new source branch on it.

The agent may inspect generic Swift packaging or protocol-client work from the quarantined branch, but any reused idea must be reimplemented from the accepted authority basis after dedicated-window assumptions are removed.

## Expected production source envelope

Expected files are:

```text
capture/macos/Package.swift
capture/macos/Resources/Info.plist
capture/macos/scripts/build-app.sh
capture/macos/Sources/PushwigCaptureHelper/main.swift
capture/macos/Sources/PushwigCaptureHelper/CaptureConfiguration.swift
capture/macos/Sources/PushwigCaptureHelper/DisplayDiscovery.swift
capture/macos/Sources/PushwigCaptureHelper/DisplayCropCapture.swift
capture/macos/Sources/PushwigCaptureHelper/AspectMapping.swift
capture/macos/Sources/PushwigCaptureHelper/SourceValidityGate.swift
capture/macos/Sources/PushwigCaptureHelper/ExternalRasterProtocolClient.swift
```

A narrowly different split inside `capture/macos/**` is allowed only when responsibilities remain bounded and the reason is explained before editing.

Do not modify:

- `kasselvania/DrivenByMoss`;
- accepted V1D-2 protocol or receiver;
- accepted V1D-1 raster contract;
- Push transport;
- prior evidence;
- authority/status files in the implementation PR.

## Helper identity and permission

Build a normal macOS `.app` with stable development identity.

Preferred bundle identifier:

```text
com.kasselvania.pushwig.capture-helper
```

Preferred build:

```text
SwiftPM release executable
        -> deterministic .app wrapper
        -> Info.plist
        -> ad-hoc development signature
```

Use public Screen Recording permission APIs only.

Required behavior:

- preflight permission;
- denied or unavailable permission publishes no frame;
- send CLEAR when a live visual authority existed;
- emit one bounded actionable error;
- leave Bitwig, DrivenByMoss, Push controls, and audio unaffected;
- relaunch the same exact helper build after permission grant when macOS requires it;
- no private TCC manipulation or global reset.

No Developer ID, notarization, installer, or App Store claim is required.

## Display inventory and exact selection

The helper must provide a bounded display-list mode.

Retain only relevant sanitized inventory:

- `SCDisplay.displayID`;
- width;
- height;
- selected/main state where public API exposes it;
- backing/logical relationship where deterministically observable.

Capture configuration must require:

```text
display id
expected display width
expected display height
normalized crop x,y,width,height
Push destination x,y,width,height
requested fps
V1D-2 port
V1D-2 token-file path
source-validity guard
```

Rules:

- never auto-select the first display;
- exactly one `SCDisplay` must match the supplied ID;
- observed width/height must equal the declared fixture dimensions;
- selected display absence or unexpected dimension change revokes visual authority;
- no physical display coordinate becomes universal device identity;
- changing display or display mode requires explicit reconfiguration or restart in V2.

The accepted fixture should begin from the successful reconnaissance values unless final evidence justifies corrected geometry:

```text
display id:            5
display size:          3430x1447
normalized crop:       0.14,0.68,0.45,0.305
reconnaissance rect:   480.2,983.96,1543.5,441.335
destination:           400,0,560,160
```

## Source-validity guard

Display capture can otherwise show unrelated content when the operator leaves Bitwig or another application occupies the crop.

V2 must use one bounded public-API guard. At minimum it must prove that the intended Bitwig application is running and is the active capture context.

An exact frontmost-application bundle-identifier gate is an acceptable first implementation.

The final source must state the exact guard.

When invalid:

```text
send one CLEAR when connected
stop FRAME publication
semantic-only Push output
```

When valid again, the helper may resume with current pixels.

The guard is not device identity and is not an embedded-panel resolver.

## Crop validation

Normalized crop values must be finite, positive, contained in `[0,1]`, and produce a positive source rectangle inside the selected display.

Destination must be positive and contained in:

```text
960x160
```

Reject invalid display, crop, destination, frame format, or dimension configuration before capture/publish.

The helper must crop locally before protocol transmission. It may not send a full-display payload and rely on DrivenByMoss to crop it.

## Capture contract

Use ScreenCaptureKit with an exact selected-display content filter.

Require:

- cursor excluded;
- complete frames only;
- BGRA capture;
- queue depth `2`, unless retained evidence proves a different bounded value;
- target cadence 30 fps;
- no project-owned unbounded frame queue;
- no historical frame replay;
- output rows top-to-bottom;
- output bytes B,G,R,A;
- alpha forced to `0xFF`;
- one bounded reusable output buffer;
- no full-frame allocation per callback when avoidable;
- payload within V1D-2's 614,400-byte cap.

## Aspect-preserving mapping

The temporary proof visibly distorted the image. Production V2 must close that defect.

The implementation must:

1. retain source crop width/height and aspect;
2. retain destination width/height and aspect;
3. identify whether the temporary distortion came from coordinate-space mapping, nonuniform scaling, or both;
4. select one explicit aspect-preserving rule;
5. never stretch width and height independently.

Accepted first-slice choices are:

- centered `cover`, with the effective source rectangle adjusted to the destination aspect; or
- uniform `contain`, with opaque black padding in unused destination pixels.

Choose exactly one before the final source commit and retain original/effective source rectangles, scale, crop or padding, output dimensions, and visual operator result.

No general fit-policy SDK is introduced.

Acceptance requires zero unexplained visible aspect distortion.

## V1D-2 protocol client

Use accepted protocol v1 exactly:

```text
magic:         0x50575852
version:       1
header:        80 bytes
messages:      HELLO=1 FRAME=2 CLEAR=3
formats:       NONE=0 OPAQUE_BGRA8888=1
max payload:   614400
transport:     configured IPv4 loopback
```

Requirements:

- read the existing private capability file without logging the capability;
- create one nonzero 128-bit session per connection;
- send HELLO once;
- send positive strictly increasing FRAME/CLEAR sequence values;
- send only complete valid frames;
- send CLEAR once on transition from valid visual authority to none;
- stop boundedly on receiver loss;
- no application frame FIFO or retry backlog;
- no protocol v2;
- no second Push or USB path.

## Fixture posture

The V2 crop is explicitly fixture-relative.

While capture is armed:

- selected display and dimensions are fixed;
- Bitwig main-window placement is fixed;
- device-chain panel location and panel sizes are fixed;
- display scaling is fixed;
- normalized crop is operator-supplied.

V2 does not claim that the crop follows Bitwig window movement, Bitwig window resize, panel layout changes, cross-display migration, or UI-scale changes.

Those require later semantic/layout resolution, anchors, or calibration.

## Required real visual proof

Use Bitwig Sampler in the main-window device-chain region.

Prove:

- actual live Sampler/device-chain pixels appear on Push;
- at least one meaningful Sampler visual change is visible live;
- the captured region is confined to the declared Push destination;
- semantic UI remains current outside/under the visual lens;
- no full display is transmitted or displayed;
- row order, BGRA channels, alpha, and geometry are correct;
- aspect mapping is visibly correct;
- no stale pixels remain after CLEAR, guard failure, helper exit, or Bitwig quit.

A plug-in may be observed through the same crop if convenient, but it is not a V2 acceptance requirement and creates no plug-in identity claim.

## Lifecycle acceptance

Prove valid capture, permission denial/grant, guard false/true, invalid display/dimensions/crop/destination, normal helper exit, forced helper exit, Bitwig quit, restart, and no wrong/full-display visual authority.

Moving/resizing the Bitwig main window and automatic crop reacquisition are explicitly not tested claims.

## Performance

At 30 fps, after warmup, retain at least 1,000 complete frames where practical.

Separate callback interval, frame-status acceptance, pixel-buffer access, crop/coordinate computation, aspect mapping/scaling, BGRA/alpha normalization, protocol preparation, socket send, and complete accepted-sample-to-send processing.

Targets:

```text
helper accepted-sample processing p95 <= 10 ms
copy/map/normalize/send p95 <= 2 ms
no unbounded backlog
no unbounded memory growth
```

Test 15 and 30 fps. 60 fps is optional.

Retain samples, p50/p95/max, incomplete/dropped frames, protocol frames/CLEAR count, guard transitions, CPU, RSS/resident start/end/peak, helper queue/thread topology, and any observable V1D-2 supersession.

The temporary estimate of approximately 1% CPU and 34,320 KB RSS is reconnaissance context, not accepted production measurement.

## Real Push acceptance

Using the exact accepted V1D-2 integration artifact, prove Push connection, pads, pressure/MPE, encoders, transport, current semantic display, Push audio/headphones, real Sampler pixels only in the declared destination, no visible aspect distortion, semantic fallback on permission/configuration/guard/helper loss, no trail/stale block/torn frame/full-display leak/control lag/display lag/xrun/dropout, and normal helper/Bitwig quit.

Then restore the exact official DrivenByMoss artifact as the sole scanned extension and physically confirm standard display, controls, audio/headphones, and absence of captured pixels.

## Evidence output

Create only:

```text
evidence/v2-macos-display-crop/
├── README.md
├── source-topology.md
├── helper-build-and-identity.md
├── display-selection-and-guard.md
├── crop-aspect-and-pixel-contract.md
├── sampler-result.md
├── permission-and-fallback.md
├── performance.md
├── real-fixture-and-rollback.md
└── limitations-and-next-resolution.md
```

Retain exact source PR/head/tree, source hashes, helper build identity, permission attribution, display identity/dimensions, guard rule, crop math, aspect mapping, pixel contract, Sampler result, protocol counts, performance, real Push behavior, rollback, and explicit limitations.

Do not commit proprietary screenshots/raw frames, `.app` bundles/Swift build products, capability tokens/files, full logs, private projects/presets, serials/UUIDs/hostnames, unrelated display/window inventories, or unsanitized personal paths.

## Completion condition

V2 is complete only when exact source and evidence PR heads exist; source is built from the corrected authority basis; the dedicated-window branch remains unmerged; stable helper/TCC identity, exact display selection, crop validation, aspect-preserving mapping, real Sampler pixels, fallback, bounded performance, Push controls/audio, and exact official rollback all pass.
