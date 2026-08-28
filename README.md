# Standalone Bitwig Push

An open-source effort to turn **Ableton Push 3 Controller** into a deeply integrated, portable **Bitwig Studio** instrument.

The project does not depend on one final hardware conversion being completed before it becomes useful. It has several independent layers of success:

1. improve Push as a Bitwig controller on ordinary Linux desktops;
2. combine DrivenByMoss semantic UI with selected live Bitwig/plug-in pixels on Push;
3. run that experience headlessly and expose the full Bitwig desktop wirelessly when needed;
4. package the existing Steam Deck, battery and angled wooden base as a portable reference appliance;
5. later replace the external host path with a Framework/mini-PC dock or a custom Intel NUC Compute Element integration;
6. treat a used NUC Compute Element plus an internal battery as the polished native-bay endgame, not the first proof.

The core software idea is deliberately hybrid: use controller-native semantic information where Bitwig’s controller API is strong, and mix in selected pixels from the real Bitwig or plug-in UI where the desktop already contains richer visual truth. A project-owned compositor decides what belongs on Push’s 960×160 display.

> **Status:** S0 external-baseline preparation. The first reference system is a Steam Deck running Bitwig Studio via Flatpak, connected to Push 3 over ordinary USB.

## A reference appliance already exists in parts

The initial maintainer rig already includes:

- a Steam Deck that runs Bitwig and has previously controlled Push;
- an angled wooden Push base with a substantial protected cavity beneath the controller;
- a battery capable of powering the current devices for meaningful use;
- a tested USB-C Power Delivery trigger cable that powers Push through its barrel input;
- Monome devices and an active plugdata/Pure Data workflow.

That means the first portable all-in-one does **not** require opening Push, designing a new enclosure or buying a Compute Element. It can be built as a headless Steam Deck instrument housed by the existing base, using Push’s normal rear USB and power ports.

Battery operation is a product requirement for the portable appliance. A wall-powered software bench remains useful as an engineering stage, but it is not the final definition of standalone.

## Why this exists

A conventional controller extension gives excellent musical control but cannot expose every waveform, modulation graph, native-device visualization or arbitrary plug-in UI. Shrinking a full desktop onto Push is equally unsatisfying.

This project combines the strengths of both:

```text
Bitwig semantic state ------> controller integration ----+
                                                       |
Bitwig / plug-in desktop ---> targeted visual capture ---+--> compositor --> Push display
                                                       |
custom analyzers -----------> optional visual layers ---+
```

The intended experience is Push-first:

- pads, MPE, encoders, sequencing, browsing and transport remain semantic controls;
- Sampler/native-device/VST/CLAP visuals can appear as useful live lenses;
- a canonical virtual desktop makes capture independent of the physical monitor’s shape and resolution;
- the full desktop remains available wirelessly for exceptional editing or recovery;
- visual failure never blocks musical control;
- the same software stack survives movement from Steam Deck to another Linux host or a native Compute Element.

## Success ladder

### Layer 0 — desktop uplift

DrivenByMoss plus the compositor is valuable on any supported Linux workstation, even when Push is used as an ordinary tethered controller.

### Layer 1 — portable reference appliance

The existing Steam Deck, battery and wooden base become a self-contained, headless Bitwig instrument. Push connects through its normal rear USB port and receives power through its normal barrel input. Wireless desktop access handles the rare operations that do not belong on Push.

### Layer 2 — reproducible compute dock

Replace the Deck with a Framework mainboard or another documented x86 computer mounted in the base, while keeping the same external Push USB contract.

### Layer 3 — internal connector development platform

Build a staged CM11EB-compatible edge-card development board to expose candidate USB and diagnostic signals safely. Use it to characterize the internal carrier, rather than guessing at BIOS, power or mux behavior.

### Layer 4 — native-bay final form

Run the proven appliance stack on a suitable used Intel NUC Compute Element, with a selected battery and validated thermal/power behavior. This is an endgame packaging target, not the only definition of project success.

## Linux plug-in strategy

Bitwig on Linux natively hosts **VST2.4, VST3 and CLAP**. It does not natively host LV2. The project therefore prefers:

1. native Linux CLAP where available;
2. native Linux VST3 when CLAP is unavailable;
3. standalone PipeWire/OSC applications when they are architecturally cleaner;
4. Windows plug-ins through yabridge only in a non-Flatpak Bitwig runtime.

