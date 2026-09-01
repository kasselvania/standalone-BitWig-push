# Performance, allocation, and memory

## Date, state, and authority

- Date: 2026-09-01 PDT.
- Machine state: accepted macOS 26.4.1 arm64 fixture, Bitwig Studio 6.1, real Push 3, and Push headphone audio route.
- Central basis/tree: `5597624bd50e5ef95ecd3af82ea1816ce4facd21` / `ec016bd3174345e32f1a6d47eb061820e7a1e9b9`.
- DrivenByMoss basis/tree: `663d719207ef58ec84b4d235c43211ec5da43605` / `c4e42825d069421a44b3241349de9a7c6453a3ad`.
- Final candidate head/tree: `4f00972355fcf7b5f0ead0fef3365b81850be12f` / `7202267e51d0f2613cea93d186b132a996ec14ec`.

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

## Exact-final allocation and fallback harnesses

The uninstrumented exact final head accepted `4,200` frames in the allocation harness:

```text
PERFORMANCE HARNESS PASS
accepted=4200 writerCalls=195956 finalSequence=4200
displayAllocatedBytes=36048 receiverAllocatedBytes=7888
displayAllocatedPerWriterCall=0.1839596644
receiverAllocatedPerAcceptedFrame=1.8780952381
fixedHarnessBitmapBytes=614400
```

Harness SHA-256: `78e98ae0d6acf8339134b8b9492cb7d035525ce6369d46316654da95a7030548`. The harness used reflection only to read the private receiver-thread object for `ThreadMXBean`; production source was unchanged.

The exact-final malformed/rejected fallback harness retained 1,000 post-warmup samples:

```text
p50  = 0.020875 ms
p95  = 0.080542 ms
max  = 0.986084 ms
```

Harness SHA-256: `44f51daaeb8ef28603dace7a8d99bdd839d49d69316f7cbff01e440fa207b61f`.

The tiny amortized allocation values are JVM/JDK measurement noise. Source and bytecode own no per-frame array/object/queue/task allocation. All three maximum-size frame arrays are construction-time fields.

## Live aggregate observation method

Temporary aggregate-only instrumentation was applied outside the candidate commit. It used fixed `long[]` sample arrays, discarded 100 warmup samples per category, excluded the first 60 seconds after Bitwig startup, emitted one aggregate summary, and wrote no frame or screenshot.

- Observation clean base: `b568c4c1b52dcdf167d141358b65483b619bbe57` / tree `89d266ff34d6039452d39bebbef0b528d8c9c235`.
- Observation patch SHA-256 tied to the retained second artifact: `f830439c6bb98a9cc7b0133f61b401252f533e4b6e242c8ad9914959f6a0fe9b`.
- Observation artifact: `14,390,613` bytes, SHA-256 `fc5885fe0ab430c89757685d5025fd74a307782233e2021d213852892c805686`.
- Three producer intervals: 1,250 SMALL, 1,250 MEDIUM, and 1,250 FULL frames requested at 30 fps; elapsed `46.54`, `47.18`, and `46.97` seconds.
- Retained payload/validation/publication samples: 1,150 per size after warmup.

The observation base preceded final lifecycle corrections (`1,500 ms` default staleness, nonblocking close epoch, failed-bind socket cleanup, and immediate-restart reuse). Those changes were separately reproved on the exact final head. The pre-restart clean artifact and final artifact differ only in `ExternalRasterReceiver.class`, and the final source change from `e7b6308e...` to `4f009723...` is confined to socket construction. The tables are therefore retained as live stage-cost evidence, not misrepresented as an exact clean-artifact binary benchmark. Exact-final allocation, failure latency, correctness, shutdown, and physical lag observations are reported separately.

All temporary instrumentation was removed. The observation worktree is clean and detached at final candidate head `4f009723...`.

## Receiver timing

Times are milliseconds. Payload useful sizes are SMALL `4,096`, MEDIUM `153,600`, FULL `614,400` bytes.

| Stage | Size | Samples | p50 | p95 | Maximum |
| --- | --- | ---: | ---: | ---: | ---: |
| Payload receive | SMALL | 1,150 | 0.018542 | 0.081292 | 0.817375 |
| Payload receive | MEDIUM | 1,150 | 0.042542 | 0.166792 | 48.363125 |
| Payload receive | FULL | 1,150 | 0.159209 | 0.390708 | 8.510833 |
| Protocol validation | SMALL | 1,150 | 0.005167 | 0.023209 | 5.146375 |
| Protocol validation | MEDIUM | 1,150 | 0.013251 | 0.033541 | 0.865168 |
| Protocol validation | FULL | 1,150 | 0.038458 | 0.071458 | 0.843875 |
| Staging-to-publication copy | SMALL | 1,150 | 0.000542 | 0.002333 | 0.074833 |
| Staging-to-publication copy | MEDIUM | 1,150 | 0.003875 | 0.005333 | 0.195167 |
| Staging-to-publication copy | FULL | 1,150 | 0.014041 | 0.021958 | 0.299416 |
| Full publication critical section | SMALL | 1,150 | 0.001542 | 0.004833 | 0.077708 |
| Full publication critical section | MEDIUM | 1,150 | 0.005042 | 0.009083 | 0.197375 |
| Full publication critical section | FULL | 1,150 | 0.015583 | 0.024916 | 0.301583 |

