# Mac-First Software Development Fixture

## Decision

The active Track V development fixture is the maintainer's macOS computer running Bitwig Studio, the project DrivenByMoss derivative, and Push 3 Controller over ordinary USB.

This changes the order of implementation, not the product definition:

- macOS is the fastest available environment for source-level display work;
- the Steam Deck remains the maintainer's first Track A appliance host and a later Linux portability fixture;
- universal visual/controller contracts remain operating-system neutral;
- no macOS-specific type is allowed to leak into the compositor, resolver, or visual-adapter contracts.

The Mac has now carried the project through the real baseline, exact source/build custody, and first functional frame seam. It can also prove bounded synthetic composition, external generated-frame ingress, the first dedicated-window capture backend, and the offline pixel-anchor benchmark before the Deck becomes available.

## Accepted fixture and source state

### S0 — accepted

S0 retained:

- macOS 26.4.1 / arm64 fixture;
- Bitwig Studio 6.1;
- real Push 3 control, display, and audio behavior;
- official DrivenByMoss 26.4.1 artifact SHA-256;
- exact upstream tag, commit, and tree;
- complete semantic-renderer-to-USB path;
- lawful cut inside `Push2Display.send(IBitmap)`.

### V1A-0 — accepted

V1A-0 retained:

- true `kasselvania/DrivenByMoss` fork;
- immutable `pushwig/upstream-26.4.1` basis;
- explicit Java 21/Maven build;
- bounded local-vs-official artifact differences;
- reversible sole-artifact installation;
- all eleven real Push checks;
- exact official rollback.

### V1A — accepted

V1A merged the first project-owned source seam into `pushwig/main`:

```text
integration commit: 033ccef8c64f08e8d8d41fa90d48fa06b326a1a1
integration tree:   9aec7429ff093addee001a62a5a07309708fd592
```

Accepted path:

```text
complete semantic IBitmap
        -> PassThroughPushFramePipeline.INSTANCE
        -> exact same IBitmap
        -> unchanged PushUsbDisplay
```

The real fixture passed without any visible change, and the official artifact was restored exactly.

## What the Mac can prove before returning to the Deck

The Mac fixture can establish:

1. the exact semantic-renderer-to-USB path — complete;
2. derivative fork/build/install/rollback baseline — complete;
3. identity frame-pipeline seam — complete;
4. bounded synthetic overlay on the semantic bitmap — active;
5. platform-neutral external-frame ingress;
6. macOS dedicated-window capture backend;
7. floating Bitwig native-device or plug-in visual lens;
8. local fixture corpus and pixel-anchor benchmark;
9. most user-facing visual-mode behavior.

The Mac fixture cannot by itself establish:

- Linux X11/Wayland/portal behavior;
- Flatpak IPC and USB constraints;
- Steam Deck power, performance, headless boot, or battery operation;
- managed appliance geometry on SteamOS;
- Linux portability claims.

Those remain explicit later validation slices rather than prerequisites for the first software implementation.

## Confirmed display path

The accepted DrivenByMoss line is:

```text
DrivenByMoss modes/views
        -> semantic graphic display rendering
        -> persistent IBitmap (960×160 ARGB32)
        -> Push2Display.send(IBitmap)
        -> PushFramePipeline
        -> PushUsbDisplay.send(IBitmap)
        -> 16-bit conversion / scan-line padding / XOR shaping
        -> Push USB interface 0 / endpoint 0x01
```

The project seam is after semantic rendering and before transport-specific encoding. `PushUsbDisplay` remains the single endpoint owner.

## V1B: the first visible-pixel proof

V1B tests a second render callback against the persistent semantic bitmap.

Default startup:

```text
property absent
        -> PassThroughPushFramePipeline.INSTANCE
```

Diagnostic startup:

```text
-Dpushwig.syntheticOverlay=true
        -> SyntheticOverlayPushFramePipeline.INSTANCE
        -> one fixed bounded two-color mark
        -> same IBitmap
        -> unchanged PushUsbDisplay
```

The exact same artifact must support both startup states.

### Why the mark is fixed

DrivenByMoss reuses one bitmap and only rebuilds semantic pixels when its model changes. A moving mark could leave stale pixels when the previous location is not redrawn. A runtime-off toggle has the same erasure problem.

V1B therefore proves one fact at a time:

- a second callback can paint;
- the rest of the semantic bitmap is preserved;
- repeated sends are stable;
- semantic mode changes remain correct;
- restarting without the property removes the mark.

Animation, hot switching, frame restoration, and external pixels remain separate.

### Why startup activation is preferred

A Java system property is:

- read once;
- platform-neutral inside the extension;
- absent in ordinary operation;
- reversible through process restart;
- narrower than adding a new DrivenByMoss settings surface.

