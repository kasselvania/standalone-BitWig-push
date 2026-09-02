# Real Push fixture and exact rollback

## Date, machine state, and authority

- Date: 2026-09-02 PDT.
- Fixture: accepted macOS 26.4.1 build 25E253 / Darwin 25.4.0 arm64 Mac,
  Bitwig Studio 6.1, real Ableton Push 3, and Push headphone audio route.
- Central basis/tree:
  `7c15abaf55c0080b2f80971e845b4ee6f1bfcc46` /
  `730726784b57016714c0a44c8f0f8caf1c5b0141`.
- Source PR/head/tree:
  [PR #43](https://github.com/kasselvania/standalone-BitWig-push/pull/43) /
  `03fb8c8824714e4bbefd7224848ca9cdad069088` /
  `f1f68bc6f0ba6527bb146a7ee93fd4333ffaf796`.
- DrivenByMoss integration commit/tree, unchanged:
  `7e3416a1bdddbcbeec4e35e6531652e1618723de` /
  `c8bc3f9e052e8f0b7b5dd256657697349d303740`.
- Exact derivative artifact: 14,388,379 bytes, SHA-256
  `3a05c8490f8947d82f80677982c1c52f71bba1b6e3b8dd37c94ce0246d0c7b48`.
- Exact amended helper executable SHA-256:
  `9a81bb292cfa00588c4be0272abb11a2e223132feb8725aca6e2c6a808bf942a`.
- Previously retained full-fixture source head/helper SHA-256:
  `c6c4e05c6c4bc1924b529a28990ea633515667cf` /
  `7dc775f8eaa6ef50d85c24394ca22e492ceba9cd07738b97a893f0a3604564cc`.
- Accepted official artifact SHA-256:
  `98dc3195ad8d911526e18b1005f09f69a1aedcb965b080565474104654345c5a`.

## Installation custody

The maintainer saved work and quit Bitwig normally. Process readback confirmed
Bitwig Studio and its audio engine were stopped. The canonical official
extension was rehashed to the accepted value, moved intact to a timestamped
backup outside every Bitwig scan path, and rehashed there.

The clean accepted DrivenByMoss integration was rebuilt without source changes:

```text
env \
  JAVA_HOME=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home \
  PATH=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin \
  mvn clean install package -Dbitwig.extension.directory=target
```

Java was Homebrew OpenJDK 21.0.11 and Maven 3.9.16. The build succeeded in
12.618 seconds. Exactly one derivative artifact was installed under the
canonical filename. A fresh private regular capability file, owned by the
current user with mode `0600`, was created outside repositories; its value was
never printed or retained. Bitwig launched with the accepted external-ingress
properties, and listener readback proved exact IPv4 loopback. The exact signed
helper then connected as the sole visual producer.

## Previously retained 31-row physical acceptance

Before the bounded repair, the maintainer returned PASS for every row using the
previous exact source/helper identities listed above:

| # | Physical check | Result |
| ---: | --- | --- |
| 1 | Push connects and leaves its connection screen | PASS |
| 2 | Pads produce notes | PASS |
| 3 | Pressure/MPE works | PASS |
| 4 | Eight encoders work | PASS |
| 5 | Transport works | PASS |
| 6 | Semantic display remains current | PASS |
| 7 | Push remains Bitwig's audio device | PASS |
| 8 | Master output is audible through Push headphones | PASS |
| 9 | Real Sampler pixels appear | PASS |
| 10 | Pixels appear only in the declared destination | PASS |
| 11 | No entire display appears | PASS |
| 12 | A meaningful Sampler visual change appears live | PASS |
| 13 | Vertical orientation is correct | PASS |
| 14 | Color channels are correct | PASS |
| 15 | Aspect proportions look correct | PASS |
| 16 | No visible independent-axis stretch remains | PASS |
| 17 | Guard false sends CLEAR and returns to semantics | PASS |
| 18 | Guard true resumes the current visual | PASS |
| 19 | Permission denial/unavailability returns to semantics | PASS |
| 20 | Invalid display/crop/destination returns to semantics | PASS |
| 21 | Normal helper exit returns to semantics | PASS |
| 22 | Forced helper termination returns to semantics | PASS |
| 23 | Bitwig quit leaves no stale captured raster | PASS |
| 24 | No torn or partial frame is observed | PASS |
| 25 | No stale crop remains | PASS |
| 26 | No control lag is observed | PASS |
| 27 | No abnormal display lag is observed | PASS |
| 28 | No audio xrun or dropout is observed | PASS |
| 29 | No relevant helper or DrivenByMoss exception is observed | PASS |
| 30 | Helper quits normally during the ordinary path | PASS |
| 31 | Bitwig quits normally without force quit | PASS |

The final live Bitwig quit occurred while the helper had been active. The
maintainer reported `Bitwig Closed Cleanly`; process readback found no Bitwig,
audio-engine, helper, or listener process, and no stale raster remained.

The repair deliberately did not repeat this entire matrix. It changed only the
socket-write bound, centered-cover geometry, point-unit wording/revalidation,
and deterministic tests. The exact amended head instead passed the following
focused smoke while relying on this retained full baseline for unaffected rows.

## Focused amended-head repair smoke

The unchanged accepted V1D-2 derivative was installed temporarily, with the
exact amended helper as the sole producer and DrivenByMoss still the sole Push
USB writer.

| # | Focused check | Result |
| ---: | --- | --- |
| 1 | Ordinary valid capture reaches Push | PASS — direct maintainer confirmation |
| 2 | New maximal fractional mapping preserves proportions | PASS — direct maintainer confirmation |
| 3 | Bitwig/frontmost guard loss sends CLEAR and restores semantics | PASS — direct maintainer confirmation plus two recorded revocations |
| 4 | Returning Bitwig frontmost resumes current capture | PASS — direct maintainer confirmation; no replay |
| 5 | Normal helper quit completes and restores semantics | PASS — exit 0, final CLEAR, direct maintainer confirmation |
| 6 | Authenticated stalled receiver releases blocked output/shutdown boundedly | PASS outside musical fixture — 40 retained runs, maximum 251.868083 ms write failure and 251.863417 ms queued shutdown |

The accepted normal-quit run recorded 555 delivered callbacks, 135 published
frames, 420 deliberate guard suppressions, two guard-invalid and two
guard-valid transitions, two authority revocations, zero protocol/stream/pixel/
stride/destination errors, one reusable output buffer, one serial output queue,
and no application frame queue. The source rectangle read back as
`480.2,984.1275,1543.5,441.0` ScreenCaptureKit points and mapped uniformly to
`560x160` output pixels.

## Exact rollback

1. The helper was stopped and the private capability file removed.
2. Bitwig and its audio engine were confirmed stopped; the V1D-2 listener was
   absent.
3. The installed derivative rehashed to
   `3a05c8490f8947d82f80677982c1c52f71bba1b6e3b8dd37c94ce0246d0c7b48`
   and was moved outside every scan path.
4. The untouched official artifact was restored to
   `$HOME/Documents/Bitwig Studio/Extensions/DrivenByMoss.bwextension`.
5. Its restored SHA-256 was exactly
   `98dc3195ad8d911526e18b1005f09f69a1aedcb965b080565474104654345c5a`.
6. A scan found exactly one DrivenByMoss extension.
7. Bitwig relaunched without Pushwig environment/properties and with no helper
   or listener.
8. The maintainer confirmed all four final checks: standard DrivenByMoss
   display, normal controls, Push audio/headphones, and no captured/generated
   pixels. Bitwig then closed normally.

Final independent readback again found one canonical extension at the exact
official hash, no listener, and no Bitwig/helper process. The ordinary
environment is left on the official artifact. The stable helper app remains
installed but inactive to preserve its proven development/TCC identity.

## Exact result

The previously retained 31 live V2 checks, the exact amended-head focused
repair smoke, and the official-artifact checks passed. The fixture ended with
Bitwig closed, no capture/ingress process, and exactly one scanned official
extension at the accepted SHA-256. The maintainer again confirmed the restored
standard DrivenByMoss display with no captured overlay and closed Bitwig
normally.

## Commands and tools

Tools included source/artifact hashing, the explicit Java 21/Maven build,
filesystem scan, file mode/type/owner checks, normal Bitwig launch/quit, stable
app launch, `ps`, `pgrep`, `lsof`, aggregate helper logs, safe file moves, and
direct maintainer observation. The repair added the deterministic stalled-peer
harness and exact amended app signature/hash readback. No token, binary, frame,
screenshot, project, or full log is committed.

## What this proves

- The original full matrix establishes the controller/display/audio baseline;
  the focused amended-head run establishes that the changed capture, aspect,
  guard, and normal-quit paths still work with the unchanged derivative.
- All required live loss/fallback paths were observed without stale or partial
  Push pixels.
- The official artifact was restored byte-for-byte and remains loadable and
  physically normal.

## What this does not prove

- It is not a forced-Bitwig-crash, cable-removal, physical display-hotplug,
  endurance, Push 2, or multi-display test.
- Direct observation complements, but does not replace, deterministic byte and
  configuration tests.