Approximate useful p50 payload-read throughput was `0.221 GB/s` SMALL, `3.61 GB/s` MEDIUM, and `3.86 GB/s` FULL. End-to-end requested producer throughput was approximately `0.11`, `4.07`, and `16.35 MB/s` respectively; the deterministic Python pattern producer did not actually sustain the requested 30 fps.

Header receive retained `3,653` samples: p50 `37.080083 ms`, p95 `38.592042 ms`, maximum `545.401916 ms`. This interval deliberately includes blocking wait/interarrival time on the receiver thread and is not protocol-processing latency or display cost.

## Display and accepted V1D-1 timing

Times are milliseconds.

| Stage | Size | Samples | p50 | p95 | Maximum |
| --- | --- | ---: | ---: | ---: | ---: |
| Display try-acquire | all | 10,000 | 0.000375 | 0.000833 | 0.076750 |
| Publication-to-consumer copy | SMALL | 1,150 | 0.000584 | 0.001000 | 0.075458 |
| Publication-to-consumer copy | MEDIUM | 1,141 | 0.004541 | 0.006250 | 0.089708 |
| Publication-to-consumer copy | FULL | 1,150 | 0.016625 | 0.023167 | 0.182625 |
| V1D-1 writer | SMALL | 1,812 | 0.002041 | 0.012584 | 0.206042 |
| V1D-1 writer | MEDIUM | 1,788 | 0.015500 | 0.024125 | 8.149292 |
| V1D-1 writer | FULL | 1,803 | 0.049875 | 0.071459 | 0.763875 |
| External pipeline | SMALL | 1,812 | 0.005625 | 0.018625 | 0.333417 |
| External pipeline | MEDIUM | 1,788 | 0.020250 | 0.032041 | 8.155375 |
| External pipeline | FULL | 1,803 | 0.067458 | 0.092375 | 0.800708 |
| No-frame path | all | 4,892 | 0.002000 | 0.003084 | 0.688375 |
| Semantic redraw | all | 10,000 | 0.316209 | 0.859375 | 51.947959 |
| Combined semantic + pipeline/send | all | 10,000 | 0.551583 | 2.106083 | 185.690208 |

The project-owned display snapshot/copy plus writer path is green: worst p95 `0.092375 ms`, far below `2 ms`. The combined p95 `2.106083 ms` is in the review band, while the `185.690208 ms` maximum is a host/scheduler wall-clock tail. The semantic-redraw-only maximum was already `51.947959 ms`; writer/pipeline maxima did not scale to the combined tail.

**Technical recommendation:** select the synchronous candidate because the new handoff/writer p95 is independently green, its fixed critical sections are sub-`0.1 ms` p95, no physical lag/dropout occurred, and adding a queue/worker/buffer would weaken authority. Retain the combined tail as a production-slice review item and repeat exact clean-head aggregate timing; do not claim hard-real-time behavior.

## Memory and thread observation

- Candidate source owns `1,843,312` fixed frame/security array bytes and exactly one new receiver thread.
- Total Bitwig process thread count observed: `82`; this includes Bitwig and all other subsystems and is not attributed wholesale to the candidate.
- First 240 seconds after startup/indexing: RSS `2,582,416 KiB` to `3,783,808 KiB`; excluded from steady candidate inference.
- Later valid 80-second interval: RSS `3,783,792 KiB` to `3,783,936 KiB`, sampled peak `3,783,936 KiB` (`+144 KiB`). No unbounded growth was observed.
- JVM heap snapshots: used `290 MiB` then `462 MiB`; capacity about `2,958 MiB`, max `3,072 MiB`. These whole-host values do not isolate the candidate.
- Native-memory tracking was not enabled, so no category-level native claim is made.

## Shutdown timing

Exact-final offline close/join timings were:

| State | Time |
| --- | ---: |
| Primary receiver | 0.361209 ms |
| Wait in accept | 0.165250 ms |
| Authenticated idle | 1.721000 ms |
| Continuous frames | 0.298541 ms |
| Partial header | 0.256500 ms |
| Partial payload | 0.523250 ms |

All are far below the 2-second join bound. All five states also quit normally on the exact final physical fixture.

## Physical observations

- Control lag: none observed.
- Abnormal display lag: none observed at 15, 30, or 60 fps.
- Audio xrun/dropout: none observed.
- Corruption, torn frame, trail, stale block, or backlog replay: none observed.

## Commands and tools

Tools included fixed-array aggregate instrumentation, `System.nanoTime`, `ThreadMXBean`, `ps` RSS, `jcmd GC.heap_info`, deterministic producer rates/sizes, exact Java/Maven paths, source/artifact hashes, extracted payload comparison, and direct real-Push observation.

## What this proves

- The project-owned publication/adoption/writer path is well inside the green p95 band with fixed memory and no frame-sized per-cycle allocation.
- Receiver blocking is isolated from display timing; publication and display copies remain short at full-frame size.
- Exact-final lifecycle/fallback/shutdown performance and live physical behavior are acceptable for a production slice.

## What this does not prove

- It does not prove hard-real-time maximum latency, exact OS/JDK socket allocation, thermal/endurance behavior, or zero Bitwig/USB allocation.
- Whole-process RSS/heap and combined tails cannot be attributed exclusively to this candidate.
- The production slice must repeat aggregate timing from its exact proposed clean head, especially the combined review-band tail.
