# Session, sequence, and freshness

## Date, state, and authority

- Date: 2026-09-01 PDT.
- Machine state: accepted macOS 26.4.1 arm64 / Bitwig Studio 6.1 / real Push 3
  fixture; official extension restored and Bitwig closed.
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

## Session authority

An authenticated HELLO supplies a nonzero 128-bit producer session identity.
The receiver assigns a distinct local connection generation. A frame can be
published only when both the authenticated session and current local generation
still match store authority.

Beginning a new authenticated connection revokes the old publication/display
authority before accepting a new frame. Clean disconnect, producer crash,
CLEAR, malformed/sequence invalidation, receiver exit, writer rejection,
staleness, and shutdown also advance/revoke authority. Consequently an old
connection or old display-owned bytes cannot become current again.

## Sequence rules

- FRAME/CLEAR sequence is a positive signed Java `long`.
- Values must be strictly greater than the previously accepted FRAME/CLEAR in
  that authenticated session.
- Legal gaps are accepted and counted; no placeholder or backlog is created.
- Duplicate, lower, and nonpositive values invalidate the session and do not
  refresh frame freshness.
- `Long.MAX_VALUE` is the final legal FRAME/CLEAR sequence. Once accepted, any
  later publication attempt is rejected and the session must reconnect.
- A new authenticated connection with a new producer session may restart at
  sequence `1`.
- Unsigned wraparound and negative wrapped sequences are not accepted.

## Freshness authority

Freshness uses only local `System.nanoTime()` captured after one complete FRAME
passes every validation and is committed to publication. HELLO, CLEAR,
duplicate/lower/nonpositive sequence, malformed/partial message, rejected
authentication, and rejected frame do not refresh it.

The default timeout is 1,500 ms, bounded to 100..10,000 ms at construction. A
display-owned frame remains usable only while its authority epoch still
matches, receipt time remains within the timeout, and the V1D-1 writer has not
rejected it. The first eligible send after expiry produces a newly current
semantic frame with no external raster.

No producer timestamp or wall clock is trusted.

## Deterministic results

The exact final harness reported:

| Counter | Result |
| --- | ---: |
| authenticated sessions | 23 |
| disconnects | 23 |
| legal sequence gaps | 1 |
| sequence rejects | 3 |
| clears | 1 |
| stale expirations | 1 |
| accepted/published frames | 1,511 / 1,511 |
| adopted/superseded frames | 1,111 / 398 |
| old-session appearances | 0 |
| duplicate/lower freshness refreshes | 0 |
| post-exhaustion appearances | 0 |

The harness accepted `Long.MAX_VALUE` as the final publication, rejected the
next attempt, and admitted sequence reset only after new authenticated session
authority. It also induced a legal gap and positive supersession while proving
no intermediate replay.

## Physical results

- A faster-than-display 5,000-frame burst produced no visible catch-up,
  tearing, residue, or stale block; current semantics returned promptly.
- Legal gap, duplicate, lower, exhaustion, and new-session/reset cases produced
  no visible error or old-session image. These are deliberately success-by-
  absence cases; exact counter/path proof is deterministic rather than inferred
  solely from the screen.
- At 1 fps the frame remained fresh under the default timeout.
- At 15/30/60 fps presentation was coherent without backlog.
- When a valid connection stopped sending, the visible raster disappeared after
  approximately the configured 1.5-second timeout while the connection remained
  open.
- CLEAR, disconnect, and process exit each returned promptly to current
  semantics.

## Fallback latency

The configured stale boundary was 1,500 ms plus the interval to the next
eligible display send; physical observation matched approximately 1.5 seconds.
CLEAR, clean disconnect, and forced producer exit revoked authority promptly at
the next send. No producer clock contributed to these outcomes.

## Commands and tools

Evidence used exact wire messages from the Python producer, reflective primitive
counter readback in the Java harness/observer, deterministic reference pixels,
local monotonic timing, accelerated burst/gap/duplicate/lower/exhaustion/reset
sequences, and direct physical observation.

## Exact result

Session plus receiver generation prevents old authority reuse; sequence
strictness, legal gaps, exhaustion, reconnect reset, and local receipt-time
freshness all passed with zero old-session, freshness-refresh, or
post-exhaustion appearances.

## What this proves

- Latest-frame authority is explicit and cannot wrap/replay across invalid or
  replacement sessions.
- Freshness depends on complete local receipt rather than an external clock.
- Absence/staleness restores the newest current semantic frame rather than a
  historical composed output.

## What this does not prove

- Physical absence alone cannot distinguish every sequence rejection; the
  exact negative cases rely on deterministic harness counters and pixel checks.
- This is one active authenticated producer/session at a time, not multi-source
  arbitration or durable sequencing across Bitwig restarts.
