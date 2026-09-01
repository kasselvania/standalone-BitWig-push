# V1C dynamic-local composition evidence

## Date, machine state, and authority

- Evidence date: 2026-09-01 PDT.
- Machine state: accepted macOS 26.4.1 arm64 reference fixture, Bitwig Studio 6.1, DrivenByMoss 26.4.1, and real Ableton Push 3 Controller with Push headphone output.
- Actual central basis: `4265dc7b6f1cabf2dcbad1b827d002bd9062cf4f`, tree `2af6b4757e5906ce74a3b52c5ee82323f5e32406`.
- DrivenByMoss integration basis: `1ae0b74f383314d170a5960ca763bdf9c319e787`, tree `a81e5c4330b31f36845c25e98e322990d62f0c67`.
- Source PR: [kasselvania/DrivenByMoss#3](https://github.com/kasselvania/DrivenByMoss/pull/3).
- Exact source head/tree: `4b3326eddcf2d890de3baa10b93f6e80842d41e1` / `d03a372e2efcf41b22cef46501e08efbfb0c0036`.
- Exact clean proposed-head artifact: 14,367,247 bytes, SHA-256 `f9671047e342ed3d2503fae3423ea27725830e359e75b51e29fc88ac316be4b3`.

## Result

V1C passed. The production source implements the selected V1C-0 ownership rule:

```text
newest retained ModelInfo
    -> full semantic redraw into the existing persistent IBitmap
    -> optional current dynamic-local visual
    -> same IBitmap reference
    -> unchanged PushUsbDisplay
    -> existing sole extension-owned USB writer
```

The default V1A path, accepted V1B static path, both-property precedence path, and V1C dynamic path were each launched from the same exact clean artifact. The real Push control/display/audio baseline passed. A deterministic external harness and aggregate real-Bitwig observation proved exact restoration across movement, replacement, absence, stale/invalid fallback, overlay changes, notification lifecycle, and semantic changes under coverage.

The official extension was restored byte-for-byte as the sole scanned artifact:

```text
SHA-256: 98dc3195ad8d911526e18b1005f09f69a1aedcb965b080565474104654345c5a
bytes:   14,362,484
```

The maintainer physically confirmed the ordinary official DrivenByMoss display and controls after rollback.

## Evidence map

- `source-topology.md` — exact fork branch, commit/tree, three-path envelope, and PR custody.
- `framework-redraw-contract.md` — retained-model assignment, dirty-render preservation, dynamic redraw hook, same-bitmap and one-writer rules.
- `lifecycle-and-pixel-restoration.md` — seven-state lifecycle, harness identity, exact hashes, and zero-mismatch results.
- `overlay-and-notification.md` — overlay-only retention, notification lifecycle, and the separately characterized Push system mixer page.
- `regression-paths.md` — default, V1B static, precedence, and dynamic startup selection.
- `performance.md` — offline and real-Bitwig timing, allocations, working set, and review recommendation.
- `build-artifact-comparison.md` — same-toolchain builds, artifact identities, extracted payload delta, and bytecode proof.
- `real-fixture-and-rollback.md` — reversible installation, real fixture, and exact official restoration.
- `manual-acceptance.md` — direct maintainer results for every formal phase.

## Commands and tools

The retained work used `git`, `gh`, Java 21, Maven 3.9.16, `javap -c -p`, `shasum -a 256`, `stat`, `file`, `unzip`, `diff`, `cmp`, scoped `find`, exact-name `pgrep`, `ps`, `jcmd GC.heap_info`, Bitwig's exact executable, narrowly filtered current-run logs, a temporary external Java harness, temporary aggregate-only in-process observation, local Bitwig UI selection, and direct maintainer use of the real Push.

## What this proves

- The selected V1C-0 semantic-redraw architecture is implemented at an exact source head.
- The current semantic model, not previous composed output, owns restoration.
- The generated local visual can move, change, disappear, become stale, or become invalid without leaving old pixels.
- The default and V1B regression paths remain available, dynamic selection has explicit precedence, and `PushUsbDisplay` remains unchanged.
- The exact clean artifact passed the accepted real fixture and the official artifact was restored exactly.

## What this does not prove

- No external-frame ingress, IPC, capture, resolver, adapter, calibration, or pixel-anchor behavior exists in V1C.
- This is not an endurance, forced-crash, hot-unplug, reconnect, detailed audio-latency, Push 2, or cross-platform acceptance.
- The bounded local visual lifecycle is proof scaffolding, not the final external visual compositor.
