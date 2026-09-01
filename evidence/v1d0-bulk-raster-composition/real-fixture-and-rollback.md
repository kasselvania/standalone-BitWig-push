# Real Push fixture and exact rollback

## Evidence identity

- Date: 2026-09-01 PDT.
- Machine state: accepted arm64 macOS, Bitwig Studio 6.1, DrivenByMoss 26.4.1, real Ableton Push 3 Controller, and Push selected as the Bitwig audio device.
- Central basis: `a66e1e45ebb2cb72f8ea1cb12e96d1bc46d7c343`, tree `b83e9e9507dc2e26d551abed1f03c30a6b76a551`.
- DrivenByMoss basis: `852b520933eed87fbe496a04b5c18819a10b3564`, tree `d03a372e2efcf41b22cef46501e08efbfb0c0036`.
- Candidate A local commit/tree: `61c659e19faad3944f610022fca5d57f09e7b442` / `6d06def69677918e871bb5a0c978be83aab29cb8`.
- Final observation patch SHA-256: `2cba0fbffabeb6e7609f6c5ffbdb433e1e9bfa90d9f1e5414f84843a8c4b7e96`.
- Exact installed observation artifact SHA-256: `f7903aabd3266b9c26db34d68279632cffac6281cf453705d7763a0f0617076a`, size `14381447` bytes.

## Installation custody and activation

Before replacement, the maintainer saved work and quit Bitwig normally. Exact executable-name process readback was empty. The sole installed artifact at:

```text
$HOME/Documents/Bitwig Studio/Extensions/DrivenByMoss.bwextension
```

hashed to the accepted official value:

```text
98dc3195ad8d911526e18b1005f09f69a1aedcb965b080565474104654345c5a
```

It was moved intact to a timestamped directory under `$HOME/Documents/ChatGPT/BitWig Standalone Push/v1d0-artifact-backups/`, outside every Bitwig extension scan path, and rehashed exactly. The final observation artifact was installed under the canonical filename, rehashed to `f7903a...76a`, and was the only matching scanned extension.

Bitwig was launched through its actual executable with the property present before JVM startup:

```text
env JAVA_TOOL_OPTIONS='-Dpushwig.v1d0RasterProbe=true' \
  '/Applications/Bitwig Studio.app/Contents/MacOS/BitwigStudio'
```

Property delivery was proven by the one-time bitmap-characterization record, aggregate correctness/timing record, and the visibly cycling generated patterns. The research property was construction-scoped and no user-facing setting was added.

## Manual acceptance

The maintainer directly exercised the real Push and reported every requested function passed. Logs/enumeration were supporting evidence only; they were not substituted for manual behavior.

