# Performance and allocation

## Date, state, and authority

- Date: 2026-09-01 PDT.
- Machine state: accepted macOS 26.4.1 arm64, Bitwig Studio 6.1, real Push 3;
  exact observer run used the accepted Mac and Push audio route.
- Central basis/tree:
  `fe8216fcadc9879bafa96acbb0f064f1d6625f4b` /
  `580786862a6f034aa111b60c4d434e64c44c7211`.
- DrivenByMoss basis/tree:
  `663d719207ef58ec84b4d235c43211ec5da43605` /
  `c4e42825d069421a44b3241349de9a7c6453a3ad`.
- Source PR/head/tree:
  <https://github.com/kasselvania/DrivenByMoss/pull/5> /
  `830b778b720a06f56de08861d27052228c82c63b` /
  `c8bc3f9e052e8f0b7b5dd256657697349d303740`.
- Harness/producer/observer source SHA-256:
  `007822786260f89a9c3d005b669162389843a4dad2fb3293c6c131762c32bd18` /
  `993cb0f4d14c0a909a629ac4063e6e1937cb50ca42075e9fbbd3f099253bacbb` /
  `2e6ff0f6e2236e0b6ad85a831ba3f8c18f3362263eeaba425749fb4cbf929eb4`.
- Observer patch/artifact SHA-256:
  `75ef6dd932d04b89096c94c3ba86978e704b012b5ff58483dd0b1d004912c81b` /
  `31af0afc675371af301f4a6b94f6e7e54866e53ef6078568f2c0ea01382d28a3`.
- Receiver-rejection timing harness source SHA-256:
  `53222c790946f3a143011f9b0df281506e2e07f2e7145f49b33ef7782fc1770c`.
- Temporary receiver-timing patch / instrumented receiver source / artifact
  SHA-256:
  `ec355d1dd306d4cfe876fb9f33f199ff701b1ed1e5886e1f8874bb7d9837052f` /
  `97b7e32243c2df3da955b35e07e388912f7cfbeb28cc4fb9880daeb9db060aa2` /
  `923716db713b83df43c53b28cd0539528e6813cff3b45e9b8ab996c6dbf260ba`.
- Instrumented receiver class SHA-256:
  `b4cba600fcfa0b1e3e3b15bda3b1618879058d754ad07910c25369f9ddbde288`.
- After removing the observer, the restored receiver source SHA-256 was
  `77d87554bd5a5087b6425d2cc1f980b6916996985c74a315842ff2396f8a9026`;
  both production and observation worktrees read back clean at source
  head/tree `830b778b720a06f56de08861d27052228c82c63b` /
  `c8bc3f9e052e8f0b7b5dd256657697349d303740`.
- The temporary timing artifact was 14,389,376 bytes. Its
  `ExternalRasterPushFramePipeline.class` and
  `LatestExternalRasterFrameStore.class` hashes remained byte-identical to the
  exact production-head build:
  `2b25c0ae6135c59bc3d8769791c7a7a9055aeaab4d506c82bc731a46420112ac`
  and
  `8cfa9663fdcdebc613d6e04e09dd62aca31a1abfb558205300b0e789426f3cd1`.

## Measurement method

The temporary observer added fixed primitive sample arrays and aggregate-only
normal-shutdown output. It excluded at least the first 60 seconds after startup,
discarded at least 100 warmups per serious category, retained no token or raw
frame, and emitted no per-frame log. It was removed completely; the observation
worktree returned to the exact clean source head, and the clean head artifact
was rebuilt and used for final acceptance.

The Java harness separately measured exact clean-head deterministic calls with
fixed references and JVM thread-allocation counters. The receiver-rejection
repair used a package-local Java 21 harness plus temporary observation-only
timestamps in `ExternalRasterReceiver`; it compiled against and executed the
exact proposed source head. The timestamps were removed after the run and the
observation worktree returned to the exact clean source head and tree. Timing
uses `System.nanoTime()`. The live observer measures whole application
scheduling as well as project code where noted; none of these measurements is a
hard-real-time guarantee.

## Live receive, validation, and publication

All values are milliseconds.

| Stage | Samples | p50 | p95 | Max |
| --- | ---: | ---: | ---: | ---: |
| header receive/interarrival | 4,618 | 34.307292 | 71.461167 | 40,607.413083 |
| small payload receive | 1,707 | 0.014542 | 0.041417 | 1.106084 |
| medium payload receive | 1,700 | 0.033583 | 0.076958 | 4.027334 |
| full 614,400-byte payload receive | 1,000 | 0.103375 | 0.258584 | 10.040417 |
| protocol validation | 4,606 | 0.009541 | 0.045291 | 4.028542 |
| publication call | 4,601 | 0.004709 | 0.020625 | 1.296750 |
| publication critical section | 4,601 | 0.003125 | 0.017750 | 0.412208 |
| staging-to-publication copy | 4,601 | 0.002042 | 0.015917 | 0.409833 |

