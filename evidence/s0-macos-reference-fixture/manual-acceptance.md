# Manual Bitwig + DrivenByMoss + Push acceptance

## Status

**Maintainer execution complete — failures and limitations retained.**

## Date

Checklist prepared and executed 2026-08-31. Results were reported during the same local session after Push was physically connected and before the approximately 11:24 PDT enumeration pass.

## Machine state

Automated inspection was completed first with Bitwig Studio 6.1 running and the installed DrivenByMoss 26.4.1 artifact unchanged. Push was then connected through the ordinary USB path. Sanitized inspection subsequently identified the expected Push 3 USB and CoreAudio devices. The maintainer stated that all aspects of DrivenByMoss work on this fixture and supplied affirmative answers for all 11 rows.

## One consolidated maintainer checklist

Record `PASS`, `FAIL`, `PARTIAL`, or `NOT TESTED` plus a short observation for every row. A process listing, source trace, or device name is not an answer to a behavioral row.

| # | Manual observation | Result | Maintainer observation |
|---:|---|---|---|
| 1 | Push connects to Bitwig/DrivenByMoss and leaves its connection screen. | PASS | Maintainer reports connection present on screen; normal DrivenByMoss display also passes in row 6. |
| 2 | Pads produce notes in a deliberately selected instrument/note context. | PASS | Maintainer reports keys/pads produce notes. |
| 3 | Configured pressure/MPE behavior is observable; state the configuration and result. | PASS | Maintainer answered “ytes,” recorded as an obvious “yes”; exact pressure/MPE configuration was not named. |
| 4 | The eight encoders control the expected visible Bitwig/DrivenByMoss state. | PASS | Maintainer answered yes. |
| 5 | Transport controls perform the expected play/stop/record operation. | PASS | Maintainer answered yes. |
| 6 | The normal DrivenByMoss semantic display is visible and updates coherently. | PASS | Maintainer answered yes and stated that all aspects of DrivenByMoss work. |
| 7 | Push appears as a macOS/Bitwig audio device. | PASS | Maintainer answered yes; sanitized CoreAudio enumeration independently identifies “Ableton Push 3 Audio.” |
| 8 | One simple Push audio input or output path produces an observed result; state route and result. | PASS | Bitwig was configured to use Ableton Push as its audio interface. The Bitwig master output was audible from Push's headphone jack. |
| 9 | A Bitwig native device can be selected. | PASS | Maintainer answered yes. |
| 10 | An Expanded Device View for that native device can be opened. | PASS | Maintainer answered yes. |
| 11 | State whether that Expanded Device View can be undocked or floated in Bitwig 6.1. | PASS | Maintainer answered yes: the view can be undocked or floated in Bitwig 6.1 on this fixture. |

Also record any reconnect or partial-failure behavior encountered during the same session, without turning an unplanned failure into a required destructive test.

## Tools and commands used

The behavioral source is the maintainer's direct physical and audible observation on the named fixture, reported in the task conversation. Sanitized `system_profiler` USB/audio inspection from `push-usb-audio.md` accompanies, but does not replace, those observations.

## What this evidence proves

- The maintainer reports successful Push connection, note input, pressure/MPE behavior, encoder control, transport, and normal DrivenByMoss semantic display behavior.
- The maintainer reports that Push appears as an audio device and that Bitwig's master output is audible from Push's headphone jack when Ableton Push is selected as Bitwig's audio interface.
- The maintainer reports that a Bitwig native device can be selected, its Expanded Device View can be opened, and that view can be undocked or floated in Bitwig 6.1.
- These claims are direct manual observations rather than deductions from process or source inspection.

## What this evidence does not prove

- It does not prove behavior from Bitwig process presence, installed files, source inspection, or USB enumeration alone.
- It will not prove universal portability, visual capture, composition, IPC, or another host.
- A `PASS` for audio enumeration will not substitute for the separate simple audio-path result.
- The successful headphone-output check does not test audio inputs, other output ports, latency, detailed channel mapping, or reconnect behavior.
- The exact pressure/MPE configuration was not named.
- No reconnect failure or partial failure was reported or deliberately induced.

## Follow-up boundary

No further manual input is required for S0. Broader Push audio routing, latency, input, or reconnect testing remains outside this slice.
