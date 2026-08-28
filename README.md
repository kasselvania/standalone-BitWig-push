# Standalone Bitwig Push

An open-source effort to turn **Ableton Push 3 Controller** into a self-contained, deeply integrated **Bitwig Studio** instrument.

The core idea is deliberately hybrid: use controller-native semantic information where Bitwig’s controller API is strong, and mix in selected pixels from the real Bitwig or plug-in UI where the desktop already contains richer visual truth. A project-owned compositor then decides what belongs on Push’s 960×160 display.

The result should be useful **before** any internal hardware modification and eventually become a fully internal Linux/Bitwig appliance.

> **Status:** founding architecture / S0 preparation. The first reference system is a Steam Deck running Bitwig Studio via Flatpak with Push 3 Controller connected over ordinary USB.

## Why this exists

A conventional controller extension gives excellent musical control but cannot expose every waveform, modulation graph, native-device visualization or arbitrary plug-in UI. Shrinking a full desktop onto Push is equally unsatisfying.

This project combines the strengths of both:

```text
Bitwig semantic state ------> controller integration ----+
                                                       |
Bitwig / VST desktop -------> targeted window capture --+--> compositor --> Push display
                                                       |
custom analyzers -----------> optional visual layers ---+
```

The intended experience is Push-first:

- pads, MPE, encoders, sequencing, browsing and transport remain semantic controls;
- Sampler/native-device/VST visuals can appear as useful live lenses;
- the full desktop remains available remotely for exceptional editing or recovery;
- visual failure never blocks musical control;
- the same software stack should eventually move from an external host into the Push chassis.

## Strategy

We prove the project in dependency order.

### Software first

1. **S0 — external baseline:** reproduce and retain the Steam Deck + Bitwig + DrivenByMoss + Push baseline.
2. **S1 — display ownership:** introduce a project compositor as the single steady-state Push display writer.
3. **S2 — Bitwig visual lens:** capture a native Bitwig region such as a waveform/graph and composite it with semantic UI.
4. **S3 — plug-in visual lens:** do the same for a VST/CLAP editor.
5. **S4/S5 — appliance proof:** boot headlessly and provide remote desktop/management.

### Then move inward

1. **H0 — bay survey:** document the empty standalone compute bay.
2. **H1 — carrier map:** map the documented Intel CM11EB connector against Push’s internal USB path.
3. **H2 — internal USB breakout:** make the external Linux host communicate through the internal compute interface.
4. **H3/H4 — compute decision:** determine whether CM11EB or another x86 host is the best internal computer.
5. **H5/H6 — self-contained appliance:** move the already-proven stack inside Push and harden it.
6. **H7 — battery:** solve portable power as its own later safety-critical subsystem.

See [`docs/ROADMAP.md`](docs/ROADMAP.md) for the acceptance-driven version.

## Start here

Contributors and coding agents should read:

1. [`AGENTS.md`](AGENTS.md) — project invariants and execution rules;
2. [`CURRENT_SLICE.md`](CURRENT_SLICE.md) — the one slice currently authorized;
3. [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) — component boundaries and data flow;
4. [`docs/ROADMAP.md`](docs/ROADMAP.md) — staged software/hardware proofs;
5. [`docs/HARDWARE_DOSSIER.md`](docs/HARDWARE_DOSSIER.md) — current hardware basis and unknowns;
6. [`CONTRIBUTING.md`](CONTRIBUTING.md) — contribution/review expectations.

## Current first slice

S0 is intentionally small: capture the real external baseline and trace the existing DrivenByMoss Push display pipeline down to its USB send path. We do not begin by rewriting DrivenByMoss, opening the Push, or buying compute hardware.

The handoff from S0 should make S1 mechanically obvious:

```text
semantic renderer -> frame handoff -> project compositor -> Push USB display
```

## Upstream work

This project expects to build on and collaborate with existing open-source work, particularly:

- **DrivenByMoss** for Bitwig/Push semantic control;
- open Push 3 protocol/documentation projects;
- Push standalone reverse-engineering projects where their findings help bound the internal hardware problem.

We will keep upstream provenance and licensing explicit. Original project code is MIT licensed; upstream/forked components retain their own licenses.

## Safety and legal notes

Hardware modification can damage equipment and may create electrical, thermal or battery hazards. Power and battery work must be measured and documented rather than guessed.

Do not commit or redistribute proprietary Ableton/Bitwig binaries, activation data, firmware or private assets without redistribution rights.

This project is independent and is **not affiliated with or endorsed by Ableton AG, Bitwig GmbH, Intel, Valve, or the DrivenByMoss project**.
