# Roadmap

The roadmap has parallel tracks. They share interfaces and evidence, but they do not form one all-or-nothing ladder.

## Valid project successes

Each outcome below is independently valuable:

1. **universal visual extension** — adaptive Bitwig/native-device/plug-in visuals mixed with DrivenByMoss on Push for ordinary users;
2. **maintainer appliance** — the existing Steam Deck, battery, and wooden stand operating as a portable headless instrument;
3. **reproducible appliance** — a documented Framework/compact-x86 version others can build;
4. **connector development platform** — an open CM11EB diagnostic edge card and carrier findings;
5. **native-bay final form** — used Compute Element, battery, power, and thermals integrated inside Push.

A later result is not required to validate an earlier one.

See [`PROJECT_TRACKS.md`](PROJECT_TRACKS.md).

# Track V — Universal visual/controller software

This is the primary open-source software track.

The first implementation fixture is macOS because the maintainer's working Mac + Bitwig + DrivenByMoss + Push system provides the shortest development loop. Steam Deck/Linux remains an explicit second-host portability and appliance checkpoint.

## S0 / V0 — macOS reference fixture — accepted

**Claim:** the first real fixture works and the semantic-display-to-USB path is understood.

Accepted evidence includes:

- Bitwig, Push controls, MPE, audio, and semantic display;
- macOS/USB/audio/display fixture data;
- exact official DrivenByMoss artifact and upstream source;
- persistent 960×160 semantic bitmap;
- `Push2Display.send(IBitmap)` to `PushUsbDisplay.send(IBitmap)` seam;
- exact official rollback baseline.

## V1A-0 — derivative custody/build baseline — accepted

**Claim:** exact unmodified upstream source can be built, installed, exercised, and rolled back safely.

Accepted evidence includes:

- true `kasselvania/DrivenByMoss` fork;
- immutable `pushwig/upstream-26.4.1` basis;
- `pushwig/main` integration branch;
- explicit Java 21/Maven toolchain;
- bounded official/local artifact comparison;
- real Push parity and exact rollback.

## V1A — identity frame pipeline — accepted

**Claim:** a project-owned synchronous frame seam can be inserted without changing output.

Accepted path:

```text
semantic IBitmap
        -> PushFramePipeline
        -> same IBitmap
        -> unchanged PushUsbDisplay
```

Acceptance established reference identity, source/bytecode call order, bounded artifact delta, real Push behavior, normal shutdown, and exact rollback.

## V1B — static bounded synthetic composition — accepted

**Claim:** project-owned pixels can be painted into the live semantic bitmap without changing pixels outside a declared region.

Accepted result:

- ordinary startup remains pass-through;
- startup diagnostic activation draws one fixed pink/white mark;
- one additional render callback returns the same bitmap;
- target region changed as expected;
- outside-region mismatch count was zero;
- repeated sends and representative modes remained coherent;
- p95/max processing was bounded;
- property-off restart removed the mark;
- real Push baseline and exact rollback passed.

V1B proves static in-place painting. It does not prove movement, erasure, stale fallback, or dynamic frame ownership.

## V1C-0 — dynamic raster restoration feasibility — accepted

**Claim:** select and prove the smallest frame-ownership/restoration architecture that can replace or remove a changing visual while restoring exact current semantic pixels.

Selected result:

```text
newest copied ModelInfo
        -> full current-semantic redraw
        -> current valid visual or no visual
        -> same persistent IBitmap
        -> unchanged PushUsbDisplay
```

Accepted evidence:

- Candidate A tested first and selected;
- 1,000 complete offline cycles / 7,000 transitions;
- 1,000 real-Bitwig samples;
- movement through four positions;
- replacement, absence, stale, and invalid states;
- semantic update beneath covered pixels;
- zero outside-region mismatch;
- zero old-region restoration mismatch;
- zero post-absence/stale/invalid full-frame mismatch;
- zero semantic-update restoration mismatch;
- p95 `0.413209 ms`, maximum `7.356958 ms`;
- bounded memory;
- real Push controls/audio/display;
- normal shutdown and exact rollback;
- no production source PR or transport change.

Candidates B–D were not reached after Candidate A satisfied the required ordered gate.

## V1C — dynamic local composition lifecycle — active

**Claim:** implement the accepted Candidate A model as bounded production source with generated local visual states.

Production rule:

```text
newest copied ModelInfo
        -> retain before redraw decision
        -> full semantic redraw only for selected dynamic-local mode
        -> current valid local visual or no visual
        -> same persistent IBitmap
        -> one existing PushUsbDisplay.send
```

