# Real fixture and exact rollback

## Date, state, and authority

- Date: 2026-09-01 PDT.
- Fixture: accepted macOS 26.4.1 build 25E253 / Darwin 25.4.0 arm64
  maintainer Mac, Bitwig Studio 6.1, real Push 3, and Push headphone audio
  route.
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
- Harness/producer/observer SHA-256:
  `007822786260f89a9c3d005b669162389843a4dad2fb3293c6c131762c32bd18` /
  `993cb0f4d14c0a909a629ac4063e6e1937cb50ca42075e9fbbd3f099253bacbb` /
  `2e6ff0f6e2236e0b6ad85a831ba3f8c18f3362263eeaba425749fb4cbf929eb4`.
- Exact clean derivative artifact: 14,388,379 bytes, SHA-256
  `026f88905cbd27890fca333cdcb5820c4fedaa3273359bb75b7e6106fd59278e`.
- Accepted/restored official SHA-256:
  `98dc3195ad8d911526e18b1005f09f69a1aedcb965b080565474104654345c5a`.

## Safe installation and property delivery

Before replacement, the maintainer saved work and quit Bitwig normally. Exact
Bitwig application/audio-engine process checks and the ingress listener check
were empty. The canonical official artifact at
`$HOME/Documents/Bitwig Studio/Extensions/DrivenByMoss.bwextension` was rehashed
to the accepted official value, moved intact to a timestamped directory outside
all scan paths, and rehashed there.

Exactly the clean PR-head derivative was installed under the canonical
filename. Its installed hash matched `026f889...`, and a filesystem scan found
one DrivenByMoss extension in the scan path.

A fresh private capability file was created outside both repositories with 32
random bytes represented by 64 hexadecimal characters plus one newline, regular
file type, current owner, and mode `0600`. The value was not printed or placed
in environment/arguments. Bitwig's actual executable was launched before Java
startup with external activation, port, token-file path, and timeout properties.

Startup selection facts, sole installed artifact hash, exact listener readback
at `127.0.0.1:45291`, and `jcmd` observation of exactly one named receiver thread
proved property delivery and derivative loading.

## Phase A: external enabled, no producer

With no producer running, all twelve required rows passed:

- Push connection, pads, pressure/MPE, eight encoders, and transport worked;
- complete coherent semantic display remained visible;
- Push remained the Bitwig audio device and master audio was audible through
  its headphones;
- the listener was exact IPv4 loopback and exactly one receiver thread existed;
- no generated raster appeared;
- no display/control block or error loop appeared.

## Phase B: valid producer

One exact standard-library Python producer generated:

- SMALL `64x16` patterns;
- an odd-width padded `117x37` pattern with stride `481` and sentinel padding;
- MEDIUM `480x80`;
- FULL `960x160`;
- moving and replacement regions with distinct color/orientation markers.

The maintainer directly confirmed the pattern order, full-screen coverage,
top-left orientation, BGRA color channels, bounds, no padding leak, no trail,
old-region semantic restoration, and unchanged controls/audio.

Separate 1, 15, 30, and 60 fps runs passed. One fps remained fresh under the
default timeout. Fifteen, thirty, and sixty fps were coherent with no tearing,
backlog, display/control lag, audio xrun, or dropout.

During a longer moving run, Track, Device Parameters, and Session/Browser modes
were exercised while selected tracks/devices/parameters changed. Semantic
content beneath and around prior coverage returned correctly; movement stayed
bounded and no old region remained.

## Phase C: latest-frame and sequence

- A 5,000-frame faster-than-display burst produced no visible catch-up or
  replay; the current image/semantics returned promptly. Deterministic counters
  prove 398 unadopted publications were superseded.
- Gap, duplicate, lower, `Long.MAX_VALUE`, post-exhaustion, and new-session
  sequence-reset runs produced no visible residue, old-session image, or
  disturbance. Because correct rejection is intentionally quiet, exact path
  success comes from harness counters/pixel checks; the maintainer confirmed
  the required absence of artifacts rather than claiming to see an invisible
  rejection event.
- A new authenticated session resumed valid current presentation from sequence
  1 without replay.

## Phase D: fallback and malformed input

The maintainer confirmed clean semantic-only output after CLEAR, clean
disconnect, forced exact producer exit, and default-timeout staleness while the
connection remained open. No tearing, residue, control issue, or audio issue
appeared.

