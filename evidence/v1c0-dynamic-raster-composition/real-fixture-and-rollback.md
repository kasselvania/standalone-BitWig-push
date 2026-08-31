# Real Push fixture and exact rollback

## Date, machine state, and authorities

- Evidence date: 2026-08-31 PDT.
- Machine state: accepted macOS 26.4.1 arm64 fixture, Bitwig Studio 6.1, DrivenByMoss 26.4.1, real Ableton Push 3 Controller, and Push headphone output.
- Central basis: `24431c70eb720235b9c7836d9b2842a798d81d54`, tree `bb72673d2b3ce01ed6525a6ab7f2096dde1ac7bf`.
- DrivenByMoss basis: `1ae0b74f383314d170a5960ca763bdf9c319e787`, tree `a81e5c4330b31f36845c25e98e322990d62f0c67`.
- Candidate commit/tree: `3e8df95e9cc489e69da72b9acb82f2d06c90dd00` / `f448eeda923232346037074a75b71c485e56ebe8`.
- Exact clean prototype artifact: 14,367,441 bytes, SHA-256 `22b37222aa9242f822c4717168ecde0d66cab10488caaabec9fe481cffba4c72`.
- Accepted official artifact: 14,362,484 bytes, SHA-256 `98dc3195ad8d911526e18b1005f09f69a1aedcb965b080565474104654345c5a`.

## Installation custody

Canonical scan path:

```text
$HOME/Documents/Bitwig Studio/Extensions/DrivenByMoss.bwextension
```

Before the first replacement, exact-name checks showed no `BitwigStudio` or `BitwigAudioEngine` process. The official artifact rehashed to the accepted value and was moved intact to this timestamped directory outside all Bitwig extension scan paths:

```text
$HOME/Documents/ChatGPT/BitWig Standalone Push/v1c0-artifact-backups/20260831T230758Z-observation
```

Its backup hash remained exact. Temporary aggregate-observation artifacts and the final clean candidate were each installed only while Bitwig was stopped, under the exact canonical filename, and verified as the sole matching extension in the scan directory. The clean real-fixture phase used only the exact artifact from the local Candidate A commit; it contained no timing or pixel observation instrumentation.

## Clean candidate launch

The actual executable was launched before process start with:

```text
JAVA_TOOL_OPTIONS=-Dpushwig.v1c0DynamicOverlay=true
```

The current-run startup log confirmed the property before Bitwig initialization. No `v1c0Measure` or `v1c0ObservePixels` property was supplied. Narrowly selected current-run checks found no relevant extension/display exception or error. Presence and logs were not used as behavioral proof; the maintainer exercised the real controller.

## Manual acceptance

| # | Check | Result | Direct observation |
| ---: | --- | --- | --- |
| 1 | Push connects and leaves connection screen | PASS | Yes. |
| 2 | Pads produce notes | PASS | Yes. |
| 3 | Configured pressure/MPE works | PASS | Yes. |
| 4 | Eight encoders control expected state | PASS | Yes. |
| 5 | Transport works | PASS | Yes. |
| 6 | Normal semantic display remains coherent | PASS | Yes. |
| 7 | Push remains the Bitwig audio device | PASS | Yes. |
| 8 | Master audio is audible through Push headphones | PASS | Yes. |
| 9 | Mark visits red R1, orange R2, green R3, and blue R4 | PASS | All four positions/colors observed. |
| 10 | Previous regions restore without a trail | PASS | Yes. |
| 11 | Mark becomes absent and full semantic display returns | PASS | Yes. |
| 12 | Track mode works | PASS | Yes. |
| 13 | Device Parameters mode works | PASS | Yes. |
| 14 | Session or Browser representative mode works | PASS | Yes. |
| 15 | Semantic change while covered appears after movement | PASS | Yes. |
| 16 | No clear, scaling error, stale block, lag, xrun, or exception | PASS | Yes. |
| 17 | Ordinary Bitwig quit completes | PASS | Initial post-check showed Bitwig still open; an ordinary Command-Q, not a force quit, ended both exact-name processes without a save-discard action. |

None, stale, and invalid are intentionally all semantic-only outputs and are visually indistinguishable. Their exact distinction was proven by deterministic/aggregate instrumentation; the physical fixture proved the semantic-only intervals and full restoration.

The maintainer initially reported a possible impression of a few more visually dropped frames but explicitly said it might be imagined. After rollback and direct comparison to the official build, the maintainer stated that refresh behavior was **exactly the same** as the colored candidate. No refresh-rate regression was reproduced.

## Exact rollback and official readback

After the normal candidate quit and exact-name stopped-process check:

1. The installed clean candidate rehashed to `22b37222aa9242f822c4717168ecde0d66cab10488caaabec9fe481cffba4c72`.
2. It was moved outside the scan path as `DrivenByMoss.candidate-clean.bwextension` and rehashed unchanged.
3. The untouched official backup rehashed to `98dc3195ad8d911526e18b1005f09f69a1aedcb965b080565474104654345c5a`.
4. The official file was moved back to the exact canonical filename/path.
5. Final canonical hash, size, and matching extension count were checked.

Final installed state:

| Field | Result |
| --- | --- |
| Filename | `DrivenByMoss.bwextension` |
| Bytes | 14,362,484 |
| SHA-256 | `98dc3195ad8d911526e18b1005f09f69a1aedcb965b080565474104654345c5a` |
| Matching scan-directory files | 1 |

Bitwig was relaunched with `JAVA_TOOL_OPTIONS` explicitly absent. The startup record contained no Pushwig property, Push 3 audio enumerated, and no relevant error was found in the narrow check. The maintainer physically confirmed the colored mark was gone, the ordinary DrivenByMoss display was back, and its refresh behavior matched the candidate. The ordinary environment was left on the exact official artifact.

## Commands and tools

Tools included exact-name `pgrep`, `ps`, `shasum -a 256`, `stat`, scoped `find`, explicit-path `mkdir`, `mv`, `cp -p`, Bitwig's exact executable, narrow current-run log filters, local computer control for deterministic track selection and normal Command-Q, and direct maintainer observation. No force quit, firmware change, cable-removal test, screenshot, raw frame, full log, project, or preset was retained.

## What this proves

- The exact clean Candidate A artifact loaded and exercised the real Push control/display/audio fixture.
- Moving/replacement/absence and current-semantic restoration behaved correctly across representative modes.
- Candidate A preserved one writer and did not produce an observed control, display, or audio regression.
- The official artifact was restored byte-for-byte as the sole scanned extension and remained physically loadable.

## What this does not prove

- This was not a forced-crash, hot-unplug, reconnect, endurance, or detailed audio-latency test.
- No Push 2 hardware acceptance is claimed.
- The out-of-scan derivative artifacts are local evidence custody only and are not loaded by Bitwig.
