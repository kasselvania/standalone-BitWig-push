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

The active implementation fixture is macOS because the maintainer's working Mac + Bitwig + DrivenByMoss + Push system is currently available. Steam Deck/Linux remains an explicit second-host portability and appliance checkpoint.

## V0 / S0 — macOS reference fixture baseline — accepted

**Claim:** the working Mac + Bitwig + Push fixture and the existing semantic-display path are reproducibly understood.

Accepted evidence includes:

- real Push control, display, and audio behavior;
- official DrivenByMoss artifact identity;
- exact upstream source tag/commit/tree;
- complete semantic-renderer-to-USB trace;
- lawful frame seam inside `Push2Display.send(IBitmap)`.

Retained under `evidence/s0-macos-reference-fixture/`.

## V1A-0 — derivative fork and build baseline — accepted

**Claim:** the exact accepted DrivenByMoss source is under correct fork custody and can be built, installed, exercised, and rolled back safely.

Accepted evidence includes:

- true `kasselvania/DrivenByMoss` fork;
- immutable `pushwig/upstream-26.4.1` basis;
- explicit Java 21/Maven build;
- bounded local-vs-official artifact comparison;
- sole-artifact installation;
- eleven-row real Push parity;
- exact official rollback.

Retained under `evidence/v1a0-drivenbymoss-build-baseline/`.

## V1A — identity frame pipeline — accepted

**Claim:** a project-owned synchronous frame seam can be inserted without changing the semantic bitmap or USB transport behavior.

Accepted path:

```text
semantic IBitmap
        -> PassThroughPushFramePipeline
        -> exact same IBitmap
        -> unchanged PushUsbDisplay
```

Accepted evidence includes:

- direct-reference bytecode and harness proof;
- one guarded pipeline call followed by one existing USB send;
- no project per-frame allocation, pixel access, queue, thread, or platform dependency;
- byte-identical `PushUsbDisplay.class`;
- bounded executable delta;
- eleven-row real Push parity;
- no visual change;
- ordinary shutdown and exact rollback.

Merged into DrivenByMoss `pushwig/main` at `033ccef8c64f08e8d8d41fa90d48fa06b326a1a1` and retained under `evidence/v1a-identity-frame-pipeline/`.

## V1B — startup-scoped static synthetic overlay — active

**Claim:** the accepted frame pipeline can add one bounded project-owned visual mark to the persistent semantic bitmap without changing pixels outside its declared region or changing USB transport ownership.

Default path remains pass-through. The preferred diagnostic activation is:

```text
-Dpushwig.syntheticOverlay=true
```

The first mark is fixed and opaque. V1B intentionally does not animate or hot-toggle because the persistent bitmap and semantic dirty-suppression lifecycle do not yet provide damage restoration.

Acceptance includes:

- exact startup property selection;
- fixed two-color mark at declared bounds;
- one reusable renderer and one additional render callback per enabled send;
- same `IBitmap` reference returned;
- outside-region pixel preservation;
- no whole-frame clear, coordinate error, expansion, or trail;
- representative semantic mode updates remain correct;
- property-off restart removes the mark;
- timing percentiles and allocation observations retained;
- unchanged `PushUsbDisplay` and one writer;
- all eleven real Push checks while enabled;
- exact official rollback.

If a second render callback clears or unpredictably damages the semantic image, stop and retain the failure rather than widening the slice.

See [`V1B_SYNTHETIC_COMPOSITION.md`](V1B_SYNTHETIC_COMPOSITION.md).

## V1C — external generated-frame ingress

**Claim:** a process outside Bitwig can publish a generated immutable `VisualSourceFrame` that the in-process compositor consumes safely.

Acceptance:

- platform-neutral frame contract;
- explicit control/status and latest-frame transport;
- no unbounded queue;
- helper absence, restart, stale data, and malformed metadata produce semantic fallback;
- compositor never waits for the helper;
- no operating-system capture API is required;
- no second Push USB owner.

## V2M — macOS dedicated-window visual lens

**Claim:** the first capture backend can discover and display a useful Bitwig/native-device/plug-in source without relying on physical desktop coordinates.

Preferred first target:

- a floating Bitwig Expanded Device View, preferably Sampler;
- followed by one ordinary plug-in editor window.

Leading backend:

- normal macOS helper application using ScreenCaptureKit;
- platform-neutral `VisualSourceFrame` output over the V1C boundary.

Acceptance includes source identity, resize/move/reopen behavior, useful Push crop, permission denial/revocation fallback, and no macOS handles in core contracts.

## V2A — semantic-seeded pixel-anchor benchmark

**Claim:** selected-device semantics can seed a low-cost, confidence-validated anchor resolver for known visual regions.

Compare at minimum:

- normalized flattened grayscale vectors;
- grayscale normalized cross-correlation;
- edge-map normalized cross-correlation;
- coarse-to-fine multi-scale matching;
- optional feature matching only if simpler methods cannot support required scaling.

Acceptance includes at least three native-device targets, strong negatives, multi-anchor geometry, zero wrong locks in the retained matrix, abstention, localization error, acquisition/revalidation timing, memory, and confidence margins.

