# Hardware Dossier

This document separates confirmed platform facts from project hypotheses. Update it as measurements replace inference.

## Scope

Target hardware begins with an **Ableton Push 3 Controller**, but the first portable appliance does not require an internal conversion.

There are three hardware configurations to distinguish:

1. **portable reference appliance** — Steam Deck, existing battery and existing angled wooden base, connected through Push’s stock rear ports;
2. **compute dock** — Framework/compact x86 host and battery packaged in the base, still using Push’s stock rear USB contract;
3. **native-bay endgame** — custom CM11EB connector tooling, used NUC Compute Element, selected battery and validated native thermal/power integration.

Battery operation is mandatory for the portable and native-bay products. A wall-powered bench is only an engineering stage.

## Existing reference hardware

The initial maintainer already has:

- a Steam Deck with Bitwig Studio installed and previously connected to Push;
- a rigid angled wooden Push base with a large protected volume beneath the controller;
- a battery believed capable of powering the Deck and Push for meaningful use;
- USB-C Power Delivery trigger cable(s) that have previously powered Push through its barrel input;
- ordinary external USB connectivity between the Linux host and Push.

These are assets, not yet fully characterized evidence.

### Required H0 measurements

Retain:

- wooden-base internal width, depth and height profile;
- rear opening and cable-bend clearances;
- removable-tray or cross-rail mounting opportunities;
- Steam Deck/dock placement and cooling clearances;
- battery manufacturer/model/capacity;
- each battery output’s supported PD profiles;
- simultaneous-output power allocation;
- whether outputs interrupt during charger connection or load renegotiation;
- play-while-charging behavior;
- USB-C-to-barrel negotiated voltage, polarity and connector dimensions;
- cable/connector temperature under representative load;
- Push and host power draw at idle, normal project load and representative peak;
- runtime and thermal observations.

Until those measurements exist, do not publish runtime or power-margin claims.

## Portable reference topology

The known-good behavioral contract is Push controller mode over its stock rear USB port.

Conceptually:

```text
protected battery / power distribution
       +--> Steam Deck or later x86 host
       +--> Push barrel input through tested PD trigger cable

Linux USB host
       +--> Push rear USB device port

all components
       +--> retained and protected by the existing wooden base
```

The Steam Deck has limited physical ports, so a dock/hub may be required for simultaneous charging, Push data and service peripherals. If a hub is used, retain the exact topology and prove that Push audio, MIDI and display traffic remain stable.

The direct external USB route is first-class and may remain a supported product configuration indefinitely. The internal connector route is an optional refinement/endgame.

## Confirmed external Push interface basis

Existing open implementations identify Push 3 controller mode as USB VID/PID:

```text
VID 0x2982
PID 0x1969
```

The Push display is accessible as USB interface 0, OUT endpoint `0x01`, with a 960×160 framebuffer protocol already implemented independently by DrivenByMoss and other reverse-engineering projects.

Push also exposes its musical controls through MIDI/MPE and functions as a USB audio interface.

These external interfaces are the behavioral reference for all internal-host experiments.

## Compute-dock option

A Framework mainboard or compact x86 computer can replace the Deck while remaining inside the existing base.

Selection should be based on:

- measured base volume, not overall Push dimensions;
- CPU/RAM performance per watt;
- board and cooler dimensions;
- documented power-button and battery behavior;
- USB host availability;
- Linux and graphics support;
- serviceability;
- used-market economics.

A compute dock need not interact with the CM11EB connector. It can use the same stock rear USB and power connections as the Deck.

## Official standalone compute basis

Ableton documents the standalone processor as an Intel NUC 11 Compute Element using an 11th-generation Core i3-1115G4 with 8 GB RAM.

This maps to Intel’s CM11EB / Elk Bay Compute Element family. Intel published platform documentation for this family, including the 300-contact gold-finger edge interface and the standard interfaces carried over it.

Relevant CM11EB family examples include:

- Core i3 / 8 GB variants;
- Core i5 / 8 GB variants;
- Core i7 / 16 GB variants.

Treat exact SKU compatibility with Push as **unproven** until tested. Shared mechanical/electrical family membership does not prove carrier embedded-controller, BIOS, power, thermal or firmware compatibility.

## Connector basis

The module side is a segmented 300-contact gold-finger edge card. Intel specifies compatible carrier-side LOTES connector families including APCI0468/APCI0480 variants.

The connector is not simply USB. It carries combinations of:

- multiple USB 2.0 and USB 3.x paths;
- PCIe and clocks;
- display-related lanes;
- Ethernet/audio/sideband functions;
- SMBus, eSPI and power-management signals;
- substantial power and ground distribution.

This is enough to bound the problem, but it also means a careless breakout can short high-current rails into data pins.

The H2/H3 questions are:

> Which documented CM11EB path does the Push carrier route to the Push hardware complex, and what mux/sideband state enables it?

They are not:

> Can we fan all 300 contacts onto random headers and safely experiment?

## Working internal topology hypothesis

Current standalone reverse engineering strongly suggests an x86 host communicating with Push hardware through an internal USB/XMOS topology.

Working hypothesis only until measured on this controller:

```text
internal x86 host
      |
CM11EB carrier USB path
      |
USB mux / hub / XMOS hardware complex
      |
+-----+---------+---------+
|               |         |
display        MIDI      audio / hardware control
```

A successful internal enumeration experiment would show that a generic Linux host connected through the correct path can enumerate useful Push functions comparable to an external computer.

## Push-bay survey checklist

Before probing or buying compute hardware, record:

### Mechanical

- compute-bay dimensions;
- edge-connector position, orientation and keying;
- mounting-hole positions;
- 45-degree insertion keep-out;
- available z-height;
- SSD socket type/location;
- thermal contact surfaces;
- battery cavity dimensions and restrictions;
- antenna locations/routes;
- cable and connector clearances.

