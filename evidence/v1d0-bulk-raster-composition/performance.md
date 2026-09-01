# Performance, allocation, and memory evidence

## Evidence identity

- Date: 2026-09-01 PDT.
- Machine state: accepted arm64 macOS + Bitwig Studio 6.1 + DrivenByMoss 26.4.1 + Push 3 fixture.
- Central basis: `a66e1e45ebb2cb72f8ea1cb12e96d1bc46d7c343`, tree `b83e9e9507dc2e26d551abed1f03c30a6b76a551`.
- DrivenByMoss basis: `852b520933eed87fbe496a04b5c18819a10b3564`, tree `d03a372e2efcf41b22cef46501e08efbfb0c0036`.
- Candidate A: local commit `61c659e19faad3944f610022fca5d57f09e7b442`, tree `6d06def69677918e871bb5a0c978be83aab29cb8`.
- Harness SHA-256: `7be829d7e302b00226f6fabf005e2a423b91132d6eebdae980acbc57657b6ee7`.
- Final observation patch/artifact SHA-256: `2cba0fbffabeb6e7609f6c5ffbdb433e1e9bfa90d9f1e5414f84843a8c4b7e96` / `f7903aabd3266b9c26db34d68279632cffac6281cf453705d7763a0f0617076a`.

## Exact build/runtime toolchain

```text
JAVA_HOME=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home
java:  /opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home/bin/java
javac: /opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home/bin/javac
mvn:   /opt/homebrew/bin/mvn
Java:  OpenJDK 21.0.11, Homebrew arm64
javac: 21.0.11
Maven: Apache Maven 3.9.16
```

Both exact accepted base and frozen candidate builds completed successfully with the required explicit environment and only known shade/module warnings.

## Real Bitwig post-warmup timing

Each row contains 1,000 post-warmup samples from the final observation artifact. Writer timing includes complete validation, including opaque-alpha scan, and absolute bulk row application. Combined timing includes the accepted current-semantic redraw plus that application.

| Path | Useful bytes | p50 | p95 | max | Approx. p50 useful throughput |
|---|---:|---:|---:|---:|---:|
| semantic redraw only | — | 0.254458 ms | 0.420417 ms | 2.414708 ms | — |
| SMALL writer | 4,096 | 0.001791 ms | 0.002750 ms | 0.047334 ms | 2.29 GB/s |
| ODD/PADDED writer | 17,316 | 0.003542 ms | 0.005417 ms | 0.125375 ms | 4.89 GB/s |
| MEDIUM writer | 153,600 | 0.015208 ms | 0.027416 ms | 0.204250 ms | 10.10 GB/s |
| FULL writer | 614,400 | 0.047875 ms | 0.083083 ms | 0.528917 ms | 12.83 GB/s |
| rejected validation | 0 | 0.000500 ms | 0.000750 ms | 0.048875 ms | — |
| redraw + SMALL | 4,096 | 0.252832 ms | 0.460583 ms | 6.142749 ms | — |
| redraw + ODD/PADDED | 17,316 | 0.253875 ms | 0.520042 ms | 5.655084 ms | — |
| redraw + MEDIUM | 153,600 | 0.269083 ms | 0.747125 ms | 17.679042 ms | — |
| redraw + FULL | 614,400 | 0.300834 ms | 0.636291 ms | 8.832250 ms | — |
| redraw + rejected | 0 | 0.250208 ms | 0.424208 ms | 3.754500 ms | — |

The acceptance band is specifically current-semantic redraw plus full-frame application. That required path is green: p95 `0.636291 ms <= 2 ms` and maximum `8.832250 ms <= 10 ms`.

One isolated MEDIUM combined sample reached `17.679042 ms` even though its p95 was `0.747125 ms` and the larger FULL path remained green. It produced no observed lag or mismatch, but V1D-1 should repeat per-size post-warmup tail measurements and retain GC/scheduling context rather than assuming monotonic maxima.