Required local lifecycle:

```text
A — initial
B — moved/enlarged with partial overlap
C — moved/reduced
D — replacement content/geometry
NONE
STALE
INVALID
```

Acceptance includes:

- exact three-path production envelope;
- protected default-false redraw hook;
- ordinary dirty-render behavior preserved;
- pass-through default preserved;
- V1B static path preserved;
- dynamic property precedence explicit;
- zero outside, restoration, semantic-only, semantic-update, overlay-only, and notification lifecycle mismatches;
- same-reference pipeline;
- no second bitmap, snapshot, queue, external frame, or second USB owner;
- bounded performance/allocation;
- full real Push controls/audio/display;
- normal shutdown and exact official rollback;
- paired open source/evidence PRs.

No external process or capture API is part of V1C.

## V1D — external generated-frame ingress

**Claim:** an optional process outside Bitwig can publish immutable/generated visual frames without blocking the controller extension.

Leading contract:

```text
VisualSourceFrame
  source_id
  source_role
  width
  height
  pixel_format
  sequence
  timestamp
  validity
  stale_reason
  confidence
  frame_data
  optional_metadata
```

Acceptance:

- explicit control/status channel;
- latest-frame-wins storage;
- no unbounded queue;
- compositor never waits for producer;
- helper absence, restart, stale sequence, malformed metadata, and invalid frame restore semantic-only output through V1C;
- no macOS type enters the frame contract;
- one generated external source appears on Push;
- real controls/audio remain independent.

## V2 — macOS dedicated-window visual lens

**Claim:** a macOS helper can discover and capture one useful dedicated Bitwig/native-device/plugin window without physical desktop coordinates.

Preferred first targets:

- floating native Expanded Device View, ideally Sampler;
- one ordinary plug-in editor.

Acceptance:

- ScreenCaptureKit remains inside a normal helper application;
- semantic state selects the intended source role;
- moving/resizing or moving between monitors preserves identity;
- a source-relative crop appears usefully on Push;
- closing/reopening recovers;
- permission denial/revocation produces exact semantic fallback;
- no Apple window/image handle enters core contracts.

## V2A — semantic-seeded pixel anchor benchmark

**Claim:** selected-device semantics can seed a lightweight confidence-validated pixel-anchor resolver.

Algorithms include:

- normalized grayscale vectors;
- grayscale cross-correlation;
- edge-map cross-correlation;
- coarse-to-fine multi-scale search;
- feature matching only if simpler approaches fail supported scaling.

Acceptance includes:

- at least three native-device targets and strong negatives;
- at least two geometrically consistent anchors for a production lock;
- correct-lock, abstention, wrong-lock, localization, and confidence metrics;
- acquisition/reacquisition and validation timing;
- CPU, memory, and optional power observations;
- zero wrong locks in the retained matrix, with abstention allowed;
- semantic fallback on ambiguity.

## V2P — Linux/Steam Deck second-host checkpoint

**Claim:** core semantic, composition, dynamic-restoration, frame, and adapter contracts survive movement to Linux.

Acceptance:

- Push semantic control/audio/display reproduce on Linux;
- core compositor/frame contracts require no macOS-specific change;
- a Linux test producer or capture backend satisfies the same frame contract;
- Flatpak/host IPC constraints are characterized;
- one useful visual lens reproduces where backend behavior permits;
- CPU and power are measured on Deck;
- failures remain localized to runtime/backend integration.

V2P is required before a Linux support claim, but it does not block the first Mac implementation.

## V3 — visual-source and adapter SDK

**Claim:** source discovery and profiles are public, testable, and community-extensible.

Acceptance:

- platform-neutral frame and resolver contracts;
- adapter schema for semantic matching, source preference, normalized crop, anchors, validation, compatibility, and fallback;
- one native-device and one plug-in example;
- tested-version/scale declarations;
- no casual redistribution of proprietary UI templates;
- Mac and Linux results represented without schema forks.

## V4 — attached-mode embedded Bitwig resolver

**Claim:** useful visuals embedded in Bitwig's main window can be found adaptively across supported layouts.

Acceptance:

- semantic device identity plus application-window geometry;
- panel state where exposed;
- normalized geometry and confidence-validated anchors rather than physical coordinates;
- revalidation after resize, panel/display-profile/UI-scale/device changes;
- bounded local validation after lock;
- wrong/low-confidence cases abstain;
- one native device across a defined matrix.

## V5 — bounded calibration and profile portability

**Claim:** unsupported layouts can be enabled once rather than recropped every session.

Acceptance:

