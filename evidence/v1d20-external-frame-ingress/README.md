# V1D-2-0 external latest-frame ingress decision

## Result

**SELECTED:** Candidate A, a capability-authenticated, loopback-only TCP framed stream with one owned receiver thread and a fixed-memory latest-frame handoff.

The selected research candidate proved this path:

```text
external generated producer
    -> 127.0.0.1 TCP framed protocol v1
    -> complete-message validation in one receiver thread
    -> fixed staging and latest-publication arrays
    -> display-thread nonblocking tryLock and fixed consumer array
    -> accepted V1D-1 IRasterWritableBitmap writer
    -> same semantic IBitmap
    -> unchanged PushUsbDisplay.send
```

Candidate A passed offline correctness, allocation, timing, live Bitwig/Push behavior, all five blocking shutdown states, rapid same-port restart, and exact official-artifact rollback. Candidates B and C were not reached under the mandated stopping rule. No research source branch was pushed, no DrivenByMoss source PR was opened, and no prototype source was merged.

## Date, machine state, and authority

- Evidence date: 2026-09-01 PDT.
- Machine state: accepted macOS 26.4.1 arm64 maintainer fixture, Bitwig Studio 6.1, real Push 3, and Push headphone audio route.
- Actual central basis/tree: `5597624bd50e5ef95ecd3af82ea1816ce4facd21` / `ec016bd3174345e32f1a6d47eb061820e7a1e9b9`.
- Accepted DrivenByMoss integration basis/tree: `663d719207ef58ec84b4d235c43211ec5da43605` / `c4e42825d069421a44b3241349de9a7c6453a3ad`.
- Selected local candidate head/parent/tree: `4f00972355fcf7b5f0ead0fef3365b81850be12f` / `663d719207ef58ec84b4d235c43211ec5da43605` / `7202267e51d0f2613cea93d186b132a996ec14ec`.
- Selected candidate patch SHA-256: `3bd908ba7ca6e5c92ca4275fbc18864d49eb35200b6636d8d42e5df83d4d6ada`.
- Exact candidate artifact: `14,386,473` bytes, SHA-256 `b7b3e98438292c86e79bcf284a18c156f7bfc6b86cb116e4ecdead26fa615464`.
- Restored official artifact SHA-256: `98dc3195ad8d911526e18b1005f09f69a1aedcb965b080565474104654345c5a`.

## Headline proof

- Full harness: `1,534` frames accepted/published, `1,529` adopted, `5` superseded, `76` sequence-gap events, and zero pixel/restoration/consumer-mutation/display-exception mismatches.
- Complete-publication proof: partial header and payload counts were positive; partial/torn visibility remained zero.
- Display acquisition: `ReentrantLock.tryLock`; five induced lock misses reused only a still-current, still-fresh display-owned frame.
- Fixed project-owned frame/security arrays: `1,843,312` bytes total; one receiver thread; no application queue.
- Exact-final allocation harness: `4,200` accepted frames, `0.184` amortized display bytes per writer call and `1.878` receiver bytes per accepted frame as JVM/JDK measurement noise; source/bytecode owns no per-frame object or array allocation.
- Live project-owned full-frame pipeline p95: `0.092375 ms`; live display copy p95: `0.023167 ms`; live V1D-1 writer p95: `0.071459 ms`.
- Exact-final malformed fallback: `1,000` samples, p50 `0.020875 ms`, p95 `0.080542 ms`, maximum `0.986084 ms`.
- Real fixture: no-producer, valid producer, 15/30/60 fps, burst/session/sequence, clear/disconnect/crash/stale/invalid/truncated cases, and all five shutdown states passed.
- Final ordinary state: one scanned official extension, physically confirmed standard DrivenByMoss display/controls/audio, no generated raster.

## Evidence map

- [accepted-source-and-constraints.md](accepted-source-and-constraints.md): accepted source/API behavior and custody.
- [candidate-a-loopback-stream.md](candidate-a-loopback-stream.md): candidate implementation, iterations, build, and source proof.
- [alternative-candidates.md](alternative-candidates.md): mandated stopping-rule disposition.
- [protocol.md](protocol.md): exact version-1 wire language and authentication.
- [buffer-and-thread-ownership.md](buffer-and-thread-ownership.md): fixed buffers, synchronization, and one-writer ownership.
- [lifecycle-and-failure-correctness.md](lifecycle-and-failure-correctness.md): deterministic lifecycle/failure matrix.
- [performance.md](performance.md): exact-final allocation/fallback results and live aggregate timing.
- [real-fixture-and-rollback.md](real-fixture-and-rollback.md): manual Push acceptance, shutdown matrix, and rollback.
- [decision.md](decision.md): exact selected production architecture and V1D-2 acceptance proposal.

## Commands and tools

Tools included `git`, `gh`, `rg`, `javap -c -p`, Java 21, Maven 3.9.16, Python 3.14.5, `shasum -a 256`, `cmp`, `diff -qr`, `lsof`, `ps`, `jcmd`, deterministic generated-raster harnesses, aggregate-only temporary Bitwig instrumentation, and direct maintainer observation on the physical Push.

The exact build command was:

```text
env \
  JAVA_HOME=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home \
  PATH=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin \
  mvn clean install package -Dbitwig.extension.directory=target
```

## What this proves

- A separate language-neutral local producer can safely publish only complete, current, bounded opaque-BGRA raster regions to the accepted synchronous V1D-1 sink.
- Display-thread consumption is nonblocking and retains exclusive ownership of the chosen consumer bytes through the synchronous raster write and existing USB send.
- Loss of external authority returns to a newly redrawn current semantic frame, never historical composed output.
- Candidate A is sufficiently exact to authorize a bounded production V1D-2 implementation slice.

## What this does not prove

- It does not merge or publish production ingress source, define a public adapter API, or retain the temporary producer as product code.
- It does not prove remote networking, multiple producers, compression, alpha blending, scaling, capture, hard-real-time scheduling, Push 2 hardware, or endurance behavior.
- The live aggregate observer is temporary instrumentation; its project-owned path timings are retained, but its whole-process memory figures do not isolate all Bitwig/JVM/native allocations.
