# Mac-First Software Development Fixture

## Decision

The active Track V development fixture is the maintainer's macOS computer running Bitwig Studio, the `kasselvania/DrivenByMoss` derivative, and Push 3 Controller over ordinary USB.

This changes implementation order, not the product definition:

- macOS provides the fastest available source/build/install/measurement loop;
- the Steam Deck remains the first Track A appliance host and the named Linux portability fixture;
- compositor, visual-frame, resolver, and adapter contracts remain operating-system neutral;
- no ScreenCaptureKit, Core Graphics, or other macOS type may leak into the controller-extension or public frame contracts.

## Accepted progress on the Mac fixture

### S0 — exact fixture and display path

Accepted evidence established:

- Bitwig Studio 6.1 and Push 3 controls/audio/display on the real fixture;
- official DrivenByMoss 26.4.1 artifact and exact upstream source;
- persistent 960×160 semantic bitmap;
- `Push2Display.send(IBitmap)` to `PushUsbDisplay.send(IBitmap)` seam;
- unchanged USB interface/endpoint ownership.

### V1A-0 — derivative custody and build

Accepted evidence established:

- true `kasselvania/DrivenByMoss` fork;
- immutable upstream basis and project integration branch;
- explicit Java 21/Maven build environment;
- reversible extension installation;
- full real-device parity;
- exact official-artifact rollback.

### V1A — identity frame pipeline

Accepted source established:

```text
complete semantic IBitmap
        -> PushFramePipeline
        -> exact same IBitmap
        -> unchanged PushUsbDisplay
```

### V1B — static bounded pixels

Accepted source and evidence established:

```text
startup property off -> pass-through
startup property on  -> one fixed bounded render callback
                       -> same IBitmap
                       -> unchanged PushUsbDisplay
```

The concrete bitmap comparison observed zero outside-region changes. The real Push, controls, audio, representative modes, shutdown, recovery, and rollback passed.

## Why the next Mac task is not IPC

The semantic display uses one persistent bitmap. `AbstractGraphicDisplay` redraws it only when `ModelInfo` changes, then sends the bitmap on every eligible update.

A fixed mark can be redrawn at the same coordinates indefinitely. A changing visual cannot safely rely on that historical bitmap:

```text
old visual at R1
new visual at R2
no visual
```

Without an explicit restoration model, `R1` can remain contaminated after the visual moves or disappears.

The same failure would occur when:

- a helper process exits;
- capture permission is revoked;
- a plug-in editor closes;
- the selected device changes;
- an anchor lock becomes ambiguous;
- an external frame becomes stale.

Therefore the Mac fixture now executes V1C-0 before external-frame ingress.

## V1C-0 — dynamic raster composition research

V1C-0 selects one exact lifecycle:

### Candidate A — redraw retained semantic state

```text
retained current ModelInfo
        -> full semantic redraw
        -> current visual
        -> unchanged transport
```

This is tested first because `ModelInfo` retains copied components and overlays. The prototype must prove current-value fidelity, exact restoration, Push-specific scope, and cost.

### Candidate B — pristine semantic bitmap plus reusable final bitmap

```text
semantic bitmap
        -> reusable full-frame copy/blit
        -> reusable final bitmap
        -> current visual
        -> unchanged transport
```

This is the preferred ownership model if the Bitwig graphics wrapper can expose a clean, host-neutral bitmap blit and the measured cost is practical.

### Candidate C — generation-aware region restore

This is acceptable only with an explicit semantic-generation rule. A snapshot captured before a semantic change may never be restored over newer semantics.

### Candidate D — narrow backend copy

A Bitwig memory-copy adapter is a fallback. It must remain behind a platform-neutral interface and declare pixel format, dimensions, bounds, allocation, and ownership.

See [`V1C0_DYNAMIC_RASTER_COMPOSITION.md`](V1C0_DYNAMIC_RASTER_COMPOSITION.md).

## What can still be proven on Mac before the Deck returns

The Mac fixture can establish:

1. exact dynamic restoration/frame ownership;
2. moving/replaced/absent/stale local generated visuals;
3. external immutable/latest-frame-wins ingress;
4. macOS dedicated-window capture;
5. one useful floating Bitwig native-device or plug-in lens;
6. a local semantic-seeded anchor benchmark;
7. most user-facing visual-mode behavior.

The Mac fixture cannot establish:

- Linux X11/Wayland/portal capture behavior;
- Flatpak IPC boundaries;
- Steam Deck performance, power, battery, headless boot, or managed geometry;
- Linux support claims.

Those remain explicit second-host slices.

## Current source and process posture

Accepted controller-extension source:

```text
repository: kasselvania/DrivenByMoss
branch:     pushwig/main
commit:     1ae0b74f383314d170a5960ca763bdf9c319e787
tree:       a81e5c4330b31f36845c25e98e322990d62f0c67
```

Accepted authority/evidence source:

```text
repository: kasselvania/standalone-BitWig-push
main:       95d93e262c33163783e23a8d3e66f6f92746918d
```

V1C-0 does not merge production source. It uses temporary prototype worktrees and retains hashes, changed paths, build results, pixel comparisons, performance, real-fixture results, rollback, and a final architecture decision in the central repository.

## Revised Track V sequence

```text
S0      accepted fixture and display seam
V1A-0   accepted fork/build/install baseline
V1A     accepted identity frame pipeline
V1B     accepted static bounded synthetic pixels
V1C-0   active dynamic restoration/ownership selection
V1C     production dynamic local composition lifecycle
V1D     external generated-frame ingress
V2      macOS dedicated-window capture
V2A     semantic-seeded pixel-anchor benchmark
V2P     Linux/Steam Deck second-host checkpoint
```

## Future external-frame posture

After V1C proves dynamic replacement/removal/fallback, a separate native macOS helper may publish a platform-neutral frame:

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

Leading local transport remains:

- control/status over a Unix-domain socket;
- latest-frame storage in shared memory or a memory-mapped file;
- sequence-based latest-frame-wins behavior;
- no unbounded queue;
- compositor never waits for capture.

That protocol is V1D, not V1C-0.

## macOS capture constraints

Window capture eventually requires explicit system permission. Permission denial or revocation must produce exact semantic-only fallback through the already-proven dynamic lifecycle.

The capture helper should be a normal macOS application so that:

- permission has a stable application identity;
- the user can inspect/revoke it in System Settings;
- window and capture lifecycle are observable;
- the Bitwig extension host does not embed platform capture code.

Dedicated top-level windows remain the first capture target. Embedded-panel resolution and pixel anchors remain later work.

## Portability guardrails

Mac-first does not mean Mac-shaped architecture.

The following remain mandatory:

- no macOS window/image handle in the compositor or frame contract;
- visual adapters identify semantic roles and source-relative geometry, not physical desktop coordinates;
- local generated-frame tests can exercise the compositor without a capture helper;
- missing/stale/invalid visual input restores current semantic output exactly;
- Linux and later Windows backends can implement the same frame contract;
- Steam Deck validation remains required before a Linux support claim.

## Result

The Mac has already proven the display seam and first visible project-owned pixels. It now determines the exact restoration ownership needed to turn that static success into a safe live visual system.

The Steam Deck then receives the same contracts as a Linux portability and appliance deployment rather than becoming the machine on which core visual semantics are invented.