- version-scoped calibration;
- normalized regions and locally generated descriptors;
- survival across ordinary window movement and monitor changes;
- invalidation rules;
- community export/import without private screenshots.

## V6 — attached-mode portability release

**Claim:** the visual extension is supportable for ordinary users.

Matrix includes:

- macOS and at least one Linux backend;
- multiple window sizes and supported UI scales;
- at least two display profiles/panel arrangements;
- single/multi-monitor placement;
- source movement, resize, hide, close, and reopen;
- selected-device transitions and negatives;
- helper/compositor/resolver restart;
- permission denial/recovery;
- multiple hardware hosts.

## V7 — additional operating-system backend

**Claim:** another Bitwig platform can implement the same contracts without compositor or adapter redesign.

Leading target: Windows Graphics Capture or another supported Windows capture API.

# Track A — All-in-one appliance

Track A consumes Track V. It does not define Track V.

## A0 — maintainer hardware survey

Retain:

- wooden-base internal dimensions and mounting opportunities;
- Steam Deck/dock/cable topology;
- battery model, capacity, PD profiles, and simultaneous-output behavior;
- tested PD-to-barrel voltage, polarity, current, and temperature;
- representative Push/host power draw;
- airflow, strain relief, and service access.

## A1 — managed/headless Steam Deck profile

Acceptance:

- boot/start services without manual desktop setup;
- representative create/open/play/record/save workflow from Push;
- managed geometry without changing attached-mode contracts;
- service restart and safe shutdown/recovery;
- remote client not required for ordinary musical control.

## A2 — battery-powered maintainer appliance

Acceptance:

- battery powers host and Push through characterized protected paths;
- USB/control/audio/display remain stable;
- full Bitwig desktop available wirelessly for exceptional work;
- runtime and thermal behavior measured;
- components/cables retained by the stand;
- safe charging transitions and low-battery shutdown.

A2 is a complete project success.

## A3 — reproducible alternate-host appliance

Acceptance:

- public Framework/compact-x86 BOM and mechanical/power topology;
- supported Linux/runtime profile;
- same Track V suite;
- battery/runtime/thermal evidence;
- service/recovery procedure;
- ordinary rear Push USB remains supported.

# Track H — Internal connector and native compute

Track H is a parallel open-hardware/reverse-engineering effort.

## H0 — Push bay and carrier survey

Retain:

- calibrated photographs;
- PCB/IC/connector markings;
- connector geometry, keying, and mounting dimensions;
- compute, SSD, thermal, antenna, and battery keep-outs;
- accessible continuity points;
- power, hub, mux, and sideband observations separated from inference.

## H1 — CM11EB diagnostic edge card D0

Acceptance:

- male edge geometry and pin map independently reviewed;
- proven grounds and candidate USB 2 pairs exposed;
- selected low-speed observations only with stated purpose;
- power disconnected by default;
- public schematic/layout/manufacturing notes;
- usable while Push remains on the stand/open bench.

## H2 — protected USB development card D1

Acceptance:

- selectable candidate USB paths;
- ESD protection and strain relief;
- explicit VBUS isolation/injection controls;
- voltage/current observation;
- clear host/device orientation;
- no uncontrolled tying of Push and host power.

## H3 — internal USB enumeration

Acceptance:

- actual Push functions enumerate through the carrier path;
- MIDI/control, display, and audio compared with external USB baseline;
- mux/enable/sideband requirements retained;
- power handled deliberately;
- failures characterized.

## H4 — targeted high-speed/sideband tooling

Add USB 3, PCIe, eSPI, or other signals only for a specific justified experiment with controlled-impedance design.

## H5 — used Compute Element bring-up

Acceptance:

- UEFI/BIOS and carrier-EC requirements understood;
- Linux boots from serviceable storage;
- networking and Push hardware enumerate;
- thermal behavior bounded;
- Track V tests run unchanged.

## H6 — native-bay battery/thermal final form

Acceptance:

- no external compute host;
- validated charging and play-while-charging;
- low-voltage warning, save, and clean shutdown;
- representative thermal/load limits;
- battery replacement/service procedure;
- external recovery path;
- acceptable audio/control/display latency.

# Optional compatibility and ecosystem work

These efforts may proceed separately but are not gates for Track V, A, or H:

- Wine/yabridge experiments, including known Deck UI/usability problems;
- plugdata/Pure Data integration;
- Monome/serialosc integration;
- device-specific analyzers and direct visual sources;
- alternative controller integrations.

The core project should expose public semantic, visual-source, and compositor contracts without absorbing those independent roadmaps.
