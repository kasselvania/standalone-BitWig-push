# V1B installation and rollback

## Date and machine state

- Evidence date: 2026-08-31 PDT.
- Machine state: accepted macOS 26.4.1 arm64 fixture, Bitwig Studio 6.1, Push 3 connected; every extension replacement occurred only after exact-name process checks showed Bitwig and its audio engine stopped.
- Central basis: `a13faef08ac8bb75a9e32f7ff7d4bc07fcd41c6e`, tree `c06009f822fee7bf36096739e7be6589f0b9ae34`.
- Source basis: `033ccef8c64f08e8d8d41fa90d48fa06b326a1a1`, tree `9aec7429ff093addee001a62a5a07309708fd592`.
- Source PR/head/tree: [kasselvania/DrivenByMoss#2](https://github.com/kasselvania/DrivenByMoss/pull/2), `a2e0341b7bccfa4e6b13614f4adffc2235f785f4`, tree `a81e5c4330b31f36845c25e98e322990d62f0c67`.

## Pre-install and safe custody

Canonical scanned path:

```text
$HOME/Documents/Bitwig Studio/Extensions/DrivenByMoss.bwextension
```

Initial official readback:

```text
bytes: 14,362,484
SHA-256: 98dc3195ad8d911526e18b1005f09f69a1aedcb965b080565474104654345c5a
matching scan-directory files: 1
```

The timestamped backup directory was outside every Bitwig extension scan path:

```text
$HOME/Documents/ChatGPT/BitWig Standalone Push/v1b-artifact-backups/20260831T212245Z-observation
```

The official artifact was moved intact, never overwritten, and immediately rehashed to the accepted value. Temporary observation builds were installed only while Bitwig was stopped, then moved outside the scan path. The final exact committed-head artifact was installed at the canonical filename and verified:

```text
bytes: 14,365,128
SHA-256: 117dbffd8ec8baa6c128893c6726b676ddacbc2b1ba645ef685f8bd6b90f75e6
matching scan-directory files: 1
```

## Exact committed-artifact launches

- Phase A: normal launch without Java property; all 14 property-off rows passed; normal quit verified by exact executable-name process checks.
- Phase B: actual Bitwig executable launched with `JAVA_TOOL_OPTIONS=-Dpushwig.syntheticOverlay=true`; all 24 baseline/overlay/stability/lag/audio/error rows passed; normal quit verified.
- Phase C: normal restart without the property; mark absent, normal semantic display restored, representative behavior passed, and normal quit verified.

Narrow current-run searches for controller/extension/display/Push/MIDI/USB errors, exceptions, or failures returned no relevant matches in all formal phases. Behavioral claims come from direct maintainer use, not from file presence or log enumeration.

## Exact rollback

After Phase C and another stopped-process check:

1. The installed V1B artifact rehashed to `117dbffd8ec8baa6c128893c6726b676ddacbc2b1ba645ef685f8bd6b90f75e6`.
2. It was moved outside the scan path as `DrivenByMoss.v1b-tested.bwextension` and rehashed unchanged.
3. The untouched official backup rehashed to the accepted official value.
4. The official file was moved back to the exact canonical path.
5. Final hash, size, original modification time, and scan count were checked.

Final installed state:

| Field | Result |
| --- | --- |
| Filename | `DrivenByMoss.bwextension` |
| Bytes | 14,362,484 |
| Modification time | 2025-11-28 22:28:38 PST |
| SHA-256 | `98dc3195ad8d911526e18b1005f09f69a1aedcb965b080565474104654345c5a` |
| Matching scan-directory files | 1 |

Bitwig was relaunched normally. The engine and controller processes started, the narrow error filter returned no relevant match, and the maintainer physically confirmed the normal official DrivenByMoss semantic display with no synthetic mark. The ordinary environment was left on the exact official artifact.

## Commands and tools

Tools included exact-name `pgrep`, `shasum -a 256`, `stat`, scoped `find`, explicit-path `mkdir`, `mv`, `cp -p`, hard hash/path preconditions, normal Launch Services startup, actual-executable property startup, narrowly filtered current-run logs, and direct maintainer observation. No force quit, reinstall, source repair, full log, screenshot, or raw frame was retained.

## What this proves

- No extension replacement occurred while Bitwig was running.
- The sole exact committed-head artifact was exercised in off/on/off phases with the real Push.
- Restart removes the diagnostic selection; no hot-removal mechanism is needed or claimed.
- The official artifact was restored byte-for-byte, remains the sole scanned extension, and remains physically loadable.

## What this does not prove

- The run is not a forced-crash, cable-removal, reconnect, endurance, or detailed audio-latency test.
- The out-of-scan tested derivative copies are evidence custody only and are not loaded by Bitwig.
