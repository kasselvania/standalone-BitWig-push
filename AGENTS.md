# AGENTS.md — Repository Execution Rules

## Mission

Build an open, inspectable path from Ableton Push 3 Controller to a self-contained Bitwig Studio instrument.

The project is deliberately staged. Software proof precedes invasive hardware work. Hardware research must not silently become a prerequisite for software progress.

## Authority order

When instructions conflict, use this order:

1. `AGENTS.md`
2. `CURRENT_SLICE.md`
3. `docs/ARCHITECTURE.md`
4. `docs/ROADMAP.md`
5. issue / PR scope
6. implementation convenience

A contributor or coding agent must stop and surface a conflict rather than quietly widening scope.

## Core invariants

- Bitwig remains the DAW and audio-engine authority.
- DrivenByMoss, or a compatible derivative, is the semantic controller authority unless a slice explicitly proves a replacement.
- The Push display is a composited output. Semantic UI and captured desktop pixels are different source classes and must remain distinguishable in the architecture.
- Exactly one component owns the Push USB display endpoint in the steady-state design.
- Desktop capture is visualization first. Do not make fragile mouse automation the primary control path when the Bitwig controller API can perform the operation.
- The external USB proof must remain usable while internal-hardware work proceeds.
- Hardware claims require evidence: source documentation, continuity measurements, USB enumeration, photographs, or captured diagnostics. Mark inference as inference.
- Do not redistribute Bitwig Studio, Ableton software/firmware, proprietary Push assets, or other third-party binaries without explicit redistribution rights.
- Upstream forks and vendored dependencies retain their upstream licenses and provenance.
- Do not copy DrivenByMoss into this repository until the integration boundary and fork strategy are explicitly accepted.

## Slice discipline

Work in small, independently reviewable slices.

Every implementation slice should state:

- basis / assumptions;
- one primary claim to prove;
- files or components in scope;
- explicit non-goals;
- executable acceptance criteria;
- retained evidence required from real hardware when applicable.

A slice is not complete because code exists. It is complete when its claim is demonstrably true.

## Experimental evidence

For hardware or real-device integration, retain useful evidence under `evidence/` when practical, for example:

- `lsusb -v` captures;
- ALSA/PipeWire enumeration;
- USB descriptor dumps;
- framebuffer timing measurements;
- photographs with annotations;
- continuity maps;
- boot and service logs;
- benchmark summaries.

Do not commit private license data, serial numbers, credentials, activation files, personal network details, or proprietary binaries.

## Engineering preferences

- Linux-first.
- Prefer observable IPC boundaries over hidden in-process coupling.
- Prefer shared memory or Unix-domain IPC for high-rate local frame/state paths.
- Keep audio/MIDI/control latency independent from visual capture latency.
- Prefer deterministic window identification/capture over full-desktop video encoding.
- Never block controller input or audio processing on a display frame.
- Build recovery paths before appliance lock-down.

## Naming

`Standalone Bitwig Push` is the repository/project description, not a claim of affiliation. Internal component names may use the provisional `pushwig-*` prefix until a final project name is selected.

## Current starting platform

The first reference platform is a Steam Deck running Linux with Bitwig Studio installed via Flatpak and an Ableton Push 3 Controller connected by ordinary external USB.

See `CURRENT_SLICE.md` before changing code.