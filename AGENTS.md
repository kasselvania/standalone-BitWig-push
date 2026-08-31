# AGENTS.md — Repository Execution Rules

## Mission

Build an open, inspectable adaptive visual/controller layer for Ableton Push 3 and Bitwig Studio, then reuse that software in optional portable-appliance and native-compute projects.

The repository coordinates three independent tracks:

1. universal visual/controller integration;
2. all-in-one appliance packaging;
3. CM11EB connector and native-compute research.

The active Track V reference fixture is the maintainer's macOS Bitwig/DrivenByMoss/Push system because it is currently available for rapid software work. The Steam Deck remains the first Track A appliance host and a later Linux portability fixture. Neither computer defines the universal product.

## Authority order

When instructions conflict, use this order:

1. `AGENTS.md`
2. `CURRENT_SLICE.md`
3. `docs/PROJECT_TRACKS.md`
4. `docs/ARCHITECTURE.md`
5. `docs/MAC_FIRST_DEVELOPMENT.md`
6. `docs/DRIVENBYMOSS_DERIVATIVE_STRATEGY.md`
7. `docs/V1B_SYNTHETIC_COMPOSITION.md`
8. `docs/VISUAL_PORTABILITY.md`
9. `docs/SEMANTIC_PIXEL_ANCHOR_RESOLVER.md`
10. `docs/ROADMAP.md`
11. `docs/RUNTIME_STRATEGY.md`
12. issue / PR scope
13. implementation convenience

A contributor or coding agent must stop and surface a conflict rather than quietly widening scope.

## Core invariants

- Bitwig remains the DAW and audio-engine authority.
- DrivenByMoss, or a compatible derivative, is the semantic Push/controller authority unless a slice explicitly proves a replacement.
- The Push display is a composited output. Semantic UI and project/captured pixels are different source classes and must remain distinguishable.
- Exactly one component owns the Push USB display endpoint in steady state.
- The first implementation keeps final composition and USB transport inside the DrivenByMoss derivative; process boundaries are not architectural authority.
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
- The Mac and Steam Deck are reference hosts. Do not generalize maintainer-specific hardware, serialosc, plugdata, or yabridge state into universal product requirements.
- yabridge/Wine compatibility is optional research and not a gate for the visual product or appliance.
- Monome/serialosc and plugdata/Pure Data are independent integrations that may consume project interfaces but do not own the core roadmap.
- The ordinary rear Push USB path is first-class and remains a valid appliance architecture.
- Battery operation is mandatory for a portable appliance claim; a wall-powered bench is only an engineering state.
- The appliance track and CM11EB hardware track must not block universal visual progress.
- Hardware claims require documentation, measurements, photographs, continuity evidence, or real enumeration. Mark inference as inference.
- Power and battery claims require measured voltage, current, negotiation, transition, runtime, and thermal evidence.
- Do not redistribute Bitwig Studio, Ableton software/firmware, proprietary Push assets, activation data, or other third-party binaries without redistribution rights.
- Do not casually redistribute proprietary UI screenshots/templates; prefer local anchor generation, recipes, hashes, descriptors, or legally distributable fixtures.
- Upstream forks and dependencies retain their licenses and provenance.
- DrivenByMoss source changes live in the `kasselvania/DrivenByMoss` fork and must preserve upstream history and LGPL notices; do not vendor that source into this repository.
- Every DrivenByMoss implementation slice must name an exact accepted commit/tree and must not silently move to a newer upstream basis.
- `pushwig/upstream-26.4.1` is the immutable accepted upstream basis. Project feature PRs target `pushwig/main`; do not merge implementation work into the immutable basis branch or upstream `master`.
- Central evidence/status work and DrivenByMoss source work are separate PRs with exact cross-references.

## Accepted source posture

Accepted DrivenByMoss integration branch:

```text
branch: pushwig/main
commit: 033ccef8c64f08e8d8d41fa90d48fa06b326a1a1
tree:   9aec7429ff093addee001a62a5a07309708fd592
```

This merge contains the exact accepted V1A source head `6e1e4cbd2e725a7951e5b4dc1278fbb6e7b5d61c`.

Accepted V1A path:

