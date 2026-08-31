# Mac-First Software Development Fixture

## Decision

The active Track V development fixture is the maintainer's macOS computer running Bitwig Studio, DrivenByMoss, and Push 3 Controller over ordinary USB.

This changes the order of implementation, not the product definition:

- macOS becomes the fastest available environment for tracing and cutting the display pipeline;
- the Steam Deck remains the maintainer's first Track A appliance host and a later Linux portability fixture;
- the universal visual/controller contracts remain operating-system neutral;
- no macOS-specific type is allowed to leak into the compositor, resolver, or visual-adapter contracts.

S0 is now accepted and merged. The active V1A-0 gate establishes the DrivenByMoss fork and proves a clean local build, reversible installation, real-device parity, and exact rollback before the first behavioral source change.

The Deck being temporarily unavailable is not a blocker for V1A-0, V1, the first dedicated-window visual proof, or the offline pixel-anchor benchmark.

## Why macOS is a strong first implementation host

The maintainer already has a working Bitwig + DrivenByMoss + Push setup on macOS. That provides a shorter loop for:

- building and installing a DrivenByMoss derivative;
- attaching debuggers and profilers;
- tracing frame construction;
- testing USB reconnect and shutdown behavior;
- iterating on the compositor seam;
- generating deterministic test frames;
- developing a native window-capture helper;
- collecting visual fixtures for the resolver benchmark.

S0 cryptographically identified the installed DrivenByMoss 26.4.1 artifact, matched it byte-for-byte to the official distribution, and pinned upstream tag `26.4.1`, commit `fd03245ab38fa5149c45934051d937ee9fda6d08`, tree `edd2ad636b0aa1f39919f0ffd05c968015450075`.

## What can be proven before returning to the Deck

The Mac fixture can establish:

1. the exact semantic-renderer-to-USB path;
2. a clean fork/build/install/rollback baseline for the pinned upstream source;
3. a no-op frame-pipeline seam with pixel-equivalent output;
4. a synthetic overlay mixed into the live DrivenByMoss display;
5. a platform-neutral external-frame ingress contract;
6. a macOS dedicated-window capture backend;
7. a floating Bitwig native-device or plug-in visual lens;
8. a local fixture corpus and pixel-anchor benchmark;
9. most of the user-facing visual-mode behavior.

The Mac fixture cannot by itself establish:

- Linux X11/Wayland/portal behavior;
- Flatpak IPC and USB constraints;
- Steam Deck power, performance, headless boot, or battery operation;
- managed appliance geometry on SteamOS;
- Linux portability claims.

Those become explicit later validation slices rather than prerequisites for the first software cut.

## Confirmed upstream display path and leading cut

S0 confirmed this exact shape for DrivenByMoss 26.4.1:

```text
DrivenByMoss modes/views
        -> semantic graphic display rendering
        -> persistent IBitmap (960x160 ARGB32)
        -> Push2Display.send(IBitmap)
        -> PushUsbDisplay.send(IBitmap)
        -> bitmap encode / 16-bit pixel conversion / scan-line padding
        -> XOR signal shaping
        -> Push USB interface 0 / endpoint 0x01
```

Push 3 intentionally uses the modern graphic-display branch implemented by `Push2Display` and `PushUsbDisplay`.

The accepted narrow cut is inside `Push2Display.send(IBitmap)`, immediately before transport-specific encoding:

```text
semantic IBitmap
        -> PushFramePipeline
             +-- semantic/base frame
             +-- optional validated visual layer snapshot
             +-- composition policy
        -> PushDisplayTransport
        -> existing Push USB protocol implementation
```

### Why this cut

It preserves:

- all existing DrivenByMoss semantic rendering;
- the current working MIDI/control model;
- the known USB transport;
- one steady-state display writer;
- a small upstream fork delta.

It creates:

- a testable frame boundary;
- a place to mix synthetic or captured pixels;
- a platform-neutral frame contract;
- a path to later move capture outside Bitwig without moving USB ownership immediately.

## DrivenByMoss implementation repository

The controller-extension delta belongs in a proper `kasselvania/DrivenByMoss` fork, not as copied source inside the central project repository.

Before V1A changes behavior, V1A-0 must prove:

```text
exact accepted upstream commit
        -> clean Java 21 / Maven build
        -> locally built .bwextension
        -> reversible temporary installation
        -> full S0 behavioral parity
        -> exact official-artifact restoration
```

See [`DRIVENBYMOSS_DERIVATIVE_STRATEGY.md`](DRIVENBYMOSS_DERIVATIVE_STRATEGY.md).

## First implementation posture: in-process composition, external capture

The lowest-risk first proof keeps final display composition and USB transmission inside the DrivenByMoss derivative.

