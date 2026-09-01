# Lifecycle and failure correctness

## Date, state, and identities

- Date: 2026-09-01 PDT.
- Machine state: accepted macOS 26.4.1 arm64 fixture and deterministic local harnesses.
- Central basis/tree: `5597624bd50e5ef95ecd3af82ea1816ce4facd21` / `ec016bd3174345e32f1a6d47eb061820e7a1e9b9`.
- DrivenByMoss basis/tree: `663d719207ef58ec84b4d235c43211ec5da43605` / `c4e42825d069421a44b3241349de9a7c6453a3ad`.
- Final candidate head/tree: `4f00972355fcf7b5f0ead0fef3365b81850be12f` / `7202267e51d0f2613cea93d186b132a996ec14ec`.
- Correctness harness SHA-256: `ed8a73fdbf5dc2e989331195719e64b5c42c2a6dae981aeda6596d7e4b653b3f`.
- Failure-latency harness SHA-256: `44f51daaeb8ef28603dace7a8d99bdd839d49d69316f7cbff01e440fa207b61f`.

## Exact final full-harness result

```text
HARNESS PASS
ticks=21837 visibleFrames=18362 semanticFrames=3475
accepted=1534 published=1534 adopted=1529 superseded=5
gapEvents=76 sequenceRejects=2 authRejects=3 malformedRejects=7
truncatedHeaders=2 truncatedPayloads=2 sessions=28 disconnects=28
clears=1 stale=2 lockMisses=5 writerRejects=1
sourceTargetMismatches=0 outsideMismatches=0 oldRegionMismatches=0 semanticOnlyMismatches=0
consumerMutations=0 escapedDisplayExceptions=0 maxFallbackNanos=553000
primaryShutdownNanos=361209
shutdownScenariosNanos=[165250,1721000,298541,256500,523250]
```

The five scenario timings, in order, are wait-in-accept, authenticated idle, continuous frames, stalled partial header, and stalled partial payload. Every value is far below the `2,000 ms` receiver join bound.

## Pixel/lifecycle invariants

The harness used exact `960x160` opaque-BGRA semantic references and deterministic small, odd-stride, medium, full, moving, replacement, and absent visuals. It exercised more than 1,000 complete publications and checked after every process call.

| Required invariant | Final count |
| --- | ---: |
| Published source-target mismatch | 0 |
| Outside-current-region mismatch | 0 |
| Old-region restoration mismatch | 0 |
| Semantic-only mismatch after absence/failure | 0 |
| Old-session appearance after reconnect | 0 |
| Duplicate/out-of-order freshness refresh | 0 |
| Partial/torn frame visibility | 0 |
| Receiver mutation of display-consumer bytes | 0 |
| Consumer source mutation during writer | 0 |
| Escaped display-loop exception | 0 |

The semantic reference changed while a raster covered a region; after movement/absence/failure, the newly current semantic bytes reappeared. No prior semantic snapshot or composed output overwrote them.

## Failure matrix

| Condition | Authority/result |
| --- | --- |
| No producer | No publication; current semantic-only output. |
| Explicit CLEAR | Validate next sequence and zero fields; invalidate publication/epoch immediately; keep session open. |
| Clean close | `finally` invalidates that local generation, increments disconnect, returns to accept. |
| Producer crash | EOF/close follows the clean-close invalidation path; semantic-only output. |
| Stale frame | Display compares local `System.nanoTime`; clears its current flag after `1,500 ms`; producer connection may remain open. |
| Wrong token/version/magic | Reject before session authority; close connection; return to accept. |
| Wrong session/common header | Reject message, invalidate authenticated generation on return, return to accept. |
| Duplicate/lower/nonpositive sequence | Count sequence rejection, invalidate session immediately, close/return to accept. |
| Skipped sequence | Accept, count one gap event, newest complete publication remains authority. |
| Malformed type/format/dimensions/stride/length/reserved bits | Count malformed rejection, invalidate authenticated generation, close/return to accept. |
| Oversized declaration | Reject before payload read/allocation; semantic-only output. |
| Nonopaque alpha | Reject after complete bounded read and before publication. |
| Partial header/payload | Count truncation; publish nothing from the message; invalidate session on connection end. |
| Slow incomplete sender | Receiver may block; display remains semantic/current without partial visibility. |
| Slow complete sender | Publish once, atomically, only after full validation. |
| Receiver exception | Log once, exit receiver, `store.close()` invalidates authority; no retry/error loop. |
| Bind failure/collision | Log once, start no receiver, leave full DrivenByMoss semantics usable. |
| V1D-1 writer rejection | Mark that publication rejected/current false; semantic-only output; do not retry the same publication. |
| Shutdown | Set closing, close store/authority, close client/server, unblock read/accept, bounded join, then existing USB/super shutdown. |

## Rates, session, and supersession

The harness tested 1 fps with the selected 1.5-second timeout, 15, 30, 60, and a 400 fps burst with legal gaps. It also tested silence just below timeout, just above timeout, and a long stall. Positive evidence included `5` superseded publications and `76` gap events. New authenticated sessions accepted sequence reset to `1`; duplicate/lower sequences were rejected and did not refresh receipt time.

The real fixture separately observed the 400 fps burst disappear without backlog replay and confirmed duplicate/out-of-order/new-session behavior.

## Fallback latency

- Full lifecycle harness maximum observed process-loop fallback: `553,000 ns` (`0.553 ms`).
- Exact-final malformed-input invalidation, 1,000 post-warmup samples: p50 `20,875 ns`, p95 `80,542 ns`, maximum `986,084 ns`.
- Staleness threshold: exactly `1,500 ms` from local complete-frame receipt; the next display process call removes the frame. The real Push visibly returned to semantics while the producer connection was still open.

## Rapid restart and active-listener ownership

The initial candidate's explicit no-reuse socket option caused a live rapid-restart bind failure after the authenticated-idle shutdown. That failure was retained and not counted as a pass. The final candidate enables address reuse before binding.

The focused Java harness proved:

```text
active_second_rejected=true
immediate_rebind=true
```

The exact final artifact then rebound `127.0.0.1:45291` immediately between every formal shutdown run and passed all five live blocking states.

## Commands and tools

Commands included exact-head Java 21 harness compilation/execution, the standard-library Python producer, `System.nanoTime`, `ThreadMXBean`, deliberate TCP close/process exit/truncation/slow sends, `lsof`, `ps`, narrow Bitwig log checks, `javap`, and real Push observation.

## What this proves

- Every complete/current/absence/failure/session lifecycle state ends in the exact required output without partial publication or historical restoration.
- Latest-frame supersession is application-level overwrite, not backlog playback.
- Startup, receiver failure, rapid restart, and all required shutdown blocking states have exact bounded behavior.

## What this does not prove

- It does not claim zero OS scheduling delay, zero packet buffering, resilience to a malicious same-user process holding the capability, or long-duration soak behavior.
- Writer rejection was induced in the deterministic harness rather than by corrupting the user's real Bitwig bitmap.
- Receiver bind failure was safely simulated and physically observed as semantic fallback; no automatic in-process rebind retry is proposed.