The full negative matrix covered wrong token, magic, version, type, format,
session, reserved values, coordinates, dimensions, stride, payload length,
oversized declaration, nonopaque alpha, partial header, and partial payload.
All produced no generated raster or semantic disturbance.

The byte-at-a-time incomplete runs exposed no partial image. A slow complete
frame appeared atomically as one coherent region, then cleared cleanly. A valid
frame immediately after the negative matrix proved receiver recovery. Writer
rejection was induced in the deterministic harness rather than by corrupting
the live Bitwig bitmap.

An independent second active listener failed while the extension listener
remained healthy; a subsequent valid producer still worked.

## Phase E: precedence and regression paths

The same exact artifact was restarted for each path:

| Startup | Physical result |
| --- | --- |
| no diagnostic properties | ordinary pass-through semantics; no listener/generated pixels |
| V1B static only | only the accepted fixed static mark |
| V1C vector only | only the accepted vector lifecycle |
| V1D-1 local raster only | only the accepted local-raster lifecycle |
| all diagnostics plus valid external | external pattern only; one listener; lower diagnostics absent |
| requested external with missing token plus lower diagnostics | ordinary semantics; no listener/thread; no lower diagnostic |

Representative controls/display/audio remained normal, and Bitwig quit normally
after every run.

## Phase F: five shutdown states

The exact clean artifact passed normal maintainer quit while:

1. waiting in accept;
2. authenticated and idle;
3. continuously receiving 30 fps;
4. stalled after 31 header bytes;
5. stalled after a valid header plus 99 payload bytes.

In every state, Bitwig and its audio engine stopped without force quit, the
listener disappeared, no post-shutdown/partial raster appeared, the final
semantic screen was not covered, and the same port rebound immediately. The
continuous producer observed close and exited. Only deliberately sleeping
temporary peer processes were interrupted after Bitwig had already closed the
socket.

The maintainer's final six-row shutdown readback confirmed normal quits,
uncovered final semantics, no partial image for either stall, no hang/residue,
and no control/audio regression.

## Exact rollback

After the final derivative run:

1. Bitwig quit normally; application/audio-engine processes and listener were
   absent.
2. The temporary producer was stopped/absent.
3. Installed derivative rehashed to
   `026f88905cbd27890fca333cdcb5820c4fedaa3273359bb75b7e6106fd59278e`.
4. The derivative moved outside all scan paths.
5. The untouched official backup rehashed to
   `98dc3195ad8d911526e18b1005f09f69a1aedcb965b080565474104654345c5a`.
6. The official artifact was restored to its exact canonical filename/path and
   rehashed to that same accepted value.
7. A scan found exactly one DrivenByMoss extension.
8. The temporary live capability file was removed.
9. Bitwig relaunched without Pushwig properties; there was no ingress listener.
10. The maintainer confirmed all five final rows: standard DrivenByMoss display,
    normal controls, Push audio/headphones, no generated pixels, and normal
    quit.

Final readback again found the sole canonical official artifact at the exact
accepted SHA-256. Bitwig is closed and the ordinary environment is left on the
official extension.

## Commands and tools

Tools included exact artifact hashing, filesystem scan, file mode/type/owner
inspection, actual Bitwig executable launch, exact process-path checks, `lsof`,
`jcmd`, controlled Python producer invocations, narrow local log review, safe
artifact moves, and direct physical maintainer observation.

## Exact result

All real-fixture phases A-F passed on the exact clean source-head artifact, all
five shutdown states passed, the official artifact was restored byte-for-byte,
and the final ordinary display/control/audio state was physically reconfirmed.

## What this proves

- V1D-2 loads and works with the accepted real Bitwig/Push/audio fixture across
  normal, rate, burst, rejection, fallback, precedence, and blocked-shutdown
  states.
- The exact derivative can be removed without loss and the accepted official
  extension remains loadable and behaviorally normal.

## What this does not prove

- It is not an endurance, forced-Bitwig-crash, cable-removal, Push 2, detailed
  latency, capture, scaling, or remote-network test.
- Quiet sequence rejection is not claimed from visual observation alone; exact
  deterministic counters/pixel checks carry that proof.
- Physical observation complements rather than replaces the deterministic
  mismatch and bytecode evidence.
