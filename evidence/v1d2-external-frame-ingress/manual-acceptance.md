# Manual acceptance

## Date, fixture, and authority

- Date: 2026-09-01 PDT.
- Fixture: accepted macOS 26.4.1 arm64 Mac, Bitwig Studio 6.1, real Push 3,
  Push selected as Bitwig audio device, and audible Push headphone output.
- Central basis/tree:
  `fe8216fcadc9879bafa96acbb0f064f1d6625f4b` /
  `580786862a6f034aa111b60c4d434e64c44c7211`.
- DrivenByMoss basis/tree:
  `663d719207ef58ec84b4d235c43211ec5da43605` /
  `c4e42825d069421a44b3241349de9a7c6453a3ad`.
- Source PR/head/tree:
  <https://github.com/kasselvania/DrivenByMoss/pull/5> /
  `830b778b720a06f56de08861d27052228c82c63b` /
  `c8bc3f9e052e8f0b7b5dd256657697349d303740`.
- Exact derivative SHA-256:
  `026f88905cbd27890fca333cdcb5820c4fedaa3273359bb75b7e6106fd59278e`.
- Harness/producer/observer SHA-256:
  `007822786260f89a9c3d005b669162389843a4dad2fb3293c6c131762c32bd18` /
  `993cb0f4d14c0a909a629ac4063e6e1937cb50ca42075e9fbbd3f099253bacbb` /
  `2e6ff0f6e2236e0b6ad85a831ba3f8c18f3362263eeaba425749fb4cbf929eb4`.

All PASS results below are direct maintainer observations unless a row says
automatic. Invisible rejection/ownership facts are not inferred from the
screen; those use the deterministic harness and are called out separately.

## Phase A — external enabled, no producer

| # | Check | Result | Observation |
| ---: | --- | --- | --- |
| 1 | Push connects | PASS | Left connection screen and operated normally. |
| 2 | Pads produce notes | PASS | Notes sounded. |
| 3 | Pressure/MPE | PASS | Configured behavior worked. |
| 4 | Eight encoders | PASS | Expected Bitwig state changed. |
| 5 | Transport | PASS | Transport controls worked. |
| 6 | Complete semantic display | PASS | Normal coherent DrivenByMoss semantics. |
| 7 | Push is Bitwig audio device | PASS | Device route present. |
| 8 | Headphone master audio | PASS | Audible through Push headphones. |
| 9 | Exact loopback listener | PASS (automatic) | Sole listener at `127.0.0.1:45291`. |
| 10 | Exactly one receiver thread | PASS (automatic) | One named receiver in JVM readback. |
| 11 | No generated raster | PASS | No test pixels without producer. |
| 12 | No block/error loop | PASS | Display, controls, and audio remained normal. |

## Phase B — valid producer and rates

| Check | Result | Observation |
| --- | --- | --- |
| HELLO authentication | PASS (automatic) | Valid patterns/counters followed authenticated HELLO. |
| SMALL pattern | PASS | Correct bounded pattern. |
| ODD_PADDED pattern | PASS | Correct `117x37`, no padding sentinel leak. |
| MEDIUM pattern | PASS | Correct centered `480x80`. |
| FULL pattern | PASS | Correct `960x160` full coverage. |
| Moving/replacement | PASS | Old regions restored; no trail. |
| Orientation/channels/alpha/stride | PASS | Top-left orientation and distinct colors correct; no malformed pixels. |
| 1 fps | PASS | Stayed fresh with default 1.5-second timeout. |
| 15 fps | PASS | Coherent. |
| 30 fps | PASS | Coherent. |
| 60 fps | PASS | Coherent. |
| Track mode | PASS | Semantics and external region behaved correctly. |
| Device Parameters mode | PASS | Semantics and external region behaved correctly. |
| Session or Browser mode | PASS | Representative third mode behaved correctly. |
| Semantic change beneath coverage | PASS | Current changed semantics reappeared after movement/removal. |
| Controls and audio/headphones | PASS | No regression. |
| Tearing/trail/backlog/lag/xrun/error | PASS | None observed. |

## Phase C — latest frame, session, and sequence