Header/interarrival values intentionally contain producer frame intervals and
the long idle/stale exercises; they are not parser processing latency. For the
full payload, derived useful loopback receive throughput is about 5.94 GB/s at
p50 and 2.38 GB/s at p95. The one 10.040417 ms full-payload maximum is retained
as a scheduling tail; p95 remained green and the deterministic full loopback
rerun maximum was 0.478792 ms.

## Live display path

| Stage | Samples | p50 ms | p95 ms | Max ms |
| --- | ---: | ---: | ---: | ---: |
| display `tryLock` | 20,000 | 0.000208 | 0.001000 | 0.242875 |
| publication-to-consumer copy | 4,136 | 0.003000 | 0.019000 | 2.221334 |
| V1D-1 writer, small | 1,896 | 0.001583 | 0.008334 | 0.060666 |
| V1D-1 writer, medium | 1,831 | 0.012375 | 0.027875 | 0.326500 |
| V1D-1 writer, full | 3,038 | 0.050666 | 0.113042 | 5.457542 |
| complete external pipeline | 6,965 | 0.022333 | 0.087708 | 23.896709 |
| no-frame path | 17,932 | 0.000959 | 0.003333 | 0.361209 |
| stale transition | 1 | 0.036417 | 0.036417 | 0.036417 |
| semantic redraw | 20,000 | 0.310083 | 0.953084 | 104.077666 |
| combined pipeline and existing send | 20,000 | 0.203667 | 0.700375 | 89.499917 |
| shutdown close/join | 1 | 0.006125 | 0.006125 | 0.006125 |

For the display `tryLock` series, 100 warmups and 4,996 startup/non-serious
observations were excluded before the retained distribution. The live run
recorded four lock misses, 4,701 accepted/published, 4,236 adopted, 465
superseded, 7,065 writer successes, and zero writer rejects.

The contract's project-owned adoption-plus-writer p95 band is green at
0.087708 ms, far below 2 ms. Two isolated live maxima are retained rather than
hidden:

- external pipeline maximum 23.896709 ms;
- full writer maximum 5.457542 ms.

They were not persistent. The exact clean-head deterministic rerun measured
1,000 current full-frame writes at p50 0.015125 ms, p95 0.016792 ms, maximum
0.094291 ms. No queue, buffer, worker, or sample deletion was introduced.
Physical 1/15/30/60 fps, burst, mode changes, audio, and controls showed no lag,
tearing, xrun, or dropout.

The semantic-redraw and combined-path maxima are whole Bitwig/JVM/host scheduling
tails outside the isolated ingress adoption/writer path; both p95 values remain
below 1 ms. They are retained explicitly and do not justify asynchronous
concealment.

## Existing exact clean-head display and accepted-input timing

The final rerun produced:

| Operation | Samples | p50 ms | p95 ms | Max ms |
| --- | ---: | ---: | ---: | ---: |
| no frame | 2,000 | 0.000084 | 0.002250 | 0.044083 |
| adopt and write small | 1,100 | 0.002958 | 0.010375 | 2.703208 |
| current frame write | 1,000 | 0.002625 | 0.009875 | 2.703208 |
| small receive end-to-end | 100 | 0.053792 | 0.066667 | 0.141583 |
| medium receive end-to-end | 100 | 0.071042 | 0.103250 | 0.170625 |
| full receive end-to-end | 100 | 0.264750 | 0.377708 | 0.478792 |
| current full-frame write | 1,000 | 0.015125 | 0.016792 | 0.094291 |
| stale/no-raster | 2,000 | 0.000083 | 0.001458 | 0.045000 |

This table's `no frame` and `stale/no-raster` rows measure only a subsequent
display-process invocation. They are not receiver rejection, authority
invalidation, connection cleanup, or listener-readiness latency. The repair
below measures those receiver-side intervals separately.

## Exact-head receiver-side rejected-input timing

The receiver-timing harness used 150 warmups followed by 1,200 retained samples
for each required series. Every sample used one authenticated loopback
connection and was followed immediately by a successful valid authenticated
producer reconnect and publication. The observation hook emitted fixed
primitive timestamps on the one production receiver thread; it did not alter
validation, publication, connection, display, or transport decisions.

