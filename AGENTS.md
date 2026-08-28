# AGENTS.md — Repository Execution Rules

## Mission

Build an open, inspectable path from Ableton Push 3 Controller to a deeply integrated, portable Bitwig Studio instrument.

The project is deliberately staged. Software value precedes invasive hardware work. A desktop controller uplift, a portable Steam Deck appliance, a compute dock and a native NUC conversion are different valid success layers.

## Authority order

When instructions conflict, use this order:

1. `AGENTS.md`
2. `CURRENT_SLICE.md`
3. `docs/ARCHITECTURE.md`
4. `docs/RUNTIME_STRATEGY.md`
5. `docs/ROADMAP.md`
6. issue / PR scope
7. implementation convenience

A contributor or coding agent must stop and surface a conflict rather than quietly widening scope.

## Core invariants

- Bitwig remains the DAW and audio-engine authority.
- DrivenByMoss, or a compatible derivative, is the semantic controller authority unless a slice explicitly proves a replacement.
- The Push display is a composited output. Semantic UI and captured desktop pixels are different source classes and must remain distinguishable in the architecture.
- Exactly one component owns the Push USB display endpoint in the steady-state design.
- Desktop capture is visualization first. Do not make fragile mouse automation the primary control path when the Bitwig controller API can perform the operation.
- The visual system targets canonical logical geometry rather than assuming the physical monitor’s size or aspect ratio.
- Capture backends and window-system details do not belong in the compositor’s frame protocol.
- The ordinary external Push USB path is a first-class supported architecture, not merely a disposable prototype.
- The portable reference appliance requires battery operation. Do not describe a wall-powered bench as the final standalone product.
- The existing battery/battery region is not generic compute volume.
- Flatpak Bitwig is the initial reference runtime; optional yabridge work belongs in a separate non-Flatpak runtime profile.
- Bitwig’s direct Linux plug-in formats are VST2.4, VST3 and CLAP. Do not claim native LV2 hosting.
- The external software and portable-appliance proofs must remain usable while internal-hardware work proceeds.
- Hardware claims require evidence: source documentation, continuity measurements, USB enumeration, photographs, or captured diagnostics. Mark inference as inference.
- Power and battery claims require measured voltage, current, output negotiation, transition and thermal evidence.
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

Do not merge separate uncertainty domains merely because they are exciting. Examples:

- display ownership is separate from visual capture;
- native Linux plug-ins are separate from Wine/yabridge compatibility;
- external-port appliance packaging is separate from CM11EB carrier research;
- reference battery integration is separate from custom native-bay battery design.

## Experimental evidence

For hardware or real-device integration, retain useful evidence under `evidence/` when practical, for example:

- `lsusb -v` captures;
- ALSA/PipeWire enumeration;
- Flatpak permissions and graphical-session data;
- USB descriptor dumps;
- framebuffer timing measurements;
- plug-in discovery/restore matrices;
- photographs with annotations;
- continuity maps;
- battery PD-profile and load measurements;
- boot and service logs;
- benchmark summaries.

Do not commit private license data, serial numbers, credentials, activation files, personal network details, or proprietary binaries.

## Engineering preferences

- Linux-first.
- Prefer native CLAP, then native VST3, before introducing Wine bridging.
- Prefer observable IPC boundaries over hidden in-process coupling.
- Prefer shared memory or Unix-domain IPC for high-rate local frame/state paths when sandbox boundaries allow it.
- Keep audio/MIDI/control latency independent from visual capture latency.
- Prefer deterministic window identification/capture over full-desktop video encoding.
- Prefer normalized/canonical visual profiles over physical-screen pixel assumptions.
- Never block controller input or audio processing on a display frame.
- Build recovery paths before appliance lock-down.
- Preserve the ability to run the same acceptance suite on Steam Deck, Framework/mini-PC and NUC hosts.

## Connector-development rules

A CM11EB development card is staged hardware:

- first expose only proven grounds, candidate USB pairs and isolated observations;
- leave power rails disconnected by default;
- do not route every high-speed signal merely to make the board look comprehensive;
- USB 3/PCIe/eSPI work requires an explicit experiment and controlled-impedance design;
- connector geometry and pin mapping must be independently reviewed before insertion into Push.

## Naming

`Standalone Bitwig Push` is the repository/project description, not a claim of affiliation. Internal component names may use the provisional `pushwig-*` prefix until a final project name is selected.

## Current starting platform

The first reference platform is a Steam Deck running Linux with Bitwig Studio installed via Flatpak and an Ableton Push 3 Controller connected by ordinary external USB.

The initial maintainer also has an angled wooden base, battery and tested PD-to-barrel power path suitable for the later portable reference appliance. Those assets must still be measured before becoming retained claims.

See `CURRENT_SLICE.md` before changing code.
