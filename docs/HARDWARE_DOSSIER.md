# Hardware Dossier

This document separates confirmed platform facts from project hypotheses. Update it as measurements replace inference.

## Scope

Target hardware: Ableton Push 3 Controller with the empty standalone upgrade bay.

The immediate hardware objective is **not** to recreate Ableton’s official upgrade kit. It is to determine the minimum electrical/mechanical interface an internal Linux host must satisfy after the external software path is proven.

## Confirmed external Push interface basis

Existing open implementations identify Push 3 controller mode as USB VID/PID:

```text
VID 0x2982
PID 0x1969
```

The Push display is accessible as USB interface 0, OUT endpoint `0x01`, with a 960×160 framebuffer protocol already implemented independently by DrivenByMoss and other reverse-engineering projects.

Push also exposes its musical controls through MIDI/MPE and functions as a USB audio interface.

These external interfaces are the behavioral reference for all internal-host experiments.

## Official standalone compute basis

Ableton documents the standalone processor as an Intel NUC 11 Compute Element using an 11th-generation Core i3-1115G4 with 8 GB RAM.

This maps to Intel’s CM11EB / Elk Bay Compute Element family. Intel published platform documentation for this family, including the edge connector and standard interfaces carried over it.

Relevant CM11EB family examples include:

- Core i3 / 8 GB variants;
- Core i5 / 8 GB variants;
- Core i7 / 16 GB variants.

Treat exact SKU compatibility with Push as **unproven** until tested. Shared mechanical/electrical family membership does not prove carrier BIOS, power, thermal, or firmware compatibility.

## Important connector observation

The CM11EB edge connector carries ordinary PC interfaces including multiple USB 2.0 and USB 3.x paths, PCIe, SMBus, display-related lanes, power-management signals and other carrier interfaces.

This sharply bounds the reverse-engineering problem.

The H1 question is:

> Which documented CM11EB USB path(s) does the Push carrier route to the Push hardware complex?

It is not:

> What undocumented mystery protocol exists on the entire edge connector?

## Working internal topology hypothesis

Current standalone reverse engineering strongly suggests an x86 host communicating with Push hardware through an internal USB/XMOS topology.

Working hypothesis only until measured on this controller:

```text
internal x86 host
      |
CM11EB carrier USB path
      |
USB hub / XMOS hardware complex
      |
+-----+---------+---------+
|               |         |
display        MIDI      audio / hardware control
```

A successful H2 experiment would show that a generic Linux host connected through the correct internal USB path can enumerate the same useful Push functions as an external computer.

## H0 survey checklist

Before probing or buying compute hardware, record:

### Mechanical

- compute-bay dimensions;
- edge-connector position, orientation and keying;
- mounting-hole positions;
- available z-height;
- SSD socket type/location;
- thermal contact surfaces;
- battery cavity dimensions;
- antenna locations/routes;
- cable and connector clearances.

### Identification

Photograph all readable:

- PCB part/revision markings;
- hub/XMOS part markings;
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
- document which findings are direct continuity versus inferred routing.

## H1 carrier-map rules

1. Never infer VBUS direction from connector position alone.
2. Do not join external-host 5 V to carrier 5 V until both sides’ source/sink behavior is understood.
3. USB differential-pair continuity should be measured powered off where possible.
4. Preserve pair identity and polarity.
5. Record resistance/continuity observations rather than only the final conclusion.
6. If an active hub lies between accessible points, continuity may terminate at the hub rather than reach the target connector directly; that is still useful evidence.

## H2 breakout concept

The desired experiment is a **reversible data-path breakout**, not a permanent modification.

Conceptually:

```text
Push carrier candidate USB D+  ---- external host D+
Push carrier candidate USB D-  ---- external host D-
Push carrier ground            ---- external host ground
VBUS                            ---- deliberately handled after measurement
```

Do not implement this literal wiring until H1 identifies voltage domains and whether a hub/device requires local power from Push.

Acceptance is enumeration and functional reproduction, not merely electrical continuity.

## Compute Element decision gate

Do not buy a CM11EB module simply because it fits the documented family.

Evaluate one only after:

- S0–S3 establish the software value;
- H0 documents the bay;
- H1/H2 establish the internal USB contract or prove a direct Compute Element is required;
- used/surplus pricing is materially better than Ableton’s upgrade economics.

If H2 succeeds, evaluate alternatives by:

- x86-64 + AVX2 compatibility with current Bitwig;
- CPU/RAM performance per watt;
- physical fit;
- USB availability;
- NVMe/storage;
- Wi-Fi/networking;
- thermal envelope;
- power-input compatibility;
- recoverability and Linux support.

## SSD

For the custom Linux path, storage does not need to contain Ableton’s standalone image. A larger commodity NVMe is desirable for Bitwig, projects, samples and plug-ins, subject to the actual physical/interface survey.

## Thermals

Treat the enclosure as the cooling system. A processor that boots is not proven usable until representative Bitwig load can run without uncontrolled throttling or unsafe chassis/component temperatures.

Early compute tests should prefer conservative power limits. Higher-performance CM11EB SKUs are interesting only if the Push thermal structure can support them.

## Battery

Battery work is intentionally isolated as H7.

The official standalone design uses a LiFePO4 battery system. Any custom battery path requires its own BMS/charging/power-transition evidence. Never treat the battery as a generic two-wire laptop pack or bypass protection circuitry for convenience.

The project is considered successful as a plugged-in self-contained Bitwig appliance before battery support exists.

## Evidence index

Populate as experiments begin:

```text
evidence/
  s0-external-baseline/
  h0-bay-survey/
  h1-carrier-map/
  h2-internal-usb/
```

Raw evidence should be accompanied by a short README explaining device state, commands/tools used, date, and what the evidence does and does not prove.