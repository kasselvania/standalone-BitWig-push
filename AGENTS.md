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
3. `docs/V2_MACOS_DEDICATED_WINDOW_LENS.md`
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
- Attached mode adapts to the user's existing Bitwig windows and monitor layout; managed geometry is optional appliance/test behavior.
- Physical desktop coordinates are never the primary identity of a visual source.
- Prefer dedicated windows, semantic identity, source-relative geometry, normalized crops, bounded calibration, and later confidence-validated anchors.
- Wrong visual content is worse than semantic fallback. Missing or ambiguous source identity must abstain.
- Capture-backend and operating-system objects do not enter the DrivenByMoss raster or ingress contracts.
- macOS objects such as `SCWindow`, `SCStream`, `CGWindowID`, `CMSampleBuffer`, and `CVPixelBuffer` remain inside the macOS helper/backend.
- Semantic fallback means restoring the exact current semantic pixels, not merely stopping future visual drawing.
- Historical composed output is never restoration authority.
- Moving, resized, replaced, closed, stale, invalid, malformed, disconnected, or crashed visual sources leave no pixels behind.
- Raster validation completes before destination mutation; rejected input causes zero partial writes.
- The external receiver thread never renders into or writes a Push bitmap.
- The display/composition thread never performs socket accept/read/write or blocks waiting for a producer.
- External publication is complete-frame only and latest-frame-wins; there is no application FIFO of visual frames.
- Local monotonic receipt time, not producer wall clock, determines external-frame staleness.
- Controller input and audio never wait for capture, window discovery, or an external producer.
- The ordinary rear Push USB path remains a first-class architecture.
- Track A and Track H do not block Track V progress.
- Do not redistribute proprietary Ableton/Bitwig binaries, firmware, activation data, private assets, or committed proprietary UI screenshot fixtures.
- Prefer hashes, geometry, recipes, descriptors, generated fixtures, and local-only screenshots for evidence.
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

Accepted external-ingress properties:

- protocol magic `0x50575852`, version 1, 80-byte network-order header;
- HELLO / FRAME / CLEAR;
- maximum opaque-BGRA payload 614,400 bytes;
- one nonzero 128-bit producer session and receiver-local generation;
- positive strictly increasing sequence with legal gaps and reconnect reset;
- `Long.MAX_VALUE` exhausts one session;
- local `System.nanoTime()` freshness, default 1,500 ms;
- fixed staging/publication/display arrays and one daemon receiver;
- display `tryLock` only;
- exact semantic fallback on no producer, clear, disconnect, crash, stale, malformed/truncated/oversized input, authentication/protocol/session failure, writer rejection, bind failure, and shutdown.

## Slice discipline

Do not merge adjacent uncertainty domains:

- external generated-frame ingress is separate from OS window capture;
- dedicated top-level window capture is separate from embedded Bitwig-panel resolution;
- capture is separate from visual-source adapter/public SDK design;
- dedicated-window identity is separate from semantic pixel-anchor recognition;
- macOS proof is separate from Linux/Steam Deck portability;
- attached desktop integration is separate from managed appliance geometry;
- software capture is separate from appliance and CM11EB hardware work.

## V2 production rules — macOS dedicated-window visual lens

V2 is the first real visual-source slice.

Primary claim:

```text
unique dedicated Bitwig/plugin window
        -> ScreenCaptureKit macOS helper
        -> source-relative normalized crop
        -> bounded helper-local scaling
        -> opaque BGRA8888
        -> accepted V1D-2 protocol v1
        -> current semantic frame + captured visual
        -> real Push
```

V2 must prove two source classes:

1. one floating/undocked Bitwig native-device Expanded Device View with meaningful visual content;
2. one already-installed ordinary plug-in editor.

### Source repository and custody

The first capture backend lives in this central repository under:

```text
capture/macos/**
```

Expected source files:

```text
capture/macos/Package.swift
capture/macos/Resources/Info.plist
capture/macos/scripts/build-app.sh
capture/macos/Sources/PushwigCaptureHelper/main.swift
capture/macos/Sources/PushwigCaptureHelper/CaptureConfiguration.swift
capture/macos/Sources/PushwigCaptureHelper/WindowDiscovery.swift
capture/macos/Sources/PushwigCaptureHelper/WindowCapture.swift
capture/macos/Sources/PushwigCaptureHelper/ExternalRasterProtocolClient.swift
```

A narrowly different split inside `capture/macos/**` is allowed only when responsibilities remain bounded and the change is explained before editing.

Do not modify DrivenByMoss in V2. Any required receiver/sink change is a blocker and authority decision.

### Helper identity and permission

