# V1D-0 bulk raster composition decision evidence

## Date, fixture, and authorities

- Evidence date: 2026-09-01 PDT.
- Machine state: accepted arm64 macOS fixture, Bitwig Studio 6.1, DrivenByMoss 26.4.1, and a physically connected Ableton Push 3 Controller.
- Actual accepted central basis: `a66e1e45ebb2cb72f8ea1cb12e96d1bc46d7c343`, tree `b83e9e9507dc2e26d551abed1f03c30a6b76a551`.
- The central basis contains accepted V1C evidence commit `e748d168ce9983bd787fad25ac03ccb5b650edb1` and the V1D-0 authority commit `a66e1e45ebb2cb72f8ea1cb12e96d1bc46d7c343`.
- Accepted DrivenByMoss basis: `852b520933eed87fbe496a04b5c18819a10b3564`, tree `d03a372e2efcf41b22cef46501e08efbfb0c0036`.
- Candidate A local research commit: `61c659e19faad3944f610022fca5d57f09e7b442`, parent `852b520933eed87fbe496a04b5c18819a10b3564`, tree `6d06def69677918e871bb5a0c978be83aab29cb8`.
- Candidate harness source SHA-256: `7be829d7e302b00226f6fabf005e2a423b91132d6eebdae980acbc57657b6ee7`.
- Supplemental aggregate-hash harness source SHA-256: `fe3db8e287dcc52706917ccec11b1a80f243b1677f8b365fb93ccf36cc24735d`.
- Final observation patch SHA-256: `2cba0fbffabeb6e7609f6c5ffbdb433e1e9bfa90d9f1e5414f84843a8c4b7e96`.
- No DrivenByMoss source branch was pushed and no DrivenByMoss pull request exists for V1D-0.

## Decision and exact result

`decision.md` records **SELECTED: Candidate A — direct writable bitmap region**.

The selected production rule is:

```text
newest retained ModelInfo
        -> complete current-semantic redraw
        -> completely validate current opaque BGRA8888 raster request
        -> absolute bulk row copies into the persistent bitmap, or no write
        -> same logical IBitmap
        -> unchanged PushUsbDisplay
        -> existing sole USB writer
```

The exact Bitwig 960x160 `ARGB32` bitmap exposed a writable, direct, non-array-backed, little-endian `ByteBuffer` with position `0`, limit/capacity `614400`, and tightly packed `3840`-byte rows. Distinct `createByteBuffer()` views aliased the same memory. Cached-view writes remained coherent with `IBitmap.encode` and the physical Push across 1,920 real sends.

The deterministic external harness ran 1,000 complete cycles, 9,000 transitions, and 25 malformed-input cases. All required source-target, outside-region, old-region restoration, NONE, STALE, INVALID, semantic-update, and partial-rejection mismatch counts were `0`. Temporary aggregate-only real-Bitwig observation recorded 1,920 sends, three complete generated-pattern cycles, a semantic update under coverage, and the same all-zero mismatch result.

Post-warmup full semantic redraw plus full-frame 960x160 raster composition measured p50 `0.300834 ms`, p95 `0.636291 ms`, and maximum `8.832250 ms`: inside the green `p95 <= 2 ms`, `max <= 10 ms` gate. The direct full-frame writer alone measured p50 `0.047875 ms`, p95 `0.083083 ms`, and maximum `0.528917 ms`, with zero project-owned per-application allocation in a 5,000-call allocation check.

All 34 real-fixture rows passed. The exact official extension was restored as the only scanned artifact at SHA-256 `98dc3195ad8d911526e18b1005f09f69a1aedcb965b080565474104654345c5a`; Bitwig was relaunched without the research property and the maintainer physically confirmed standard DrivenByMoss display and control behavior.

## Evidence map

- `accepted-source-and-api.md` — exact V1C source behavior, API 21 signatures, wrapper limits, and real bitmap-memory characterization.
- `candidate-a-direct-write.md` — candidate source custody, interface, build, bytecode, artifact delta, and one-writer result.
- `alternative-candidates.md` — ordered stopping-rule disposition for Candidates B and C.
- `raster-correctness.md` — generated corpus, lifecycle, hashes, mismatch counts, encode/Push coherence, and restoration.
- `negative-validation.md` — complete validation order, 25-case rejection matrix, and zero-partial-write result.
- `performance.md` — same-toolchain timings, allocations, carrier comparison, heap/RSS, and fixture observations.
- `real-fixture-and-rollback.md` — installation custody, 34 manual results, normal shutdown, exact rollback, and official confirmation.
- `decision.md` — exact V1D-1 production ownership model, source envelope, contract, budgets, and acceptance proposal.

## Commands and tools

The work used `git`, `gh`, `rg`, `find`, `shasum -a 256`, `stat`, `unzip`, extracted-payload hashing/diffing, Java 21, Maven 3.9.16, `javap -c -p`, `jcmd GC.heap_info`, `ps`, exact-name process checks, narrowly filtered current-run Bitwig logs, two temporary external Java harnesses, temporary aggregate-only in-process observation, direct Bitwig launch with a construction-time Java property, local UI control, and maintainer interaction with the real Push.

All source builds used:

```text
env \
  JAVA_HOME=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home \
  PATH=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin \
  mvn clean install package -Dbitwig.extension.directory=target
```

## What this proves

- Candidate A is an exact, synchronous, bounded bulk-raster sink for the accepted V1C restoration lifecycle on the accepted Bitwig 6.1 fixture.
- The host-neutral boundary can use opaque BGRA8888 plus primitive geometry/stride metadata and a caller-owned `byte[]`, while the Bitwig adapter alone owns destination memory access.
- Complete validation precedes every destination byte, padded source rows copy without sentinel leakage, and rejected input leaves exact fresh semantics.
- The selected mechanism needs no second bitmap, scaling, filter, render callback, transport change, asynchronous work, or second USB writer.
- The real Push control, display, audio, malformed-input, shutdown, and exact official rollback gates pass.

## What this does not prove

- V1D-0 does not merge production source, open an external ingress, define `VisualSourceFrame`, add IPC/shared memory, capture a window, scale, blend, or claim Push 2 hardware.
- Bitwig API 21 exposes `MemoryBlock.createByteBuffer()` but does not document view lifetime, aliasing, row packing, or cross-render coherence. Those properties are fixture-proven for this exact host/API combination, not guaranteed cross-host contracts.
- The debug display window was not used as a separate correctness authority; exact encode comparisons and the physical Push provided the two accepted observation paths.
- The fixture measurement is bounded evidence, not an endurance or cross-machine benchmark.
