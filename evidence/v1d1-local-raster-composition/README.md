# V1D-1 local raster-composition evidence

## Date, machine state, and authority

- Evidence date: 2026-09-01 PDT.
- Machine state: accepted macOS 26.4.1 arm64 reference fixture, Bitwig Studio 6.1, DrivenByMoss 26.4.1, and real Ableton Push 3 Controller with Push headphone output.
- Actual central basis: `c94d1b74d702e696d6cc4cc89625f1a2f7a95530`, tree `8539026fc9476bbf2df34b310190a57906113b90`.
- DrivenByMoss integration basis: `852b520933eed87fbe496a04b5c18819a10b3564`, tree `d03a372e2efcf41b22cef46501e08efbfb0c0036`.
- Source PR: [kasselvania/DrivenByMoss#4](https://github.com/kasselvania/DrivenByMoss/pull/4).
- Exact source head/tree: `3c3ca02ff81ab5ce110ae3d714e20b5fca05a03f` / `c4e42825d069421a44b3241349de9a7c6453a3ad`.
- Exact clean proposed-head artifact: 14,373,269 bytes, SHA-256 `476a57a3733cd350bd068de44a5a1019df5e198c49572d1f633e43e006ae2877`.

## Result

V1D-1 passed. The proposed source head adds a host-neutral, synchronous, all-or-nothing local raster-region capability and a bounded nine-state generated lifecycle:

```text
newest retained ModelInfo
    -> full semantic redraw into the existing persistent IBitmap
    -> optional opaque BGRA8888 local raster write
    -> exact same IBitmap reference
    -> unchanged PushUsbDisplay
    -> existing sole extension-owned USB writer
```

The exact source-PR-head artifact passed default, V1B static, V1C vector, all-property precedence, and V1D-1 raster launches. The real Push control/display/audio baseline passed. Offline and in-Bitwig observation proved exact target writes, exact preservation outside the target, restoration of old regions, semantic-only fallback, malformed-request rejection without partial output, and current-semantic restoration after an update beneath prior coverage.

The ordinary installation was restored to the sole official artifact:

```text
SHA-256: 98dc3195ad8d911526e18b1005f09f69a1aedcb965b080565474104654345c5a
bytes:   14,362,484
```

The maintainer physically confirmed the standard official DrivenByMoss display and controls, no generated pattern, and normal quit after rollback.

## Evidence map

- `source-topology.md` — exact repository custody, one-commit source topology, five-path envelope, and source PR.
- `raster-contract-and-adapter.md` — host-neutral contract, cached Bitwig adapter, record compatibility, validation order, and thread ownership.
- `lifecycle-and-correctness.md` — startup selection, nine-state lifecycle, exact geometries, hashes, and zero-mismatch proof.
- `negative-validation.md` — destination-support failures, 28 request negatives, all-or-nothing behavior, and race tests.
- `regression-paths.md` — default, V1B, V1C, precedence, non-raster, and one-writer regressions.
- `performance.md` — offline and real-Bitwig timing, tail review, allocations, heap, RSS, and subjective observations.
- `build-artifact-comparison.md` — Java 21 builds, artifact identities, extracted payload delta, protected class identity, and bytecode proof.
- `real-fixture-and-rollback.md` — observation/install custody, exact clean-head fixture run, and official rollback.
- `manual-acceptance.md` — direct maintainer results for every formal physical phase.

## Commands and tools

The retained work used `git`, `gh`, Java/Javac 21.0.11, Maven 3.9.16, `javap -c -p`, `shasum -a 256`, `stat`, `file`, `unzip`, extracted-tree `diff`, `cmp`, scoped `find`, exact-name `pgrep`, `ps`, `jcmd GC.heap_info`, Bitwig's exact executable, narrowly filtered current-run logs, a temporary external Java harness, temporary aggregate-only in-process observation, and direct maintainer use of the real Push.

## What this proves

- The exact V1D-1 source head implements the selected production local-raster seam without adding a second bitmap, asynchronous compositor, or second USB writer.
- Supported writes are synchronous, opaque BGRA8888, bounded, source-offset/stride aware, and all-or-nothing after complete validation.
- The current semantic frame remains restoration authority across movement, replacement, absence, stale/invalid fallback, malformed rejection, and semantic updates.
- The default, accepted V1B, and accepted V1C paths remain available with deterministic startup precedence.
- The exact clean artifact passed the accepted real fixture and the exact official artifact was restored.

## What this does not prove

- V1D-1 does not add external-frame ingress, IPC, capture, a final wire format, ScreenCaptureKit, resolver, adapter, calibration, or pixel anchors.
- The generated raster lifecycle is bounded production proof scaffolding, not the final external visual source.
- This is not an endurance, forced-crash, hot-unplug, reconnect, detailed audio-latency, Push 2, or cross-platform acceptance.
- Maximum wall-clock tails are retained for technical-lead review; the evidence does not claim hard real-time scheduling.
