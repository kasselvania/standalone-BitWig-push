# Current Slice: V2 — macOS Dedicated-Window Visual Lens

## Status

Ready to execute from the current accepted central `origin/main` containing merged V1D-2 evidence and from DrivenByMoss `origin/pushwig/main` at the exact accepted V1D-2 integration.

Active issue: [#38 — V2: macOS dedicated-window visual lens](https://github.com/kasselvania/standalone-BitWig-push/issues/38).

Before work begins, fetch central `origin/main` and verify that its history contains:

```text
198b44a838009dac0df83464501004b6e6b59d9d  # accepted V1D-2 evidence
```

Create V2 source and evidence branches directly from the then-current accepted `origin/main`. If `origin/main` has moved, inspect every intervening commit and stop if it changes V2 authority or scope.

## Primary claim

Implement and prove the first real visual source:

```text
unique dedicated Bitwig/plugin window
        -> ScreenCaptureKit macOS helper
        -> source-relative normalized crop
        -> bounded helper-local scale
        -> opaque BGRA8888
        -> accepted V1D-2 protocol v1
        -> current semantic frame + captured visual
        -> real Push
```

V2 must prove two dedicated-window classes:

1. one floating/undocked Bitwig native-device Expanded Device View with visually meaningful content;
2. one already-installed ordinary plug-in editor window.

No DrivenByMoss source change is authorized. The accepted V1D-2 receiver/sink/USB path is the fixed consumer boundary.

## Accepted authorities

### Central

```text
repository: kasselvania/standalone-BitWig-push
V1D-2 evidence: 198b44a838009dac0df83464501004b6e6b59d9d
tree:            76d9f92ae8ec7369790b0b8dd325cd4a602e3dbb
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

Immutable upstream basis remains:

```text
branch: pushwig/upstream-26.4.1
commit: fd03245ab38fa5149c45934051d937ee9fda6d08
tree:   edd2ad636b0aa1f39919f0ffd05c968015450075
```

Official rollback artifact:

```text
$HOME/Documents/Bitwig Studio/Extensions/DrivenByMoss.bwextension
SHA-256: 98dc3195ad8d911526e18b1005f09f69a1aedcb965b080565474104654345c5a
```

## Source topology

V2 adds production helper source to this central repository under:

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

A narrowly different split within `capture/macos/**` is allowed only when the same responsibilities remain bounded and the change is explained before editing.

Do not edit `kasselvania/DrivenByMoss` in V2. Stop if the helper cannot use the accepted protocol without a receiver change.

## Source and evidence branches

Capture-helper source branch:

```text
capture/v2-macos-dedicated-window-lens
```

Source commit subject:

```text
V2: add macOS dedicated-window capture helper
```

Source PR title:

```text
V2: add macOS dedicated-window visual lens
```

Evidence branch:

```text
codex/v2-macos-dedicated-window-evidence
```

Evidence only:

```text
evidence/v2-macos-dedicated-window/**
```

Both PRs target `main`, remain open/non-draft/unmerged, and are reviewed together.

## Helper identity

Build a normal macOS `.app` bundle with stable development identity rather than relying on Terminal as capture authority.

Preferred bundle identifier:

```text
com.kasselvania.pushwig.capture-helper
```

Preferred initial build path is SwiftPM plus a retained app-bundle/ad-hoc-sign script. Stop and retain a packaging blocker before changing build systems if ScreenCaptureKit/TCC cannot attribute permission safely to that bundle.

V2 makes no Developer ID, notarization, App Store, or production installer claim.

## Window discovery and source identity

Use `SCShareableContent` / ScreenCaptureKit shareable-window enumeration.

Fixture logical descriptor:

```text
owning application bundle identifier
+ exact window title
+ source role (native-device | plugin)
```

The current `SCWindow.windowID` is instance identity while the window exists.

Rules:

- require exactly one matching visible dedicated window;
- zero matches -> CLEAR/semantic fallback;
- multiple matches -> CLEAR/abstain, never guess;
- same-display movement does not change logical identity;
- cross-display movement does not change logical identity when a second display exists;
- resize recomputes normalized crop from current source dimensions;
- close revokes external authority promptly;
- reopen may create a new windowID and must be reacquired through the same unique logical descriptor;
- physical desktop x/y is never persisted as source identity.

Ambiguous duplicate plug-in windows are intentionally not solved in V2.

## Fixture targets

Inventory the accepted Mac before selecting targets.

Native target:

- prefer a Bitwig native device with a floating/undocked Expanded Device View and useful visual content, such as Sampler when available;
- retain exact Bitwig version, device name, bundle identifier, window title, and source dimensions;
- keep target choice out of generic source code.

Plug-in target:

- use one already-installed ordinary plug-in editor;
- retain name/vendor/version, exact window title, and dimensions;
- do not install or purchase a plug-in merely to satisfy V2 without maintainer approval.

If no suitable installed plug-in is available, stop and ask the maintainer to choose one.

## Capture contract

Use ScreenCaptureKit with a desktop-independent dedicated-window filter.

Require:

- cursor excluded;
- complete frames only;
- BGRA capture;
- bounded queue depth;
- no application-level unbounded frame queue;
- default capture target 30 fps;
- normalized source-relative crop `(x,y,width,height)` in `[0,1]`;
- source rect recomputed after resize/reacquire;
- helper-local bounded scale to declared Push destination dimensions;
- top-to-bottom output rows;
- B,G,R,A output bytes with alpha forced to `0xFF` before transmission;
- destination rectangle entirely inside 960x160.

Fixture/development arguments may supply owner bundle ID, exact title, source role, crop, destination, fps, V1D-2 port, and token-file path. They are not the future public adapter SDK.

## Screen Recording permission

Use normal public macOS permission APIs only.

- preflight permission before starting capture;
- denied/unavailable permission publishes no frame and clears any current external authority when possible;
- emit one bounded actionable error;
- do not impair Bitwig, DrivenByMoss, controls, or audio;
- after permission is granted, relaunch of the same exact helper build is acceptable when macOS requires it;
- no private TCC manipulation and no silent permission reset.

## Accepted protocol producer

The helper must speak accepted V1D-2 protocol v1 exactly.

- connect only to the configured IPv4 loopback endpoint;
- read the private token file without logging the capability;
- one nonzero 128-bit session per connection;
- HELLO once;
- positive strictly increasing FRAME/CLEAR sequence;
- complete opaque BGRA payloads only;
- send CLEAR on transition to missing/ambiguous/closed source where possible;
- receiver disconnect/failure stops boundedly rather than accumulating frames;
- no protocol-v2 or alternate Push path.

## Lifecycle proof

For both accepted source classes where physically possible:

1. unique source discovery;
2. real captured pixels visible on Push;
3. move substantially on same display;
4. resize smaller and larger;
5. verify normalized crop follows source geometry;
6. close -> current semantic-only output;
7. reopen -> reacquire new instance and resume;
8. obscure window and verify dedicated-window capture remains coherent where ScreenCaptureKit supports it;
9. move between displays when two displays exist, otherwise retain explicit no-claim;
10. induce or identify ambiguity when safely possible and prove abstention.

Wrong visual capture is a blocker.

## Correctness evidence

Retain hashes and metadata rather than proprietary frame files.

For each target retain:

- logical descriptor;
- windowID lifecycle;
- source dimensions;
- normalized crop and computed source rect;
- destination rect;
- capture pixel format and bytes-per-row;
- cropped/output hashes;
- protocol sequences;
- capture/publish timing;
- lifecycle outcomes.

Require zero unexplained:

```text
wrong-window captures
frames after source authority loss
stale pixels after CLEAR/close/permission denial
crop-out-of-bounds events
row/channel/alpha mismatches
partial/torn protocol output
old-window-instance frames after reacquire
helper failures affecting Bitwig/Push
```

Do not commit proprietary screenshots or raw captured frames.

## Performance

Measure capture delivery separately from helper processing.

After warmup, retain at least 1,000 complete frames per serious 30-fps target where practical for:

- ScreenCaptureKit callback interval;
- pixel-buffer access;
- crop/scale preparation;
- BGRA/alpha-normalization copy;
- protocol header build;
- loopback send;
- helper capture-to-send processing;
- V1D-2 supersession/dropped-frame observations where available.

Test 15 fps and 30 fps. Test 60 fps when stable; 60 fps is not required for acceptance.

Targets:

```text
helper capture-to-ready processing p95 <= 10 ms at 30 fps
helper copy/normalize/send p95 <= 2 ms at 30 fps
no unbounded backlog or frame-memory growth
```

Retain CPU, RSS/resident growth, dropped/late-frame counts, and distinguish source cadence from processing latency.

## Real fixture

Use the exact accepted V1D-2 DrivenByMoss integration artifact or an exact rebuild from accepted `pushwig/main`; do not modify it.

Prove:

- Push connection, pads, pressure/MPE, encoders, transport;
- Push audio device and audible headphones;
- current semantic UI remains correct under/around the lens;
- useful native-device pixels on Push;
- useful plug-in pixels on Push;
- no accidental whole-desktop capture;
- move/resize/close/reopen and permission/missing/ambiguity fallback;
- helper exit/crash returns to semantics through accepted ingress behavior;
- no trail, stale block, torn frame, wrong source, control lag, abnormal display lag, xrun, or dropout;
- normal helper and Bitwig shutdown.

After live testing restore the exact official DrivenByMoss artifact as the sole scanned extension and physically confirm standard display, controls, and audio.

## Evidence output

Create only:

```text
evidence/v2-macos-dedicated-window/
├── README.md
├── source-topology.md
├── helper-build-and-identity.md
├── window-discovery-and-lifecycle.md
├── capture-pixel-contract.md
├── native-device-result.md
├── plugin-result.md
├── permission-and-fallback.md
├── performance.md
└── real-fixture-and-rollback.md
```

Retain exact source PR/head/tree, helper build identity, permission identity, target descriptors, window lifecycle, crop/destination metadata, hashes, timing, CPU/memory, real Push behavior, and rollback.

## Non-goals

No DrivenByMoss changes; no embedded Bitwig-panel resolver; no pixel-anchor matching; no public visual adapter SDK; no persistent calibration database; no mouse automation; no plug-in control automation; no Linux/Steam Deck capture; no remote network ingress; no private WindowServer/TCC APIs; no second Push bitmap or USB writer; no appliance/CM11EB work.

## Completion posture

V2 is complete only when both exact source/evidence PR heads exist, one floating native-device window and one ordinary plug-in editor produce useful real captured pixels on Push through unchanged V1D-2, permission and lifecycle fallback are correct, wrong/ambiguous sources abstain, helper processing is bounded, Push controls/audio remain normal, and the exact official DrivenByMoss artifact is restored.