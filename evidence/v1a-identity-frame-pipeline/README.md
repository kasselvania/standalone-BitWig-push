# V1A identity Push frame pipeline

## Date and machine state

- Evidence date: 2026-08-31 PDT.
- Host: the accepted S0/V1A-0 macOS fixture, macOS 26.4.1 (25E253), Darwin 25.4.0, arm64.
- Bitwig Studio: 6.1 on the accepted fixture.
- Controller: Ableton Push 3 connected over USB and exercised directly against the exact V1A artifact.
- Central basis: commit `a36779d4c04a11d6c6e9ce0d48c34ea3b813a0cc`, tree `bc4634da23f794f2afd39c63fab9eb5cf44524c1`.
- DrivenByMoss integration basis: commit `fd03245ab38fa5149c45934051d937ee9fda6d08`, tree `edd2ad636b0aa1f39919f0ffd05c968015450075`.
- Proposed source: PR [kasselvania/DrivenByMoss#1](https://github.com/kasselvania/DrivenByMoss/pull/1), head `6e1e4cbd2e725a7951e5b4dc1278fbb6e7b5d61c`, tree `9aec7429ff093addee001a62a5a07309708fd592`.

## Status

**V1A complete.**

The exact proposed source head passes source, bytecode, identity-harness, same-toolchain artifact, Bitwig-load, real Push behavior, ordinary shutdown, and exact official-artifact rollback gates. Both required PR heads exist and remain open/unmerged. The final ordinary environment is running the restored official extension at SHA-256 `98dc3195ad8d911526e18b1005f09f69a1aedcb965b080565474104654345c5a`.

## Implemented boundary

For each eligible `Push2Display.send(IBitmap)` call, the proposed head performs:

```text
complete semantic IBitmap
    -> synchronous PushFramePipeline.process(IBitmap)
    -> exact same IBitmap object
    -> unchanged PushUsbDisplay.send(IBitmap)
    -> existing Push USB writer
```

The public `Push2Display` constructor selects one shared `PassThroughPushFramePipeline.INSTANCE`. The pass-through method returns its argument directly. No pixel access, bitmap copy, retained frame, queue, task, thread, executor, timer, IPC, capture type, or transport rewrite was added.

## Exact source result

| Item | Exact result |
| --- | --- |
| Source branch | `pushwig/v1a-no-op-frame-pipeline` |
| Source parent | `fd03245ab38fa5149c45934051d937ee9fda6d08` |
| Source head | `6e1e4cbd2e725a7951e5b4dc1278fbb6e7b5d61c` |
| Source tree | `9aec7429ff093addee001a62a5a07309708fd592` |
| Source PR | <https://github.com/kasselvania/DrivenByMoss/pull/1> |
| V1A artifact SHA-256 | `94e69a2f2ce91ac6522ed6a0c1c52d7c216dea3a8c3d03f76c2221886bc62706` |
| V1A artifact size | 14,363,745 bytes |
| Official artifact SHA-256 | `98dc3195ad8d911526e18b1005f09f69a1aedcb965b080565474104654345c5a` |

## Evidence index

- `source-topology.md` — exact repository custody, one-commit source envelope, and PR topology.
- `implementation-proof.md` — source, bytecode, identity, synchronous-call, and forbidden-dependency evidence.
- `build-artifact-comparison.md` — explicit toolchain builds and extracted base/head payload comparison.
- `install-rollback.md` — exact real-fixture swap, derivative load, ordinary shutdown, rollback, and restored-official evidence.
- `manual-acceptance.md` — all eleven direct physical behavior results plus visual-difference and error observations.

## Commands and tools

Evidence uses `git`, `gh`, `sw_vers`, `uname`, Java/Javac 21.0.11, Maven 3.9.16, `javap`, `shasum`, `stat`, `file`, `unzip`, `zipinfo`, `comm`, `diff`, `cmp`, a temporary external Java identity harness, targeted process inspection, and direct maintainer interaction with Bitwig and Push. Topic files retain exact command shapes and results.

Paths are sanitized with `$HOME`. No extension binary, full Bitwig log, screenshot corpus, user project, serial number, hardware UUID, hostname, IP address, or account/license data is retained.

## What this evidence proves

- The source PR has one commit on the exact accepted integration parent and changes exactly three authorized production paths.
- The pass-through operation preserves Java reference identity and performs no per-send allocation.
- `Push2Display.send` remains synchronous, preserves its shutdown/null guard, calls the pipeline once, and then calls the existing USB display once.
- The untouched base and proposed head both build successfully with the same explicit Java 21/Maven toolchain.
- Extracted payload differences are bounded to `Push2Display.class` and the two new pipeline classes; `PushUsbDisplay.class` is byte-identical.
- Bitwig loaded the sole exact V1A artifact, and all eleven direct Push/controller/display/audio/native-device rows passed.
- The maintainer observed no visible mark, overlay, crop, color, animation, or other display difference.
- Bitwig quit normally, the exact official artifact was restored, and its normal DrivenByMoss display was physically reconfirmed after relaunch.

## What this evidence does not prove

- It does not claim Push 2 hardware acceptance, archive-byte reproducibility, frame timing, allocation profiling, reconnect behavior, or endurance.
- It does not implement V1B composition, frame copying/snapshotting, external visual frames, IPC, capture, calibration, or pixel-anchor resolution.

## Explicit unresolved questions and V1B boundary

- Physical visual equivalence is direct maintainer observation, not a captured pixel hash; V1A intentionally adds no second render or readback path.
- The source proof establishes no per-send allocation in the identity operation, but it is not a profiler-based whole-extension allocation benchmark.
- The shared class preserves Push 2 behavior by source and byte-identical transport only; no Push 2 hardware was tested.
- V1B must decide how an alternate composed `IBitmap` is supplied without weakening the single-writer rule, copying the semantic frame unnecessarily, or introducing macOS/capture types into the controller extension. V1A intentionally exposes no public injection/configuration mechanism for that future choice.
