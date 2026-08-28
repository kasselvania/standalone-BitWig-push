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

## V0 / current S0 — Reference fixture baseline

**Claim:** the maintainer's known-good Push/Bitwig fixture is reproducible and the existing semantic-display path is understood.

Reference fixture:

- Steam Deck / Linux;
- Flatpak Bitwig Studio;
- Push 3 Controller over ordinary external USB;
- current compatible DrivenByMoss integration.

Acceptance:

- Bitwig launches;
- Push controls, audio enumeration, and semantic display are exercised;
- USB/ALSA/PipeWire/graphical-session evidence is retained;
- the tested DrivenByMoss revision is identified;
- the semantic-renderer-to-USB path is traced;
- the narrow compositor handoff seam is named.

This proves one test fixture. It does not define universal hardware, packaging, or monitor geometry.

## V1 — Independent framebuffer ownership

**Claim:** a project-owned compositor can own Push's display without degrading semantic control.

Acceptance:

- valid 960×160 frames reach Push;
- a synthetic layer can be mixed with the semantic/base frame;
- only one steady-state process owns the display endpoint;
- pads, encoders, transport, MIDI/MPE, and audio remain independent;
- compositor failure has semantic/recovery fallback;
- frame cadence, CPU use, and reconnect behavior are measured.

## V2 — Portable dedicated-window visual lens

**Claim:** the system can discover and display a useful source without relying on physical desktop coordinates.

Preferred first target:

- a Bitwig native Expanded Device View opened or undocked as a floating window, preferably Sampler;
- followed by one ordinary native plug-in editor window.

Acceptance:

- DrivenByMoss/Bitwig semantic state identifies the selected target;
- resolver discovers the correct top-level source window;
- moving/resizing the source or moving it to another monitor does not break identity;
- a source-relative crop appears usefully on Push;
- closing/reopening the source recovers automatically;
- semantic fallback remains available.

V2 is already a broadly useful desktop extension.

## V2A — Semantic-seeded pixel anchor benchmark

**Claim:** selected-device semantics can seed a low-cost, confidence-validated pixel-anchor resolver that locates a known Bitwig visual representation without generic desktop recognition.

The first benchmark may run entirely against locally captured fixture frames before live integration.

Algorithms to compare include:

- flattened normalized grayscale-vector similarity;
- grayscale normalized cross-correlation;
- edge-map normalized cross-correlation;
- coarse-to-fine multi-scale matching;
- optional feature matching only if simpler methods cannot handle supported scale changes.

Acceptance:

- at least three native Bitwig device targets plus strong negative candidates are represented;
- semantic device identity selects the correct adapter and anchor constellation;
- at least two anchors with expected relative geometry are required for a production lock;
- selection changes and source resize trigger bounded reacquisition;
- correct-lock, abstention, wrong-lock, localization-error, and confidence-margin metrics are retained;
- acquisition/reacquisition latency, per-check CPU time, working memory, and optional fixture power delta are measured;
- zero wrong locks are observed in the retained acceptance matrix, with abstention permitted;
- ambiguous/unsupported cases fall back to semantic output;
- one simple algorithm is selected for the first live implementation or the experiment records why anchor matching is not yet viable.

Provisional target bands are documented in [`SEMANTIC_PIXEL_ANCHOR_RESOLVER.md`](SEMANTIC_PIXEL_ANCHOR_RESOLVER.md); they are not current performance claims.

## V3 — Visual-source and adapter SDK

**Claim:** source discovery and visual profiles are public, testable, and community-extensible.

Acceptance:

- platform-neutral `VisualSourceFrame` and resolver contracts exist;
- adapter schema supports semantic matching, source preference, normalized crop, anchor constellations, validation, confidence, compatibility, and fallback;
- one native-device adapter and one plug-in adapter are retained as examples;
- profiles declare tested versions/scales rather than implying universal compatibility;
- adapter validation can distinguish a correct source from a wrong/stale source;
- proprietary UI template pixels are generated locally or otherwise handled without casual redistribution.

## V4 — Attached-mode embedded Bitwig resolver

**Claim:** a useful visual embedded in Bitwig's main window can be found adaptively across supported layouts.

Acceptance:

- resolver uses semantic device identity plus Bitwig application-window geometry;
- panel layout/visibility state is used where the controller API exposes it;
- normalized geometry and confidence-validated anchor constellations replace physical desktop coordinates;
- source is revalidated after resize, panel movement, display-profile change, UI-scale change, and device selection change;
- locked-state maintenance uses bounded local validation rather than full-frame search at display cadence;
- wrong/low-confidence resolution falls back rather than showing unrelated pixels;
- at least one native Bitwig device is demonstrated across a defined configuration matrix.

## V5 — Bounded calibration and profile portability

**Claim:** unsupported layouts can be enabled without requiring users to crop the screen every session.

Acceptance:

- one-time/version-scoped calibration flow exists;
- records include source identity, normalized region, UI scale/version context, locally generated anchors/descriptors, and invalidation rules;
- calibration survives ordinary window movement and monitor changes;
- invalid records are detected and safely disabled;
- community profiles can be exported/imported without private screenshots or proprietary assets.

## V6 — Linux attached-mode portability release

**Claim:** the visual extension is supportable for ordinary Linux users rather than only the maintainer fixture.

Acceptance matrix includes, where relevant:

- X11 and/or Wayland capture backend(s);
- multiple Bitwig window sizes;
- supported UI scales;
- at least two display profiles/panel arrangements;
- single- and multi-monitor placement;
- source windows moved, resized, hidden, and reopened;
- selected-device transitions and negative candidates;
- compositor/capture/resolver restart;
- permission denial and recovery;
- multiple hardware hosts, with Steam Deck only one row in the matrix.

