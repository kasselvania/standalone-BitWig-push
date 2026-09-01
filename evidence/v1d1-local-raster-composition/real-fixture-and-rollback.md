# V1D-1 real fixture, installation, and rollback

## Date, machine state, and authority

- Evidence date: 2026-09-01 PDT.
- Machine state: accepted macOS 26.4.1 arm64 fixture, Bitwig Studio 6.1, DrivenByMoss 26.4.1, real Push 3 Controller, and Push headphone audio route.
- Central basis/tree: `c94d1b74d702e696d6cc4cc89625f1a2f7a95530` / `8539026fc9476bbf2df34b310190a57906113b90`.
- DrivenByMoss basis/tree: `852b520933eed87fbe496a04b5c18819a10b3564` / `d03a372e2efcf41b22cef46501e08efbfb0c0036`.
- Source PR/head/tree: [kasselvania/DrivenByMoss#4](https://github.com/kasselvania/DrivenByMoss/pull/4), `3c3ca02ff81ab5ce110ae3d714e20b5fca05a03f`, tree `c4e42825d069421a44b3241349de9a7c6453a3ad`.

## Initial official state and safe backup

Before each artifact change, the maintainer saved work and quit Bitwig normally. Exact-name process readback showed no `BitwigStudio` or `BitwigAudioEngine-ARM64-NEON` process. The sole scanned file was:

```text
$HOME/Documents/Bitwig Studio/Extensions/DrivenByMoss.bwextension
SHA-256 98dc3195ad8d911526e18b1005f09f69a1aedcb965b080565474104654345c5a
bytes 14,362,484
```

The official file was moved intact to a timestamped directory under `$HOME/Documents/ChatGPT/BitWig Standalone Push/v1d1-artifact-backups/`, outside Bitwig scan paths. Its hash was rechecked before any derivative was installed. At no point did a second DrivenByMoss extension exist in the scanned directory tree.

## Temporary observation artifact

The observation worktree was detached/derived from exact production head `3c3ca02ff81ab5ce110ae3d714e20b5fca05a03f`. It changed only observation hooks and one aggregate observer, remained uncommitted, and was built under the exact Java 21/Maven environment.

```text
complete patch SHA-256:
f3292a792fe7eb465549d3156b8890983a6349e98934e74cbe6834a2b6c0ccf0

temporary source SHA-256:
BitmapImpl.java                           56ba16b651387b4fd6a88478ec688f31e65cf0b5b7df7034bed5609d4488a973
DynamicLocalRasterPushFramePipeline.java  83fd026346d48b56149f3562eda7999915f9203a796e732c4f137c0ea8b160d0
Push2Display.java                         f829bad2eb3792a26d5b193325a370e7b2387e378acb23bb5d6bb3117fe83eac
AbstractGraphicDisplay.java               83b76e705f393de86b4644e3efcc7f7319a20f2079651b285e0934ecab3ea67a
V1D1RasterObserver.java                   79d9cb2f61ac565a8b63da79816dcf05e21428878fa748d5ef40e66dc62a97d9

artifact bytes:   14,381,388
artifact SHA-256: c4e569fe831b8661b6a77dffa8dd772f7f47eca3a79144683a0fceb403eacd5a
build:             BUILD SUCCESS, 14.205 s, finished 2026-09-01 13:19:41 PDT
```

The installed observation artifact hash matched exactly and was the sole scanned copy. Bitwig was launched through its actual executable with both properties supplied before process start:

```sh
env JAVA_TOOL_OPTIONS='-Dpushwig.dynamicLocalRaster=true -Dpushwig.v1d1RasterObservation=true' \
  '/Applications/Bitwig Studio.app/Contents/MacOS/BitwigStudio'
```

The startup log directly showed the exact `JAVA_TOOL_OPTIONS`. The observer independently characterized a 960×160, 614,400-byte, direct writable little-endian ARGB32 destination on the `Control Surface Session` thread. The interactive and required hands-off rerun each completed 1,920 correctness sends with every mismatch, invalid-acceptance, rejection, and dimension-error count zero. Timing and observation overhead are retained in `performance.md`.

After the second run, Bitwig quit normally. The observation artifact was moved outside the scan path. Its worktree was restored to exact clean source head/tree and no temporary source remained.

## Exact clean-head installation

The exact clean proposed-head artifact was independently rehashed:

```text
bytes:   14,373,269
SHA-256: 476a57a3733cd350bd068de44a5a1019df5e198c49572d1f633e43e006ae2877
```

It was installed under the canonical filename as the sole scanned DrivenByMoss extension. The installed hash matched the build. The same exact file was used for every formal phase:

| Phase | Startup environment | Physical result | Quit |
| --- | --- | --- | --- |
| A default | `env -u JAVA_TOOL_OPTIONS` | 14/14 PASS | normal |
| B V1B static | `-Dpushwig.syntheticOverlay=true` | 7/7 PASS | normal |
| C V1C vector | `-Dpushwig.dynamicLocalVisual=true` | 5/5 PASS | normal |
| D all properties | static + vector + raster true | 5/5 PASS; raster alone selected | normal |
| E V1D-1 raster | `-Dpushwig.dynamicLocalRaster=true` | 38/38 PASS | normal |

Property delivery was proven from the current startup log for each enabled phase. The exact derivative demonstrably loaded because it was the sole scanned artifact and the selected V1B/V1C/V1D-1 visual behavior appeared on the real Push. Narrow error searches found no relevant controller/display exception. Logs were not committed.

## Rollback

After Phase E:

1. the maintainer quit Bitwig normally;
2. exact-name process checks showed Studio and audio engine absent;
3. the installed derivative rehashed to `476a57a3733cd350bd068de44a5a1019df5e198c49572d1f633e43e006ae2877`;
4. it was moved outside every scan path;
5. the untouched official backup rehashed to `98dc3195ad8d911526e18b1005f09f69a1aedcb965b080565474104654345c5a`;
6. the official file was moved back to the exact canonical filename/path;
7. the restored canonical file rehashed to the same accepted official SHA-256;
8. scoped `find` showed exactly one scanned DrivenByMoss extension;
9. Bitwig launched through its exact executable with `JAVA_TOOL_OPTIONS` removed;
10. the maintainer confirmed standard official DrivenByMoss display, normal controls, no generated pattern, and normal quit;
11. final exact-name process readback showed Bitwig and its audio engine stopped.

Final ordinary state:

```text
canonical file: $HOME/Documents/Bitwig Studio/Extensions/DrivenByMoss.bwextension
sole scanned copy: yes
official SHA-256: 98dc3195ad8d911526e18b1005f09f69a1aedcb965b080565474104654345c5a
Bitwig running: no
```

## Commands and tools

Commands included exact-name `pgrep`, scoped `find`, `shasum -a 256`, `stat`, reversible `mv`, `cp -p`, exact Bitwig executable launches with explicit environments, narrowly filtered current-run logs, `ps`, `jcmd GC.heap_info`, and Git cleanup/readback. Direct physical results came from the maintainer using the real Push.

## What this proves

- Both the observation artifact and exact clean source-head artifact were the sole scanned extensions during their respective runs.
- Bitwig loaded and exercised the exact clean derivative on the real Push across all required paths.
- No relevant load/display error or unsafe shutdown occurred.
- The exact official artifact was restored, loaded, physically confirmed, and left as the ordinary sole scanned extension.

## What this does not prove

- It is not a forced-crash, cable-removal, hot-reload, reconnect, endurance, or Push 2 test.
- No proprietary binary, full log, screenshot, project, preset, serial, UUID, account, hostname, or IP data is retained in the repository.
- Manual physical observations do not replace the separate deterministic pixel harness; both are required and retained.
