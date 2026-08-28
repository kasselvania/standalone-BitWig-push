# Current Slice: S0 — External Baseline and Display Reconnaissance

## Status

Ready to start after the founding-architecture PR is accepted.

## Primary claim

Establish a reproducible, retained baseline for Bitwig Studio + Push 3 Controller + DrivenByMoss on the Steam Deck, and identify the exact existing display ownership path we will replace or interpose in S1.

S0 is intentionally observational and minimally invasive. It does **not** implement the compositor yet.

## Reference machine

- Steam Deck running Linux / SteamOS-derived environment;
- Bitwig Studio already installed via Flatpak;
- Ableton Push 3 Controller;
- external USB connection;
- current compatible DrivenByMoss release/source.

## In scope

1. Record host/kernel/Flatpak/Bitwig versions relevant to reproducibility.
2. Record USB enumeration and descriptors for Push 3.
3. Record ALSA and PipeWire device/port enumeration.
4. Confirm Bitwig + DrivenByMoss control baseline:
   - pads;
   - MPE/pressure where configured;
   - encoders;
   - transport;
   - semantic Push display;
   - Push audio device enumeration and a simple audio test.
5. Obtain/build the exact DrivenByMoss source revision corresponding to the tested setup.
6. Trace the Push 3 display construction and USB-send path in that revision.
7. Produce a short S1 design note identifying the narrowest seam for:
   - semantic base-frame export;
   - single compositor ownership of the USB display endpoint.
8. Retain sanitized evidence under `evidence/s0-external-baseline/`.

## Explicit non-goals

- no internal Push disassembly;
- no compute-module purchase;
- no internal USB probing;
- no persistent headless boot changes;
- no VST/Bitwig window capture;
- no large DrivenByMoss fork;
- no redesign of existing Push modes;
- no requirement to solve remote desktop yet.

## Required evidence

At minimum retain textual/sanitized outputs equivalent to:

```text
uname -a
flatpak info <Bitwig app id>
lsusb
lsusb -v -d 2982:1969
aconnect -l   (or equivalent ALSA sequencer enumeration)
wpctl status  (or equivalent PipeWire graph/device summary)
```

Also retain:

- tested Bitwig version;
- tested DrivenByMoss revision/version;
- whether Push audio was selected through Bitwig/PipeWire and the observed result;
- short manual controller acceptance checklist;
- source-path notes for the display pipeline.

Sanitize serial numbers, account/license data, hostnames, IPs and other personal identifiers before committing.

## Acceptance criteria

S0 is complete only when all of the following are true:

1. A new contributor can understand the tested external setup from repository evidence.
2. Push musical controls demonstrably work in Bitwig through DrivenByMoss.
3. Push display demonstrably works in the baseline configuration.
4. Push audio enumeration and a simple audio result are recorded, whether pass or a clearly characterized blocker.
5. The exact code path from DrivenByMoss semantic rendering to Push USB frame transmission is named and linked to a tested upstream revision.
6. S1 can begin without rediscovering how the existing display pipeline works.

## Expected S1 handoff

S1 should be able to state a concrete interface such as:

```text
semantic renderer -> frame handoff -> project compositor -> Push USB display
```

with the compositor as the sole steady-state owner of the Push display endpoint.

## Review standard

Do not mark S0 complete from documentation research alone. The claim is about the user’s real Steam Deck + Push 3 + Bitwig setup, so retained real-device evidence is required.