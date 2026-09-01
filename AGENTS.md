# AGENTS.md — Repository Execution Rules

## Mission

Build an open, inspectable adaptive visual/controller layer for Ableton Push 3 and Bitwig Studio, then reuse that software in optional portable-appliance and native-compute projects.

The repository coordinates three independent tracks:

1. universal visual/controller integration;
2. all-in-one appliance packaging;
3. CM11EB connector and native-compute research.

The active Track V reference fixture is the maintainer's macOS Bitwig/DrivenByMoss/Push system because it provides the shortest software loop. The Steam Deck remains the first Track A appliance host and a later Linux portability fixture. Neither computer defines the universal product.

## Authority order

When instructions conflict, use this order:

1. `AGENTS.md`
2. `CURRENT_SLICE.md`
3. `docs/PROJECT_TRACKS.md`
4. `docs/ARCHITECTURE.md`
5. `docs/MAC_FIRST_DEVELOPMENT.md`
6. `docs/DRIVENBYMOSS_DERIVATIVE_STRATEGY.md`
7. `docs/V1C_DYNAMIC_LOCAL_COMPOSITION.md`
8. `docs/V1C0_DYNAMIC_RASTER_COMPOSITION.md`
9. `docs/V1B_SYNTHETIC_COMPOSITION.md`
10. `docs/VISUAL_PORTABILITY.md`
11. `docs/SEMANTIC_PIXEL_ANCHOR_RESOLVER.md`
12. `docs/ROADMAP.md`
13. `docs/RUNTIME_STRATEGY.md`
14. issue / PR scope
15. implementation convenience

A contributor or coding agent must stop and surface a conflict rather than quietly widening scope.

## Core invariants

- Bitwig remains the DAW and audio-engine authority.
- DrivenByMoss, or a compatible derivative, is the semantic Push/controller authority unless a slice explicitly proves a replacement.
- The Push display is a composited output. Semantic UI and project/captured pixels are different source classes and must remain distinguishable.
- Exactly one component owns the Push USB display endpoint in steady state.
- The first implementation keeps final composition and USB transport inside the DrivenByMoss derivative.
- Visual capture is visualization first. Do not make fragile mouse automation the primary control path when the Bitwig controller API can perform the operation.
- The universal visual product must support **attached mode**, adapting to a user's existing Bitwig windows and monitor layout.
- A canonical or virtual desktop is a **managed appliance/test mode**, not a requirement imposed on ordinary desktop users.
- Physical desktop coordinates must not be the primary identity of a visual source.
- Prefer dedicated top-level windows, semantic identity, window-relative geometry, normalized regions, anchors, and bounded calibration.
- Semantic device identity may seed visual matching, but a single template hit is not sufficient for a production lock.
- Anchor-based resolution must use confidence validation, competing-candidate margin, and preferably multiple anchors with consistent relative geometry.
- The resolver must prefer abstention and semantic fallback over displaying the wrong visual region.
- Capture backend and operating-system details do not belong in the compositor frame protocol.
- macOS capture types such as `SCWindow`, `CGWindowID`, and `CVPixelBuffer` must remain inside the macOS backend/helper.
- Visual failure must fall back safely to semantic control/display behavior.
- Semantic fallback means restoring the exact **current** semantic pixels. It does not mean merely stopping future visual drawing.
- Output must be conceptually derived from `current semantic frame + optional current visual`.
- Historical composed output is never semantic restoration authority.
- A moving, replaced, resized, absent, stale, or invalid visual must not leave pixels behind.
- The Mac and Steam Deck are reference hosts. Do not generalize maintainer-specific hardware, serialosc, plugdata, or yabridge state into universal requirements.
- yabridge/Wine compatibility is optional research and not a gate for the visual product or appliance.
- Monome/serialosc and plugdata/Pure Data are independent integrations that may consume project interfaces but do not own the core roadmap.
- The ordinary rear Push USB path is first-class and remains a valid appliance architecture.
- Battery operation is mandatory for a portable appliance claim; a wall-powered bench is only an engineering state.
- The appliance track and CM11EB hardware track must not block universal visual progress.
- Hardware claims require documentation, measurements, photographs, continuity evidence, or real enumeration. Mark inference as inference.
- Power and battery claims require measured voltage, current, negotiation, transition, runtime, and thermal evidence.
- Do not redistribute Bitwig Studio, Ableton software/firmware, proprietary Push assets, activation data, or other third-party binaries without redistribution rights.
- Do not casually redistribute proprietary UI screenshots/templates. Prefer local anchor generation, recipes, hashes, descriptors, or legally distributable fixtures.
- Upstream forks and dependencies retain their licenses and provenance.
- DrivenByMoss source changes live in the `kasselvania/DrivenByMoss` fork and must preserve upstream history and LGPL notices. Do not vendor that source into this repository.
- Every DrivenByMoss implementation slice must name an exact accepted commit/tree and must not silently move to a newer upstream basis.
- `pushwig/upstream-26.4.1` is the immutable accepted upstream basis.
- Project feature PRs target `pushwig/main`; do not merge implementation work into the immutable basis branch or upstream `master`.
- Central evidence/status work and DrivenByMoss source work are separate PRs with exact cross-references.

