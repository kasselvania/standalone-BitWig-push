# Real fixture and exact rollback

## Date, machine state, and authority

- Evidence date: 2026-09-01 PDT.
- Machine state: accepted macOS 26.4.1 arm64 fixture, Bitwig Studio 6.1, real Ableton Push 3 Controller, and Push headphone output.
- Actual central basis/tree: `4265dc7b6f1cabf2dcbad1b827d002bd9062cf4f` / `2af6b4757e5906ce74a3b52c5ee82323f5e32406`.
- DrivenByMoss basis/tree: `1ae0b74f383314d170a5960ca763bdf9c319e787` / `a81e5c4330b31f36845c25e98e322990d62f0c67`.
- Source PR/head/tree: [kasselvania/DrivenByMoss#3](https://github.com/kasselvania/DrivenByMoss/pull/3), `4b3326eddcf2d890de3baa10b93f6e80842d41e1`, tree `d03a372e2efcf41b22cef46501e08efbfb0c0036`.
- Exact clean V1C artifact: 14,367,247 bytes, SHA-256 `f9671047e342ed3d2503fae3423ea27725830e359e75b51e29fc88ac316be4b3`.
- Accepted official artifact: 14,362,484 bytes, SHA-256 `98dc3195ad8d911526e18b1005f09f69a1aedcb965b080565474104654345c5a`.

## Safe installation custody

Canonical scan path:

```text
$HOME/Documents/Bitwig Studio/Extensions/DrivenByMoss.bwextension
```

Before replacement:

- exact-name checks showed no Bitwig Studio or Bitwig Audio Engine process;
- the installed official artifact rehashed to the accepted value;
- it was the sole matching extension in the scan directory.

The official artifact was moved intact to this timestamped directory outside Bitwig's scan paths:

```text
$HOME/Documents/ChatGPT/BitWig Standalone Push/v1c-artifact-backups/20260901T171417Z-observation
```

Its backup hash remained exact. Temporary observation artifacts and the final clean proposed-head artifact were installed only while Bitwig was stopped, under the canonical filename, and verified as the sole scanned DrivenByMoss extension.

The formal fixture phases used only the exact clean artifact SHA-256 `f9671047e342ed3d2503fae3423ea27725830e359e75b51e29fc88ac316be4b3`. It contained no harness, timing, pixel observer, temporary property, or aggregate logging code.

## Formal clean-artifact phases

| Phase | Startup | Result |
| --- | --- | --- |
| A | no Pushwig property | Full controller/audio baseline passed; no generated visual; normal quit |
| B | `pushwig.syntheticOverlay=true` | Accepted fixed V1B mark; no dynamic lifecycle; regression modes/audio passed; normal quit |
| B2 | both static and dynamic true | Dynamic lifecycle won; static mark not stacked; restoration passed; normal quit |
| C | `pushwig.dynamicLocalVisual=true` | Full seven-state lifecycle, representative modes, semantic update, overlay, notification, controls/audio, and normal quit passed |

Startup logs confirmed only property delivery. Direct behavior was supplied by the maintainer using the real Push.

Narrow current-run log checks found no relevant DrivenByMoss extension/display exception. Bitwig's log contained unrelated plug-in metadata/indexer, missing package asset, EOF, and network-route messages; none named or implicated the V1C display path and none was promoted to controller acceptance evidence.

## Master/Cue hardware-page note

During Phase C, touching/pressing the conductive Volume encoder displayed Push's own system mixer page. “Cue Volume” text stayed present while the representation behind it alternated. Holding the encoder kept the system page present.

The clean Clip-mode notification test passed without that hardware page, and the maintainer identified the conductive-touch mixer page after official rollback as the explanation for the earlier visual alternation. This is retained as a pre-existing Push/DrivenByMoss interaction, not a V1C-generated-layer failure.

## Exact rollback

After Phase C:

1. Bitwig quit normally.
2. Exact-name checks confirmed Bitwig Studio and Bitwig Audio Engine stopped.
3. The installed clean derivative rehashed to `f9671047e342ed3d2503fae3423ea27725830e359e75b51e29fc88ac316be4b3`.
4. It was moved outside the scan path as `DrivenByMoss.v1c-clean-tested.bwextension` and rehashed unchanged.
5. The untouched official backup rehashed to `98dc3195ad8d911526e18b1005f09f69a1aedcb965b080565474104654345c5a`.
6. The official artifact was moved to the exact canonical filename/path.
7. Final hash, size, timestamp, and sole-copy count were read back.

Final installed state:

| Field | Result |
| --- | --- |
| Filename | `DrivenByMoss.bwextension` |
| Bytes | 14,362,484 |
| Modification time | 2025-11-28 22:28:38 PST |
| SHA-256 | `98dc3195ad8d911526e18b1005f09f69a1aedcb965b080565474104654345c5a` |
| Matching scan-directory files | 1 |

Bitwig was relaunched with `JAVA_TOOL_OPTIONS` absent. The maintainer physically confirmed:

- Push connected normally;
- the ordinary DrivenByMoss semantic display returned;
- no generated colored boxes appeared;
- representative controls remained functional.

The user's ordinary environment was left on the exact official artifact.

## Commands and tools

Tools included exact-name `pgrep`, `shasum -a 256`, `stat`, scoped `find`, explicit-path `mkdir`/`mv`/`cp -p`, hard hash/path preconditions, Bitwig's actual executable, narrow current-run log filters, and direct maintainer observation. No force quit, overwrite of the official file, screenshot, raw frame, full log, project, or preset was retained.

## What this proves

- Every extension replacement occurred with Bitwig stopped.
- The exact clean source-head artifact, not an instrumented build, passed the full fixture.
- The official artifact was restored byte-for-byte as the sole scanned extension and remained physically loadable.

## What this does not prove

- This is not a forced-crash, cable-removal, reconnect, endurance, detailed latency, or Push 2 test.
- Out-of-scan derivative/observation artifacts are custody copies only and are not loaded by Bitwig.