The current Bitwig Flatpak is a strong first reference because it already works on the Deck and can load native plug-ins from reachable user directories. However, yabridge explicitly does not support Flatpak DAWs. Windows plug-in compatibility is therefore a separate runtime track, likely using native Bitwig inside an Ubuntu 24.04 Distrobox/Podman environment after the core display proof works.

plugdata is particularly useful here because it can run on Linux as a standalone application and can be built as VST3, LV2 or CLAP. For Bitwig integration, CLAP or VST3 is the direct path; LV2 is useful to other Linux hosts but is not required for this project.

See [`docs/RUNTIME_STRATEGY.md`](docs/RUNTIME_STRATEGY.md).

## Strategy

We prove the project in dependency order.

### Core software

1. **S0 — external baseline:** reproduce and retain the Steam Deck + Bitwig + DrivenByMoss + Push baseline.
2. **S1 — display ownership:** introduce a project compositor as the single steady-state Push display writer.
3. **S2 — canonical visual surface:** run/capture Bitwig in a deterministic logical desktop independent of the viewer’s monitor.
4. **S3 — Bitwig visual lens:** capture a native Bitwig region such as a waveform/graph and composite it with semantic UI.
5. **S4 — plug-in visual lens:** do the same for a VST/CLAP editor.
6. **S5/S6 — appliance proof:** boot headlessly, provide wireless desktop/management and package the portable reference rig.

### Runtime compatibility

1. prove native Flatpak-visible CLAP/VST3 plug-ins;
2. prove plugdata plus Monome/serialosc operation;
3. characterize a native/containerized Bitwig runtime for yabridge and Windows plug-ins;
4. keep project/session portability across the supported runtimes.

### Hardware progression

1. integrate and measure the existing Steam Deck/base/battery rig;
2. optionally replace the Deck with a Framework or compact x86 board;
3. survey the Push compute bay and CM11EB connector;
4. build a safe connector development board;
5. enumerate Push through the internal USB route;
6. evaluate used Compute Elements only after the software and carrier contracts are proven.

See [`docs/ROADMAP.md`](docs/ROADMAP.md) for acceptance-driven milestones.

## Start here

Contributors and coding agents should read:

1. [`AGENTS.md`](AGENTS.md) — project invariants and execution rules;
2. [`CURRENT_SLICE.md`](CURRENT_SLICE.md) — the one slice currently authorized;
3. [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) — component boundaries and data flow;
4. [`docs/RUNTIME_STRATEGY.md`](docs/RUNTIME_STRATEGY.md) — Linux, plug-in and visual-runtime decisions;
5. [`docs/ROADMAP.md`](docs/ROADMAP.md) — staged software/hardware proofs;
6. [`docs/HARDWARE_DOSSIER.md`](docs/HARDWARE_DOSSIER.md) — current hardware basis and unknowns;
7. [`CONTRIBUTING.md`](CONTRIBUTING.md) — contribution/review expectations.

## Current first slice

S0 is intentionally small: capture the real external baseline and trace the existing DrivenByMoss Push display pipeline down to its USB send path. It also records the current graphical session, Flatpak permissions and native plug-in environment so later capture and compatibility work starts from evidence.

The handoff from S0 should make S1 mechanically obvious:

```text
semantic renderer -> frame handoff -> project compositor -> Push USB display
```

## Upstream work

This project expects to build on and collaborate with existing open-source work, particularly:

- **DrivenByMoss** for Bitwig/Push semantic control;
- **gamescope** or another controlled visual-surface backend;
- **plugdata**, Pure Data and Monome/serialosc tooling;
- **yabridge** for an optional non-Flatpak Windows plug-in runtime;
- open Push 3 protocol/documentation projects;
- Push standalone reverse-engineering projects where their findings help bound the internal hardware problem.

We will keep upstream provenance and licensing explicit. Original project code is MIT licensed; upstream/forked components retain their own licenses.

## Safety and legal notes

Hardware modification can damage equipment and may create electrical, thermal or battery hazards. Power and battery work must be measured and documented rather than guessed. Early integration should use complete protected battery products and tested power-conversion cables before any custom cell pack is considered.

Do not commit or redistribute proprietary Ableton/Bitwig binaries, activation data, firmware or private assets without redistribution rights.

This project is independent and is **not affiliated with or endorsed by Ableton AG, Bitwig GmbH, Intel, Valve, Framework Computer, Monome, or the DrivenByMoss project**.
