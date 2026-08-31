# V1B real Push manual acceptance

## Date and machine state

- Evidence date: 2026-08-31 PDT.
- Machine state: accepted macOS 26.4.1 arm64 fixture, Bitwig Studio 6.1, Ableton Push 3 physically connected, normal project state suitable for notes, controls, device selection, and headphone audio.
- Central basis: `a13faef08ac8bb75a9e32f7ff7d4bc07fcd41c6e`, tree `c06009f822fee7bf36096739e7be6589f0b9ae34`.
- Source basis: `033ccef8c64f08e8d8d41fa90d48fa06b326a1a1`, tree `9aec7429ff093addee001a62a5a07309708fd592`.
- Source PR/head/tree: [kasselvania/DrivenByMoss#2](https://github.com/kasselvania/DrivenByMoss/pull/2), `a2e0341b7bccfa4e6b13614f4adffc2235f785f4`, tree `a81e5c4330b31f36845c25e98e322990d62f0c67`.
- Exact tested V1B artifact: SHA-256 `117dbffd8ec8baa6c128893c6726b676ddacbc2b1ba645ef685f8bd6b90f75e6`.

All statuses below are the maintainer's direct observations during this V1B run. Logs and enumeration were used only as supporting startup/error facts.

## Phase A — exact artifact, property off

| # | Check | Result | Observation |
| ---: | --- | --- | --- |
| 1 | Push connects and leaves connection screen | PASS | Maintainer answered yes. |
| 2 | Pads produce notes | PASS | Maintainer answered yes. |
| 3 | Configured pressure/MPE works | PASS | Maintainer answered yes. |
| 4 | Eight encoders control expected state | PASS | Maintainer answered yes. |
| 5 | Transport works | PASS | Maintainer answered yes. |
| 6 | Semantic display is coherent | PASS | Maintainer answered yes. |
| 7 | Push is selectable as Bitwig audio device | PASS | Maintainer answered yes. |
| 8 | Master audio audible through Push headphones | PASS | Maintainer answered yes. |
| 9 | Native Bitwig device can be selected | PASS | Maintainer answered yes. |
| 10 | Compatible Expanded Device View opens | PASS | Maintainer answered yes. |
| 11 | Compatible Expanded Device View floats/undocks | PASS | Maintainer answered yes. |
| 12 | No synthetic mark visible | PASS | Maintainer answered yes to mark absence. |
| 13 | No relevant extension/display error | PASS | Maintainer answered yes; narrow current-run filter also had no match. |
| 14 | Bitwig quits normally | PASS | Maintainer answered yes; exact-name process readback confirmed exit. |

## Phase B — same exact artifact, property on

| # | Check | Result | Observation |
| ---: | --- | --- | --- |
| 1 | Push connects | PASS | Direct yes. |
| 2 | Pads produce notes | PASS | Direct yes. |
| 3 | Pressure/MPE works | PASS | Direct yes. |
| 4 | Eight encoders work | PASS | Direct yes. |
| 5 | Transport works | PASS | Direct yes. |
| 6 | Semantic display is coherent | PASS | Direct yes. |
| 7 | Push is selectable as audio device | PASS | Direct yes. |
| 8 | Headphone audio is audible | PASS | Direct yes. |
| 9 | Native device selection works | PASS | Direct yes. |
| 10 | Expanded Device View opens | PASS | Direct yes. |
| 11 | Compatible view floats/undocks | PASS | Direct yes. |
| 12 | Pink outer/white inner mark visible | PASS | Direct yes. |
| 13 | Mark bounded at declared top-right location | PASS | Direct yes. |
| 14 | No whole-frame clear; outside content coherent | PASS | Direct yes. |
| 15 | Track/Mix mode correct | PASS | Direct yes. |
| 16 | Device Parameters mode correct | PASS | Direct yes. |
| 17 | Session/Browser mode correct | PASS | Direct yes. |
| 18 | Stable 30 seconds without expansion/smear/duplication/trail | PASS | Direct yes after timed observation. |
| 19 | Track/device/parameter changes update normally | PASS | Direct yes. |
| 20 | No control lag | PASS | Direct yes. |
| 21 | No display lag | PASS | Direct yes. |
| 22 | No audio xrun/dropout | PASS | Direct yes. |
| 23 | No relevant extension/display error | PASS | Direct yes; narrow current-run filter also had no match. |
| 24 | Bitwig quits normally | PASS | Direct yes; exact-name process readback confirmed exit. |

## Phase C — property-off recovery

| Check | Result | Observation |
| --- | --- | --- |
| Mark absent | PASS | Direct yes. |
| Full normal semantic display restored | PASS | Direct yes. |
| Representative controls/display updates work | PASS | Direct yes. |
| Normal quit | PASS | Direct yes; process readback confirmed exit. |

## Phase D — restored official artifact

The restored installed artifact hashed to `98dc3195ad8d911526e18b1005f09f69a1aedcb965b080565474104654345c5a`, was the sole matching scanned extension, and launched normally. The maintainer answered yes that Push showed its normal official DrivenByMoss semantic display with no pink/white mark.

## Commands and tools

The acceptance combined exact installed-artifact hashing and scan count, normal and actual-executable launches, exact-name process checks after normal quits, narrowly filtered sanitized current-run error searches, and the maintainer's direct use of the physical Push controls, display, audio interface/headphones, Bitwig device views, and semantic modes.

## What this proves

- Both startup selections and the property-off recovery boundary work with the real Push 3.
- The enabled mark is visible and stable while ordinary semantic/controller/audio behavior remains intact.
- No behavioral row was inferred from process lists, source, artifact presence, or prior slices.
- Exact official restoration remained physically operational.

## What this does not prove

- The matrix does not test Push 2 hardware, cable removal, forced crash, extended endurance, or detailed latency.
- It does not test arbitrary overlays, damage restoration, runtime hot switching, external frames, or capture.
