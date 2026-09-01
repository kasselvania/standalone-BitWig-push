# Real fixture and exact rollback

## Date, state, and authority

- Date: 2026-09-01 PDT.
- Fixture: accepted macOS 26.4.1 arm64 maintainer Mac, Bitwig Studio 6.1, real Push 3, and Push headphone audio route.
- Central basis/tree: `5597624bd50e5ef95ecd3af82ea1816ce4facd21` / `ec016bd3174345e32f1a6d47eb061820e7a1e9b9`.
- DrivenByMoss basis/tree: `663d719207ef58ec84b4d235c43211ec5da43605` / `c4e42825d069421a44b3241349de9a7c6453a3ad`.
- Final candidate head/tree: `4f00972355fcf7b5f0ead0fef3365b81850be12f` / `7202267e51d0f2613cea93d186b132a996ec14ec`.
- Final candidate artifact: `14,386,473` bytes, SHA-256 `b7b3e98438292c86e79bcf284a18c156f7bfc6b86cb116e4ecdead26fa615464`.
- Official artifact required/restored: SHA-256 `98dc3195ad8d911526e18b1005f09f69a1aedcb965b080565474104654345c5a`.

## Safe installation and property delivery

Before every artifact replacement, the maintainer saved work and quit Bitwig normally. Exact `BitwigStudio` and `BitwigAudioEngine` process-path checks returned no process. The installed official artifact was rehashed, moved intact to a timestamped directory outside every scan path, rehashed there, and replaced by exactly one candidate file at `$HOME/Documents/Bitwig Studio/Extensions/DrivenByMoss.bwextension`.

Bitwig was launched through its actual executable, not `open -a`, with construction-time `JAVA_TOOL_OPTIONS` carrying only:

- `pushwig.v1d20ExternalIngress=true`;
- port `45291`;
- private token-file path;
- stale timeout `1500` ms.

The capability value itself was not in the environment or command line. Startup log selection plus `lsof` readback proved delivery. `lsof` displayed macOS's socket object type as IPv6 while the endpoint name was exactly `TCP 127.0.0.1:45291 (LISTEN)`; source constructs the bound address from bytes `127,0,0,1`.

No producer was running during Phase A. Producer processes were resolved by exact temporary-source command path and stopped before rollback.

## Phase A: no producer

On the final exact artifact, the maintainer confirmed all seven consolidated rows:

1. Push connected.
2. Pads and pressure/MPE worked.
3. Eight encoders and transport worked.
4. Semantic display was complete/coherent.
5. Push audio/headphones worked.
6. No generated pattern appeared.
7. No display/control block, repeated error, or other regression appeared.

The earlier pre-restart-fix artifact had also passed the expanded ten-row no-producer baseline. The final artifact result is the authority claim.

## Phase B: valid producer

The deterministic producer generated top-to-bottom opaque BGRA patterns with color bars, gradients, and distinct red/green/blue/white corners. Geometry covered:

- SMALL: `64x16` near upper-left;
- odd padded: `117x37`, stride `481`;
- MEDIUM: `480x80` centered;
- FULL: `960x160`;
- SMALL near lower-right.

The maintainer confirmed on the candidate:

- small, odd-stride, medium, full, moving, and replacement patterns had correct bounds/orientation/colors;
- 15, 30, and 60 fps presentations were coherent;
- old regions restored immediately to current semantics;
- Track, Device Parameters, and Session/Browser modes remained correct;
- track/device/parameter changes reappeared under prior coverage;
- pads, pressure/MPE, encoders, transport, Push audio, and headphones remained normal;
- no torn frame, malformed pixels, corruption, trail, backlog, lag, or dropout appeared.

The exact final artifact separately passed the complete six-row continuous valid-stream baseline at 60 fps. Extracted comparison proved the only change from the pre-restart clean candidate artifact was `ExternalRasterReceiver.class`, confined in source to construction-time address reuse; frame receipt/publication/display/writer code was unchanged.

## Phase C: latest frame and session

- A 1,300-frame, 400 fps requested burst with a legal sequence gap every 17 frames showed a valid current image, then returned promptly to semantics with no delayed replay.
- Duplicate sequence did not leave/replay an invalid image.
- Out-of-order sequence did not leave/replay an invalid image.
- A fresh authenticated reconnect accepted sequence reset, showed the new valid pattern, then returned cleanly to semantics.
- No old-session image, trail, corruption, control/audio issue, or application backlog appeared.

