# V1D-1 performance, allocation, and tail review

## Date, machine state, and authority

- Evidence date: 2026-09-01 PDT.
- Machine state: accepted macOS 26.4.1 arm64 fixture, Bitwig Studio 6.1, real Push 3, and ordinary Push audio route. The second live run was hands-off on one stable semantic page.
- Central basis/tree: `c94d1b74d702e696d6cc4cc89625f1a2f7a95530` / `8539026fc9476bbf2df34b310190a57906113b90`.
- DrivenByMoss basis/tree: `852b520933eed87fbe496a04b5c18819a10b3564` / `d03a372e2efcf41b22cef46501e08efbfb0c0036`.
- Source PR/head/tree: [kasselvania/DrivenByMoss#4](https://github.com/kasselvania/DrivenByMoss/pull/4), `3c3ca02ff81ab5ce110ae3d714e20b5fca05a03f`, tree `c4e42825d069421a44b3241349de9a7c6453a3ad`.

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

The external harness ran against the exact clean artifact. After 100 warmup calls it retained 1,000 calls per size/path. `System.nanoTime` measured duration. Writer timing includes request validation, full alpha scan, and absolute bulk row copies; those sub-costs were not separately instrumented.

| Path | Useful copied bytes | Samples | p50 | p95 | Maximum | Approx. p50 useful throughput |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Semantic full-frame baseline | 614,400 | 1,000 | 10,041 ns | 12,666 ns | 104,834 ns | 61.19 GB/s |
| SMALL writer | 4,096 | 1,000 | 417 ns | 500 ns | 19,834 ns | 9.82 GB/s |
| SMALL combined | 618,496 | 1,000 | 10,167 ns | 13,542 ns | 86,917 ns | — |
| ODD_PADDED writer | 17,316 | 1,000 | 1,375 ns | 1,459 ns | 8,792 ns | 12.59 GB/s |
| ODD_PADDED combined | 631,716 | 1,000 | 11,250 ns | 14,334 ns | 124,834 ns | — |
| MEDIUM writer | 153,600 | 1,000 | 11,042 ns | 11,750 ns | 53,042 ns | 13.91 GB/s |
| MEDIUM combined | 768,000 | 1,000 | 20,625 ns | 24,584 ns | 115,083 ns | — |
| FULL writer | 614,400 | 1,000 | 44,333 ns | 68,500 ns | 458,334 ns | 13.86 GB/s |
| FULL combined | 1,228,800 | 1,000 | 55,834 ns | 106,208 ns | 1,165,375 ns | — |
| REPLACEMENT writer | 4,096 | 1,000 | 417 ns | 459 ns | 625 ns | 9.82 GB/s |
| REPLACEMENT combined | 618,496 | 1,000 | 10,333 ns | 12,750 ns | 107,958 ns | — |
| Rejected request | 0 | 1,000 | 83 ns | 84 ns | 542 ns | n/a |

`ThreadMXBean.getThreadAllocatedBytes` measured exactly 0 bytes across 5,000 FULL applications after warmup. The destination view creation count remained exactly 1. Production code owns no per-application frame, byte array, buffer view, collection, closure, task, queue, or future allocation.

## Real-Bitwig method

Temporary uncommitted instrumentation derived from the exact source head:

- excluded the first 60 seconds after startup;
- discarded 100 warmup samples per category;
- retained 1,000 semantic samples and 1,000 writer/combined samples for SMALL, ODD_PADDED, MEDIUM, FULL, REPLACEMENT, and rejected request;
- used fixed `long[]` arrays and one aggregate log line;
- used two observation-only `IBitmap.encode` calls for the first 1,920 correctness sends;
- emitted no frame and retained no screenshot.

### Interactive semantic-change run

The maintainer changed tracks/devices/parameters while the visual lifecycle ran.

| Interval | p50 | p95 | Maximum |
| --- | ---: | ---: | ---: |
| Semantic redraw | 0.268125 ms | 0.481417 ms | 3.529958 ms |
| SMALL writer | 0.001500 ms | 0.002250 ms | 0.247667 ms |
| SMALL combined | 0.182792 ms | 0.548958 ms | 30.861208 ms |
| ODD_PADDED writer | 0.003708 ms | 0.005166 ms | 0.098167 ms |
| ODD_PADDED combined | 0.194083 ms | 0.487541 ms | 2.013667 ms |
| MEDIUM writer | 0.015167 ms | 0.021625 ms | 0.330916 ms |
| MEDIUM combined | 0.206583 ms | 0.548459 ms | 4.237625 ms |
| FULL writer | 0.048750 ms | 0.081625 ms | 2.221958 ms |
| FULL combined | 0.239625 ms | 0.571292 ms | 2.457333 ms |
| REPLACEMENT writer | 0.001667 ms | 0.002417 ms | 0.066833 ms |
| REPLACEMENT combined | 0.193417 ms | 0.516292 ms | 32.092542 ms |
| Rejected writer | 0.000458 ms | 0.000708 ms | 0.033208 ms |
| Rejected combined | 0.192000 ms | 0.668750 ms | 24.154041 ms |

### Required hands-off stable rerun

Because the first run contained combined samples above 15 ms, the same observation artifact was restarted and left on one stable semantic page.

| Interval | p50 | p95 | Maximum |
| --- | ---: | ---: | ---: |
| Semantic redraw | 0.320958 ms | 0.823459 ms | 17.142792 ms |
| SMALL writer | 0.001542 ms | 0.002125 ms | 0.047625 ms |
| SMALL combined | 0.315292 ms | 0.678458 ms | 14.274833 ms |
| ODD_PADDED writer | 0.003500 ms | 0.004833 ms | 0.112625 ms |
| ODD_PADDED combined | 0.319667 ms | 0.807541 ms | 11.394084 ms |
| MEDIUM writer | 0.015459 ms | 0.026958 ms | 0.482583 ms |
| MEDIUM combined | 0.336917 ms | 0.877916 ms | 16.505292 ms |
| FULL writer | 0.048417 ms | 0.079834 ms | 0.678917 ms |
| FULL combined | 0.362416 ms | 0.848375 ms | 26.223208 ms |
| REPLACEMENT writer | 0.001834 ms | 0.002625 ms | 0.208833 ms |
| REPLACEMENT combined | 0.318708 ms | 0.784791 ms | 31.948291 ms |
| Rejected writer | 0.000459 ms | 0.000667 ms | 0.038583 ms |
| Rejected combined | 0.314542 ms | 0.774000 ms | 26.455875 ms |

All p95 values are in the green band and the worst combined p95 is 0.877916 ms. Every writer-only maximum is far below 15 ms; the stable semantic redraw itself produced a 17.142792 ms maximum. Above-15 ms combined samples were:

```text
interactive: SMALL 30.861208 ms; REPLACEMENT 32.092542 ms; rejected 24.154041 ms
stable:      MEDIUM 16.505292 ms; FULL 26.223208 ms; REPLACEMENT 31.948291 ms; rejected 26.455875 ms
```

The isolated tails are not attributable to the bounded writer: corresponding writer maxima remained between 0.038583 and 0.678917 ms in the stable run. They are consistent with host redraw/scheduler tails already retained in V1D-0 (MEDIUM combined maximum 17.679042 ms; mixed startup/interaction maximum 47.747125 ms), not a persistent project-writer regression.

Technical recommendation: accept the synchronous writer for V1D-1 because p95 is green, writer maxima are bounded, historical tails are not worsened, and no physical lag occurred. Retain the maxima for explicit technical-lead review and repeat the same separation when external ingress is introduced. Do not add a queue, worker, second bitmap, or asynchronous masking to hide wall-clock outliers.

## Technical-lead tail disposition

**Disposition: ACCEPTED for V1D-1.** The technical-lead review explicitly accepts the above-15 ms combined maxima as non-blocking host/redraw/scheduler tails rather than raster-writer regressions, for this slice and this accepted fixture.

The acceptance rests on the complete retained evidence, not on p95 alone:

- every writer-only p95 is at most `0.079834 ms` and every writer-only maximum is at most `0.678917 ms` in the required stable run;
- the same stable run records a `17.142792 ms` semantic-redraw-only maximum before raster work is included;
- the largest combined tails occur on small, replacement, and rejected states as well as FULL, so they do not scale with copied byte count;
- V1D-0 already retained larger mixed host tails up to `47.747125 ms` before this exact production writer existed;
- the exact clean artifact produced no observed control lag, abnormal display lag, audio xrun/dropout, corruption, or missed restoration;
- all correctness, allocation, source-custody, and real-fixture gates passed.

The decision does **not** reclassify these maxima as green, claim hard real-time behavior, or erase the stop-band rule. It approves the project-owned synchronous writer because the writer is independently bounded and the repeated wall-clock outliers are attributable to the pre-existing semantic/host scheduling path. V1D-2 must repeat separate consumer, handoff/copy, semantic-redraw, and combined measurements under a real external producer; a repeated project-owned ingress or writer stop-band result remains blocking.

## Regression timing context

The accepted V1C evidence retained offline p95 of 0.043792 ms default, 0.067875 ms V1B static, 0.086083 ms V1C no-visual, and 0.074292 ms V1C visual. Real V1C combined p95 was 0.631751 ms no-visual and 0.761333 ms visual. The corresponding V1A/V1B/V1C/framework classes are byte-identical in V1D-1, and formal Phase A/B/C runs observed no control/display/audio regression.

## RSS, heap, and observation overhead

The two `IBitmap.encode` calls per correctness send are temporary observation overhead and are absent from the proposed source head. They caused large host/native working-set growth during the fixed 1,920-send correctness window; growth plateaued after that window.

| Run | First RSS snapshot | Last/observed-peak snapshot | JVM heap at completion |
| --- | ---: | ---: | --- |
| Interactive | 1,649,440 KiB | 3,964,944 KiB | ZHeap used 376 MiB, capacity 2,970 MiB, max 3,072 MiB |
| Stable | 1,639,488 KiB | 3,731,456 KiB | ZHeap used 222 MiB, capacity 2,952 MiB, max 3,072 MiB |

Native-memory tracking was not enabled, so no category-level native attribution is claimed. The temporary patch/artifact were removed from the scan path and the observation worktree was restored exactly clean. Production allocation evidence is the separate 0-byte/5,000-call `ThreadMXBean` result and one cached-view count.

## Real fixture observations

- Control lag: none observed.
- Abnormal display lag: none observed.
- Audio xrun/dropout: none observed.
- Corruption, trail, stale block, scaling/filtering, or whole-frame clear: none observed.
- Shutdown: normal in every formal phase.

## Commands and tools

Tools included the external Java harness, `System.nanoTime`, `ThreadMXBean`, fixed sample arrays, temporary aggregate-only Bitwig instrumentation, `ps -o rss`, `jcmd GC.heap_info`, exact Java/Maven paths, aggregate-line SHA-256, and direct real-Push observation.

## What this proves

- Writer p95 and maximum costs are bounded well below the stop band on the accepted Mac.
- The FULL 614,400-byte application has zero project-owned thread allocation and reuses one destination view.
- Real-Bitwig p95 remains green and physical controls/display/audio show no regression.
- Above-15 ms wall-clock tails were repeated, retained, separated from writer cost, compared with accepted historical host tails, and explicitly accepted at technical-lead review for V1D-1.

## What this does not prove

- It does not claim hard real-time scheduling, zero host allocation, or zero maximum wall-clock tail.
- Temporary `IBitmap.encode` RSS behavior is not representative of the clean production artifact.
- It is not an endurance, thermal, power, detailed audio-latency, or future external-producer benchmark.