- Build a normal macOS `.app` bundle rather than using Terminal as capture authority.
- Preferred development bundle identifier: `com.kasselvania.pushwig.capture-helper`.
- SwiftPM + retained app-bundle/ad-hoc-sign build script is preferred when the installed toolchain supports it.
- No Developer ID, notarization, App Store, or release-signing claim is required in V2.
- Use normal macOS Screen Recording/TCC APIs only; no private TCC manipulation.
- Permission denial produces no captured frame, clears external authority where applicable, emits one bounded actionable error, and leaves Bitwig/Push semantics operational.
- Relaunch after permission grant is acceptable when required by macOS and must be retained explicitly.

### Window identity

Use ScreenCaptureKit shareable-window discovery.

A V2 fixture target is identified by:

```text
owning application bundle identifier
+ exact window title
+ declared source role
```

The current `SCWindow.windowID` is instance identity while the window exists.

- zero matches -> CLEAR/semantic fallback;
- multiple matches -> abstain/CLEAR;
- move does not change logical identity;
- resize recomputes the source-relative crop;
- close revokes authority;
- reopen may acquire a new windowID through the same unique logical descriptor;
- desktop physical x/y is never persisted as source identity.

V2 does not solve ambiguous duplicate plug-in windows. It must refuse ambiguity rather than guess.

### Capture and pixel contract

- ScreenCaptureKit dedicated-window filter.
- Cursor excluded.
- Complete frames only.
- BGRA capture.
- Bounded ScreenCaptureKit queue depth; no extra unbounded application frame queue.
- Default target cadence 30 fps.
- Crop expressed as normalized source-relative x/y/width/height in `[0,1]`.
- Recompute source rectangle after resize/reacquire.
- Helper-local bounded scaling to the declared Push destination width/height is authorized.
- Output rows top-to-bottom, bytes B/G/R/A, alpha forced to `0xFF` before protocol transmission.
- Destination must fit inside 960x160.

Fixture/development arguments for bundle id, exact title, role, normalized crop, destination, fps, port, and token-file path are allowed. They are not the future public visual-adapter SDK.

### Protocol producer

The helper must use accepted V1D-2 protocol v1 exactly. It may not bypass the receiver.

- Connect only to configured IPv4 loopback.
- Read the existing private capability file without logging its value.
- One nonzero producer session per connection.
- HELLO once, then positive strictly increasing FRAME/CLEAR sequence.
- Send CLEAR on transition to no valid source where possible.
- On receiver failure/disconnect, stop boundedly; do not queue historical frames.
- No protocol-v2 change and no second Push path.

### Dedicated-window lifecycle acceptance

For both source classes where physically possible:

- unique discovery and real captured pixels on Push;
- same-display movement;
- resize smaller/larger;
- source-relative crop follows resize;
- close -> semantics;
- reopen/new windowID -> reacquire and resume;
- source obscured by another window remains coherent where ScreenCaptureKit supports it;
- cross-display move when two displays are present, otherwise retain explicit no-claim;
- ambiguous source condition abstains rather than captures the wrong window.

Do not retain proprietary screenshots in Git.

### Performance

At 30 fps retain capture callback interval separately from helper processing cost.

Targets:

```text
helper capture-to-ready processing p95 <= 10 ms
helper copy/normalize/protocol-send p95 <= 2 ms
no unbounded backlog or frame-memory growth
```

Test 15 fps and 30 fps. Test 60 fps when stable, but 60 fps is not required for V2 acceptance.

Retain CPU, memory/RSS, dropped/late-frame counts, and V1D-2 supersession where useful.

### Real fixture and rollback

Use the exact accepted V1D-2 integration artifact or an exact rebuild from accepted `pushwig/main`; do not modify it.

Prove normal pads/MPE/encoders/transport/audio/headphones, current semantic UI around/under the lens, useful native-device pixels, useful plug-in pixels, no whole-desktop/wrong-window capture, lifecycle fallback, helper exit/crash fallback, no control/display/audio regression, normal shutdown, and exact official DrivenByMoss rollback afterward.

## V2 PR topology

Source PR in this central repository:

```text
branch: capture/v2-macos-dedicated-window-lens
paths:  capture/macos/**
```

Evidence PR separately:

```text
branch: codex/v2-macos-dedicated-window-evidence
paths:  evidence/v2-macos-dedicated-window/**
```

Both remain open/non-draft/unmerged for technical-lead review.

## Evidence rules

Retain exact source/build/helper identity, selected source descriptors, windowID transitions, source dimensions, normalized crops, destination geometry, pixel format/stride, hashes, permission behavior, lifecycle events, processing timing, real Push checks, and rollback.

Do not commit helper build products, proprietary screenshots/raw captured frames, capability tokens/files, private project/preset data, full logs, hostnames, serials, UUIDs, or unsanitized personal paths.

## Current posture

S0, V1A-0, V1A, V1B, V1C-0, V1C, V1D-0, V1D-1, V1D-2-0, and V1D-2 are accepted.

V2 is active: macOS dedicated-window capture through the unchanged accepted external-ingress boundary. Embedded Bitwig resolution, pixel anchors, public adapter SDK, and Linux portability remain later slices.
