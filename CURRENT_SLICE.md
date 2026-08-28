# Current Slice: S0 — Reference Fixture Baseline and Display Reconnaissance

## Status

Ready to start from current `main` after the project-track correction is merged.

## Primary claim

Establish a reproducible, retained baseline for the maintainer's working Bitwig Studio + Push 3 Controller + DrivenByMoss fixture, and identify the exact existing display ownership path that S1 will replace or interpose.

The Steam Deck is used because it is the available real-device development host. S0 does **not** make Steam Deck, Flatpak, one monitor geometry, or one appliance layout normative for the project.

S0 is observational and minimally invasive. It does not implement the compositor, adaptive visual resolver, managed desktop, headless appliance, alternate plug-in runtime, or hardware integration.

## Reference fixture

- Steam Deck running Linux / SteamOS-derived environment;
- Bitwig Studio already installed via Flatpak;
- Ableton Push 3 Controller;
- ordinary external USB connection;
- current compatible DrivenByMoss release/source.

The maintainer's wooden base, battery, Monome/serialosc work, plugdata work, and prior yabridge experiments are outside this slice.

## In scope

1. Record host, kernel, Flatpak, Bitwig, and graphical-session versions relevant to reproducing this fixture.
2. Record Bitwig Flatpak permissions relevant to later USB, capture, and IPC work.
3. Record Push USB enumeration and descriptors.
4. Record ALSA and PipeWire device/port enumeration.
5. Confirm the Bitwig + DrivenByMoss control baseline:
   - pads;
   - MPE/pressure where configured;
   - encoders;
   - transport;
   - semantic Push display;
   - Push audio-device enumeration and one simple audio result.
6. Record the current Bitwig window/display state only as fixture evidence:
   - session type;
   - current monitor resolution/scaling;
   - Bitwig display profile/panel arrangement where observable;
   - whether native-device expanded/floating views can be opened in this fixture.
7. Obtain or identify the exact DrivenByMoss source revision corresponding to the tested setup.
8. Trace the Push 3 semantic-display construction and USB-send path in that revision.
9. Produce an S1 design note identifying the narrowest seam for:
   - semantic base-frame export or interception;
   - single compositor ownership of the Push display endpoint.
10. Retain sanitized evidence under `evidence/s0-reference-fixture/`.

## Explicit non-goals

- no claim of universal monitor/layout adaptation;
- no visual-source capture or resolver implementation;
- no fixed/canonical desktop implementation;
- no internal Push disassembly or connector probing;
- no compute-module purchase;
- no persistent headless boot changes;
- no yabridge repair or alternate Bitwig runtime;
- no plugdata, Pure Data, Monome, or serialosc integration work;
- no large DrivenByMoss fork;
- no redesign of existing Push modes;
- no remote-desktop implementation.

## Required evidence

At minimum retain sanitized outputs equivalent to:

```text
uname -a
cat /etc/os-release
flatpak info <Bitwig app id>
flatpak info --show-permissions <Bitwig app id>
echo "$XDG_SESSION_TYPE"
echo "$WAYLAND_DISPLAY"
echo "$DISPLAY"
lsusb
lsusb -v -d 2982:1969
aconnect -l   # or equivalent ALSA sequencer enumeration
wpctl status  # or equivalent PipeWire graph/device summary
```

Also retain:

- tested Bitwig version;
- tested DrivenByMoss version/revision;
- whether Push audio was selected through Bitwig/PipeWire and the observed result;
- a short manual controller acceptance checklist;
- source-path notes for the display pipeline;
- current monitor/window/display-profile notes as fixture evidence only;
- host/Flatpak paths that appear suitable for a later broker/frame handoff.

Sanitize serial numbers, account/license data, hostnames, IP addresses, and other personal identifiers before committing.

## Acceptance criteria

S0 is complete only when all of the following are true:

1. A contributor can reproduce and understand the tested maintainer fixture.
2. Push musical controls demonstrably work in Bitwig through DrivenByMoss.
3. The semantic Push display demonstrably works in the baseline configuration.
4. Push audio enumeration and one simple audio result are recorded, whether pass or a clearly characterized blocker.
5. The graphical and sandbox environment relevant to later visual work is recorded without being generalized into a product requirement.
6. The exact path from DrivenByMoss semantic rendering to Push USB frame transmission is named and linked to the tested upstream revision.
7. S1 can begin without rediscovering how the current display pipeline works.

## Expected S1 handoff

S1 should be able to state a concrete interface such as:

```text
semantic renderer -> frame handoff -> project compositor -> Push USB display
```

with the compositor as the sole steady-state owner of the Push display endpoint.

Adaptive source discovery, attached-mode portability, managed appliance geometry, and operating-system capture backends begin in later slices.

## Review standard

Do not mark S0 complete from documentation research alone. The claim is about the maintainer's real Steam Deck + Push 3 + Bitwig fixture, so retained real-device evidence is required.
