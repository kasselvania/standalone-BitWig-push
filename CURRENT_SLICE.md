# Current Slice: S0 — macOS Reference Fixture and Display Reconnaissance

## Status

Ready to start from current `main` after the Mac-first fixture update is merged.

## Primary claim

Establish a reproducible, retained baseline for the maintainer's working macOS + Bitwig Studio + Push 3 Controller + DrivenByMoss fixture, and identify the exact existing display ownership path that V1 will replace or interpose.

The Mac is used because it is currently available and already has the working Bitwig/DrivenByMoss environment. S0 does **not** make macOS, one monitor geometry, or one capture API normative for the project.

S0 is observational and minimally invasive. It does not implement the compositor, adaptive visual resolver, ScreenCaptureKit helper, managed desktop, headless appliance, alternate plug-in runtime, or hardware integration.

## Reference fixture

- macOS development computer;
- Bitwig Studio already installed and activated;
- Ableton Push 3 Controller;
- ordinary external USB connection;
- current compatible DrivenByMoss release/source.

The Steam Deck remains the maintainer's first appliance host and a later Linux portability fixture. The wooden base, battery, Monome/serialosc work, plugdata work, and prior yabridge experiments are outside this slice.

## In scope

1. Record macOS, kernel, hardware architecture, Bitwig, and graphical/display versions relevant to reproducing this fixture.
2. Record Push USB and audio enumeration through macOS tools.
3. Confirm the Bitwig + DrivenByMoss control baseline:
   - pads;
   - MPE/pressure where configured;
   - encoders;
   - transport;
   - semantic Push display;
   - Push audio-device enumeration and one simple audio result.
4. Record the current Bitwig window/display state only as fixture evidence:
   - attached displays and scaling;
   - Bitwig application-window dimensions;
   - Bitwig display profile/panel arrangement where observable;
   - whether native-device expanded/floating views can be opened in this fixture.
5. Obtain or identify the exact DrivenByMoss source revision corresponding to the tested setup.
6. Trace the Push 3 semantic-display construction and USB-send path in that revision.
7. Confirm whether the tested revision follows the expected shape:

```text
semantic graphic renderer
        -> IBitmap
        -> Push2Display.send(IBitmap)
        -> PushUsbDisplay.send(IBitmap)
        -> USB encoding/transport
```

8. Produce a V1 design note identifying the narrowest seam for:
   - a no-op frame-pipeline insertion;
   - semantic base-frame access;
   - one steady-state USB display writer;
   - later external `VisualSourceFrame` ingress.
9. Retain sanitized evidence under `evidence/s0-macos-reference-fixture/`.

## Explicit non-goals

- no claim of universal monitor/layout adaptation;
- no visual-source capture or resolver implementation;
- no ScreenCaptureKit code or Screen Recording permission request;
- no internal Push disassembly or connector probing;
- no compute-module purchase;
- no headless boot changes;
- no Steam Deck or Linux validation;
- no yabridge repair or alternate Bitwig runtime;
- no plugdata, Pure Data, Monome, or serialosc integration work;
- no broad DrivenByMoss redesign;
- no redesign of existing Push modes;
- no remote-desktop implementation.

## Required evidence

At minimum retain sanitized outputs equivalent to:

```text
sw_vers
uname -a
uname -m
system_profiler SPHardwareDataType
system_profiler SPUSBDataType
system_profiler SPAudioDataType
system_profiler SPDisplaysDataType
```

Where useful, retain a sanitized targeted USB tree or `ioreg` extract for Push rather than committing an unnecessarily broad machine inventory.

Also retain:

- tested Bitwig version/build;
- tested DrivenByMoss version/revision;
- whether Push audio was selected in Bitwig and the observed result;
- a short manual controller acceptance checklist;
- source-path notes for the semantic display pipeline;
- current monitor/window/display-profile notes as fixture evidence only;
- the exact proposed V1A no-op frame seam;
- any build/install steps needed to reproduce the tested DrivenByMoss derivative locally.

Sanitize serial numbers, account/license data, hostnames, user paths, and other personal identifiers before committing.

## Acceptance criteria

S0 is complete only when all of the following are true:

1. A contributor can reproduce and understand the tested Mac fixture.
2. Push musical controls demonstrably work in Bitwig through DrivenByMoss.
3. The semantic Push display demonstrably works in the baseline configuration.
4. Push audio enumeration and one simple audio result are recorded, whether pass or a clearly characterized blocker.
5. The macOS/display environment relevant to later visual work is recorded without being generalized into a product requirement.
6. The exact path from DrivenByMoss semantic rendering to Push USB frame transmission is named and linked to the tested upstream revision.
7. The V1A no-op frame-pipeline seam is concrete enough to implement without rediscovering the current display path.
8. The Steam Deck is explicitly preserved as a later Linux/appliance validation fixture rather than treated as abandoned.

## Expected V1 handoff

V1 should begin with a no-op cut equivalent to:

```text
semantic renderer
        -> PushFramePipeline (no-op first)
        -> PushDisplayTransport
        -> Push USB display
```

The leading current-source hypothesis is to cut at or immediately before `Push2Display.send(IBitmap)` hands the complete semantic frame to `PushUsbDisplay`. S0 must confirm this against the exact tested revision.

The first implementation keeps composition and final USB transmission in one DrivenByMoss-derived process. External capture and platform-specific helpers begin only after synthetic composition and IPC ingress are proven.

## Review standard

Do not mark S0 complete from documentation research alone. The claim is about the maintainer's real Mac + Push 3 + Bitwig fixture, so retained real-device evidence is required.