| # | Check | Result | Observation |
|---:|---|---|---|
| 1 | Push connects/leaves connection screen | PASS | Normal connected operating display. |
| 2 | Pads produce notes | PASS | Notes played. |
| 3 | Pressure/MPE works | PASS | Configured pressure behavior observed. |
| 4 | Eight encoders work | PASS | Expected Bitwig state changed. |
| 5 | Transport works | PASS | Transport controls operated normally. |
| 6 | Semantic display coherent | PASS | DrivenByMoss content remained coherent around/beneath patterns. |
| 7 | Push remains Bitwig audio device | PASS | Push audio device remained selected/available. |
| 8 | Master audible through Push headphones | PASS | Headphone output remained audible. |
| 9 | SMALL at exact bounds | PASS | 64x16 pattern visible at declared position. |
| 10 | Corner orientation | PASS | Four asymmetric corners appeared in correct positions. |
| 11 | RGB/white/black channels | PASS | Declared colors appeared correctly. |
| 12 | Opaque alpha policy | PASS | Opaque generated output, no transparency artifact. |
| 13 | Odd 117x37 pattern not skewed | PASS | Geometry/rows coherent. |
| 14 | Padding sentinels absent | PASS | No `0x5A` padding leakage visible. |
| 15 | Medium raster coherent | PASS | 480x80 pattern coherent. |
| 16 | Full-frame orientation/channels | PASS | 960x160 pattern correct. |
| 17 | Movement restores old regions | PASS | Current semantics returned without trail. |
| 18 | Enlargement/reduction restore | PASS | Newly uncovered areas returned to current semantics. |
| 19 | Replacement content correct | PASS | New content replaced old content cleanly. |
| 20 | NONE semantic-only | PASS | Full normal semantic screen returned. |
| 21 | STALE semantic-only | PASS | Full normal semantic screen returned. |
| 22 | INVALID semantic-only | PASS | Full normal semantic screen returned. |
| 23 | Semantic update under coverage | PASS | Updated semantic content appeared when uncovered. |
| 24 | Malformed intervals semantic-only | PASS | No generated raster appeared in malformed states. |
| 25 | No partial invalid write | PASS | No fragment/corruption visible. |
| 26 | Track mode | PASS | Normal control and semantic updates. |
| 27 | Device Parameters mode | PASS | Normal control and semantic updates. |
| 28 | Session or Browser mode | PASS | Representative additional mode worked. |
| 29 | No trail/filter/scale/coordinate/clear defect | PASS | None observed. |
| 30 | No control lag | PASS | None observed. |
| 31 | No abnormal display lag | PASS | None reproduced. |
| 32 | No audio xrun/dropout | PASS | None observed. |
| 33 | No relevant extension/display exception | PASS | None observed; narrow current-run search was clean. |
| 34 | Normal Bitwig quit | PASS | Bitwig quit normally without force quit; exact process check was empty. |

The user's final aggregate statement for rows 1–33 was: all functions pass. Normal quit was then directly verified for row 34.

## Supporting live aggregate evidence

The exact run produced 1,920 sends, three complete pattern cycles, one semantic-update-under-coverage event, over 102 million positive target changes, and zero source-target, outside, restoration, NONE, STALE, INVALID, malformed, semantic-update, valid-rejection, or invalid-acceptance errors. Narrow current-run log selection contained no relevant V1D-0/DrivenByMoss/Push display exception. No full log, frame, or screenshot was retained.

## Rollback and official confirmation

After the normal candidate quit:

1. Exact Bitwig executable readback was empty.
2. The installed prototype rehashed to `f7903aabd3266b9c26db34d68279632cffac6281cf453705d7763a0f0617076a`.
3. It was moved outside the scan path as `DrivenByMoss.final-observer.bwextension`.
4. The untouched official backup rehashed to `98dc3195ad8d911526e18b1005f09f69a1aedcb965b080565474104654345c5a`.
5. The official file was moved back to its exact canonical filename/path.
6. The canonical installed file rehashed to the same accepted official SHA-256.
7. `find` showed exactly one matching scanned extension.
8. Bitwig was launched normally with no research property.
9. Current-run readback showed the Push 3 audio device and normal Bitwig processes.
10. The maintainer physically confirmed: standard DrivenByMoss display/control behavior, with no research patterns.

The ordinary environment was left on the exact official artifact. The timestamped out-of-scan directory retains derivative experiment artifacts only; none is scanned or committed.

## Commands and tools

Used exact-name `ps`/process checks, `shasum -a 256`, explicit `mv`, exact-path `find`, actual Bitwig executable launch, narrow `rg` current-run log selection, local UI control for normal operation/quit, and direct maintainer confirmation on the physical Push.

## What this proves

The exact observation artifact loaded, exercised Candidate A through the real controller/audio/display fixture, shut down normally, and was reversibly replaced by the cryptographically exact official extension, which remained loadable and physically normal.

## What this does not prove

It is not an endurance, cable-removal, forced-crash, Push 2, or cross-Mac test. The out-of-scan prototype artifacts are custody files, not installed software or review artifacts.
