# Permission and fail-closed fallback

## Date, machine state, and authority

- Date: 2026-09-02 PDT.
- Machine state: accepted macOS 26.4.1 arm64 fixture, stable helper app at
  `$HOME/Applications/PushwigCaptureHelper.app`, Bitwig Studio 6.1, and real
  Push 3.
- Central basis/tree:
  `7c15abaf55c0080b2f80971e845b4ee6f1bfcc46` /
  `730726784b57016714c0a44c8f0f8caf1c5b0141`.
- Source PR/head/tree:
  [PR #43](https://github.com/kasselvania/standalone-BitWig-push/pull/43) /
  `03fb8c8824714e4bbefd7224848ca9cdad069088` /
  `f1f68bc6f0ba6527bb146a7ee93fd4333ffaf796`.
- Amended helper executable SHA-256:
  `9a81bb292cfa00588c4be0272abb11a2e223132feb8725aca6e2c6a808bf942a`.

## Public Screen Recording lifecycle

The original V2 stable app executable, SHA-256
`7dc775f8eaa6ef50d85c24394ca22e492ceba9cd07738b97a893f0a3604564cc`,
first ran without Screen Recording authorization. Public
preflight/request APIs returned denied; the helper entered
`PERMISSION_UNAVAILABLE`, sent no FRAME, established no visual authority, and
reported one bounded actionable error. DrivenByMoss semantics, controls, and
audio remained operational.

Public TCC logging attributed that attempt to
`com.kasselvania.pushwig.capture-helper` at its stable `$HOME/Applications`
path. The maintainer then enabled the exact app manually in System Settings.
Relaunch of the same executable hash reported granted preflight and produced
the live crop. No private TCC operation, database edit, or automated global
reset was performed.

The amended exact-head executable retained the same stable app path and bundle
identifier. It reported granted preflight in both bounded inventory and focused
capture runs. The already accepted denial/regrant matrix was not repeated, and
denial is not attributed to the amended executable hash.

## Invalid configuration and source states

The temporary executable-level harness source SHA-256 was
`a63874d353ad1629789fddd56688d92453cd1030a8f38e6fef2c12a69e0f19b8`.
It tested 21 bounded cases:

- missing/unknown display ID;
- wrong expected width or height;
- NaN, infinity, negative origin, zero width/height, extent greater than one,
  and right/bottom crop overflow;
- negative, zero-size, and out-of-Push destination;
- missing or invalid capability file;
- invalid port, frame rate, or guard bundle ID;
- safely simulated unavailable/drifted selected display.

Every case exited nonzero without starting capture or establishing a protocol
connection, emitted one bounded actionable diagnostic, and did not crash or
fall back to full-display capture. Generated deterministic tests additionally
proved one-CLEAR authority transitions and rejection of incomplete/wrong-format
samples before publication.

## Live authority-loss paths

| Event | Exact observed result |
| --- | --- |
| Another app truly frontmost | one CLEAR, FRAME suppression, current DrivenByMoss semantics |
| Bitwig frontmost again | current frames resume; no historical replay |
| Normal helper exit | one CLEAR where the receiver remained available; semantics |
| Forced exact-helper termination | socket disappeared within 80 ms; receiver disconnect/stale fallback; no residue |
| Bitwig quit while helper active | receiver close produced bounded disconnect; helper stopped; no stale raster |
| Authenticated receiver stops reading | fixed 250 ms message deadline; client closes; queued shutdown released in at most 251.863417 ms in 40 retained runs |
| Screen Recording denied | no FRAME/no visual authority; semantics |
| Invalid display/crop/destination | no capture or connection; semantics |
| Simulated display disappearance/drift | revalidation rejects authority; no current frame |

The forced termination was intentionally limited to the helper, not Bitwig.
The maintainer confirmed the crop disappeared with no stale pixels, tearing, or
residue. The previously retained final live quit recorded the helper transition
`GUARD_INVALID -> CAPTURING -> DISCONNECTED -> STOPPING`, 75 frames, 1,324
guard-suppressed samples, and no capture/pixel errors. Two protocol failures
were expected bounded broken-pipe behavior: the receiver closed during Bitwig
quit, so the in-flight FRAME and subsequent best-effort CLEAR could not be
delivered. No stale image remained.

The capture stream delegate's failure path revokes capture authority, stops
eligible FRAME publication, and performs serialized CLEAR where possible.
That path and display-loss behavior were covered deterministically. A physical
display hot-unplug or forced ScreenCaptureKit service failure was not induced
because it would have changed the accepted workstation topology; this boundary
is explicit rather than claimed as a physical test.

## Exact result

Every required permission, invalid-configuration, source-guard, helper-exit,
forced-helper-termination, receiver-loss, and safely simulated display-loss
path produced no continuing visual authority and returned the Push to current
semantics. No rejected state published a partial or full-display fallback.

## Commands and tools

Evidence used public `CGPreflightScreenCaptureAccess`/
`CGRequestScreenCaptureAccess`, stable-app LaunchServices launch, narrow public
TCC log selection, exact executable hashing, aggregate helper counters,
process/socket checks, deterministic Swift tests, the 21-case temporary harness,
maintainer focus changes, and direct physical Push observation. The capability
value, screenshots, frames, and full logs were not retained.

## What this proves

- Permission denial, invalid configuration, focus loss, helper exit/kill,
  receiver loss, and safely simulated display invalidation fail closed to
  semantic authority without partial or historical frame replay.
- The accepted denial/regrant pair is tied to one stable app/binary identity;
  amended-head success is tied to the same stable bundle/path identity and its
  separately retained executable hash.

## What this does not prove

- It does not physically hot-unplug the display or forcibly crash Apple's
  capture service.
- Public Screen Recording permission is user-controlled machine state; this
  evidence does not claim an installer can grant it automatically.
