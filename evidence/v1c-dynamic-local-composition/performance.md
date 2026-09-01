# V1C performance and memory evidence

## Date, machine state, and authority

- Evidence date: 2026-09-01 PDT.
- Machine state: accepted macOS 26.4.1 arm64 fixture, Bitwig Studio 6.1, real Push 3, transport stopped for stable timing, and ordinary Push audio route.
- Actual central basis/tree: `4265dc7b6f1cabf2dcbad1b827d002bd9062cf4f` / `2af6b4757e5906ce74a3b52c5ee82323f5e32406`.
- DrivenByMoss basis/tree: `1ae0b74f383314d170a5960ca763bdf9c319e787` / `a81e5c4330b31f36845c25e98e322990d62f0c67`.
- Source PR/head/tree: [kasselvania/DrivenByMoss#3](https://github.com/kasselvania/DrivenByMoss/pull/3), `4b3326eddcf2d890de3baa10b93f6e80842d41e1`, tree `d03a372e2efcf41b22cef46501e08efbfb0c0036`.

## Exact toolchain

```text
JAVA_HOME=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home
java:  OpenJDK 21.0.11 Homebrew, arm64
javac: 21.0.11
mvn:   Apache Maven 3.9.16
java:  /opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home/bin/java
javac: /opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home/bin/javac
mvn:   /opt/homebrew/bin/mvn
```

## Offline exact-artifact measurement

The external harness ran against classes from the exact clean proposed-head artifact. It discarded warmup calls and retained 1,000 calls per path. `System.nanoTime` measured duration and `ThreadMXBean.getThreadAllocatedBytes` measured total thread allocation:

| Path | Samples | p50 | p95 | Maximum | Total allocated bytes/call |
| --- | ---: | ---: | ---: | ---: | ---: |
| Default pass-through | 1,000 | 33,750 ns | 43,792 ns | 283,750 ns | 128 |
| V1B static | 1,000 | 34,417 ns | 67,875 ns | 485,583 ns | 448 |
| V1C no visual | 1,000 | 65,958 ns | 86,083 ns | 369,333 ns | 768 |
| V1C visual | 1,000 | 63,875 ns | 74,292 ns | 266,750 ns | 1,088 |

Harness used-heap readback was 5,107,720 bytes at start and 26,131,392 bytes at end, a 21,023,672-byte bounded process/JIT/harness delta.

## Real-Bitwig observation method

Temporary uncommitted instrumentation derived from the exact head measured:

- current-semantic work before the frame pipeline;
- pipeline work;
- their synchronous sum.

It used fixed `long[]` sample arrays, `System.nanoTime`, a 60-second startup exclusion interval, 100 warmup samples, and 1,000 retained samples per serious path. It emitted one aggregate line per category and no per-frame log.

### Rejected startup-contaminated run

An earlier observer without the 60-second exclusion interval recorded:

```text
dynamic visual combined:    p95 1.088999 ms, max 5.222541 ms
dynamic no-visual combined: p95 1.304750 ms, max 59.712208 ms
```

The no-visual maximum exceeded the stop band while Bitwig RSS and JVM startup state were still changing. That run was stopped and retained as invalid for the required stable-idle claim. Its identities were:

```text
temporary patch SHA-256:   3f335ead0438b099e4ee0a8da77403f4320cf87af7d8eb59c4e7b3a7c2984efe
observer source SHA-256:   55b46c3e3a06c2f318aa7032a76fd14e1452a26e3eedb775bbe8083e995ff72f
artifact SHA-256:          fd3c35e62f8001a6d8f12e981b0f0fba32c8eb1048a9b44d877b062c3f1292d4
artifact bytes:            14,375,203
```

It was not reported as acceptance evidence and no production optimization was attempted.

### Stable-idle real result

The corrected observer waited 60 seconds before warmup and used artifact SHA-256 `c9a409ec87fb73f8ed3b19d70485ebb8737b919d6f84fc842a9cf781bbc08b53`.

| Path/interval | Samples | p50 | p95 | Maximum |
| --- | ---: | ---: | ---: | ---: |
| No visual: semantic redraw | 1,000 | 0.262583 ms | 0.630709 ms | 5.109709 ms |
| No visual: pipeline | 1,000 | 0.000709 ms | 0.000916 ms | 0.063209 ms |
| No visual: combined | 1,000 | 0.263500 ms | 0.631751 ms | 5.110459 ms |
| Visual: semantic redraw | 1,000 | 0.277250 ms | 0.735833 ms | 13.567791 ms |
| Visual: pipeline | 1,000 | 0.005500 ms | 0.015125 ms | 0.284709 ms |
| Visual: combined | 1,000 | 0.283708 ms | 0.761333 ms | 13.583291 ms |

The p95 values are inside the green band. No-visual maximum is green. The isolated visual maximum is within the review band, not the stop band; the pipeline portion itself remained below 0.285 ms.

Technical recommendation: accept the synchronous architecture for V1C, retain the review-band maximum, repeat measurement when a future external producer is added, and do not add queues, buffers, workers, or asynchronous masking to conceal a wall-clock outlier.

## Allocation ownership

- `DynamicLocalPushFramePipeline.process` has no `new` bytecode.
- Four renderer instances are class-initialized once.
- The state counter is one bounded primitive field.
- No project-owned bitmap, frame, byte array, collection, closure, queue, task, or future is allocated per send by the V1C pipeline.
- `AbstractGraphicDisplay` already created one `ModelInfo` per send on the accepted basis; V1C changes assignment/redraw ownership, not that construction count.
- Forced redraw activates existing render-path and Bitwig host-adapter work, so zero total JVM allocation is not claimed.

## Working-set observation

Startup windows were retained separately and not described as steady state. The later one-hertz, 30-second window after timing completion was:

```text
RSS start: 2,197,424 KiB
RSS end:   2,199,824 KiB
RSS peak:  2,199,824 KiB
delta:         2,400 KiB
```

Final `jcmd GC.heap_info`:

```text
ZHeap used 738M, capacity 2130M, max capacity 3072M
```

No unbounded V1C state exists and the late window plateaued. This is a bounded observation, not an endurance claim.

## Real fixture observation

- Control lag: none observed.
- Display lag beyond accepted ordinary behavior: none observed.
- Audio xrun/dropout: none observed.
- Trail, stale block, whole-frame clear, scale error, or coordinate error: none observed.
- Shutdown: normal.

## Commands and tools

Tools included the external Java harness, `System.nanoTime`, `ThreadMXBean`, fixed arrays, temporary aggregate-only Bitwig instrumentation, `ps -o rss`, `jcmd GC.heap_info`, exact Java/Maven paths, and direct real-Push observation.

## What this proves

- The exact V1C head stays inside the accepted synchronous p95 band on the real fixture.
- The isolated maximum is bounded and explicitly retained for review.
- The V1C pipeline itself has zero project-owned per-send allocation sites and very small measured execution cost.
- No control, display, or audio regression was observed.

## What this does not prove

- It is not an endurance, thermal, power, audio-latency, cross-Mac, or future external-frame benchmark.
- It does not eliminate existing DrivenByMoss/Bitwig render-path allocation.
