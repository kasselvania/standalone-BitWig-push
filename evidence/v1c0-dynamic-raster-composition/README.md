# V1C-0 dynamic raster composition decision evidence

## Date and machine state

- Evidence date: 2026-08-31 PDT.
- Machine state: accepted macOS 26.4.1 arm64 reference fixture, Bitwig Studio 6.1, DrivenByMoss 26.4.1, and a physically connected Ableton Push 3 Controller.
- Actual accepted central basis: `24431c70eb720235b9c7836d9b2842a798d81d54`, tree `bb72673d2b3ce01ed6525a6ab7f2096dde1ac7bf`.
- Fetched `origin/main` remained at that prompt-time SHA and contained required V1B evidence commit `95d93e262c33163783e23a8d3e66f6f92746918d` and V1C-0 status commit `1e5767552838a5bf97ee6197ff2f5ac7bfb541a7`; no intervening authority change existed.
- Accepted DrivenByMoss integration basis: `1ae0b74f383314d170a5960ca763bdf9c319e787`, tree `a81e5c4330b31f36845c25e98e322990d62f0c67`.
- Candidate A local research commit: `3e8df95e9cc489e69da72b9acb82f2d06c90dd00`, tree `f448eeda923232346037074a75b71c485e56ebe8`, parent `1ae0b74f383314d170a5960ca763bdf9c319e787`.
- Harness source SHA-256: `4dc4ea733ba7b46e3dc9db542cfe0567e7c6059ab6d042260e9956535a4e382c`.
- No DrivenByMoss production branch was pushed and no DrivenByMoss pull request exists for V1C-0.

## Decision and exact result

`decision.md` records **SELECTED: Candidate A — retained current semantic redraw**.

For every eligible dynamic send, the selected ownership rule is:

```text
newest retained ModelInfo
        -> full semantic redraw into the one persistent IBitmap
        -> current valid generated visual, or no visual
        -> same IBitmap
        -> existing Push2Display send guard
        -> unchanged PushUsbDisplay
```

It is not `mutate(previousOutput, maybeNewVisual)`. The previous composed output is never restoration authority.

The deterministic 960x160 BGRA8888 harness ran 1,000 complete A/B/C/D/none/stale/invalid cycles, or 7,000 transitions. It measured:

- outside-current-region mismatches: `0`;
- old-region restoration mismatches: `0`;
- post-absence full-frame mismatches: `0`;
- stale full-frame mismatches: `0`;
- invalid full-frame mismatches: `0`;
- semantic-update-under-overlay mismatches: `0`.

Temporary aggregate-only instrumentation inside real Bitwig then observed 1,000 output sends, two semantic changes while a visual region was covered, and zero mismatches in every required preservation/restoration category. The exact clean candidate artifact passed the real Push control, display, audio, movement, disappearance, stale/invalid, representative-mode, semantic-update, and shutdown checklist.

The accepted live restore-plus-compose timing was p50 `0.275166 ms`, p95 `0.413209 ms`, and maximum `7.356958 ms`, inside the green `p95 <= 2 ms` and `max <= 10 ms` bands. A second 30-second RSS window plateaued at 2,531,104–2,531,328 KiB. The candidate adds no project-owned per-cycle allocation site; existing full-render host-adapter allocations remain.

The exact official artifact was restored as the sole scanned extension at SHA-256 `98dc3195ad8d911526e18b1005f09f69a1aedcb965b080565474104654345c5a`. The maintainer physically confirmed the ordinary official display and directly compared its refresh behavior with the colored candidate: they appeared exactly the same.

## Evidence map

- `accepted-source-analysis.md` — persistent bitmap/model ownership, exact API 21 signatures, wrapper limits, and transport boundary.
- `candidate-a-semantic-redraw.md` — candidate source custody, local commit, changed paths, bytecode, build, and one-writer result.
- `alternative-candidates.md` — why B, C, and D were not reached after A passed the ordered gate.
- `pixel-restoration.md` — offline and live aggregate pixel lifecycle proof, hashes, regions, and mismatch counts.
- `performance.md` — offline and real-Bitwig latency, allocation, heap, RSS, and subjective fixture observations.
- `real-fixture-and-rollback.md` — clean-artifact installation, all manual results, normal shutdown, exact rollback, and official confirmation.
- `decision.md` — the precise selected production ownership model and bounded V1C proposal.

## Commands and tools

The work used `git`, `gh`, Java 21, Maven 3.9.16, `javap`, `shasum -a 256`, `stat`, `unzip`, `diff`, `find`, exact-name `pgrep`, `ps`, `jcmd GC.heap_info`, Bitwig's actual executable, narrowly filtered current-run logs, a temporary external Java raster harness, temporary aggregate-only in-process observation instrumentation, local computer control for Bitwig UI selection/normal quit, and direct maintainer interaction with the real Push.

Build command for both accepted base and candidate:

```text
env \
  JAVA_HOME=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home \
  PATH=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin \
  mvn clean install package -Dbitwig.extension.directory=target
```

## What this proves

- The newest retained semantic model can be synchronously redrawn before a changing local visual without a second bitmap or raw copy.
- Movement, replacement, absence, stale/invalid fallback, and a semantic change under covered pixels restore the exact current semantic output.
- The selected path is bounded, synchronous, within the accepted timing band, and preserves the existing sole USB writer.
- The exact clean candidate works with the accepted real Push controls, display, and audio fixture.
- Exact official-artifact rollback remains safe and loadable.

## What this does not prove

- V1C-0 does not merge production source, define the V1D external `VisualSourceFrame` wire contract, add IPC, capture a window, or prove Push 2 hardware.
- The fixture timing is bounded evidence on one accepted Mac, not an endurance or cross-machine benchmark.
- Candidate A's existing host render path allocates adapter objects; V1C must keep the observed budget but this slice does not redesign those upstream allocations.
- The live fixture covered Track, Device Parameters, and Session/Browser, not every DrivenByMoss mode or notification combination.
