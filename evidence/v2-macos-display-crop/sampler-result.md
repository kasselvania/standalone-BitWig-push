# Live Bitwig Sampler result

## Date, machine state, and authority

- Date: 2026-09-02 PDT.
- Machine state: Bitwig Studio 6.1 main window on the accepted `3430x1447`
  ScreenCaptureKit-point display, Sampler open in the main-window device-chain
  region, exact V1D-2 derivative installed temporarily, and real Push 3
  attached.
- Central basis/tree:
  `7c15abaf55c0080b2f80971e845b4ee6f1bfcc46` /
  `730726784b57016714c0a44c8f0f8caf1c5b0141`.
- Source PR/head/tree:
  [PR #43](https://github.com/kasselvania/standalone-BitWig-push/pull/43) /
  `03fb8c8824714e4bbefd7224848ca9cdad069088` /
  `f1f68bc6f0ba6527bb146a7ee93fd4333ffaf796`.
- Helper executable SHA-256:
  `9a81bb292cfa00588c4be0272abb11a2e223132feb8725aca6e2c6a808bf942a`.

## Operator setup

The maintainer placed the Bitwig main-window device chain, with Sampler loaded,
inside the explicitly configured fixed display crop. The helper did not locate
Bitwig or Sampler; the operator established the accepted fixed-layout fixture.
The destination was the right-hand Push region `400,0,560,160`, leaving the
DrivenByMoss semantic region outside those bounds current and interactive.

## Direct physical result

The maintainer directly observed and reported:

- real live Bitwig/Sampler pixels appeared on the physical Push;
- the waveform/device panel updated meaningfully in response to Bitwig use;
- controls remained fully responsive and the feed was described as
  “shockingly performant”;
- the crop stayed within the declared Push region;
- DrivenByMoss semantic pixels outside it remained current;
- BGRA color order, vertical orientation, opacity, and proportions looked
  correct;
- there was no visible stretching, tearing, residue, or persistent stale crop;
- when Bitwig was moved out of the configured desktop region, that region's
  other desktop content appeared instead; moving Bitwig back into it restored
  useful Sampler content.

The maintainer explicitly judged this fixed-coordinate behavior to be within
the V2 proof: it proves bounded display selection/crop and live publication,
while making clear that the helper does not yet know where Bitwig is.

The focused amended-head smoke did not repeat the full Sampler matrix. It
confirmed that ordinary live capture still reached Push and that the new
maximal fractional point-space mapping remained visibly proportional and
undistorted. The original full result below remains the broader fixture proof.

## Bounded visual references

Two local operator photos were inspected but not committed:

| Observation | Local file metadata retained |
| --- | --- |
| Bitwig/Sampler positioned inside the fixed crop and visible on Push | JPEG `2880x3840`, SHA-256 `b5e3ae78f2faf0054e4972b6bf14e1b5ce7cb4647efea147a28ed911ced3e157` |
| Bitwig moved outside the crop while other desktop content occupied it | JPEG `2880x3840`, SHA-256 `12c713b41375fd56cb15a916e426d51305026949122531bd2347a9a2563a5f75` |

These hashes establish which local references were inspected without retaining
or publishing screenshots or proprietary pixels. Direct operator readback,
runtime counters, and generated-pixel tests carry the acceptance claims.

## Commands and tools

The exact signed helper app was launched against the explicit display/crop and
the accepted loopback receiver. Aggregate counters and hashes were inspected
without saving raw frames. The maintainer performed Sampler selection, window
placement, visual changes, control checks, and physical Push observation.

## Exact result

Every required Sampler-specific physical row passed: valid crop, real Sampler
pixels, destination confinement, current surrounding semantics, meaningful
live change, no entire-display transmission, correct channels/orientation/
opacity, proportional mapping, and clean restoration after source loss.

## What this proves

- Useful, changing, real Bitwig Sampler pixels traverse the exact production
  helper and unchanged accepted receiver to the physical Push.
- The fixed crop can serve as a practical first visual lens without taking
  controller or USB authority from DrivenByMoss.

## What this does not prove

- It does not identify Sampler semantically, discover Bitwig geometry, or
  distinguish a native device panel from another object occupying the same
  desktop coordinates.
- It does not claim automatic tracking after window movement/resize or any
  VST/VST3/CLAP window identity.