The exact measured intervals were:

1. **Header-only protocol/metadata rejection:** immediately after the receiver
   completed the authenticated 80-byte message-header read through the next
   pre-`accept` timestamp, after rejection of a nonzero reserved/flags field,
   session/publication-authority invalidation, socket close, and client cleanup.
   No payload was read.
2. **Full-payload alpha rejection:** immediately after the receiver completed
   the 614,400-byte payload read through the next pre-`accept` timestamp, after
   scanning the complete useful payload, rejecting a nonopaque alpha byte in
   its final pixel, invalidating authority, and completing connection cleanup.
3. **Authenticated sequence rejection:** immediately after the complete
   duplicate-sequence 80-byte header read through the next pre-`accept`
   timestamp. The authenticated session first published one valid small frame;
   the duplicate did not refresh freshness.
4. **Truncated-header cleanup:** immediately when `readExact` observed EOF after
   31 of 80 header bytes through the next pre-`accept` timestamp, after
   truncation classification, invalidation, and cleanup.
5. **Truncated-payload cleanup:** immediately when `readExact` observed EOF after
   99 of 614,400 declared payload bytes through the next pre-`accept` timestamp,
   after truncation classification, invalidation, and cleanup.

The common endpoint was emitted immediately before the next
`ServerSocket.accept()`, after the outer socket close and client-reference
cleanup. The two truncation intervals begin at receiver-observed EOF, so
intentional sender stall time is excluded. Timestamp/probe overhead was not
subtracted: every sample includes the corresponding `System.nanoTime()` calls,
the static package-local probe callback, and one fixed primitive-array write.
The probe retained no payload, token, or frame.

All values are milliseconds.

| Receiver rejection/cleanup series | Samples | p50 | p95 | Max |
| --- | ---: | ---: | ---: | ---: |
| header-only nonzero-reserved rejection | 1,200 | 0.014958 | 0.039000 | 0.126250 |
| full-payload final-alpha rejection | 1,200 | 0.045833 | 0.070834 | 0.591875 |
| authenticated duplicate-sequence rejection | 1,200 | 0.007958 | 0.025042 | 0.271167 |
| partial-header EOF cleanup | 1,200 | 0.007584 | 0.020791 | 0.341333 |
| partial-payload EOF cleanup | 1,200 | 0.007583 | 0.023584 | 0.095167 |

### Separate display semantic fallback

After a receiver-ready event proved rejection, authority invalidation, and
cleanup complete, the harness timed one exact production-head
`ExternalRasterPushFramePipeline.process` call with no usable external frame.
This distribution covers only the project-owned invocation; it deliberately
does **not** include an actual Bitwig display-loop scheduling interval.

| Display fallback series | Samples | p50 ms | p95 ms | Max ms |
| --- | ---: | ---: | ---: | ---: |
| no usable external frame -> semantic-only output | 6,000 | 0.000291 | 0.001292 | 0.403625 |

Across the receiver and display series:

- rejected publication appearances: zero;
- publication-mutation mismatches: zero;
- old-session appearances after cleanup: zero;
- partial destination writes: zero;
- semantic-only mismatches: zero;
- freshness refreshes from rejected input: zero;
- partial/torn frame appearances: zero;
- escaped display exceptions: zero;
- authority-invalidation mismatches: zero;
- receiver-readiness mismatches: zero;
- immediate valid reconnect failures: zero;
- semantic bitmap reference-identity mismatches: zero.

The benchmark recorded 1,200 successful immediate reconnect/publication checks
after every rejection class. Listener readiness therefore was exercised 6,000
times after the retained rejection samples rather than inferred from a thread
state.

## Allocation and memory

- Project-owned fixed frame/security arrays: exactly 1,843,312 bytes.
- Receiver threads: exactly one.
- Project-owned frame-sized array/object allocation per accepted frame/send:
  zero by source and bytecode.
- Harness display allocation: 96 bytes/call, attributed to the deliberate Java
  dynamic proxy used as the fake bitmap, not production.
- Receiver-side measurement: 19.632 bytes per accepted frame, characterized as
  amortized JDK/JVM socket/accounting noise; no frame-sized project allocation
  site exists.
- Rejected-message receiver-thread allocation averaged 335.84 bytes for the
  header-only series, 336.00 bytes for full-alpha, 335.98 bytes for sequence,
  336.00 bytes for truncated-header, and 336.29 bytes for truncated-payload.
  This is bounded JDK/socket close and cleanup accounting. Source/bytecode
  inspection found zero project frame-sized rejection-path allocation sites.