```text
macOS capture helper --------------------+
                                         |
DrivenByMoss semantic IBitmap             v
        -> in-process PushFramePipeline <- external VisualSourceFrame snapshot
        -> existing Push USB transport
```

This avoids two processes fighting over the Push display interface.

The capture helper should be a normal macOS application/service, likely written in Swift, responsible for:

- Screen Recording permission lifecycle;
- enumerating Bitwig and editor windows;
- capturing a selected window or source-relative region;
- publishing a platform-neutral `VisualSourceFrame`;
- reporting missing, denied, stale, and recreated-window states.

The helper must not control Bitwig parameters and must not sit on the audio or controller-input path.

## Frame and IPC boundary

The first external-frame contract should remain simple:

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

Recommended early transport:

- control/status over a Unix-domain socket;
- latest-frame storage in shared memory or a memory-mapped file;
- sequence-based, latest-frame-wins semantics;
- no unbounded queue;
- compositor never waits for a capture frame.

The exact IPC implementation is a slice decision. The contract, not POSIX or macOS handles, is architectural authority.

## Proposed slice sequence

### M0 / S0 — Mac fixture and display trace — complete

The working Mac setup, exact artifact/source pin, real Push baseline, concrete frame path, and identity seam are retained under `evidence/s0-macos-reference-fixture/`.

### V1A-0 — Fork and local build baseline — active

Create/verify the DrivenByMoss fork, build the exact unmodified 26.4.1 source, install it reversibly, rerun the accepted hardware checklist, and restore the exact official artifact.

This isolates source-build and installation uncertainty from frame-pipeline uncertainty.

### V1A — No-op frame pipeline

Insert the frame-pipeline abstraction without changing visible output.

Acceptance includes:

- exact object-identity pass-through;
- before/after frame hashes or retained pixel-equivalence evidence;
- no control/audio regression;
- no additional USB owner;
- bounded allocation and timing behavior.

### V1B — Synthetic composition

Draw a project-owned moving shape, test strip, or diagnostic overlay over the semantic frame.

This is the first proof that the project can mix pixels without screen capture.

### V1C — External frame ingress

A tiny helper publishes generated test frames through the platform-neutral IPC boundary. The DrivenByMoss derivative composites them without any Bitwig-window capture.

This separates IPC/composition errors from capture-permission and window-discovery errors.

### V2M — macOS dedicated-window capture

Use the macOS capture backend to discover and capture one dedicated Bitwig native-device/floating view or plug-in editor.

Preferred first target remains a floating Expanded Device View, ideally Sampler, if the installed Bitwig version exposes it suitably.

### V2A — semantic-seeded pixel anchor benchmark

Use locally captured Mac fixture frames to benchmark flattened pixels, grayscale/edge correlation, multi-scale search, multi-anchor geometry, false locks, and compute cost.

### V2P — second-host portability checkpoint

After the first useful Mac lens exists, port the relevant transport/capture backend to a Linux fixture, preferably the Steam Deck when available.

This checkpoint proves that:

- the compositor and adapter schema were not accidentally macOS-specific;
- only the capture/backend and host integration layers need replacement;
- the same semantic/visual acceptance test can run on a second host.

## macOS-specific capture constraints

Window capture requires explicit system permission. Permission denial or revocation must produce semantic fallback, not a broken controller.

The capture helper should be packaged as a normal macOS application so that:

- the permission request has a stable application identity;
- the user can see and revoke access in System Settings;
- capture lifecycle and errors are observable;
- Bitwig's extension host does not need to embed platform capture code.

The first capture implementation should prefer a dedicated window. Embedded Bitwig-panel resolution and anchor matching remain separate later problems.

## Portability guardrails

Mac-first does not mean Mac-shaped architecture.

The following remain mandatory:

- `VisualSourceFrame` contains no `SCWindow`, `CGWindowID`, `CVPixelBuffer`, or other platform handle;
- the compositor contains no ScreenCaptureKit code;
- visual adapters identify semantic roles and source-relative geometry, not macOS desktop coordinates;
- the frame pipeline can accept a synthetic source in tests;
- semantic fallback works with no capture helper installed;
- Linux and later Windows backends can implement the same contracts;
- Steam Deck validation remains a named portability checkpoint before a Linux support claim.

## Result

The Mac can carry the project through the most important early software work:

```text
understand the existing renderer
        -> prove the derivative build/install baseline
        -> insert a safe frame pipeline
        -> mix project-owned pixels
        -> accept external frames
        -> capture a real Bitwig window
        -> benchmark semantic-seeded anchors
```

The Steam Deck then becomes a second-host and appliance deployment, rather than the machine that must be free before any software work can begin.
