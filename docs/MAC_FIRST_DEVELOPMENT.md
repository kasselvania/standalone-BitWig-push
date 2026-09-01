# Mac-First Software Development Fixture

## Decision

The active Track V development fixture is the maintainer's macOS computer running Bitwig Studio, the `kasselvania/DrivenByMoss` derivative, and Push 3 Controller over ordinary USB.

This changes implementation order, not the product definition:

- macOS provides the fastest available source/build/install/measurement loop;
- the Steam Deck remains the first Track A appliance host and the named Linux portability fixture;
- compositor, visual-frame, resolver, and adapter contracts remain operating-system neutral;
- no ScreenCaptureKit, Core Graphics, or other macOS type may leak into controller-extension or public frame contracts.

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
        -> same IBitmap
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

### V1C-0 — dynamic restoration decision

Accepted research selected:

```text
newest copied ModelInfo
        -> complete current-semantic redraw
        -> current valid visual or no visual
        -> same persistent IBitmap
        -> unchanged PushUsbDisplay
```

It produced zero outside, old-region, disappearance, stale, invalid, and semantic-update mismatch counts.

Real-Bitwig restore-plus-compose measured:

```text
p50       0.275166 ms
p95       0.413209 ms
maximum   7.356958 ms
```

The real Push control/display/audio lifecycle and exact official rollback passed.

## Why V1C remains local

The next source slice is production V1C, not external IPC.

V1C proves the accepted restoration ownership with a bounded local state machine:

```text
A
B moved/enlarged with overlap
C moved/reduced
D replacement
NONE
STALE
INVALID
```

This isolates:

- newest-model retention;
- current semantic redraw;
- movement and overlap;
- size changes;
- disappearance and invalidity;
- overlay-only updates;
- notification lifecycle;
- default and V1B regressions;
- exact cost and allocations.

Only after those production behaviors are accepted should another process be allowed to supply visual pixels.

## Current Mac task: V1C

V1C implements:

```text
newest copied ModelInfo
        -> retain before redraw decision
        -> full semantic redraw only for dynamic-local selection
        -> zero or one current local visual
        -> same bitmap
        -> one USB send
```

The expected source envelope is:

```text
AbstractGraphicDisplay.java
Push2Display.java
DynamicLocalPushFramePipeline.java
```

The ordinary display framework keeps its dirty-render behavior because the new redraw hook defaults false.

The selected dynamic Push path alone requests current-model redraw every eligible send.

See [`V1C_DYNAMIC_LOCAL_COMPOSITION.md`](V1C_DYNAMIC_LOCAL_COMPOSITION.md).

## Property matrix

The Mac fixture must prove:

```text
no property
    -> pass-through

pushwig.syntheticOverlay=true
    -> accepted fixed V1B diagnostic

pushwig.dynamicLocalVisual=true
    -> V1C dynamic lifecycle

both true
    -> V1C dynamic lifecycle only
```

Properties are read before controller construction, not polled per frame.

## Semantic edge cases

### Overlay-only update

`ModelInfo.equals/hashCode` omit overlays.

V1C retains the newest copied model before its render decision, then forces current-model redraw in dynamic mode.

The Mac fixture must prove that an overlay-only update appears even when equality-covered state is stable.

### Notification lifecycle

The Mac fixture must prove:

```text
notification appears
        -> visual moves/disappears
        -> current notification remains correct
        -> notification replaces/expires
        -> underlying semantics return
```

No stale visual or notification pixels may remain.

## What can still be proven on Mac before the Deck returns

The Mac fixture can establish:

1. production dynamic local composition;
2. immutable/latest-frame-wins external ingress;
3. macOS dedicated-window capture;
4. one useful floating Bitwig native-device or plug-in lens;
5. a local semantic-seeded anchor benchmark;
6. most attached-mode user behavior.

The Mac fixture cannot establish:

- Linux X11/Wayland/portal capture behavior;
- Flatpak IPC boundaries;
- Steam Deck performance, power, battery, headless boot, or managed geometry;
- Linux support claims.

Those remain explicit second-host slices.

## Current source posture

Accepted controller-extension source:

```text
repository: kasselvania/DrivenByMoss
branch:     pushwig/main
commit:     1ae0b74f383314d170a5960ca763bdf9c319e787
tree:       a81e5c4330b31f36845c25e98e322990d62f0c67
```

Accepted V1C-0 evidence:

```text
repository: kasselvania/standalone-BitWig-push
commit:     c6ccc72c315bac85af53a0c2942a191a1e40e0d3
tree:       9b1dddab50519a06b54ea873f5c07f18197238c6
```

Active issue:

[#23 — V1C: Implement dynamic local visual composition lifecycle](https://github.com/kasselvania/standalone-BitWig-push/issues/23)

## Revised Track V sequence

```text
S0      accepted fixture and display seam
V1A-0   accepted fork/build/install baseline
V1A     accepted identity frame pipeline
V1B     accepted static bounded synthetic pixels
V1C-0   accepted dynamic restoration architecture
V1C     active production dynamic local composition
V1D     external generated-frame ingress
V2      macOS dedicated-window capture
V2A     semantic-seeded pixel-anchor benchmark
V2P     Linux/Steam Deck second-host checkpoint
```

## Future external-frame posture

After V1C proves production movement/removal/fallback, a separate helper may publish a platform-neutral frame:

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
- controller extension never waits for capture.

That protocol is V1D.

External absence, stale sequence, invalid metadata, producer restart, permission denial, and resolver abstention must consume the V1C fallback:

```text
current semantic redraw
        -> no visual draw
        -> semantic-only Push output
```

## macOS capture constraints

Window capture eventually requires explicit system permission. Permission denial or revocation must produce exact semantic-only fallback through V1C.

The capture helper should be a normal macOS application so that:

- permission has a stable application identity;
- the user can inspect/revoke it in System Settings;
- window and capture lifecycle are observable;
- the Bitwig extension host does not embed platform capture code.

Dedicated top-level windows remain the first capture target. Embedded-panel resolution and pixel anchors remain later work.

## Portability guardrails

Mac-first does not mean Mac-shaped architecture.

Mandatory:

- no macOS window/image handle in compositor or frame contract;
- visual adapters identify semantic roles and source-relative geometry, not physical desktop coordinates;
- local generated tests exercise composition without capture;
- missing/stale/invalid visual input restores exact current semantics;
- Linux and later Windows backends can implement the same frame contract;
- Steam Deck validation is required before a Linux support claim.

## Result

The Mac has proven the display seam, first project-owned pixels, and exact restoration ownership.

V1C now hardens that ownership into production source before the project crosses a process boundary.

The Steam Deck then receives the same contracts as a Linux portability and appliance deployment rather than becoming the machine on which core visual semantics are invented.
