# Fail-closed negative validation

## Evidence identity

- Date: 2026-09-01 PDT.
- Machine state: accepted arm64 macOS + Bitwig Studio 6.1 + DrivenByMoss 26.4.1 + Push 3 fixture.
- Central basis: `a66e1e45ebb2cb72f8ea1cb12e96d1bc46d7c343`, tree `b83e9e9507dc2e26d551abed1f03c30a6b76a551`.
- DrivenByMoss basis: `852b520933eed87fbe496a04b5c18819a10b3564`, tree `d03a372e2efcf41b22cef46501e08efbfb0c0036`.
- Candidate A: local commit `61c659e19faad3944f610022fca5d57f09e7b442`, tree `6d06def69677918e871bb5a0c978be83aab29cb8`.
- Harness source SHA-256: `7be829d7e302b00226f6fabf005e2a423b91132d6eebdae980acbc57657b6ee7`.
- Observation patch SHA-256: `2cba0fbffabeb6e7609f6c5ffbdb433e1e9bfa90d9f1e5414f84843a8c4b7e96`.

## Validation and application order

The candidate performs no destination write until all of the following are known valid:

1. Destination bitmap is `ARGB32`, positive-sized, exactly four bytes per pixel, writable, and has the expected complete capacity/limit.
2. Format is exactly `OPAQUE_BGRA8888` and source is non-null.
3. Width/height are positive; destination x/y and source offset are nonnegative.
4. Destination right/bottom, row-byte count, required source end, and required destination end are computed with `long` arithmetic.
5. Destination extents fit the actual bitmap.
6. Source stride is at least `width * 4` and every required source row fits the array.
7. Destination offsets fit the validated memory size/view limit.
8. Every source pixel alpha byte is `0xFF`.
9. The call is on the bound display/composition thread.
10. The pipeline has already classified the current local raster as valid. NONE, STALE, and INVALID never call the writer.

Only then does the method issue absolute bulk row copies. Primitive metadata is passed by value, so it cannot change between validation and application. The caller's source-array content is under an explicit exclusive-ownership-until-return rule.

## Twenty-five-case harness matrix

Every case below returned rejection or construction-invalid state without changing any destination byte and without leaking an exception into the display loop:

| # | Case | Result |
|---:|---|---|
| 1 | null/inaccessible source | rejected, unchanged |
| 2 | unsupported/unknown pixel format | rejected, unchanged |
| 3 | negative destination x | rejected, unchanged |
| 4 | negative destination y | rejected, unchanged |
| 5 | x near `Integer.MAX_VALUE` | rejected, unchanged |
| 6 | y near `Integer.MAX_VALUE` | rejected, unchanged |
| 7 | zero width | rejected, unchanged |
| 8 | zero height | rejected, unchanged |
| 9 | negative width | rejected, unchanged |
| 10 | negative height | rejected, unchanged |
| 11 | `width * 4` overflow | rejected, unchanged |
| 12 | destination right-edge overflow/out of bounds | rejected, unchanged |
| 13 | destination bottom-edge overflow/out of bounds | rejected, unchanged |
| 14 | destination wholly outside 960x160 | rejected, unchanged |
| 15 | stride below `width * 4` | rejected, unchanged |
| 16 | stride/height arithmetic overflow | rejected, unchanged |
| 17 | negative source offset | rejected, unchanged |
| 18 | source offset/end overflow | rejected, unchanged |
| 19 | source exactly one byte short | rejected, unchanged |
| 20 | source one complete row short | rejected, unchanged |
| 21 | one non-opaque alpha byte | rejected before first write |
| 22 | destination memory/capacity too short | writer construction invalid; unchanged |
| 23 | read-only destination view | writer construction invalid; unchanged |
| 24 | destination bitmap format not `ARGB32` | writer construction invalid; unchanged |
| 25 | valid request from a different thread after binding | rejected, unchanged |

Aggregate result:

```text
negative cases: 25
invalid accepts: 0
exceptions escaping display path: 0
partial invalid writes: 0
semantic fallback mismatches: 0
```

The real observation pipeline also inserted malformed destination-x and over-height intervals. Across 1,920 sends it reported `malformedMismatches=0` and `invalidWriteAcceptances=0`, and the maintainer observed no partial invalid pattern.

## Carrier-specific cases

The selected `byte[]` contract has no source position/limit; those mutable cursor cases are not representable. Primitive metadata also has no mutation window. A separate read-only `ByteBuffer` comparison proved absolute operations can preserve position/limit, but that carrier was not selected because it adds mutable view metadata or a duplicate-view allocation requirement without helping V1D-1's local generated source.

The source bytes themselves remain mutable Java memory. The contract therefore requires exclusive source ownership until synchronous return. External/shared-memory producer concurrency is deliberately deferred to V1D-2 rather than falsely hidden inside this sink.

## Fallback rule

For absent, stale, invalid, unsupported, malformed, short, overflowed, wrong-thread, or unsupported-destination input:

```text
newest current-semantic redraw
        -> no raster write
        -> same semantic IBitmap
        -> unchanged PushUsbDisplay
```

No old raster, previous composed output, region snapshot, or transport byte store is consulted.

## Commands and tools

Used the external Java 21 harness against the frozen candidate class, fake writable/read-only/short/wrong-format memory targets, a second Java thread, full-frame before/after SHA-256 comparisons, `javap -c -p`, and temporary real-Bitwig malformed intervals.

## What this proves

The candidate's bounded rejection behavior is all-or-nothing for the tested metadata, format, alpha, capacity, and thread matrix, and invalid states preserve exact fresh semantics.

## What this does not prove

It does not provide cross-process producer custody, prevent a caller that violates exclusive array ownership from racing source contents, or define V1D-2 sequence/freshness behavior.
