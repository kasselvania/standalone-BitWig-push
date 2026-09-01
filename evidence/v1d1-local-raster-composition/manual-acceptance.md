# V1D-1 manual real-Push acceptance

## Date, machine state, and authority

- Evidence date: 2026-09-01 PDT.
- Machine state: accepted macOS 26.4.1 arm64 fixture, Bitwig Studio 6.1, real Push 3 Controller, and Push selected as Bitwig's audio device with audible headphone output.
- Central basis/tree: `c94d1b74d702e696d6cc4cc89625f1a2f7a95530` / `8539026fc9476bbf2df34b310190a57906113b90`.
- DrivenByMoss basis/tree: `852b520933eed87fbe496a04b5c18819a10b3564` / `d03a372e2efcf41b22cef46501e08efbfb0c0036`.
- Source PR/head/tree: [kasselvania/DrivenByMoss#4](https://github.com/kasselvania/DrivenByMoss/pull/4), `3c3ca02ff81ab5ce110ae3d714e20b5fca05a03f`, tree `c4e42825d069421a44b3241349de9a7c6453a3ad`.
- Exact clean derivative: 14,373,269 bytes, SHA-256 `476a57a3733cd350bd068de44a5a1019df5e198c49572d1f633e43e006ae2877`.

All results below are direct maintainer observations from the real Push. Process, hash, log, harness, and bytecode evidence support but do not substitute for these answers.

## Phase A — default path

The maintainer replied `1-14 yes, bitwig closed`.

| # | Check | Result | Observation |
| ---: | --- | --- | --- |
| 1 | Push connects and leaves connection screen | PASS | Directly confirmed |
| 2 | Pads produce notes | PASS | Directly confirmed |
| 3 | Pressure/MPE works | PASS | Directly confirmed |
| 4 | Eight encoders work | PASS | Directly confirmed |
| 5 | Transport works | PASS | Directly confirmed |
| 6 | Semantic display is coherent | PASS | Standard DrivenByMoss semantics |
| 7 | Push is Bitwig audio device | PASS | Directly confirmed |
| 8 | Master output audible through Push headphones | PASS | Directly confirmed |
| 9 | Native Bitwig device selection works | PASS | Directly confirmed |
| 10 | Compatible Expanded Device View opens | PASS | Directly confirmed |
| 11 | Compatible view floats/undocks | PASS | Directly confirmed |
| 12 | No project visual appears | PASS | No static/vector/raster mark |
| 13 | No relevant extension/display error observed | PASS | None observed; narrow log check empty |
| 14 | Normal quit | PASS | No force quit |

## Phase B — accepted V1B static regression

The maintainer replied `1-7 yes`.

| # | Check | Result | Observation |
| ---: | --- | --- | --- |
| 1 | Fixed accepted pink/white mark appears | PASS | Directly confirmed |
| 2 | No V1C vector lifecycle | PASS | Not stacked |
| 3 | No V1D-1 raster lifecycle | PASS | Not stacked |
| 4 | Representative semantic modes normal | PASS | Track/device/representative mode |
| 5 | Controls and Push headphone audio normal | PASS | Directly confirmed |
| 6 | No corruption, lag, dropout, or relevant error | PASS | None observed |
| 7 | Normal quit | PASS | Process readback empty afterward |

## Phase C — accepted V1C vector regression

The maintainer replied `1-5 yes, bitwig closed`.

| # | Check | Result | Observation |
| ---: | --- | --- | --- |
| 1 | Accepted A/B/C/D/NONE/STALE/INVALID vector boxes cycle | PASS | Directly confirmed |
| 2 | No V1D-1 raster cards | PASS | Not stacked |
| 3 | Movement/disappearance/restoration correct | PASS | Directly confirmed |
| 4 | Representative modes, controls, and audio normal | PASS | Directly confirmed |
| 5 | Normal quit | PASS | No force quit |

## Phase D — all-property precedence

The maintainer replied `1-5 yes, bitwig closed`.

| # | Check | Result | Observation |
| ---: | --- | --- | --- |
| 1 | Raster lifecycle only | PASS | Directly confirmed |
| 2 | V1B pink/white mark not stacked | PASS | Absent |
| 3 | V1C vector boxes not stacked | PASS | Absent |
| 4 | Current semantic content restores | PASS | Directly confirmed |
| 5 | Normal quit | PASS | No force quit |

## Phase E — V1D-1 raster path

The maintainer watched a complete cycle and replied `1-38 yes`, then reported Bitwig closed.

| # | Check | Result | Observation |
| ---: | --- | --- | --- |
| 1 | Push connects and leaves connection screen | PASS | Directly confirmed |
| 2 | Pads produce notes | PASS | Directly confirmed |
| 3 | Pressure/MPE works | PASS | Directly confirmed |
| 4 | Eight encoders work | PASS | Directly confirmed |
| 5 | Transport works | PASS | Directly confirmed |
| 6 | Semantic display remains coherent | PASS | Directly confirmed |
| 7 | Push remains Bitwig audio device | PASS | Directly confirmed |
| 8 | Master output audible through Push headphones | PASS | Directly confirmed |
| 9 | SMALL at x=16, y=8, 64×16 | PASS | Correct top-left placement |
| 10 | SMALL corner orientation correct | PASS | Not mirrored/flipped |
| 11 | SMALL channel bars correct | PASS | Red/green/blue/white/black |
| 12 | ODD_PADDED at x=48, y=12, 117×37 | PASS | Correct placement |
| 13 | ODD_PADDED not skewed | PASS | Odd stride handled correctly |
| 14 | Padding sentinel absent | PASS | No stray padding pixels |
| 15 | MEDIUM coherent | PASS | 480×80 centered pattern |
| 16 | FULL covers complete display | PASS | 960×160 coverage |
| 17 | FULL corner orientation correct | PASS | Red TL, green TR, blue BL, white BR |
| 18 | Red/green/blue/white/black channels correct | PASS | Directly confirmed |
| 19 | Opaque alpha behavior correct | PASS | No semantic bleed-through |
| 20 | REPLACEMENT content/destination correct | PASS | Bottom-right 64×16 |
| 21 | Movement restores previous regions | PASS | No old-region residue |
| 22 | Enlargement/reduction restores current semantics | PASS | Directly confirmed |
| 23 | NONE produces semantic-only output | PASS | Complete semantics visible |
| 24 | STALE produces semantic-only output | PASS | Complete semantics visible |
| 25 | INVALID produces semantic-only output | PASS | Complete semantics visible |
| 26 | MALFORMED produces semantic-only output | PASS | Complete semantics visible |
| 27 | No partial malformed pattern | PASS | No flash/partial row |
| 28 | Semantic update beneath prior coverage reappears | PASS | New current semantics restored |
| 29 | Track mode works | PASS | Directly confirmed |
| 30 | Device Parameters mode works | PASS | Directly confirmed |
| 31 | Session or Browser works | PASS | Directly confirmed |
| 32 | No trail or stale raster | PASS | Directly confirmed |
| 33 | No filtering/scaling/coordinate/channel/clear defect | PASS | Directly confirmed |
| 34 | No control lag | PASS | None observed |
| 35 | No abnormal display lag | PASS | None observed |
| 36 | No audio xrun/dropout | PASS | None observed |
| 37 | No relevant extension/display exception | PASS | None observed; narrow log check empty |
| 38 | Normal quit without force quit | PASS | Directly confirmed |

## Official-artifact rollback acceptance

After exact hash restoration and a no-property launch, the maintainer replied `1-4 yes, bitwig closed`.

| # | Check | Result | Observation |
| ---: | --- | --- | --- |
| 1 | Standard official DrivenByMoss display | PASS | Push connected normally |
| 2 | Normal controls | PASS | Directly confirmed |
| 3 | No generated static/vector/raster pattern | PASS | Ordinary display restored |
| 4 | Normal quit | PASS | Final process readback empty |

## Commands and tools

Each phase used the exact Bitwig executable with explicit startup environment, installed-artifact SHA-256 checks, scoped extension counts, exact-name process checks, narrowly selected error/property log lines, and direct maintainer operation of the real Push.

## What this proves

- The exact clean source-head artifact passed every required default, regression, precedence, raster, control, display, audio, and shutdown row on the real fixture.
- Visual orientation, channels, opacity, stride, movement, restoration, semantic fallback, and malformed absence were physically observable and accepted.
- The exact official artifact remained fully usable after rollback.

## What this does not prove

- Manual observation does not establish nanosecond timing or byte-exact outside-region equality; the harness/observer evidence supplies those claims.
- It is not a Push 2, endurance, hot-unplug, forced-crash, reconnect, detailed audio-latency, or cross-platform test.
