# Real Bitwig and Push acceptance of the local build

## Date and machine state

- Acceptance date: 2026-08-31 PDT.
- Machine: accepted S0 arm64 Mac fixture, macOS 26.4.1.
- Bitwig Studio: 6.1, revision `94a90411037fa337883222813b7372a3ace9dbd7`.
- Controller: connected Ableton Push 3.
- Artifact under test: the sole scanned extension at `$HOME/Documents/Bitwig Studio/Extensions/DrivenByMoss.bwextension`.
- Installed local-build SHA-256 during this checklist: `61ff21e5f21d96ee64bfe1b09c5971116f1f5075d5805bc015f0a168fe00b8f9`.
- Source represented by that build: commit `fd03245ab38fa5149c45934051d937ee9fda6d08`, tree `edd2ad636b0aa1f39919f0ffd05c968015450075`.

Bitwig was launched only after the local hash and sole-extension count were verified. Available logs showed Bitwig starting, connecting to its control-surface service, and opening Push's audio and Live MIDI endpoints. Behavioral status below comes from the maintainer's direct interaction with the physical controller, not from those logs.

## Consolidated checklist result

| # | Acceptance item | Status | Direct observation |
| ---: | --- | --- | --- |
| 1 | Push connects and leaves its connection screen. | PASS | Maintainer answered yes while the local artifact was the sole scanned extension. |
| 2 | Pads produce notes. | PASS | Maintainer answered yes. |
| 3 | Configured pressure/MPE behavior is observable. | PASS | Maintainer answered yes. |
| 4 | Eight encoders control expected Bitwig state. | PASS | Maintainer answered yes. |
| 5 | Transport works. | PASS | Maintainer answered yes. |
| 6 | Normal DrivenByMoss semantic display works coherently. | PASS | Maintainer answered yes. |
| 7 | Push appears as the audio device. | PASS | Maintainer answered yes; Bitwig's engine also opened Ableton Push 3 Audio. |
| 8 | Bitwig master output is audible through Push's headphone jack. | PASS | Maintainer answered yes, using Push as Bitwig's audio device. |
| 9 | A Bitwig native device can be selected. | PASS | Organ was visibly selected in Bitwig and the maintainer answered yes. |
| 10 | Expanded Device View opens. | PASS | Maintainer proved this with Polysynth, a device that supports Expanded Device View. |
| 11 | Expanded Device View can float/undock. | PASS | Maintainer proved Polysynth's Expanded Device View in a separate floating window. |

## Organ/Polysynth clarification

The initial answer to row 11 was qualified because the currently selected Organ device did not present a way to float its panel. Direct Bitwig UI inspection showed that Organ has no Expanded Device View control. The current Bitwig user guide likewise states that only certain devices expose Expanded Device View; Organ is not listed, while Polysynth is.

This is not a local-build failure. The checklist's Expanded Device View rows concern a compatible native device. The maintainer then explicitly proved both rows with Polysynth.

Reference: <https://www.bitwig.com/userguide/latest/introduction_to_devices/#the_expanded_device_view>

## Tools and commands used

- Exact installed-artifact hash and scan-directory count before Bitwig launch
- Bitwig 6.1 normal launch
- Sanitized startup/engine inspection for audio and Live MIDI endpoint opening
- Direct macOS UI inspection of the selected Organ and Bitwig controller state
- Bitwig's official current user guide for the supported-device distinction
- Maintainer direct physical interaction and answers for every row

No screenshot or raw proprietary UI corpus is retained.

## What this evidence proves

- The locally built, exact clean-source 26.4.1 artifact loaded sufficiently to drive the real Push 3.
- Notes, pressure/MPE, encoders, transport, semantic display, Push audio selection, and headphone output worked during the local-build run.
- A compatible Bitwig native device's Expanded Device View opened and floated.
- The Organ ambiguity was resolved without falsely classifying unsupported Organ behavior as a DrivenByMoss regression.

## What this evidence does not prove

- It does not automate or instrument the physical observations.
- It does not prove all Bitwig devices have Expanded Device View; they do not.
- It does not deliberately test reconnect, cable removal, forced shutdown, transfer faults, or endurance.
- It does not measure frame identity, timing, allocations, audio latency, or controller latency.
- It does not test a functional source modification.