See [`SEMANTIC_PIXEL_ANCHOR_RESOLVER.md`](SEMANTIC_PIXEL_ANCHOR_RESOLVER.md).

## V2P — Linux/Steam Deck second-host checkpoint

**Claim:** frame, composition, semantic, and adapter contracts survive movement from the Mac implementation fixture to Linux.

Acceptance includes:

- Push control/display reproduction;
- no macOS-specific core changes;
- Linux producer/capture backend satisfying the same frame contract;
- Flatpak/host IPC characterization;
- at least one visual lens where supported;
- Deck CPU/power observations;
- failures localized to backend/runtime integration.

## V3 — visual-source and adapter SDK

**Claim:** source discovery and visual profiles are public, testable, and community-extensible.

Acceptance includes platform-neutral frame/resolver contracts, semantic matching, source preference, normalized crops, anchors, compatibility declarations, confidence, fallback, locally generated proprietary-UI descriptors, and shared Mac/Linux schema.

## V4 — attached-mode embedded Bitwig resolver

**Claim:** a useful visual embedded in Bitwig's main window can be found adaptively across supported layouts.

Acceptance includes semantic identity, application-window geometry, panel state where available, normalized geometry, confidence-validated anchors, revalidation after layout/scale/device changes, bounded maintenance cost, safe fallback, and a defined compatibility matrix.

## V5 — bounded calibration and profile portability

**Claim:** unsupported layouts can be enabled without repeated manual cropping.

Acceptance includes version-scoped calibration, normalized region, local anchors/descriptors, invalidation rules, survival across monitor movement, safe disabling, and profile export without proprietary screenshots.

## V6 — attached-mode portability release

**Claim:** the visual extension is supportable for ordinary users rather than only the maintainer fixtures.

Acceptance matrix includes macOS and Linux backends, multiple Bitwig sizes/scales/layouts, single and multi-monitor placement, source recreation, selected-device transitions, permission/restart recovery, and multiple hardware hosts.

## V7 — additional operating-system backend

**Claim:** another Bitwig platform can use existing compositor and adapter contracts without redesign.

Leading target: Windows Graphics Capture or another supported Windows capture API.

# Track A — All-in-one appliance

Track A consumes Track V. It does not define Track V.

## A0 — maintainer hardware survey

Document the existing wooden stand, Deck/dock/cables, protected battery, PD profiles, Push power cable, representative draw, airflow, strain relief, and service access.

## A1 — managed/headless Steam Deck profile

Prove unattended service start, ordinary Push-only workflow, controlled geometry without core-contract changes, restart/recovery, and safe shutdown.

## A2 — battery-powered portable maintainer appliance

Prove the Deck, existing battery, stand, Push, and stock rear ports form a portable all-in-one instrument with stable USB/audio/display, wireless full desktop, measured runtime/thermals, protected components, charging transitions, and low-battery shutdown.

A2 is a complete project success, not scaffolding.

## A3 — reproducible alternate-host appliance

Publish a Framework/compact-x86 BOM, mechanical/power topology, supported Linux profile, Track V acceptance suite, battery/runtime/thermal behavior, service/recovery procedure, and ordinary rear-USB option.

# Track H — Internal connector and native compute

Track H is a parallel open-hardware/reverse-engineering effort.

## H0 — Push bay and carrier survey

Retain calibrated photographs, markings, connector geometry, compute/SSD/thermal/antenna/battery keep-outs, continuity points, and measured power/hub/mux/sideband observations separated from inference.

## H1 — passive CM11EB diagnostic edge card

Publish a mechanically correct male edge card exposing only proven grounds, candidate USB 2 pairs, and purpose-bound low-speed observations, with power contacts disconnected by default.

## H2 — protected USB development card

Add selectable candidate USB paths, ESD protection, strain relief, explicit VBUS isolation/injection, current/voltage observation, and clear host/device orientation.

## H3 — internal USB enumeration

Prove an external host can enumerate useful Push functions through the internal carrier path and compare MIDI/control, display, and audio behavior with the external-USB baseline.

## H4 — targeted high-speed/sideband tooling

Add USB 3, PCIe, eSPI, or other signals only for a specific justified experiment with proper high-speed design. Do not fan all 300 contacts to generic headers.

## H5 — used Compute Element bring-up

Prove a suitable surplus CM11EB-family element can boot the accepted Linux/Bitwig stack, network, enumerate Push hardware, meet thermal bounds, and run Track V acceptance unchanged.

## H6 — native-bay battery/thermal final form

Integrate Compute Element, protected battery/power path, storage, antennas, cooling, charging, low-voltage save/shutdown, serviceability, recovery, and acceptable latency.

# Optional compatibility and ecosystem work

These may proceed separately but are not gates for Track V, A, or H:

- Wine/yabridge experiments, including known Deck UI/usability problems;
- plugdata/Pure Data integration;
- Monome/serialosc integration;
- device-specific analyzers and direct visual sources;
- alternative controller integrations.

The core project should expose stable semantic, visual-source, and compositor contracts without absorbing those independent roadmaps.