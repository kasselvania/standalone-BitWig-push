# Candidate A performance and memory evidence

## Date, machine state, and identities

- Evidence date: 2026-08-31 PDT.
- Machine state: accepted macOS 26.4.1 arm64 fixture, Bitwig Studio 6.1, real Push 3, and the user's ordinary Push audio route.
- Central basis: `24431c70eb720235b9c7836d9b2842a798d81d54`, tree `bb72673d2b3ce01ed6525a6ab7f2096dde1ac7bf`.
- DrivenByMoss basis: `1ae0b74f383314d170a5960ca763bdf9c319e787`, tree `a81e5c4330b31f36845c25e98e322990d62f0c67`.
- Candidate commit/tree: `3e8df95e9cc489e69da72b9acb82f2d06c90dd00` / `f448eeda923232346037074a75b71c485e56ebe8`.
- Harness source SHA-256: `4dc4ea733ba7b46e3dc9db542cfe0567e7c6059ab6d042260e9956535a4e382c`.
- Aggregate observation diff/artifact: `3ad3e472cfdce65c6af59e941e5b090a960acf3b7395c03b567427dfb1f3d1a4` / `d06c316588a839d221e0bb9fa026f32a3f1abb0b3ad1be8ef7dd174971ebb0e4`.
- Exact clean candidate artifact SHA-256: `22b37222aa9242f822c4717168ecde0d66cab10488caaabec9fe481cffba4c72`.

## Exact build/runtime toolchain

```text
JAVA_HOME=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home
java:  OpenJDK 21.0.11 Homebrew, arm64
javac: 21.0.11
mvn:   Apache Maven 3.9.16
java:  /opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home/bin/java
javac: /opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home/bin/javac
mvn:   /opt/homebrew/bin/mvn
```

## Offline deterministic measurement

The external harness discarded 2,000 warmup calls and retained 1,000 calls per path. It used `System.nanoTime` for duration and `com.sun.management.ThreadMXBean.getThreadAllocatedBytes` for thread-allocation deltas. The latest exact rerun against the clean candidate artifact produced:

| Path | Samples | p50 | p95 | Maximum | Allocated bytes/call |
| --- | ---: | ---: | ---: | ---: | ---: |
| Semantic baseline | 1,000 | 84 ns | 125 ns | 26,542 ns | 128 |
| Forced redraw, no visual | 1,000 | 240,708 ns | 285,666 ns | 531,250 ns | 144 |
| Forced redraw plus visual | 1,000 | 241,708 ns | 300,541 ns | 2,743,208 ns | 144 |

Harness used-heap readback was 5,107,720 bytes at start and 22,115,144 bytes at end, a 17,007,424-byte process/JIT/harness delta. The harness is a bounded test process, not the Bitwig heap authority.

## Real-Bitwig measurement

Temporary uncommitted instrumentation derived from the exact candidate commit measured three synchronous intervals with `System.nanoTime`:

- pre-pipeline semantic work;
- pipeline work;
- their sum.

It discarded 100 warmup sends, stored 1,000 samples in fixed `long[]` arrays, and sorted/reported only after sampling. Measurement overhead was three `nanoTime` calls and fixed-array stores per retained send. No per-frame log or file write occurred.

### Semantic baseline

```text
samples=1000
pre:      p50=792 ns       p95=1,208 ns       max=12,041 ns
pipeline: p50=541 ns       p95=1,084 ns       max=5,959 ns
combined: p50=1,375 ns     p95=1,875 ns       max=16,250 ns
```

### Forced current-semantic redraw, no visual

```text
samples=1000
pre:      p50=271,208 ns   p95=383,042 ns     max=4,265,958 ns
pipeline: p50=667 ns       p95=958 ns         max=29,542 ns
combined: p50=271,958 ns   p95=383,709 ns     max=4,266,500 ns
```

### Forced current-semantic redraw plus generated visual

```text
samples=1000
pre:      p50=270,458 ns   p95=403,417 ns     max=7,342,750 ns
pipeline: p50=5,917 ns     p95=11,917 ns      max=509,791 ns
combined: p50=275,166 ns   p95=413,209 ns     max=7,356,958 ns
```

The selected restore-plus-compose path is inside the green review band:

```text
p95 0.413209 ms <= 2 ms
max 7.356958 ms <= 10 ms
```

## Allocation ownership

- `ResearchDynamicOverlayPushFramePipeline.process` has no `new` bytecode and creates no bitmap, byte array, collection, closure, queue, task, or future per call.
- Its four renderer instances are created once in the class initializer.
- `AbstractGraphicDisplay.send` already creates a `ModelInfo` and list copies on every send in the accepted base; Candidate A does not add a second model object.
- Forced redraw activates existing render-path construction, including graphics-info/bounds/component work.
- Real `BitmapImpl.render` retains a host callback call site and constructs `GraphicsContextImpl` for the host render callback.

Accordingly, project-owned Candidate A pipeline allocation per cycle is zero, while total harness-recorded allocation is 144 bytes/call on forced-redraw paths because existing semantic/host-adapter work is exercised. No claim of zero total JVM allocation is made.

## Working-set observation

An initial measurement-adjacent RSS window still included Bitwig/JVM startup growth:

```text
7 samples: start 1,773,024 KiB; end/peak 2,152,304 KiB
```

Two later one-hertz, 30-second steady dynamic-overlay windows produced:

```text
window 1: start 2,330,336 KiB; end 2,528,624 KiB; peak 2,529,696 KiB
window 2: start 2,531,104 KiB; end 2,531,328 KiB; peak 2,531,328 KiB
```

`jcmd GC.heap_info` distinguished RSS commitment from live use:

```text
read 1: ZHeap used 358M; capacity 1750M; max 3072M
read 2: ZHeap used 510M; capacity 1750M; max 3072M
```

The second RSS window plateaued within 224 KiB and no unbounded project-owned state exists in the pipeline. This is a bounded observation, not an endurance proof.

## Real fixture observations

- Control lag: none observed.
- Display lag, trail, or scale error: none observed.
- Audio xrun/dropout: none observed.
- Candidate shutdown: normal, with no force quit.
- The maintainer initially noted that there *might* be a few more visually dropped frames but explicitly marked that impression uncertain.
- After exact official rollback and direct A/B comparison, the maintainer stated the official screen was **exactly the same** as the colored candidate with respect to refresh rate. The possible regression was therefore not reproduced.

## Commands and tools

Tools included the external Java harness, `System.nanoTime`, `ThreadMXBean`, fixed arrays, temporary aggregate-only Bitwig instrumentation, exact-path Java/Maven, `ps -o rss`, `jcmd GC.heap_info`, `javap -c -p`, direct real-Push observation, and exact official A/B rollback.

## What this proves

- Candidate A remained comfortably inside the accepted synchronous frame budget on the actual Bitwig/Push fixture.
- The added dynamic pipeline state is fixed and bounded, with no per-cycle project-owned allocation site.
- A steady observation reached an RSS plateau and no control, display, or audio regression was reproduced.

## What this does not prove

- It is not an endurance, power, thermal, audio-latency, or cross-Mac benchmark.
- It does not eliminate existing DrivenByMoss/Bitwig render-path allocations.
- It does not prove every future generated-local-frame implementation will remain inside this budget; V1C must repeat the same measurements on its exact proposed head.
