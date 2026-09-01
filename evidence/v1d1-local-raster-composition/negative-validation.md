# V1D-1 negative validation and write-ownership proof

## Date, machine state, and authority

- Evidence date: 2026-09-01 PDT.
- Machine state: isolated Java 21 harness against the exact clean source-head artifact; no Bitwig or Push was required for destructive negative cases.
- Central basis/tree: `c94d1b74d702e696d6cc4cc89625f1a2f7a95530` / `8539026fc9476bbf2df34b310190a57906113b90`.
- DrivenByMoss basis/tree: `852b520933eed87fbe496a04b5c18819a10b3564` / `d03a372e2efcf41b22cef46501e08efbfb0c0036`.
- Source PR/head/tree: [kasselvania/DrivenByMoss#4](https://github.com/kasselvania/DrivenByMoss/pull/4), `3c3ca02ff81ab5ce110ae3d714e20b5fca05a03f`, tree `c4e42825d069421a44b3241349de9a7c6453a3ad`.

## Destination-support matrix

One fully supported destination was accepted and cached one view. Fourteen unsupported constructions were retained:

1. wrong bitmap format;
2. zero width;
3. size-arithmetic overflow;
4. short `MemoryBlock.size()`;
5. short buffer limit;
6. short buffer capacity;
7. read-only buffer;
8. heap/non-direct buffer;
9. nonzero initial position;
10. unexpected byte order;
11. null view;
12. `createByteBuffer()` `RuntimeException`;
13. null memory block;
14. null bitmap.

Result:

```text
DESTINATION accepted=1 rejected=14 escapedRuntimeExceptions=0
ordinary display-window/render/encode methods remained available
```

## Request-negative matrix

The harness exercised 27 metadata/content/destination negatives plus one wrong-thread negative:

- null source and null format;
- negative X/Y and `Integer.MAX_VALUE` X/Y;
- zero/negative width and height;
- width×4 overflow, right overflow, and bottom overflow;
- wholly outside destination, right-edge exceed, and bottom-edge exceed;
- short, negative, and overflow-stressing source stride;
- negative offset, offset arithmetic overflow, and offset past source;
- one-byte-short, one-row-short, and empty sources;
- non-opaque alpha;
- unsupported destination;
- wrong owner thread after a successful bind.

Every case returned false or the defined unsupported outcome, no exception escaped, and destination comparisons found:

```text
NEGATIVE cases=28
changedBytes=0
changedRows=0
invalidAccepts=0
escapedExceptions=0
unsupportedEnumRepresentable=false
```

The enum has one accepted constant; Java cannot construct an arbitrary unsupported enum value without leaving ordinary language semantics. Null format covers the rejected non-accepted format input.

## Validation and alpha ordering

Source/bytecode inspection and before/after destination comparison establish that:

- bounds/overflow/source-shape validation occurs before any write;
- wrong-thread rejection occurs before alpha scan/write;
- complete alpha scanning occurs before ownership binding and before any write;
- invalid calls cannot bind the owner;
- row copying begins only after every request-wide rejection condition has passed.

The MALFORMED production lifecycle state supplies destination X=-1. It calls the writer once, requires `false`, and throws only if a broken adapter incorrectly accepts the malformed request. Harness and live observation both recorded zero malformed output and zero invalid acceptance.

## Thread ownership and race behavior

The dedicated thread test proved:

```text
malformedDidNotBind=true
sameThreadSecondWrite=true
wrongThreadRejected=true
simultaneousFirstWriters=1
```

Two simultaneous first-valid callers were released from the same latch. Exactly one bound and wrote; the other returned false. The losing caller did not mutate destination bytes. No queue, worker, executor, lock object, or thread is created by production code; the synchronized helper only arbitrates owner binding among caller threads.

## Commands and tools

The proof used final harness source SHA-256 `724095ad2ee2c0273164dada172dabfb63161230df0826269f09aaa5d2305038`, exact artifact SHA-256 `476a57a3733cd350bd068de44a5a1019df5e198c49572d1f633e43e006ae2877`, Java 21, fake API-21 bitmap/memory implementations, direct buffer snapshots, `CountDownLatch`, SHA-256, `javap -c -p`, and source inspection. The harness exited zero after 592,712 assertions. A pre-final summary string had hard-coded `rejected=13` despite 14 executed calls; it was replaced by a dynamic counter and the complete harness was rerun before retaining these results. Production source and artifact were unchanged.

## What this proves

- Unsupported destinations fail closed without breaking ordinary bitmap methods.
- Every exercised malformed request leaves every destination byte unchanged.
- Non-opaque source content is rejected before mutation.
- First-valid thread binding is race-safe and enforces one synchronous producer thread.
- The production malformed lifecycle cannot display a partial rejected pattern on the tested adapter.

## What this does not prove

- It does not test malicious JVM instrumentation, reflection-created enum instances, or host memory invalidation after construction.
- It does not make a multi-writer design safe or desirable; wrong-thread calls are deliberately rejected.
- Negative harness results do not replace the separate real-Bitwig destination characterization.
