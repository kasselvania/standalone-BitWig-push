# Lifecycle and failure correctness

## Date, state, and authority

- Date: 2026-09-01 PDT.
- Machine state: accepted macOS 26.4.1 arm64, Bitwig Studio 6.1, real Push 3
  fixture; final official extension restored and Bitwig closed.
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

## Required fallback rule

Every no-authority or rejected state returns to a newly redrawn current
semantic frame and sends that same bitmap once through the unchanged transport.
Historical external bytes and prior composed pixels are never restoration
authority.

The deterministic harness covered no producer, CLEAR, clean close, crash,
stale timeout, wrong capability/protocol/session, duplicate/lower/exhausted
sequence, malformed/oversized metadata, nonopaque alpha, partial header,
partial payload, slow incomplete/complete messages, lock miss, collision,
writer rejection, receiver close, and shutdown.

## Exact correctness counters

The final clean-head harness rerun reported:

| Category | Count |
| --- | ---: |
| accepted frames | 1,511 |
| published frames | 1,511 |
| adopted frames | 1,111 |
| superseded frames | 398 |
| legal sequence gaps | 1 |
| sequence rejects | 3 |
| authentication rejects | 7 |
| malformed rejects | 11 |
| truncated headers | 1 |
| truncated payloads | 1 |
| sessions | 23 |
| disconnects | 23 |
| clears | 1 |
| stale expirations | 1 |
| induced lock misses | 1 |
| induced writer rejects | 1 |

Every required mismatch/failure count was exactly zero:

| Invariant | Count |
| --- | ---: |
| source-target mismatches | 0 |
| outside-current-region mismatches | 0 |
| old-region restoration mismatches | 0 |
| semantic-only fallback mismatches, all causes | 0 |
| old-session appearances after reconnect | 0 |
| duplicate/lower freshness refreshes | 0 |
| post-exhaustion appearances | 0 |
| partial/torn frame visibility | 0 |
| receiver mutation of display-consumer bytes | 0 |
| consumer mutation during V1D-1 application | 0 |
| partial destination writes | 0 |
| escaped display-loop exceptions | 0 |

The harness ran exact `960x160` opaque-BGRA semantic/output references and
checked target, outside, prior-region, semantic-only, and session transitions.

## Malformed and partial matrix

The producer exercised wrong capability, magic, version, HELLO/message type,
format, session, reserved fields, coordinates, dimensions, stride, payload
length, oversized declaration, nonopaque alpha, partial header, partial
payload, byte-at-a-time incomplete send, and slow complete send.

Rejected/incomplete messages produced no publication. The slow complete frame
appeared once as one coherent image only after its last byte. The subsequent
valid frame proved that the first listener remained healthy after rejection.

## Collision and restart

- While the first listener was active, a second bind to the exact port failed
  with address-in-use and started no second project thread.
- The original listener remained usable; a valid authenticated frame still
  appeared afterward.
- After each normal shutdown, an independent same-port bind probe succeeded
  immediately.
- Every following Bitwig external run also rebound successfully.

## Shutdown order and five-state matrix

Production source begins shutdown by revoking store/display authority and
closing active client/server sockets. The final semantic shutdown message is
therefore not covered. `isShutdown` is then set, and the existing shutdown
executor performs a maximum two-second receiver wait before unchanged USB and
superclass shutdown.

The exact clean artifact passed five normal maintainer quits:

| Receiver state | Result |
| --- | --- |
| waiting in `accept()` | normal quit; Bitwig/audio engine ended; listener absent; immediate rebind |
| authenticated and idle | socket close unblocked peer; normal quit; no residual listener; immediate rebind |
| continuously receiving 30 fps | producer observed close/exited; final semantics uncovered; normal quit/rebind |
| stalled after 31 header bytes | no partial raster; close unblocked read; normal quit/rebind |
| valid header plus 99 payload bytes | no partial raster; close unblocked read; normal quit/rebind |

No Bitwig force quit was used. `Ctrl-C` was applied only to exact temporary
producer processes that intentionally slept after Bitwig had already closed
their sockets.

The observer recorded one shutdown close/join sample of 0.006125 ms. The five
physical quits are the stronger blocked-state termination proof; no join
timeout, post-shutdown publication, listener residue, control/audio issue, or
covered final semantic screen was observed.

## Narrow error review

Narrow controller/startup/shutdown facts showed expected external selection,
listener creation, deliberate invalid-config/collision outcomes, and normal
socket closure. No relevant ingress/display exception appeared in passing
runs. Unrelated plugin-index/network license messages in Bitwig logs were not
attributed and no full logs were retained.

## Commands and tools

Evidence used the Java harness, Python failure producer, fixed reference pixel
arrays, `lsof`, exact process-path checks, socket collision/rebind probes,
aggregate counters, narrow log selection, and direct maintainer observation of
the Push through every fallback and shutdown state.

## Exact result

All deterministically required counters were reached, every mismatch/failure
invariant stayed zero, slow complete publication was atomic, the active
listener survived rejection, and all five blocking shutdown states terminated
normally with immediate same-port reuse.

## What this proves

- Rejected, partial, stale, disconnected, invalid-session, writer-failed, and
  shutdown states cannot retain external visual authority.
- Complete frames publish atomically; latest-only supersession does not replay.
- Normal shutdown unblocks both accept and partial reads without moving joins to
  the display thread.

## What this does not prove

- This was not a forced Bitwig crash, cable-removal, hostile same-user denial of
  service, or endurance test.
- Writer rejection was induced deterministically outside the real bitmap; the
  physical bitmap was not deliberately corrupted.
- One stalled peer may occupy protocol v1 until disconnect/shutdown; this is an
  explicit availability limitation, not a hidden correctness claim.
