# Capture performance and bounded resources

## Date, machine state, and authority

- Date: 2026-09-02 PDT.
- Machine state: accepted macOS 26.4.1 arm64 fixture, Bitwig Studio 6.1, real
  Push 3, and exact stable helper app.
- Central basis/tree:
  `7c15abaf55c0080b2f80971e845b4ee6f1bfcc46` /
  `730726784b57016714c0a44c8f0f8caf1c5b0141`.
- Source PR/head/tree:
  [PR #43](https://github.com/kasselvania/standalone-BitWig-push/pull/43) /
  `03fb8c8824714e4bbefd7224848ca9cdad069088` /
  `f1f68bc6f0ba6527bb146a7ee93fd4333ffaf796`.
- Helper executable SHA-256:
  `9a81bb292cfa00588c4be0272abb11a2e223132feb8725aca6e2c6a808bf942a`.
- Previously retained full 30-fps source head/helper SHA-256:
  `c6c4e05c6c4bc1924b529a28990ea633515667cf` /
  `7dc775f8eaa6ef50d85c24394ca22e492ceba9cd07738b97a893f0a3604564cc`.

## Method

The production helper contains bounded fixed-capacity aggregate timing
series and prints summaries only on normal shutdown; it does not log per frame
or retain pixel histories. Timing uses monotonic host time around separately
identified stages. The previously retained full 30-fps series excluded the
first 100 accepted frames and retained 2,079 post-warmup complete frames. The
15-fps series retained 282 post-warmup complete frames; it is useful rate
corroboration but not a 1,000-sample serious series. The repair did not repeat
the full fixture matrix, but its focused run naturally retained 1,003
post-warmup frames from the exact amended helper as a same-fixture throughput
corroboration.

The ScreenCaptureKit display-time-to-callback interval is reported only when
the public display-time value was nonnegative and comparable to callback host
time. It is a limited attribution sample, not a claim to isolate all internal
ScreenCaptureKit crop/scaling work.

## Exact 30-fps distributions

All timings are milliseconds.

| Stage | Samples | p50 | p95 | Max |
| --- | ---: | ---: | ---: | ---: |
| Callback delivery interval | 2,079 | 39.927500 | 40.710333 | 42.130166 |
| Public display time -> callback | 95 | 0.378125 | 0.483625 | 0.907958 |
| Frame-status validation | 2,079 | 0.033458 | 0.046917 | 0.125459 |
| Pixel-buffer lock/access | 2,079 | 0.923375 | 1.331458 | 2.315125 |
| Normalized crop calculation | 1 | 0.015500 | 0.015500 | 0.015500 |
| Aspect-policy calculation | 1 | 0.000583 | 0.000583 | 0.000583 |
| Stream configuration/start setup | 1 | 124.929000 | 124.929000 | 124.929000 |
| BGRA copy + forced alpha | 2,079 | 0.088959 | 0.116166 | 0.625500 |
| Protocol-header preparation | 2,079 | 0.000292 | 0.000500 | 0.002000 |
| Loopback socket send | 2,079 | 0.082125 | 0.116292 | 0.574792 |
| Copy/map/normalize/send | 2,079 | 0.172916 | 0.218208 | 0.709375 |
| Complete accepted sample -> send | 2,079 | 1.141459 | 1.553917 | 2.523375 |

Both required processing bands pass: complete helper processing p95 is below
10 ms, and copy/map/normalize/send p95 is below 2 ms. The approximately 40-ms
callback interval is delivery cadence, not helper processing time.

## Exact amended-head loopback corroboration

The focused exact-amended-app run retained these 1,003 post-warmup complete
frames before the maintainer closed Bitwig:

| Stage | Samples | p50 ms | p95 ms | Max ms |
| --- | ---: | ---: | ---: | ---: |
| Callback delivery interval | 1,360 | 39.903666 | 41.046875 | 49.171542 |
| BGRA copy + forced alpha | 1,003 | 0.091375 | 0.110708 | 0.409625 |
| Protocol-header preparation | 1,003 | 0.000500 | 0.000750 | 0.001417 |
| Normal loopback socket send | 1,003 | 0.079375 | 0.091916 | 0.489875 |
| Copy/map/normalize/send | 1,003 | 0.173333 | 0.202792 | 0.587000 |
| Complete accepted sample -> send | 1,003 | 1.851416 | 2.628583 | 4.628208 |

Observed valid publication was 25.398 fps. The later dedicated normal-quit run
exited zero, while this longer run ended after Bitwig closed its receiver and
therefore recorded three immediate bounded protocol failures during teardown.
Those receiver-closed failures are not stalled-reader deadline expirations and
do not alter the accepted processing samples.

## Rates, counters, and resources

The requested 30-fps run observed 25.265 complete published frames/s. It
recorded 3,410 callbacks, 2,179 complete frames, sequence 1 through 2,180,
one CLEAR, and 1,231 guard-suppressed samples during deliberate focus-invalid
periods. The delivered-callback accounting is exact:

```text
2,179 complete published callbacks
+ 1,231 intentionally guard-suppressed callbacks
= 3,410 delivered callbacks
```

Helper-side delivered-callback drops/rejections were zero. Incomplete or
invalid delivered callbacks were zero, as were status/pixel/protocol
publication failures, full-display payloads, and wrong-destination
publications. The request was 30 fps; `25.265 fps` is the observed valid
publication rate and therefore source under-delivery relative to that requested
upper target. ScreenCaptureKit does not expose the count of callbacks or frames
it never delivered, so that upstream count is unknown, not zero.

The 15-fps run observed 14.290 complete frames/s and recorded 382 FRAMEs plus
one CLEAR with zero rejected/format/pixel/protocol errors. Its post-warmup
callback interval p50/p95/max was `69.990500/70.678750/71.769416` ms;
accepted-sample total was `1.174000/1.589583/2.490625` ms; copy path was
`0.171750/0.218583/0.307375` ms. The maintainer confirmed responsive output and
clean semantic fallback at both rates.

## Stalled-reader bounded-failure distribution

The amended client changes the connected socket to nonblocking mode after the
normal loopback connect and gives each complete HELLO, FRAME, or CLEAR one
fixed 250 ms monotonic deadline. `EINTR` is retryable only while that deadline
remains valid. `EAGAIN`/`EWOULDBLOCK` waits with `poll(POLLOUT)` only for the
remaining time. Expiration is a protocol failure that closes the socket and
zeros the capability and reusable header storage. No retry queue, callback
queue, worker, or frame slot was added.

A temporary exact-production-source harness used a loopback server that read
the complete authenticated HELLO and then stopped reading. One reusable
`960x160` frame payload was sent repeatedly until kernel backpressure applied.
Five warmups preceded 40 retained samples:

| Interval | Samples | p50 ms | p95 ms | Max ms |
| --- | ---: | ---: | ---: | ---: |
| First frame-send attempt -> bounded write failure and closed client | 40 | 251.261541 | 251.462791 | 251.868083 |
| Shutdown enqueued behind that send -> `close()` completed | 40 | 251.259250 | 251.460583 | 251.863417 |

Across all retained samples, the client was closed after failure, harness
timeouts and protocol-classification errors were zero, and zero or one complete
frames fit before backpressure. A subsequent send always returned `closed`.
The deterministic package test additionally measured idempotent `close()` after
failure below 50 ms. The harness reused one frame-sized array, introduced no
historical frame queue, and did not exercise the musical fixture.

Harness source/binary SHA-256 were
`e17ed88e8b19ead9202a76de0fcc4bd943e5bb4777893a2148174e317a980383`
and
`5c9831c3ef440379726a34e8104755c537f6ed538c16e92cb1ab7e3fcab5468b`.
The temporary files and capability were removed after measurement.

Twenty comparable resource samples measured mean helper CPU 4.325%. RSS was
39,008 KiB at start, end, minimum, and peak. Seven helper process threads were
observed; exactly one serial application output queue was project-owned. There
was no application frame queue, one reusable 358,400-byte output buffer, and
ScreenCaptureKit queue depth was two. The constant RSS and supersession through
the serial current-sample path show no observed backlog or unbounded growth in
this interval.

## Observable behavior

At 15 and 30 fps, the maintainer observed no control lag, abnormal display lag,
audio xrun/dropout, tearing, partial frame, or stale crop. Focus-invalid samples
were suppressed rather than queued. On resume, current frames appeared without
catch-up replay. Stopping the helper superseded the crop with current semantics.

## Exact result

Both the retained full 30-fps series and the focused amended-head corroboration
exceeded 1,000 post-warmup frames and passed both processing targets. Memory
was flat across the original comparable samples, output storage and queue
topology stayed fixed, and neither the accepted 15/30-fps fixture runs nor the
focused amended run showed a visible capture regression.

## Commands and tools

The helper's fixed aggregate metrics, `ps` CPU/RSS/thread snapshots, process and
socket readback, exact counters, generated-pixel checks, and physical Push
observation supplied these results. Aggregate output was narrowed and
sanitized; no raw frame or full log is committed.

## What this proves

- On the accepted fixture, project-visible capture processing stays within the
  required p95 bands with fixed memory, one reusable output buffer, one serial
  output path, and no historical application queue.
- A receiver that authenticates and then stops consuming cannot hold that
  serial path indefinitely; the fixed 250 ms message deadline closes the
  client and releases queued shutdown work within the retained bound.
- Live 15/30-fps operation preserves controls, display responsiveness, and
  audio.

## What this does not prove

- Requested fps is an upper target, not a guaranteed delivery rate; observed
  30-fps valid publication was 25.265 fps. ScreenCaptureKit's never-delivered
  callback/frame count is not exposed and remains unknown.
- This is not an endurance, energy, thermal, hard-real-time, or all-Mac profile.
- Public display-time samples do not isolate Apple's complete internal
  crop/scale cost, and setup timing is a one-shot rather than a distribution.