If the property cannot reach the controller-extension process, the experiment must stop before choosing another mechanism.

### Evidence available on the Mac

The Mac fixture supports:

- the physical Push display;
- DrivenByMoss's existing debug bitmap window;
- local screen/image analysis without committing proprietary frames;
- Java bytecode inspection;
- temporary uncommitted timing or bitmap-observation instrumentation;
- process launch with controlled environment;
- precise extension installation and rollback.

V1B should use those capabilities to prove that only the declared target rectangle changes and to measure the additional render cost.

See [`V1B_SYNTHETIC_COMPOSITION.md`](V1B_SYNTHETIC_COMPOSITION.md).

## First implementation posture: in-process composition, external capture

The lowest-risk architecture keeps final display composition and USB transmission inside the DrivenByMoss derivative.

```text
future macOS capture helper ---------------+
                                           |
DrivenByMoss semantic IBitmap               v
        -> in-process PushFramePipeline <- latest VisualSourceFrame
        -> existing Push USB transport
```

This avoids two processes fighting over the Push display interface.

The later capture helper should be a normal macOS application/service responsible for:

- Screen Recording permission lifecycle;
- enumerating Bitwig and editor windows;
- capturing a selected window or source-relative region;
- publishing a platform-neutral `VisualSourceFrame`;
- reporting missing, denied, stale, and recreated-window states.

The helper must not control Bitwig parameters and must not sit on the audio or controller-input path.

## Future frame and IPC boundary

The first external-frame contract should remain platform-neutral:

```text
VisualSourceFrame
  source_id
  source_role
  width
  height
  pixel_format
  sequence
  timestamp
  validity
  stale_reason
  confidence
  frame_data
  optional_metadata
```

Recommended early transport remains:

- control/status over a Unix-domain socket;
- latest-frame storage in shared memory or a memory-mapped file;
- sequence-based, latest-frame-wins semantics;
- no unbounded queue;
- compositor never waits for a capture frame.

The exact IPC implementation belongs to V1C. V1B adds no IPC or external frame.

## Slice sequence

### S0 — Mac fixture and display trace — complete

Retained under `evidence/s0-macos-reference-fixture/`.

### V1A-0 — fork and local build baseline — complete

Retained under `evidence/v1a0-drivenbymoss-build-baseline/`.

### V1A — identity frame pipeline — complete

Retained under `evidence/v1a-identity-frame-pipeline/` and merged into `pushwig/main`.

### V1B — static synthetic composition — active

Prove one startup-scoped fixed mark, outside-region preservation, repeated-send stability, representative semantic updates, bounded cost, property-off recovery, real Push behavior, and exact rollback.

### V1C — external generated-frame ingress

A helper publishes generated `VisualSourceFrame` data through a platform-neutral latest-frame boundary. The DrivenByMoss derivative consumes it without window capture.

### V2M — macOS dedicated-window capture

Use a macOS capture backend to discover and capture one floating native-device view or plug-in editor.

### V2A — semantic-seeded pixel-anchor benchmark

Use local fixture frames to compare flattened-pixel, grayscale/edge correlation, multi-scale search, multi-anchor geometry, false locks, and compute cost.

### V2P — Linux/Steam Deck portability checkpoint

Port the accepted contracts and one useful visual lens to Linux, preferably the Steam Deck when available.

## macOS-specific capture constraints

Window capture requires explicit system permission. Permission denial or revocation must produce semantic fallback, not a broken controller.

The capture helper should be packaged as a normal macOS application so that:

- the permission request has a stable application identity;
- the user can see and revoke access in System Settings;
- capture lifecycle and errors are observable;
- Bitwig's extension host does not need to embed platform capture code.

These constraints begin in V2M, not V1B.

## Portability guardrails

Mac-first does not mean Mac-shaped architecture.

The following remain mandatory:

- no `SCWindow`, `CGWindowID`, `CVPixelBuffer`, or other platform handle in core frame contracts;
- no ScreenCaptureKit code inside the compositor/controller extension;
- visual adapters identify semantic roles and source-relative geometry, not macOS desktop coordinates;
- the frame pipeline can accept synthetic sources in tests;
- semantic fallback works without a capture helper;
- Linux and later Windows backends can implement the same contracts;
- Steam Deck validation remains required before a Linux support claim.

## Result

The Mac development sequence is now:

```text
understand the existing renderer              complete
        -> prove source/build custody         complete
        -> insert identity frame seam         complete
        -> prove bounded in-place pixels      active
        -> accept external frames
        -> capture a real Bitwig window
        -> benchmark semantic anchors
```

The Steam Deck remains a second-host and appliance deployment rather than a prerequisite for the first software breakthroughs.