| Check | Result | Observation |
| --- | --- | --- |
| Faster-than-display burst | PASS | No catch-up/replay, tearing, or stale blocks; quick return to semantics. |
| Newest-frame behavior | PASS | Current output remained clean; deterministic supersession count was positive. |
| Legal gaps | PASS | No disturbance; harness counter positive. |
| Duplicate/lower rejection | PASS | No artifact or freshness extension; exact rejection proven by harness. |
| `Long.MAX_VALUE` then post-exhaustion | PASS | No post-exhaustion image; exact path proven by harness. |
| New authenticated session/reset | PASS | Valid presentation resumed without an old-session image. |

The maintainer accurately reported that the negative sequence cases showed
nothing unusual. That is the expected visible result. This table does not
convert the absence into a counter claim; the harness supplies those exact
facts.

## Phase D — fallbacks and invalid messages

| Check | Result | Observation |
| --- | --- | --- |
| CLEAR | PASS | Exact semantic-only output returned cleanly. |
| Clean disconnect | PASS | No residue. |
| Forced producer exit | PASS | No stall, display, control, or audio issue. |
| Stale connection | PASS | Raster disappeared after about 1.5 seconds while connection stayed open. |
| Wrong capability/magic/version/type/format/session/reserved | PASS | No generated raster or semantic disturbance. |
| Invalid coordinate/dimension/stride/length/oversize/alpha | PASS | No generated raster or semantic disturbance. |
| Partial header/payload | PASS | No partial image. |
| Slow incomplete | PASS | No partial image or blocked controls/audio. |
| Slow complete | PASS | Appeared atomically once as a coherent frame. |
| Valid recovery after negatives | PASS | Subsequent valid pattern worked. |
| Writer rejection | PASS (harness) | Semantic-only, zero partial write; live bitmap not corrupted. |
| Active-listener collision | PASS (automatic) | Second bind rejected; first listener remained healthy. |

## Phase E — precedence and regression

| Startup path | Result | Observation |
| --- | --- | --- |
| default pass-through | PASS | Ordinary semantics, no listener or generated pixels. |
| V1B static | PASS | Only fixed static mark. |
| V1C vector | PASS | Only vector lifecycle. |
| V1D-1 local raster | PASS | Only local-raster lifecycle. |
| all diagnostic properties plus valid external | PASS | External only; lower paths absent. |
| invalid external plus lower diagnostics | PASS | Ordinary semantics; no listener/thread/lower visual. |

Each representative run retained normal control/display/audio behavior and
ended with a normal Bitwig quit.

## Phase F — shutdown

| Receiver state | Result | Observation |
| --- | --- | --- |
| waiting in accept | PASS | Normal quit; listener gone; immediate rebind. |
| authenticated idle | PASS | Socket unblocked; normal quit/rebind. |
| continuous 30 fps | PASS | Producer observed close; final semantics uncovered; normal quit/rebind. |
| stalled mid-header | PASS | No partial pixels; normal quit/rebind. |
| stalled mid-payload | PASS | No partial pixels; normal quit/rebind. |

Final consolidated shutdown confirmation also passed: no force quit, no hang,
no residue, no post-shutdown frame, no control/audio issue, and no covered final
semantic screen.

## Official rollback acceptance

After restoration, the canonical artifact hash was
`98dc3195ad8d911526e18b1005f09f69a1aedcb965b080565474104654345c5a`.
The maintainer confirmed:

| # | Check | Result |
| ---: | --- | --- |
| 1 | Standard official DrivenByMoss display | PASS |
| 2 | Normal controls | PASS |
| 3 | Push audio and headphones | PASS |
| 4 | No generated pixels | PASS |
| 5 | Normal Bitwig quit | PASS |

Bitwig is closed and the official artifact is the sole scanned extension.

## Commands and tools

Manual rows were presented in consolidated groups while automated support used
exact artifact/listener/thread/process readback, the deterministic conformance
producer, narrow logs, and safe launch/rollback operations. No screenshots or
raw frames are committed.

## Exact result

Every required physical row passed on the exact derivative or, for final
rollback, the exact official artifact. Quiet negative cases are carefully
bounded to what the maintainer could observe and paired with deterministic
proof.

## What this proves

- The exact proposed artifact preserves real Push controls, semantic display,
  audio, and headphones while valid external frames appear and disappear.
- The latest-frame, fallback, precedence, and shutdown behaviors have direct
  physical acceptance.
- The official extension is physically normal after exact restoration.

## What this does not prove

- Manual observation cannot reveal internal sequence counters, byte ownership,
  or every sub-frame mismatch; those are proven by the harness/bytecode.
- This is not an endurance, forced-Bitwig-crash, cable-removal, detailed
  latency, or Push 2 acceptance run.