The harness counted `5` superseded publications and `76` sequence-gap events, independently proving the paths were reached.

## Phase D: fallbacks

Each visually meaningful state was rerun long enough to be unambiguous after the initial grouped pulses were judged too brief. The maintainer's final observations were:

| Case | Physical result |
| --- | --- |
| Explicit CLEAR | Large center raster visible about 10 seconds, then instant clean semantics; no tearing/residue. |
| Clean disconnect | Changing raster visible about 8 seconds, then clean semantics; no residue. |
| Forced producer exit | Exact temporary producer killed with exit `137`; raster disappeared immediately; no stall/audio/control issue. |
| Stale timeout | Center raster stopped updating, disappeared while TCP connection remained open after about 1.5 seconds. |
| Wrong token/version/magic/session | No generated image or semantic disturbance. |
| Invalid type/format/dimensions/stride/oversize/alpha | No generated image or semantic disturbance. |
| Partial/slow-incomplete header/payload | No partial image; display/control/audio remained normal. |
| Slow complete frame | Small raster appeared as one coherent image, never built in pieces, and disappeared cleanly. |
| Writer rejection | Deterministic harness returned semantic-only output; not induced by corrupting the real Bitwig bitmap. |
| Receiver/bind failure | Pre-fix rapid restart safely showed ordinary semantics and one error, exposing the restart defect without an error loop. Final candidate corrected/reproved restart. |

The exact-final malformed fallback harness reported p50 `0.020875 ms`, p95 `0.080542 ms`, and maximum `0.986084 ms` over 1,000 samples.

## Phase E: normal shutdown

The exact final artifact `b7b3e984...` passed all five physical shutdown states with normal maintainer `Command-Q`, no force quit:

| Receiver state at quit | Exact-final result |
| --- | --- |
| Waiting in `accept()` | Bitwig and audio engine ended; listener absent. |
| Authenticated producer connected and idle | Bitwig and audio engine ended; listener absent. |
| Producer continuously sending valid rasters | Bitwig ended normally; producer subsequently observed close and exited. |
| Producer stalled mid-header | Bitwig ended normally; no partial image/post-shutdown listener. |
| Producer stalled mid-payload | Bitwig ended normally; no partial image/post-shutdown listener. |

The final candidate rebound the same loopback port immediately between runs. No indefinite join, post-shutdown publication, or USB ownership change was observed.

## Narrow log result

Narrow startup/controller/shutdown searches showed the expected candidate selection/listener facts and the deliberately retained pre-fix bind error. No relevant ingress/display exception appeared in passing final runs. Existing unrelated plug-in indexer/network messages and generic socket-close/EOF messages during normal Bitwig shutdown were not attributed to the candidate.

## Exact rollback

After the final exact-candidate phase:

1. Bitwig quit normally and exact process checks were empty.
2. The temporary producer was absent.
3. Installed candidate SHA-256 was re-read as `b7b3e98438292c86e79bcf284a18c156f7bfc6b86cb116e4ecdead26fa615464`.
4. Candidate moved outside all scan paths.
5. Untouched official backup re-read as `98dc3195ad8d911526e18b1005f09f69a1aedcb965b080565474104654345c5a`.
6. Official artifact restored to the exact canonical filename/path.
7. Canonical SHA-256 re-read as the same accepted official hash.
8. A filesystem scan found exactly one DrivenByMoss extension.
9. Bitwig relaunched without research properties.
10. Maintainer reconfirmed: Push/controls normal, standard DrivenByMoss display present, no generated pattern, Push audio/headphones normal.

The ordinary environment is left on the official artifact. Bitwig may remain open normally.

## Commands and tools

Tools included exact process-path `ps`, `lsof`, `shasum -a 256`, safe `mv`/`cp -p`, actual Bitwig executable launch, narrow log filtering, deterministic Python producer commands, exact producer PID/exit checks, and direct physical maintainer observation.

## What this proves

- The leading candidate works end-to-end with the actual Bitwig/DrivenByMoss/Push/audio fixture across normal, burst, failure, and shutdown states.
- Complete/invalid/stale/session states have physically distinguishable and correct display outcomes.
- The exact final candidate passed all five shutdown states and the official artifact was restored exactly afterward.

## What this does not prove

- It is not a cable-removal, forced-Bitwig-crash, endurance, detailed latency, or Push 2 test.
- Manual display observation does not replace deterministic pixel comparison; both are retained separately.
- It does not claim the temporary producer, token-file delivery, or research property is the final product UX.