## Accepted source posture

Accepted DrivenByMoss integration branch:

```text
branch: pushwig/main
commit: 1ae0b74f383314d170a5960ca763bdf9c319e787
tree:   a81e5c4330b31f36845c25e98e322990d62f0c67
```

This merge contains exact accepted V1B source head:

```text
a2e0341b7bccfa4e6b13614f4adffc2235f785f4
```

Accepted default path:

```text
complete semantic IBitmap
        -> PassThroughPushFramePipeline.INSTANCE
        -> same IBitmap
        -> unchanged PushUsbDisplay
```

Accepted V1B diagnostic path:

```text
pushwig.syntheticOverlay=true
        -> SyntheticOverlayPushFramePipeline.INSTANCE
        -> one fixed bounded render callback
        -> same IBitmap
        -> unchanged PushUsbDisplay
```

Accepted V1C-0 production decision:

```text
newest copied ModelInfo
        -> retain before render decision
        -> complete semantic redraw for dynamic-local mode
        -> current valid local visual or no visual
        -> same persistent IBitmap
        -> unchanged PushUsbDisplay
```

`PushUsbDisplay` remains the sole transport owner.

## Slice discipline

Work in small, independently reviewable slices.

Every implementation slice states:

- basis and assumptions;
- one primary claim;
- files/components in scope;
- explicit non-goals;
- executable acceptance criteria;
- retained evidence required from real hardware or UI configurations.

A slice is complete only when its claim is demonstrably true.

Do not merge separate uncertainty domains merely because they are exciting. Examples:

- display-path tracing is separate from modifying the display path;
- fork/toolchain/build/install/rollback proof is separate from source modification;
- no-op frame-pipeline insertion is separate from synthetic composition;
- static painting is separate from dynamic restoration;
- restoration architecture selection is separate from production implementation;
- local dynamic composition is separate from external-frame IPC;
- external-frame IPC is separate from operating-system window capture;
- framebuffer ownership is separate from visual-source discovery;
- top-level-window capture is separate from embedded-panel resolution;
- semantic-seeded anchor benchmarking is separate from live resolver integration;
- attached desktop adaptation is separate from managed headless geometry;
- macOS proof is separate from Linux portability validation;
- all-in-one packaging is separate from connector research;
- yabridge experimentation is separate from native Bitwig/Push operation;
- external battery integration is separate from custom native-bay battery engineering.

## V1C production rules

V1C implements the accepted Candidate A model.

### Source custody