```text
complete semantic IBitmap
        -> PassThroughPushFramePipeline.INSTANCE
        -> exact same IBitmap reference
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
- fork/toolchain/build/install/rollback proof is separate from the no-op frame-pipeline source change;
- no-op frame-pipeline insertion is separate from synthetic composition;
- second-render preservation is separate from moving-overlay damage restoration;
- static composition is separate from runtime hot switching;
- synthetic composition is separate from external-frame IPC;
- external-frame IPC is separate from operating-system window capture;
- framebuffer ownership is separate from visual-source discovery;
- top-level-window capture is separate from embedded-panel resolution;
- semantic-seeded anchor benchmarking is separate from live resolver integration;
- attached desktop adaptation is separate from managed headless geometry;
- macOS proof is separate from Linux portability validation;
- all-in-one packaging is separate from connector research;
- yabridge experimentation is separate from native Bitwig/Push operation;
- external battery integration is separate from custom native-bay battery engineering.

## V1B synthetic-composition rules

V1B is a bounded diagnostic experiment.

- The exact artifact must remain pass-through by default.
- The preferred activation is the startup Java property `pushwig.syntheticOverlay=true`, read once during `Push2Display` construction.
- Do not poll activation per frame.
- Do not add a user-facing configuration setting in V1B.
- The enabled pipeline may draw only one fixed opaque mark within the declared rectangle.
- Do not animate or move the mark.
- Do not hot-toggle it at runtime.
- Use one reusable renderer; do not allocate a renderer/lambda per send.
- Invoke at most one additional `IBitmap.render` callback per eligible enabled send.
- Return the exact same `IBitmap` reference.
- Do not retain the bitmap after the call.
- Do not copy/read raw pixels in committed production source.
- Do not add an off-screen final bitmap, frame snapshot, queue, thread, executor, timer, IPC channel, capture object, or platform type.
- Do not modify `PushUsbDisplay`, `AbstractGraphicDisplay`, `BitmapImpl`, `IBitmap`, `PushConfiguration`, or `PushControllerSetup`.
- If the second render callback clears or unpredictably damages semantic pixels, stop, restore the official artifact, and retain the failure. Do not widen into transport replacement or raw bitmap copying.
- If the startup property cannot reach the extension process, stop before proposing another activation mechanism.
- Property-off restart is the V1B removal/recovery boundary. Runtime damage restoration is a later claim.

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
- declared overlay geometry and colors;
- target/outside-region mismatch counts and hashes;
- property-off/on/recovery results;
- pipeline timing percentiles and allocation observations;
- source-discovery logs and screenshots;
- visual profile compatibility matrices;
- anchor benchmark summaries and diagnostics;
- photographs and continuity maps;
- battery and power measurements;
- boot/service logs;
- benchmark summaries.

Do not commit serial numbers, credentials, activation files, personal network details, user-specific paths, proprietary binaries, generated DrivenByMoss extension artifacts, proprietary screenshots, or raw Bitwig/Push frames.

## Engineering preferences

- Use the currently available Mac to shorten the first implementation loop, while keeping core interfaces platform-neutral.
- Treat accepted S0, V1A-0, and V1A evidence as authority; do not repeat or silently replace their source/toolchain claims.
- Use the explicitly pinned Java 21 environment for DrivenByMoss builds; do not rely on the host's default Java selection.
- Keep the accepted pass-through pipeline as the default path.
- Prove direct static in-place composition before adding external frames or a general compositor.
- Prefer a fixed opaque diagnostic mark over animation in V1B.
- Measure actual render cost now that V1B introduces pixel work, but keep instrumentation temporary and uncommitted.
- Prefer in-process final composition/USB transport initially so two processes do not fight over Push's display interface.
- Keep platform capture in a separate helper/backend and publish only `VisualSourceFrame`-style data across the boundary.
- Prefer observable IPC boundaries over hidden cross-process coupling.
- Prefer shared memory or Unix-domain IPC for high-rate local frame/state paths when boundaries allow it.
- Use latest-frame-wins behavior rather than unbounded queues.
- Keep audio/MIDI/control latency independent from capture latency.
- Prefer window identity and source-relative capture over full-desktop recording.
- Prefer semantic-seeded, deterministic, explainable pixel/edge methods before introducing trained models.
- Prefer coarse-to-fine bounded search and low-rate local revalidation over full-frame recognition at display cadence.
- Prefer confidence-validated automatic resolution; use bounded user calibration rather than silently wrong capture.
- Never block controller input or audio processing on a display or capture frame.
- Build semantic fallback and recovery before appliance lock-down.
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

S0 accepted the maintainer's macOS computer, Bitwig Studio 6.1, Push 3, and official DrivenByMoss 26.4.1 as the first real-device fixture and pinned the display handoff seam.

V1A-0 accepted the true fork, exact upstream basis, explicit Java 21/Maven build, reversible installation, full behavioral parity, and exact official-artifact rollback.

V1A accepted the synchronous identity frame boundary and merged it into `pushwig/main` while preserving the same semantic bitmap and unchanged USB writer.

V1B now tests one startup-scoped static synthetic mark on that accepted path. It must prove outside-region preservation, repeated-send stability, representative semantic updates, bounded timing, property-off recovery, real Push behavior, and exact official rollback.

The Steam Deck remains the named second-host/Linux portability and appliance fixture when it becomes available.

See `CURRENT_SLICE.md` before changing code.