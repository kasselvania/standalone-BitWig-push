# AGENTS.md — Repository Execution Rules

## Mission

Build an open, inspectable adaptive visual/controller layer for Ableton Push 3 and Bitwig Studio, then reuse that software in optional portable-appliance and native-compute projects.

The repository coordinates three independent tracks:

1. universal visual/controller integration;
2. all-in-one appliance packaging;
3. CM11EB connector and native-compute research.

The Steam Deck is the maintainer's first reference fixture. It is not a project-wide hardware requirement or the definition of the software product.

## Authority order

When instructions conflict, use this order:

1. `AGENTS.md`
2. `CURRENT_SLICE.md`
3. `docs/PROJECT_TRACKS.md`
4. `docs/ARCHITECTURE.md`
5. `docs/VISUAL_PORTABILITY.md`
6. `docs/SEMANTIC_PIXEL_ANCHOR_RESOLVER.md`
7. `docs/ROADMAP.md`
8. `docs/RUNTIME_STRATEGY.md`
9. issue / PR scope
10. implementation convenience

A contributor or coding agent must stop and surface a conflict rather than quietly widening scope.

## Core invariants

- Bitwig remains the DAW and audio-engine authority.
- DrivenByMoss, or a compatible derivative, is the semantic Push/controller authority unless a slice explicitly proves a replacement.
- The Push display is a composited output. Semantic UI and captured pixels are different source classes and must remain distinguishable.
- Exactly one component owns the Push USB display endpoint in steady state.
- Visual capture is visualization first. Do not make fragile mouse automation the primary control path when the Bitwig controller API can perform the operation.
- The universal visual product must support **attached mode**, adapting to a user's existing Bitwig windows and monitor layout.
- A canonical or virtual desktop is a **managed appliance/test mode**, not a requirement imposed on ordinary desktop users.
- Physical desktop coordinates must not be the primary identity of a visual source.
- Prefer dedicated top-level windows, semantic identity, window-relative geometry, normalized regions, anchors, and bounded calibration.
- Semantic device identity may seed visual matching, but a single template hit is not sufficient for a production lock.
- Anchor-based resolution must use confidence validation, competing-candidate margin, and preferably multiple anchors with consistent relative geometry.
- The resolver must prefer abstention and semantic fallback over displaying the wrong visual region.
- Capture backend and operating-system details do not belong in the compositor frame protocol.
- Visual failure must fall back safely to semantic control/display behavior.
- The Steam Deck is one reference host. Do not generalize maintainer-specific hardware, serialosc, plugdata, or yabridge state into universal product requirements.
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
- Do not copy DrivenByMoss into this repository until the integration boundary and fork strategy are explicitly accepted.

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

- framebuffer ownership is separate from visual-source discovery;
- top-level-window capture is separate from embedded-panel resolution;
- semantic-seeded anchor benchmarking is separate from live resolver integration;
- attached desktop adaptation is separate from managed headless geometry;
- cross-platform capture is separate from Linux proof;
- all-in-one packaging is separate from connector research;
- yabridge experimentation is separate from native Bitwig/Push operation;
- external battery integration is separate from custom native-bay battery engineering.

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
- calibration invalidation and semantic fallback.

Do not call a profile portable because it worked at one monitor resolution.

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

- USB, ALSA, and PipeWire enumeration;
- graphical-session and sandbox permissions;
- framebuffer timing;
- source-discovery logs and screenshots;
- visual profile compatibility matrices;
- anchor benchmark summaries and diagnostics;
- photographs and continuity maps;
- battery and power measurements;
- boot/service logs;
- benchmark summaries.

Do not commit serial numbers, credentials, activation files, personal network details, or proprietary binaries.

## Engineering preferences

- Linux-first implementation, platform-neutral core interfaces.
- Prefer observable IPC boundaries over hidden in-process coupling.
- Prefer shared memory or Unix-domain IPC for high-rate local frame/state paths when boundaries allow it.
- Keep audio/MIDI/control latency independent from capture latency.
- Prefer window identity and source-relative capture over full-desktop recording.
- Prefer semantic-seeded, deterministic, explainable pixel/edge methods before introducing trained models.
- Prefer coarse-to-fine bounded search and low-rate local revalidation over full-frame recognition at display cadence.
- Prefer confidence-validated automatic resolution; use bounded user calibration rather than silently wrong capture.
- Never block controller input or audio processing on a display frame.
- Build semantic fallback and recovery before appliance lock-down.
- Preserve acceptance suites across reference hosts without making one host normative.

## Connector-development rules

A CM11EB development card is staged open hardware:

- expose only proven grounds, candidate USB pairs, and explicitly chosen observations first;
- leave power rails disconnected by default;
- do not fan all high-speed contacts onto generic headers;
- USB 3/PCIe/eSPI work requires a specific experiment and controlled-impedance design;
- connector geometry and pin mapping require independent review before insertion.

## Naming

`Standalone Bitwig Push` is a working repository/project description, not a claim of affiliation. Internal software may use the provisional `pushwig-*` prefix.

## Current reference fixture

S0 uses the maintainer's Steam Deck, Flatpak Bitwig, Push 3, and DrivenByMoss because that working system is available for real-device evidence.

The purpose of S0 is to establish a first tested fixture and the display handoff seam—not to define Steam Deck, Flatpak, Monome, plugdata, or yabridge as universal requirements.

See `CURRENT_SLICE.md` before changing code.