A preliminary mixed startup/active-interaction batch recorded semantic redraw p50 `0.271417 ms`, p95 `1.005958 ms`, and maximum `47.747125 ms`. That non-isolated batch was not used as the post-warmup full-frame acceptance authority; it is retained as evidence that JVM/host scheduling outliers exist and should remain visible in V1D-1 review.

## External harness timing

The external harness collected 5,000 samples per path:

| Path | p50 | p95 | max |
|---|---:|---:|---:|
| semantic byte copy | 0.011000 ms | 0.014208 ms | 0.154084 ms |
| SMALL writer | 0.000417 ms | 0.000500 ms | 0.056750 ms |
| ODD/PADDED writer | 0.001292 ms | 0.001417 ms | 0.031667 ms |
| MEDIUM writer | 0.011875 ms | 0.012625 ms | 0.067667 ms |
| FULL writer | 0.051000 ms | 0.083584 ms | 2.501334 ms |
| rejected validation | 0.000042 ms | 0.000125 ms | 0.006084 ms |
| semantic copy + FULL | 0.062250 ms | 0.098458 ms | 1.731042 ms |

The real host remains the acceptance authority; the external results isolate validation/copy behavior.

## Source-carrier timing

For identical full-frame content and 5,000 calls:

| Carrier | p50 | p95 | max | Cursor behavior |
|---|---:|---:|---:|---|
| `byte[]` | 0.010708 ms | 0.018250 ms | 2.570125 ms | no position/limit |
| read-only `ByteBuffer` | 0.010500 ms | 0.017375 ms | 0.709334 ms | unchanged by absolute operation |

Performance does not force either carrier. Ownership simplicity selects `byte[]` for V1D-1.

## Allocation and view result

- `com.sun.management.ThreadMXBean.getThreadAllocatedBytes` measured `0` project-thread bytes across 5,000 full-frame writer calls.
- Bytecode contains no allocation in `writeRasterRegion`; array patterns were class-initialized once.
- The research `BitmapImpl` created two destination `ByteBuffer` views once: one writer view and one observation-only alias-verification view.
- Production budget is one cached destination view per bitmap; the second view, diagnostic text, pattern arrays, and observation timing arrays are not production requirements.
- Project-owned per-application allocation budget: `0` bytes/objects.
- Existing V1C semantic rendering still creates existing host-adapter graphics objects; this research does not relabel them as absent.
- Fixed research raster pattern bytes: `794023`; fixed observation arrays/state: `1931200` bytes.

## Heap and working set

Observed JVM heap readbacks included:

```text
used from total/free sample: 375390208 bytes
jcmd ZHeap used:            approximately 368 MiB
ZHeap capacity:             approximately 2940 MiB
ZHeap max:                  3072 MiB
```

Bitwig Studio RSS grew during startup/indexing from 1,674,592 KiB to 3,843,664 KiB. In the late stable window it moved from 3,843,664 KiB to 3,846,544 KiB over about 69 seconds, a 2,880 KiB delta, while fixed observer state remained bounded. The audio engine moved from about 245 MiB during startup to about 342 MiB later. This is a bounded fixture observation, not an attribution of all Bitwig RSS to the extension and not an endurance proof.

## Control, display, and audio observations

The maintainer reported no control lag, no abnormal display lag, and no audio xrun/dropout. All control/display/audio fixture rows passed. No queue, worker, second bitmap, or transport change was introduced to hide synchronous cost.

## Commands and tools

Used fixed `System.nanoTime` sample arrays with warmup, aggregate percentile calculation, Java thread-allocation readback, `jcmd GC.heap_info`, `ps` RSS snapshots, exact same-toolchain builds, bytecode disassembly, external carrier benchmark, physical fixture operation, and narrow current-run error search.

## What this proves

Candidate A's required full redraw plus full-frame raster path is green on the accepted Mac, has zero project-owned per-application allocation, and remains bounded without asynchronous work.

## What this does not prove

It does not prove hard real-time scheduling, eliminate JVM/host outliers, establish cross-machine performance, or provide an endurance/leak claim. V1D-1 must remeasure the exact proposed production head.