- Receiver thread count before/during/after the rejection benchmark was
  `0 / 1 / 0`. The listener was reused for every next accept, no application
  queue existed, and no extra receiver thread appeared.
- Comparable post-warmup same-process heap was 8,511,728 bytes before and
  8,080,256 bytes after the rejection series: a decrease of 431,472 bytes, with
  no unbounded growth. This short deterministic comparison is not an endurance
  heap profile.
- Harness used heap: 5,107,720 bytes before the full configuration/correctness
  suite and 60,123,256 bytes afterward. The end includes retained harness
  reference arrays, JIT, classes, and runtime state; it is not a production leak
  slope.
- Whole-Bitwig observation: an earlier observer startup snapshot read 2,604,928
  KiB RSS; a later exact-final observer snapshot read 3,722,272 KiB RSS with
  physical footprint/peak about 3.6 GiB. These were not same-process
  start/end samples and therefore are retained only as whole-process bounds,
  not attributed ingress growth.

The exact same-process live RSS start/end delta was not captured. Fixed array
inspection, no-allocation bytecode, stable 75-second physical presentation,
and deterministic heap/allocation results bound project ownership, but do not
turn the whole Bitwig process readings into an ingress-only memory claim.

## Commands and tools

Tools included temporary fixed-array `System.nanoTime()` instrumentation,
`ThreadMXBean`, `jcmd`, process RSS/footprint readback, exact source/bytecode
allocation-site inspection, deterministic loopback and fake-writer harnesses,
Python 3.14.5 producer rates/patterns, and physical control/display/audio
observation.

The receiver-rejection repair compiled and ran with OpenJDK/Javac 21.0.11 and
Maven 3.9.16, the exact source-head `target/classes`, a 256 MiB initial heap,
and a 512 MiB maximum heap. Sanitized commands were:

```text
/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home/bin/javac \
  -cp "$HOME/Documents/ChatGPT/BitWig Standalone Push/DrivenByMoss-v1d2-observation/target/classes" \
  -d /private/tmp/pushwig-v1d2-rejected-timing/classes \
  /private/tmp/pushwig-v1d2-rejected-timing/ReceiverRejectedTimingHarness.java

/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home/bin/java \
  -Xms256m -Xmx512m \
  -cp "/private/tmp/pushwig-v1d2-rejected-timing/classes:$HOME/Documents/ChatGPT/BitWig Standalone Push/DrivenByMoss-v1d2-observation/target/classes" \
  de.mossgrabers.controller.ableton.push.controller.ReceiverRejectedTimingHarness \
  /private/tmp/pushwig-v1d2-rejected-timing/runtime
```

The temporary timing artifact was built with the same accepted explicit Java
21/Maven environment and `mvn clean install package
-Dbitwig.extension.directory=target`. The first sandboxed install attempt
compiled successfully but could not write the local Maven repository; the
authorized rerun completed successfully in 27.803 seconds. No Bitwig launch,
extension installation, or physical-fixture repetition was required because
the deterministic exact-head benchmark passed.

## Exact result

The repaired evidence now measures receiver rejection/invalidation/cleanup/
next-accept readiness independently from the later display fallback. Every
required receiver p95 is below 0.071 ms, display semantic fallback p95 is
0.001292 ms, fixed one-thread ownership remains intact, and all correctness
counters are zero. No production source changed.

## What this proves

- Normal V1D-2 receive, publish, adopt, and writer costs are comfortably within
  the synchronous review band on the accepted Mac.
- Latest-only ownership does not require unbounded memory or per-frame project
  allocation.
- The isolated tails did not reproduce in the deterministic clean-head rerun or
  produce observable physical regressions.
- Header-only, full-alpha, authenticated-sequence, and both truncation classes
  invalidate authority, clean up, and return the listener to `accept` with a
  bounded measured distribution.
- Rejected input does not publish, mutate the display publication, refresh
  freshness, leak an old session, or create a partial/torn display frame.

## What this does not prove

- It is not a hard-real-time, endurance, energy, or isolated native-memory
  profile.
- The whole Bitwig RSS snapshots are not a valid same-process ingress-growth
  delta; a future endurance slice should capture that if long-run memory
  characterization becomes an acceptance requirement.
- No claim is made that all host/JVM scheduling maxima can be eliminated.
- The display fallback distribution measures project-owned processing after
  invalidation, not the scheduler delay until Bitwig's next real display tick.
- These deterministic loopback distributions do not replace the already
  retained physical fixture evidence and do not constitute a network endurance
  or adversarial same-user security test.
