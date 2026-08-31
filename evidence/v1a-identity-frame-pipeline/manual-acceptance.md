# V1A real Bitwig and Push acceptance

## Date and machine state

- Evidence date: 2026-08-31 PDT.
- Host: accepted macOS 26.4.1 arm64 fixture, Bitwig Studio 6.1.
- Controller: connected Ableton Push 3.
- Central basis: `a36779d4c04a11d6c6e9ce0d48c34ea3b813a0cc`, tree `bc4634da23f794f2afd39c63fab9eb5cf44524c1`.
- Source basis: `fd03245ab38fa5149c45934051d937ee9fda6d08`, tree `edd2ad636b0aa1f39919f0ffd05c968015450075`.
- Source PR/head/tree: [kasselvania/DrivenByMoss#1](https://github.com/kasselvania/DrivenByMoss/pull/1), `6e1e4cbd2e725a7951e5b4dc1278fbb6e7b5d61c`, `9aec7429ff093addee001a62a5a07309708fd592`.
- Exact artifact exercised: SHA-256 `94e69a2f2ce91ac6522ed6a0c1c52d7c216dea3a8c3d03f76c2221886bc62706`, 14,363,745 bytes.

Bitwig was launched only after this exact artifact was verified as the sole matching extension in the user scan directory. Available current-run facts established engine/control-surface startup and Push audio/MIDI opening, but every behavioral status below comes from the maintainer's direct interaction with the real Push 3 during this V1A run. No row is inferred from source, logs, enumeration, artifact presence, or prior V1A-0 acceptance.

## Consolidated checklist

| # | Acceptance item | Status | Direct observation |
| ---: | --- | --- | --- |
| 1 | Push connects and leaves its connection screen. | PASS | Maintainer answered yes during the exact V1A run. |
| 2 | Pads produce notes. | PASS | Maintainer answered yes. |
| 3 | Configured pressure/MPE behavior works. | PASS | Maintainer answered yes. |
| 4 | Eight encoders control expected Bitwig state. | PASS | Maintainer answered yes. |
| 5 | Transport works. | PASS | Maintainer answered yes. |
| 6 | Normal DrivenByMoss semantic display is coherent. | PASS | Maintainer's sixth sequential answer was yes; it was labeled a second `5)` and is recorded here as row 6. |
| 7 | Push appears as the Bitwig audio device. | PASS | Maintainer answered yes; the current engine log also showed Ableton Push 3 Audio open. |
| 8 | Bitwig master output is audible through Push headphones. | PASS | Maintainer answered yes. |
| 9 | A Bitwig native device can be selected. | PASS | Maintainer answered yes. |
| 10 | A compatible Expanded Device View opens. | PASS | Maintainer answered yes using Polysynth, the accepted compatible native device. |
| 11 | A compatible Expanded Device View floats/undocks. | PASS | Maintainer answered yes using Polysynth. |

## Additional required observations

- Intentional mark, overlay, crop, color, animation, or other visual difference: **NONE OBSERVED**. The maintainer answered no.
- Ordinary Bitwig quit/shutdown after derivative run: **PASS**. The maintainer quit normally, and exact executable-name inspection returned no Bitwig process before rollback.
- Extension/display error observation: **NONE OBSERVED**. The maintainer answered no; a narrowly filtered current-run log search also returned no controller/extension/display/Push/MIDI/USB error, exception, or failure match.

Polysynth is the accepted compatible native device for rows 10 and 11. Organ is not used for those rows because it does not expose an Expanded Device View on this Bitwig version.

## Commands and tools

The record combines exact installed-artifact hash and sole-extension readback, a normal Bitwig launch, sanitized startup/engine facts, exact process checks after the maintainer's normal quit, and the maintainer's direct physical answers. No behavior was promoted from logs or enumeration alone. No screenshot or proprietary UI corpus is retained.

## What this proves

- The exact source-PR-head artifact loaded sufficiently to drive the real Push 3.
- Notes, pressure/MPE, all eight encoders, transport, semantic display, Push audio selection, and headphone output passed.
- A Bitwig native device was selectable, and Polysynth's compatible Expanded Device View opened and floated.
- The identity seam produced no maintainer-observable visual change and no observed extension/display error.
- The derivative run completed an ordinary Bitwig shutdown before rollback.

## What this does not prove

- Direct observation is not automated pixel equivalence or frame hashing.
- This is not a reconnect, crash, cable-removal, endurance, allocation-profile, frame-cadence, or latency test.
- It does not claim every Bitwig device supports Expanded Device View; Organ does not on this Bitwig version, so Polysynth was used.
- It does not make a Push 2 hardware claim.
