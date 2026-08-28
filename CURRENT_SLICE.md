# Current Slice: S0 — External Baseline and Display Reconnaissance

## Status

Ready to start from current `main` after the project-direction documentation update is merged.

## Primary claim

Establish a reproducible, retained baseline for Bitwig Studio + Push 3 Controller + DrivenByMoss on the Steam Deck, and identify the exact existing display ownership path we will replace or interpose in S1.

S0 is intentionally observational and minimally invasive. It does **not** implement the compositor, canonical visual surface or alternate plug-in runtime yet.

## Reference machine

- Steam Deck running Linux / SteamOS-derived environment;
- Bitwig Studio already installed via Flatpak;
- Ableton Push 3 Controller;
- external USB connection;
- current compatible DrivenByMoss release/source.

The existing wooden base and battery are part of the later portable-reference appliance, but S0 does not require packaging changes.

## In scope

1. Record host/kernel/Flatpak/Bitwig versions relevant to reproducibility.
2. Record the current graphical session and Bitwig Flatpak permissions relevant to later capture/IPC.
3. Record USB enumeration and descriptors for Push 3.
4. Record ALSA and PipeWire device/port enumeration.
5. Confirm Bitwig + DrivenByMoss control baseline:
   - pads;
   - MPE/pressure where configured;
   - encoders;
   - transport;
   - semantic Push display;
   - Push audio device enumeration and a simple audio test.
6. Inventory the current native Linux plug-in environment without trying to solve it:
   - configured Bitwig plug-in locations;
   - any known-good native CLAP/VST3 already visible;
   - current plugdata installation/build/format if present;
   - current `serialosc` installation/service state if present;
   - current yabridge state, recorded explicitly as incompatible with the Flatpak host rather than treated as an S0 blocker.
7. Obtain/build the exact DrivenByMoss source revision corresponding to the tested setup.
8. Trace the Push 3 display construction and USB-send path in that revision.
9. Produce a short S1 design note identifying the narrowest seam for:
   - semantic base-frame export;
   - single compositor ownership of the USB display endpoint.
10. Retain sanitized evidence under `evidence/s0-external-baseline/`.

## Explicit non-goals

- no internal Push disassembly;
- no compute-module purchase;
- no internal USB probing;
- no persistent headless boot changes;
- no Bitwig/VST/CLAP window capture;
- no gamescope/canonical-desktop implementation;
- no yabridge repair or alternate Bitwig container/runtime;
- no large DrivenByMoss fork;
- no redesign of existing Push modes;
- no requirement to solve remote desktop yet.

## Required evidence

At minimum retain textual/sanitized outputs equivalent to:

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
- tested DrivenByMoss revision/version;
- whether Push audio was selected through Bitwig/PipeWire and the observed result;
- short manual controller acceptance checklist;
- source-path notes for the display pipeline;
- Bitwig plug-in-location screenshots or sanitized textual notes;
- current native CLAP/VST3/plugdata/serialosc observations, including “not installed” where applicable;
- Flatpak/host paths that appear suitable for the later broker/frame handoff.

Sanitize serial numbers, account/license data, hostnames, IPs and other personal identifiers before committing.

## Acceptance criteria

S0 is complete only when all of the following are true:

1. A new contributor can understand the tested external setup from repository evidence.
2. Push musical controls demonstrably work in Bitwig through DrivenByMoss.
3. Push display demonstrably works in the baseline configuration.
4. Push audio enumeration and a simple audio result are recorded, whether pass or a clearly characterized blocker.
5. The actual graphical/Flatpak environment relevant to S1/S2 is recorded.
6. The native plug-in and Monome/plugdata starting point is known without pretending S0 solved compatibility.
7. The exact code path from DrivenByMoss semantic rendering to Push USB frame transmission is named and linked to a tested upstream revision.
8. S1 can begin without rediscovering how the existing display pipeline works.

## Expected S1 handoff

S1 should be able to state a concrete interface such as:

```text
semantic renderer -> frame handoff -> project compositor -> Push USB display
```

with the compositor as the sole steady-state owner of the Push display endpoint.

S2 will later establish the canonical logical desktop and capture backend; do not pull that implementation into S0/S1 prematurely.

## Review standard

Do not mark S0 complete from documentation research alone. The claim is about the user’s real Steam Deck + Push 3 + Bitwig setup, so retained real-device evidence is required.