The factory battery region remains battery/power territory. Do not allocate it to compute simply because the controller model contains a spacer there.

### Identification

Photograph all readable:

- PCB part/revision markings;
- hub/XMOS/mux part markings;
- power-controller markings;
- connector manufacturer/part markings if visible;
- test-point labels;
- battery/power connector labels;
- SSD and antenna markings.

### Electrical

Without injecting power:

- establish ground points;
- map connector ground pins to Intel documentation;
- continuity-test candidate USB differential pairs;
- identify obvious VBUS/power rails separately from data;
- document which findings are direct continuity versus inferred routing;
- identify mux/select/enable components and accessible observation points.

## Carrier-map rules

1. Never infer VBUS direction from connector position alone.
2. Do not join external-host 5 V to carrier 5 V until both sides’ source/sink behavior is understood.
3. USB differential-pair continuity should be measured powered off where possible.
4. Preserve pair identity, polarity and controlled-impedance routing.
5. Record resistance/continuity observations rather than only the final conclusion.
6. If an active hub or mux lies between accessible points, continuity may terminate there; that is still useful evidence.
7. Power rails on any development board remain isolated/disconnected by default.

## CM11EB development-board strategy

The useful idea is a **development edge card**, not a fake complete carrier on revision one.

### D0 — passive diagnostic edge card

Purpose:

- verify mechanical mating/keying;
- expose ground references;
- expose candidate USB 2 differential pairs to test points or selectable headers;
- expose selected low-speed sideband observations;
- keep all high-current power contacts unconnected by default.

### D1 — protected USB diagnostic card

Add only after D0 geometry and pin mapping are verified:

- ESD protection;
- explicit VBUS isolation and optional measured injection;
- selectable candidate USB paths;
- current/voltage observation;
- high-quality connectors and strain relief;
- clearly separated host/device orientation.

### D2 — targeted high-speed/sideband development

Only route USB 3, PCIe, eSPI or other high-speed functions when a specific experiment requires them.

Those paths may require:

- controlled-impedance differential routing;
- length matching;
- more PCB layers;
- reference-plane continuity;
- validated connector launch geometry;
- active mux/retimer/embedded-controller support.

Do not claim that a cheap two-layer breakout exposing every “utility” contact is a valid full NUC development board.

### Desired bench use

The card should allow Push to remain mounted on the wooden stand while the open back/carrier is connected to a Deck or other development host.

It should support:

- safe `lsusb` enumeration attempts;
- USB trace/mux investigation;
- observation of sideband states;
- later comparison against a real Compute Element;
- reproducible public schematics and measurement notes.

## Internal USB experiment

The desired first experiment is a **reversible data-path breakout**, not a permanent modification.

Conceptually:

```text
Push carrier candidate USB D+  ---- external host D+
Push carrier candidate USB D-  ---- external host D-
Push carrier ground            ---- external host ground
VBUS                            ---- deliberately isolated/handled after measurement
```

Do not implement literal wiring until the carrier survey identifies voltage domains, muxes and whether a downstream hub/device requires local power from Push.

Acceptance is enumeration and functional reproduction, not merely electrical continuity.

## Compute Element decision gate

Do not buy a CM11EB module simply because it fits the documented family.

Evaluate one only after:

- S0–S4 establish the software value;
- the portable Deck appliance proves the workflow;
- the bay and connector are measured;
- the development card establishes the internal USB/sideband contract or proves a direct Compute Element is required;
- used/surplus pricing is materially better than Ableton’s upgrade economics.

The native-bay final form should compare candidates by:

- current Bitwig x86-64/AVX2 compatibility;
- CPU/RAM performance per watt;
- physical fit;
- carrier embedded-controller/BIOS compatibility;
- USB availability;
- NVMe/storage;
- Wi-Fi/networking;
- thermal envelope;
- battery/power-input compatibility;
- recoverability and Linux support.

## SSD

For the custom Linux path, storage does not need to contain Ableton’s standalone image. A larger commodity NVMe is desirable for Bitwig, projects, samples and plug-ins, subject to the actual physical/interface survey.

## Thermals

There are two different cooling problems:

- **base/dock cooling:** Steam Deck, Framework or mini-PC cooling inside the wooden stand;
- **native-bay cooling:** a Compute Element coupled to Push’s stock backplate/heatsink geometry.

A processor that boots is not proven usable until representative Bitwig load can run without uncontrolled throttling, recirculating exhaust or unsafe battery/chassis/component temperatures.

Keep battery cells physically separated from hot exhaust paths.

## Battery and power

Battery operation is a mandatory product requirement.

Separate:

### Reference battery integration

Use the existing complete protected battery and already-tested PD trigger cable(s) for the early portable appliance.

Required evidence:

- supported output profiles;
- simultaneous load behavior;
- real runtime;
- play-while-charging transitions;
- connector/cable temperature;
- low-battery behavior;
- safe host/Push shutdown.

### Native-bay final battery

A later NUC final form may use a different selected battery/charging architecture. That work remains safety-critical and must cover pack chemistry, BMS, charging, low-voltage handling, thermal limits, serviceability and fault recovery.

The project can succeed at the portable reference-appliance level before a custom internal pack is designed, but it is **not** considered portable standalone without battery operation.

## Evidence index

Populate as experiments begin:

```text
evidence/
  s0-external-baseline/
  h0-reference-rig/
  h1-portable-integration/
  h2-bay-survey/
  h3-edge-card/
  h4-internal-usb/
```

Raw evidence should be accompanied by a short README explaining device state, commands/tools used, date, and what the evidence does and does not prove.
