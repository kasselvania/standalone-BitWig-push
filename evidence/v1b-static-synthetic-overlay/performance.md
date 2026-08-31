# V1B performance evidence

## Date and machine state

- Evidence date: 2026-08-31 PDT.
- Machine state: accepted macOS 26.4.1 arm64 fixture, Bitwig Studio 6.1, real Push 3, audio operating at the user's live fixture settings.
- Central basis: `a13faef08ac8bb75a9e32f7ff7d4bc07fcd41c6e`, tree `c06009f822fee7bf36096739e7be6589f0b9ae34`.
- Source basis: `033ccef8c64f08e8d8d41fa90d48fa06b326a1a1`, tree `9aec7429ff093addee001a62a5a07309708fd592`.
- Source PR/head/tree: [kasselvania/DrivenByMoss#2](https://github.com/kasselvania/DrivenByMoss/pull/2), `a2e0341b7bccfa4e6b13614f4adffc2235f785f4`, tree `a81e5c4330b31f36845c25e98e322990d62f0c67`.

## Measurement method

Temporary uncommitted instrumentation derived from the exact source head measured only the synchronous `framePipeline.process(image)` interval with `System.nanoTime`. Each run discarded 100 warmup calls and retained the next 1,000 eligible sends in one preallocated `long[]`. Sorting and output happened only after sampling. Measurement overhead was two `nanoTime` calls plus one array store per sample.

The property-off sample covered a stable semantic view. The enabled run covered Track/Mix, Device Parameters, and Session/Browser changes plus a stable 30-second view. The one-time enabled before/after pixel observation occurred during warmup and was excluded from the 1,000 retained timing values.

## Exact result

| Startup path | Samples | p50 | p95 | Maximum | Review band |
| --- | ---: | ---: | ---: | ---: | --- |
| Property off | 1,000 | 250 ns (0.000250 ms) | 833 ns (0.000833 ms) | 11,459 ns (0.011459 ms) | PASS |
| Property on | 1,000 | 32,625 ns (0.032625 ms) | 54,542 ns (0.054542 ms) | 194,000 ns (0.194000 ms) | PASS |

Both are well below the provisional `p95 <= 2 ms` and `maximum <= 10 ms` bands.

The exact two-line property-off metric record content hashed to `baa338eec8373b25b2ba4bcb5a4ff28b1958e33047067b91886df3457be5680e`. The enabled metrics file, which also contains the preservation record, hashed to `e994dab53dc825be70520a284ca98e24ec94b20b06af7ac7168d7a3695ad090b`.

## Allocation result

- `PassThroughPushFramePipeline.process`: zero allocation bytecode per call.
- New `SyntheticOverlayPushFramePipeline.process`: zero `new` instructions, no per-call lambda construction, no bitmap/array/queue/task allocation, and the renderer is class-initialized once.
- Existing concrete `BitmapImpl.render`: bytecode retains one capturing `invokedynamic` renderer call site and its callback contains an explicit `new GraphicsContextImpl` allocation site for each enabled render invocation.

Therefore the V1B pipeline itself adds zero project-owned allocation sites per send, while the pre-existing host adapter exposes two structural enabled-render allocation sites. No heap profiler was used, so whether the JVM scalar-replaces the capturing callback in this embedded runtime is unresolved; no claim of zero total host-adapter allocations is made.

## Real fixture observations

Across the exact committed artifact's property-off and property-on acceptance:

- controller lag: none observed;
- display lag: none observed;
- audio xrun/dropout: none observed;
- abnormal display behavior: none observed;
- enabled mark remained stable and semantic changes remained coherent;
- normal Bitwig quit succeeded in both paths.

## Commands and tools

Tools included temporary `System.nanoTime` instrumentation, a preallocated sample array, Maven/Java 21, `javap -c -p` for the final pipeline and `BitmapImpl`, SHA-256 hashing, real mode/parameter changes, direct audio/control/display observation, and normal process shutdown checks.

## What this proves

- The synchronous fixed-overlay operation stayed comfortably within the V1B review band on the accepted fixture.
- No queue, worker, asynchronous handoff, buffering strategy, or transport rewrite was needed.
- The new pipeline type itself is allocation-free per call at bytecode level.

## What this does not prove

- This is not an endurance, statistical cross-machine benchmark, audio-latency measurement, or full JVM allocation profile.
- It does not prove the existing `BitmapImpl.render` allocation sites are eliminated at runtime.
- It does not justify adding buffering, threads, queues, or optimization work in V1B.
