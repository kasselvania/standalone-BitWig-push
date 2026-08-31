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
7. `docs/V1C0_DYNAMIC_RASTER_COMPOSITION.md`
8. `docs/V1B_SYNTHETIC_COMPOSITION.md`
9. `docs/VISUAL_PORTABILITY.md`
10. `docs/SEMANTIC_PIXEL_ANCHOR_RESOLVER.md`
11. `docs/ROADMAP.md`
12. `docs/RUNTIME_STRATEGY.md`
13. issue / PR scope
14. implementation convenience

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
- Semantic fallback means restoring the exact **current** semantic pixels; it does not mean merely stopping future visual drawing.
- Output must be derived conceptually from `current semantic frame + optional current visual`, not from historical output state.
- A moving, replaced, absent, stale, or invalid visual must not leave pixels behind.
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
commit: 1ae0b74f383314d170a5960ca763bdf9c319e787
tree:   a81e5c4330b31f36845c25e98e322990d62f0c67
```

This merge contains the exact accepted V1B source head:

```text
a2e0341b7bccfa4e6b13614f4adffc2235f785f4
```

Accepted default path:

```text
complete semantic IBitmap
        -> PassThroughPushFramePipeline.INSTANCE
        -> exact same IBitmap reference
        -> unchanged PushUsbDisplay
```

Accepted diagnostic V1B path:

```text
pushwig.syntheticOverlay=true at startup
        -> SyntheticOverlayPushFramePipeline.INSTANCE
        -> one fixed bounded render callback
        -> same IBitmap
        -> unchanged PushUsbDisplay
```

`PushUsbDisplay` remains the sole transport owner.

V1B proved static bounded in-place painting. It did not accept a dynamic-restoration architecture.

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
- static composition is separate from dynamic replacement/removal;
- dynamic restoration selection is separate from production implementation;
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

## V1C-0 dynamic-composition research rules

V1C-0 is an evidence and architecture-selection slice.

- Begin from exact accepted DrivenByMoss integration commit `1ae0b74f383314d170a5960ca763bdf9c319e787` and central commit `95d93e262c33163783e23a8d3e66f6f92746918d`.
- Do not open or merge a production DrivenByMoss source PR in V1C-0.
- Temporary prototype worktrees, patches, harnesses, and instrumentation are allowed only when their hashes, changed paths, build results, and removal are retained.
- Test current-semantic restoration before designing external-frame IPC.
- Candidate order is: retained semantic redraw; reusable final bitmap and blit; generation-aware region restore; backend memory copy.
- Stop evaluating once one candidate satisfies every correctness, lifecycle, one-writer, portability, and performance requirement strongly enough to authorize a production slice.
- Correctness outranks minimal source delta and benchmark speed.
- The selected model must produce output from the current semantic frame and the current optional visual; historical composed output must not become semantic authority.
- Require exact movement, replacement, absence, stale-source fallback, and semantic-update-under-overlay tests.
- Require zero unexplained outside-region mismatches.
- Require zero unexplained old-region restoration mismatches.
- Require zero full-frame mismatches after the visual becomes absent.
- A target-region snapshot is invalid unless it has a trustworthy semantic-generation rule; restoring an old snapshot over newer semantics is forbidden.
- A separate final bitmap must be allocated once and reused if selected.
- A backend copy primitive must remain behind a host-neutral interface and must declare pixel format, dimensions, ownership, and bounds.
- No candidate may introduce a second USB writer, unbounded queue, per-frame task/thread creation, platform capture type, or arbitrary reflection into Bitwig implementation internals.
- `PushUsbDisplay` remains outside the experiment.
- Real-fixture prototype use requires safe sole-artifact installation and exact official rollback.
- The final central evidence must select one precise production seam or one precise blocker.

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
- declared visual geometry and current/old region masks;
- target, outside-region, restoration, and absent-state mismatch counts;
- semantic-reference, visual-region, and outside-region hashes;
- stale/absent visual fallback results;
- candidate timing percentiles, allocation observations, and working-set behavior;
- prototype/patch/harness hashes and changed-path summaries;
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
- Treat accepted S0, V1A-0, V1A, and V1B evidence as authority; do not repeat or silently replace their source/toolchain claims.
- Use the explicitly pinned Java 21 environment for DrivenByMoss builds; do not rely on the host's default Java selection.
- Keep the accepted pass-through pipeline as the ordinary default path.
- Treat the V1B static overlay as diagnostic evidence, not the final compositor representation.
- Prefer a pristine semantic authority and a reproducible output build over historical in-place mutation.
- Test retained semantic redraw first because it may be the smallest exact restoration path.
- Prefer a reusable final bitmap if full semantic redraw is too expensive or couples visual cadence to semantic rendering.
- Do not choose target-region snapshots without explicit semantic-generation ownership.
- Prefer in-process final composition/USB transport initially so two processes do not fight over Push's display interface.
- Keep platform capture in a separate helper/backend and publish only `VisualSourceFrame`-style data across the boundary.
- Do not implement `VisualSourceFrame` ingress until local dynamic replacement/removal/fallback is proven.
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

V1B accepted the first visible project-owned pixels: one default-off, startup-scoped static mark with zero outside-region mismatches, bounded cost, real-fixture success, property-off recovery, and exact rollback.

V1C-0 now determines the dynamic restoration/frame-ownership architecture required before external-frame ingress. It is a research/evidence slice, not a production source slice.

The Steam Deck remains the named second-host/Linux portability and appliance fixture when it becomes available.

See `CURRENT_SLICE.md` before changing code.