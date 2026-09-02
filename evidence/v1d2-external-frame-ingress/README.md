# V1D-2 production external latest-frame ingress

## Result

This proposed evidence head retains the V1D-2 production source, protocol,
fixed-ownership, correctness, performance, real-fixture, shutdown, and rollback
results. It also repairs the receiver rejected-input performance evidence by
separating rejection/invalidation/cleanup/listener-readiness time from the
subsequent display semantic-fallback call. The repair remains subject to review
and merge; this document does not declare V1D-2 complete ahead of that review.

The exact proposed source head implements this path:

```text
external producer
    -> TCP 127.0.0.1 framed protocol v1
    -> capability-authenticated complete message
    -> receiver-owned fixed staging bytes
    -> fixed latest-publication bytes
    -> display-thread nonblocking adoption into fixed consumer bytes
    -> local monotonic freshness validation
    -> accepted V1D-1 writeRasterRegion, or no raster
    -> exact same semantic IBitmap
    -> exactly one unchanged PushUsbDisplay.send
```

The implementation is one source commit over the accepted integration basis,
uses exactly the authorized four production paths, and is proposed in
[DrivenByMoss PR #5](https://github.com/kasselvania/DrivenByMoss/pull/5). The
official extension was restored after the physical experiment at its accepted
SHA-256.

## Date, machine state, and authority

- Evidence date: 2026-09-01 PDT.
- Machine state: accepted macOS 26.4.1 build 25E253, Darwin 25.4.0, arm64
  maintainer fixture; Bitwig Studio 6.1; DrivenByMoss 26.4.1; real Ableton Push
  3; Push headphone audio route.
- Final ordinary state: Bitwig closed; no ingress listener; one scanned official
  `DrivenByMoss.bwextension`; no temporary live capability file.
- Actual central basis/tree:
  `fe8216fcadc9879bafa96acbb0f064f1d6625f4b` /
  `580786862a6f034aa111b60c4d434e64c44c7211`.
- DrivenByMoss basis/tree:
  `663d719207ef58ec84b4d235c43211ec5da43605` /
  `c4e42825d069421a44b3241349de9a7c6453a3ad`.
- Proposed source head/parent/tree:
  `830b778b720a06f56de08861d27052228c82c63b` /
  `663d719207ef58ec84b4d235c43211ec5da43605` /
  `c8bc3f9e052e8f0b7b5dd256657697349d303740`.
- Source branch: `pushwig/v1d2-external-frame-ingress`.
- Source PR: <https://github.com/kasselvania/DrivenByMoss/pull/5>.
- Clean proposed artifact: 14,388,379 bytes, SHA-256
  `026f88905cbd27890fca333cdcb5820c4fedaa3273359bb75b7e6106fd59278e`.
- Restored official SHA-256:
  `98dc3195ad8d911526e18b1005f09f69a1aedcb965b080565474104654345c5a`.

## Temporary evidence identities

- Java conformance harness source SHA-256:
  `007822786260f89a9c3d005b669162389843a4dad2fb3293c6c131762c32bd18`.
- Python conformance producer source SHA-256:
  `993cb0f4d14c0a909a629ac4063e6e1937cb50ca42075e9fbbd3f099253bacbb`.
- Final aggregate observer source SHA-256:
  `2e6ff0f6e2236e0b6ad85a831ba3f8c18f3362263eeaba425749fb4cbf929eb4`.
- Final observer patch SHA-256:
  `75ef6dd932d04b89096c94c3ba86978e704b012b5ff58483dd0b1d004912c81b`.
- Observer artifact SHA-256:
  `31af0afc675371af301f4a6b94f6e7e54866e53ef6078568f2c0ea01382d28a3`.
- Receiver-rejection timing harness source SHA-256:
  `53222c790946f3a143011f9b0df281506e2e07f2e7145f49b33ef7782fc1770c`.
- Temporary receiver-timing patch / instrumented receiver source / artifact
  SHA-256:
  `ec355d1dd306d4cfe876fb9f33f199ff701b1ed1e5886e1f8874bb7d9837052f` /
  `97b7e32243c2df3da955b35e07e388912f7cfbeb28cc4fb9880daeb9db060aa2` /
  `923716db713b83df43c53b28cd0539528e6813cff3b45e9b8ab996c6dbf260ba`.

These temporary sources, binaries, tokens, and generated frames are not
committed.

## Headline proof

- Clean Java 21.0.11 / Maven 3.9.16 base and head builds passed.
- The extracted head delta is confined to `Push2Display.class`, the three new
  top-level classes, and the store's one construction-time nested
  `DisplayFrame.class`.
- All protected transport, bitmap, raster-sink, display, and earlier pipeline
  classes are byte-identical to the base build.
- Final harness rerun: 1,511 accepted and published frames, 1,111 adoptions,
  398 supersessions, positive coverage for every required lifecycle/failure
  counter, and zero pixel/restoration/fallback/torn/mutation/partial-write/
  escaped-exception/post-exhaustion mismatches.
- Fixed project-owned frame/security arrays: 1,843,312 bytes; exactly one
  receiver thread; no application frame queue.
- Live external pipeline: 6,965 samples, p50 0.022333 ms, p95 0.087708 ms,
  maximum 23.896709 ms. The isolated maximum was retained; a deterministic
  clean-head rerun reached p95 0.016792 ms and maximum 0.094291 ms for the
  current full-frame write, with no physical lag or dropout.
- Exact-head receiver rejection/cleanup through next-accept readiness, 1,200
  post-warmup samples each: header-only p50/p95/max
  `0.014958/0.039000/0.126250` ms; full-payload final-alpha
  `0.045833/0.070834/0.591875` ms; duplicate sequence
  `0.007958/0.025042/0.271167` ms; partial-header EOF
  `0.007584/0.020791/0.341333` ms; partial-payload EOF
  `0.007583/0.023584/0.095167` ms.
- Separate exact-head semantic fallback, 6,000 project-owned process calls:
  p50/p95/max `0.000291/0.001292/0.403625` ms. This excludes actual Bitwig
  display-loop scheduling and is not conflated with receiver cleanup.
- Rejected-input publication, mutation, old-session, partial-write,
  semantic-fallback, freshness, torn-frame, escaped-exception, invalidation,
  readiness, reconnect, and reference-identity mismatch counts were all zero.
- Receiver threads before/during/after were `0/1/0`; average receiver-thread
  allocation was about 336 bytes per rejected message, with no frame-sized
  project allocation, application queue, or comparable-process heap growth.
- Real Push phases A-F passed: no producer, all generated patterns and rates,
  latest-frame/session behavior, the full fallback matrix, precedence, five
  shutdown states, active-listener collision, and immediate rebind.
- Rollback passed: standard official display, controls, Push audio/headphones,
  no generated pixels, and normal quit were physically reconfirmed.

## Evidence map

- [source-topology.md](source-topology.md): exact repository/source custody,
  authorized paths, construction selection, and bytecode identities.
- [protocol-and-security.md](protocol-and-security.md): endpoint, token-file
  contract, version-1 wire language, and configuration matrix.
- [buffer-and-thread-ownership.md](buffer-and-thread-ownership.md): fixed arrays,
  synchronization, receiver/display separation, and one-writer proof.
- [session-sequence-freshness.md](session-sequence-freshness.md): authenticated
  generation, sequence/exhaustion, reconnect, and monotonic freshness.
- [lifecycle-and-failure-correctness.md](lifecycle-and-failure-correctness.md):
  deterministic mismatch/failure results, collision/restart, and shutdown.
- [performance.md](performance.md): exact-final harness and live aggregate
  timing, separate receiver rejection and display-fallback distributions,
  allocation, memory, and tail disposition.
- [build-artifact-comparison.md](build-artifact-comparison.md): toolchain,
  artifacts, extracted payload comparison, and protected-class hashes.
- [real-fixture-and-rollback.md](real-fixture-and-rollback.md): installation,
  physical phases A-F, and exact official rollback.
- [manual-acceptance.md](manual-acceptance.md): every direct maintainer result
  and its observational boundary.

## Commands and tools

Tools included `git`, `gh`, `rg`, `javap -c -p`, Java 21, Maven 3.9.16,
Python 3.14.5, `shasum -a 256`, `cmp`, extracted-tree comparison, `ps`,
`lsof`, `jcmd`, narrow local log selection, the temporary deterministic
producer/harness/aggregate observer, and direct physical maintainer observation.

The exact build shape was:

```text
env \
  JAVA_HOME=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home \
  PATH=/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin \
  mvn clean install package -Dbitwig.extension.directory=target
```

The rejected-input repair used temporary package-local Java 21 observation
instrumentation against the unchanged exact source head. After correctness and
timing passed, it was removed and the observation worktree returned to the
exact clean head/tree. No extension was installed, Bitwig was not launched, and
the already accepted physical Push fixture was not repeated.

## What this proves

- The exact source PR implements the selected bounded, authenticated,
  latest-only local ingress while retaining one unchanged Push USB writer.
- Complete-message validation, nonblocking display adoption, current-semantic
  fallback, sequence/freshness rules, fixed memory, and bounded shutdown work
  both deterministically and on the real Mac/Bitwig/Push fixture.
- The official artifact was restored exactly after all live tests.
- The repair proves separately that representative rejected inputs invalidate
  authority, complete connection cleanup, and return the same one-thread
  listener to its next accept, while the later no-frame display call preserves
  exact semantic output.

## What this does not prove

- This does not add or prove ScreenCaptureKit, window discovery, proprietary
  capture, scaling, alpha blending, remote transport, multiple producers, a
  public adapter SDK, Push 2 hardware, or endurance behavior.
- The capability authenticates possession of a private file; it is not OS
  process identity and cannot exclude a same-user process able to read it.
- A stalled authenticated peer can occupy the single receiver slot until it
  disconnects or shutdown closes it; this is an intentional protocol-v1
  availability limit.
- Exact same-process live RSS start/end attribution was not captured; retained
  whole-process observations and deterministic fixed-array/heap evidence are
  bounded explicitly in [performance.md](performance.md).