## V7 — Additional operating-system backends

**Claim:** the platform-neutral core can support non-Linux Bitwig users.

Possible backends:

- Windows Graphics Capture;
- macOS ScreenCaptureKit;
- other supported APIs where needed.

Acceptance for each operating system:

- window/source discovery works through the platform adapter;
- existing visual adapters and anchor policies require no compositor changes;
- relevant permission lifecycle is handled;
- a portability matrix is retained;
- semantic fallback remains universal.

V7 is incremental platform coverage, not a prerequisite for the Linux release.

# Track A — All-in-one appliance

Track A consumes Track V. It does not define Track V.

## A0 — Maintainer hardware survey

**Claim:** document the already-owned appliance parts.

Retain:

- wooden-base internal dimensions and mounting opportunities;
- Steam Deck/dock/cable topology;
- battery model, capacity, PD profiles, and simultaneous-output behavior;
- tested PD-to-barrel voltage, polarity, current behavior, and temperature;
- Push/host representative power draw;
- airflow, strain relief, and service access.

## A1 — Managed/headless Steam Deck profile

**Claim:** the maintainer's Deck can run the visual/controller stack without using its built-in screen during ordinary operation.

Acceptance:

- boot/start services without manual desktop setup;
- Push can perform a representative create/open/play/record/save workflow;
- managed geometry may be used without changing attached-mode contracts;
- services restart cleanly;
- safe shutdown/recovery exists;
- remote client is not required for ordinary musical control.

## A2 — Battery-powered portable maintainer appliance

**Claim:** the Deck, existing battery, stand, Push, and stock rear ports form a portable all-in-one instrument.

Acceptance:

- battery powers host and Push through characterized protected paths;
- USB/control/audio/display remain stable through the chosen dock/hub topology;
- full Bitwig desktop is available wirelessly for exceptional work;
- representative runtime and thermal behavior are measured;
- components/cables are retained and protected by the stand;
- charging transitions and low-battery shutdown are safe.

A2 is a complete project success for the maintainer, not merely scaffolding.

## A3 — Reproducible alternate-host appliance

**Claim:** another builder can assemble a documented Framework or compact-x86 version without requiring the maintainer's exact Deck or stand.

Acceptance:

- public BOM and mechanical/power topology;
- supported Linux/runtime profile;
- same Track V acceptance suite;
- documented battery/runtime/thermal behavior;
- service and recovery procedure;
- ordinary rear Push USB remains supported.

# Track H — Internal connector and native compute

Track H is a parallel open-hardware/reverse-engineering effort.

## H0 — Push bay and carrier survey

**Claim:** document the empty standalone bay and carrier reproducibly.

Retain:

- calibrated photographs;
- PCB/IC/connector markings;
- connector geometry, keying, and mounting dimensions;
- compute, SSD, thermal, antenna, and battery keep-outs;
- accessible continuity points;
- power, hub, mux, and sideband observations separated from inference.

## H1 — CM11EB diagnostic edge card D0

**Claim:** create a mechanically correct passive diagnostic card.

Acceptance:

- male edge geometry and pin map independently reviewed;
- proven grounds and candidate USB 2 pairs exposed;
- selected low-speed observations exposed only with a stated purpose;
- power contacts disconnected by default;
- public schematic/layout/manufacturing notes;
- board usable while Push remains on the stand/open bench.

## H2 — Protected USB development card D1

**Claim:** make internal-host enumeration experiments repeatable and electrically bounded.

Acceptance:

- selectable candidate USB paths;
- ESD protection and strain relief;
- explicit VBUS isolation/injection controls;
- voltage/current observation;
- clear host/device orientation;
- no uncontrolled connection of Push and host power sources.

## H3 — Internal USB enumeration

**Claim:** an external Linux host can enumerate useful Push functions through the internal carrier path.

Acceptance:

- actual USB functions enumerate;
- MIDI/control, display, and audio behavior are compared with the external USB baseline;
- mux/enable/sideband requirements are retained;
- failures are characterized rather than inferred away.

H3 makes the development board useful even before a Compute Element is purchased.

## H4 — Targeted high-speed/sideband tooling

Only add USB 3, PCIe, eSPI, or other signals when a specific experiment justifies controlled-impedance routing, reference planes, length treatment, or active carrier support.

Do not treat a generic all-300-pin fanout as a valid development plan.

## H5 — Used Compute Element bring-up

**Claim:** a suitable surplus CM11EB-family Compute Element can boot the proven Linux/Bitwig stack on the Push carrier.

Acceptance:

- UEFI/BIOS and carrier-EC requirements are understood;
- Linux boots from serviceable storage;
- networking works;
- Push hardware enumerates;
- thermal behavior is bounded;
- Track V acceptance tests run unchanged.

## H6 — Native-bay battery/thermal final form

**Claim:** Compute Element, selected protected battery/power path, storage, antennas, and cooling form a serviceable portable instrument.

Acceptance includes:

- no external compute host;
- validated charging and play-while-charging behavior;
- low-voltage warning, save, and clean shutdown;
- representative thermal/load limits;
- battery replacement/service procedure;
- external recovery path;
- acceptable audio/control/display latency.

# Optional compatibility and ecosystem work

These efforts may proceed in separate repositories or issues but are not gates for Track V, A, or H:

- Wine/yabridge experiments, including known Deck UI/usability problems;
- plugdata/Pure Data integration;
- Monome/serialosc integration;
- device-specific analyzers and direct visual sources;
- alternative controller integrations.

The core project should make these integrations possible through public semantic, visual-source, and compositor contracts without absorbing their independent roadmaps.
