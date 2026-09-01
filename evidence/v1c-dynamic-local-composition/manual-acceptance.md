# Manual acceptance

## Date, machine state, and authority

- Evidence date: 2026-09-01 PDT.
- Machine state: accepted Mac + Bitwig Studio 6.1 + real Push 3 + Push headphones fixture.
- Actual central basis/tree: `4265dc7b6f1cabf2dcbad1b827d002bd9062cf4f` / `2af6b4757e5906ce74a3b52c5ee82323f5e32406`.
- DrivenByMoss basis/tree: `1ae0b74f383314d170a5960ca763bdf9c319e787` / `a81e5c4330b31f36845c25e98e322990d62f0c67`.
- Source PR/head/tree: [kasselvania/DrivenByMoss#3](https://github.com/kasselvania/DrivenByMoss/pull/3), `4b3326eddcf2d890de3baa10b93f6e80842d41e1`, tree `d03a372e2efcf41b22cef46501e08efbfb0c0036`.
- Exact clean artifact: `f9671047e342ed3d2503fae3423ea27725830e359e75b51e29fc88ac316be4b3`.

Behavioral results below are the maintainer's direct physical observations. Source, bytecode, hashes, and logs were not substituted for manual behavior.

## Phase A — default

| # | Check | Result | Observation |
| ---: | --- | --- | --- |
| 1 | Push connects/leaves connection screen | PASS | Yes |
| 2 | Pads produce notes | PASS | Yes |
| 3 | Pressure/MPE works | PASS | Yes |
| 4 | Eight encoders work | PASS | Yes |
| 5 | Transport works | PASS | Yes |
| 6 | Semantic display coherent | PASS | Yes |
| 7 | Push is Bitwig audio device | PASS | Yes |
| 8 | Master output audible through headphones | PASS | Yes |
| 9 | Native device selection works | PASS | Yes |
| 10 | Compatible Expanded Device View opens | PASS | Yes |
| 11 | Compatible view floats/undocks | PASS | Yes |
| 12 | No V1B/V1C visual | PASS | Yes |
| 13 | No relevant extension/display error | PASS | No relevant error observed |
| 14 | Normal quit | PASS | Yes |

## Phase B — V1B static regression

| # | Check | Result | Observation |
| ---: | --- | --- | --- |
| 1 | Eleven controller/audio rows remain correct | PASS | Explicitly cross-referenced to immediately preceding Phase A |
| 2 | Fixed pink/white mark appears | PASS | Yes |
| 3 | No dynamic A/B/C/D movement | PASS | Yes |
| 4 | Track mode works | PASS | Yes |
| 5 | Device Parameters works | PASS | Yes |
| 6 | Session or Browser works | PASS | Yes |
| 7 | Controls/audio remain correct | PASS | Yes |
| 8 | No lag, xrun, relevant error, smear, or clear | PASS | Yes |
| 9 | Normal quit | PASS | Yes |

## Phase B2 — property precedence

| # | Check | Result | Observation |
| ---: | --- | --- | --- |
| 1 | Dynamic lifecycle selected | PASS | Yes |
| 2 | Fixed V1B mark not stacked | PASS | Yes |
| 3 | Current semantics restore | PASS | Yes |
| 4 | Normal quit | PASS | Yes |

## Phase C — V1C dynamic lifecycle

| # | Check | Result | Direct observation |
| ---: | --- | --- | --- |
| 1 | Push connects/leaves connection screen | PASS | All normal controller functionality present |
| 2 | Pads produce notes | PASS | Present |
| 3 | Pressure/MPE works | PASS | Present |
| 4 | Eight encoders work | PASS | Present |
| 5 | Transport works | PASS | Present |
| 6 | Semantic display coherent | PASS | Present throughout lifecycle |
| 7 | Push remains audio device | PASS | Present |
| 8 | Headphone output audible | PASS | Present |
| 9 | Visual A appears at declared bounds | PASS | Generated boxes visibly cycled; exact bounds independently measured |
| 10 | B moves/enlarges/overlaps A | PASS | Moving/changing box sequence observed; exact geometry independently measured |
| 11 | A outside B restores | PASS | Covered image restored without issue |
| 12 | C moves and shrinks | PASS | Moving/changing box sequence observed; exact geometry independently measured |
| 13 | B's larger extent restores | PASS | Covered image restored without issue |
| 14 | D replaces C with different geometry | PASS | Moving/changing box sequence observed; exact geometry independently measured |
| 15 | D remains bounded | PASS | No spill or oddity observed; exact mask independently measured |
| 16 | NONE is full semantic-only output | PASS | Full semantic display observed during no-box interval |
| 17 | STALE is full semantic-only output | PASS | Full semantic display remained through indistinguishable semantic-only interval |
| 18 | INVALID is full semantic-only output | PASS | Full semantic display remained through indistinguishable semantic-only interval |
| 19 | Track mode works | PASS | Present |
| 20 | Device Parameters works | PASS | Present |
| 21 | Session or Browser works | PASS | Present |
| 22 | Semantic update under coverage restores | PASS | Behind-image changes restored without issue |
| 23 | Deterministic overlay update works | PASS | Setup/pad-curve path remained correct |
| 24 | Current notification appears | PASS | Clip notification and Master/Cue text appeared |
| 25 | Moving/removing visual preserves notification | PASS | Clip message remained while generated boxes moved |
| 26 | Notification expiration restores semantics | PASS | Mix display returned correctly after Clip message expired |
| 27 | No trail/smear/stale block/duplicate/scale/coordinate/clear error | PASS | “no issues or oddities” |
| 28 | No control lag | PASS | No problem observed |
| 29 | No display lag beyond ordinary behavior | PASS | No problem observed |
| 30 | No audio xrun/dropout | PASS | No problem observed |
| 31 | No relevant extension/display exception | PASS | No relevant error observed |
| 32 | Normal quit without force quit | PASS | “bitwig closed”; exact-name process checks confirmed |

The maintainer initially needed a simpler description of the local lifecycle. Their decisive direct summary was that the boxes came and went, the covered image behind them moved through current changes, and everything recovered with no issues or oddities.

For notification isolation, the maintainer reported that the Clip page stayed over the Mix display while the generated boxes continued, then expired to a correct Mix display without interrupting the boxes.

The Master/Cue encoder separately showed Push's conductive-touch system mixer page. The “Cue Volume” text stayed present; holding the knob held that page. After official rollback the maintainer identified this as the pre-existing system-page behavior that explained the earlier background alternation. It was not used as the clean V1C notification gate.

## Official rollback acceptance

After exact restoration, the maintainer confirmed the Push connected, ordinary DrivenByMoss semantic display and controls returned, and no generated boxes appeared.

## Commands and tools

Tools included Bitwig's exact executable, exact startup properties, direct Push controls, Push headphones, representative Bitwig modes, exact-name process readback, and narrowly selected logs only as supporting evidence.

## What this proves

- The exact clean V1C artifact passed every formal startup and real-hardware row.
- Generated visual movement/absence did not interfere with controls, audio, semantic modes, overlays, or clean notification behavior.
- Normal shutdown and exact official rollback both passed.

## What this does not prove

- Manual observation does not replace exact pixel comparison; exact bounds and mismatches are retained separately.
- No Push 2, endurance, forced-crash, hot-unplug, reconnect, or detailed latency claim is made.