- Begin from exact accepted `kasselvania/DrivenByMoss:pushwig/main` at `1ae0b74f383314d170a5960ca763bdf9c319e787`.
- Do not cherry-pick the local V1C-0 research commit as production source.
- Reimplement from the accepted basis using retained research evidence as guidance.
- Expected production paths are exactly:
  - `AbstractGraphicDisplay.java`
  - `Push2Display.java`
  - `DynamicLocalPushFramePipeline.java`
- Stop before editing any additional production path.

### Semantic ownership

- `AbstractGraphicDisplay` continues to own one persistent bitmap.
- Every send constructs and retains the newest copied `ModelInfo` before the render decision.
- Add one protected redraw-request hook that defaults to false.
- Ordinary graphic displays retain their existing dirty-render behavior.
- Only selected dynamic-local Push mode requests a complete current-model redraw.
- Do not make `ModelInfo` public or mutate it asynchronously.
- Do not use historical pixels, region snapshots, or frame hashes as restoration authority.
- Because `ModelInfo.equals/hashCode` omit overlays, newest-model retention must occur even when equality-covered state is unchanged.

### Pipeline selection

Startup properties are read once.

```text
no properties
    -> pass-through

pushwig.syntheticOverlay=true
    -> accepted static V1B pipeline

pushwig.dynamicLocalVisual=true
    -> dynamic local pipeline

both true
    -> dynamic local pipeline
```

Exactly one pipeline is selected. Static and dynamic diagnostics are not stacked.

### Local lifecycle

The dynamic pipeline is package-private and one instance per display.

It must cover:

```text
A
B moved/enlarged with partial overlap
C moved/reduced
D replacement content/geometry
NONE
STALE
INVALID
```

Valid states draw the current layer. Semantic-only states draw nothing after the full redraw.

### Frame and allocation limits

The dynamic pipeline:

- returns the exact input bitmap;
- retains no bitmap, raw frame, prior output, semantic snapshot, or queue;
- uses no second bitmap;
- adds no per-send bitmap, frame, byte-array, renderer, collection, task, future, or `Enum.values()` array;
- adds no thread, executor, scheduler, timer, IPC, socket, shared memory, capture type, USB object, or second writer;
- uses fixed bounded state and reusable renderers.

### Regression paths

The exact head must prove:

- ordinary/default subclasses retain dirty-render behavior;
- pass-through remains default;
- V1B static mode remains accepted and does not request dynamic redraw;
- V1C dynamic mode retains newest semantics and redraws every eligible send;
- `Push2Display.send` remains one guarded pipeline call followed by one USB send.

### Semantic edge cases

V1C must test:

- overlay-only update while equality-covered state is stable;
- notification appearance;
- visual movement/removal while notification is current;
- notification replacement/expiration;
- restoration of current underlying semantics.

### Correctness

Require zero unexplained mismatch counts for:

- outside current visual bounds;
- old visual bounds;
- post-NONE full frame;
- STALE full frame;
- INVALID full frame;
- semantic update beneath prior visual;
- overlay-only update;
- notification lifecycle restoration.

### Performance

On the accepted Mac:

```text
green:  p95 <= 2 ms and max <= 10 ms
review: p95 <= 5 ms and max <= 15 ms
stop:   p95 > 5 ms or max > 15 ms
```

Measure default, V1B static, V1C redraw-without-visual, and V1C redraw-plus-visual.

Do not add asynchronous buffering to conceal synchronous cost.

### Transport

- `PushUsbDisplay` is not modified.
- USB interface, endpoint, encoding, line padding, XOR shaping, transfer scheduling, and shutdown ownership remain unchanged.
- Exactly one steady-state USB writer remains.

## Visual portability evidence

Portable visual claims require a test matrix appropriate to the source class, including where relevant:

- Bitwig version;
- operating system and capture backend;
- display profile;
- UI scale;
- application window size;
- source moved/resized between monitors;
- source closed/reopened;
- selected device changed;
- negative/wrong candidate windows;
- anchor confidence and competitor margin;
- capture/compositor/resolver restart;
- permission denial/revocation and recovery;
- calibration invalidation and semantic fallback.

Do not call a profile portable because it worked on one Mac or one monitor resolution.

For anchor-based resolvers, retain at minimum:

- correct-lock rate;
- abstention rate;
- wrong-lock rate;
- localization error;
- acquisition and reacquisition latency;
- locked-state validation cost;
- CPU time, memory, and relevant host-power observations;
- confidence-threshold behavior.

## Experimental evidence

Retain useful evidence under `evidence/` when practical:

- USB and audio enumeration;
- operating-system, graphical-session, sandbox, and permission state;
- upstream basis, build toolchain, artifact hashes, installation, and rollback evidence;
- framebuffer timing and pixel/object-equivalence evidence;
- source and bytecode diffs that bound controller-extension changes;
- current/previous visual geometry and masks;
- target, outside, restoration, semantic-only, overlay, and notification mismatch counts;
- semantic-reference, target, and outside hashes;
- pipeline timing percentiles and allocation observations;
- working-set behavior;
- source-discovery logs and screenshots;
- visual profile compatibility matrices;
- anchor benchmark summaries and diagnostics;
- photographs and continuity maps;
- battery and power measurements;
- boot/service logs;
- benchmark summaries.

Do not commit serial numbers, credentials, activation files, personal network details, user-specific paths, proprietary binaries, generated DrivenByMoss artifacts, proprietary screenshots, or raw Bitwig/Push frames.

## Engineering preferences

- Use the available Mac to shorten the first implementation loop while keeping core interfaces platform-neutral.
- Treat accepted S0, V1A-0, V1A, V1B, and V1C-0 evidence as authority.
- Use the explicitly pinned Java 21 environment for DrivenByMoss builds.
- Keep pass-through as the ordinary default path.
- Preserve the accepted V1B static diagnostic path.
- Implement the accepted semantic-redraw model directly rather than revisiting second-bitmap or region-snapshot candidates without a demonstrated blocker.
- Keep composition synchronous and in-process through V1C.
- Do not introduce `VisualSourceFrame` before V1D.
- Keep platform capture in a separate helper/backend.
- Prefer observable IPC boundaries when V1D begins.
- Use latest-frame-wins behavior rather than unbounded queues.
- Keep audio/MIDI/control latency independent from capture latency.
- Prefer window identity and source-relative capture over full-desktop recording.
- Prefer semantic-seeded, deterministic, explainable pixel/edge methods before trained models.
- Prefer confidence-validated automatic resolution and bounded calibration over silently wrong capture.
- Never block controller input or audio on a display/capture frame.
- Preserve acceptance suites across Mac, Linux/Steam Deck, Framework/mini-PC, and NUC hosts without making one host normative.

## Connector-development rules

A CM11EB development card is staged open hardware:

- expose only proven grounds, candidate USB pairs, and explicitly chosen observations first;
- leave power rails disconnected by default;
- do not fan all high-speed contacts onto generic headers;
- USB 3/PCIe/eSPI work requires a specific experiment and controlled-impedance design;
- connector geometry and pin mapping require independent review before insertion.

## Naming

`Standalone Bitwig Push` is a working repository/project description, not a claim of affiliation. Internal software may use the provisional `pushwig-*` prefix.

## Current reference fixture and active posture

S0 accepted the Mac + Bitwig 6.1 + Push 3 fixture and pinned the display handoff seam.

V1A-0 accepted the true fork, exact upstream basis, explicit Java 21/Maven build, reversible installation, real-device parity, and exact official rollback.

V1A accepted the synchronous identity frame boundary.

V1B accepted the first visible project-owned pixels: one default-off static mark with zero outside-region mismatches and bounded cost.

V1C-0 accepted Candidate A: full redraw from the newest retained semantic model before the current optional visual, with zero restoration/fallback mismatches and green timing.

V1C now implements that decision as production source with a bounded local lifecycle. External ingress remains V1D.

The Steam Deck remains the named second-host/Linux portability and appliance fixture.

See `CURRENT_SLICE.md` before changing code.
