# Lifecycle and pixel restoration

## Date, machine state, and authority

- Evidence date: 2026-09-01 PDT.
- Machine state: exact 960×160 BGRA8888 deterministic harness plus aggregate observation on Bitwig Studio 6.1 and the real Push 3 fixture.
- Actual central basis/tree: `4265dc7b6f1cabf2dcbad1b827d002bd9062cf4f` / `2af6b4757e5906ce74a3b52c5ee82323f5e32406`.
- DrivenByMoss basis/tree: `1ae0b74f383314d170a5960ca763bdf9c319e787` / `a81e5c4330b31f36845c25e98e322990d62f0c67`.
- Source PR/head/tree: [kasselvania/DrivenByMoss#3](https://github.com/kasselvania/DrivenByMoss/pull/3), `4b3326eddcf2d890de3baa10b93f6e80842d41e1`, tree `d03a372e2efcf41b22cef46501e08efbfb0c0036`.

## Exact bounded lifecycle

Each state lasts 64 eligible sends; one complete cycle is 448 sends:

| State | Outer bounds | Content | Semantic-only |
| --- | --- | --- | --- |
| A | x=16, y=4, w=64, h=16 | red outer, white inner | no |
| B | x=48, y=8, w=96, h=24 | orange outer, white inner | no |
| C | x=320, y=112, w=48, h=12 | green outer, white inner | no |
| D | x=808, y=64, w=136, h=28 | blue outer, white/yellow bars | no |
| NONE | none | no render callback | yes |
| STALE | none | no render callback | yes |
| INVALID | none | no render callback | yes |

The state counter is instance-local and bounded. The pipeline retains no bitmap, semantic snapshot, prior region, frame object, collection, byte array, queue, task, or future.

## External deterministic harness

- Harness location: temporary directory outside both repositories.
- Harness source SHA-256: `104588b6e634af85478b129b675a1d274f0e4d95c6e438f37524b466c79a4845`.
- Invocation environment: exact Java 21 against classes extracted from the exact proposed-head artifact.
- Frame: 960×160, four-byte BGRA8888 test representation.
- Run: 1,000 complete A/B/C/D/NONE/STALE/INVALID cycles, 7,003 observed transitions including setup/final state.
- Harness source and binary were not retained in either repository.

The harness proved:

```text
valid visual render calls per lifecycle: 4
semantic-only render calls:              0
same IBitmap reference:                  true
renderer identity reused:                true
positive target mismatches:              7,716,960
outside-current-region mismatches:       0
old-region restoration mismatches:       0
post-NONE full-frame mismatches:          0
STALE full-frame mismatches:              0
INVALID full-frame mismatches:            0
semantic updates while covered:          1
semantic-update restoration mismatches:  0
```

Second-generation semantic reference SHA-256:

```text
91813d9c966e6d97314d824382ea70e9b59d92504f73f68f8b3975ba1c50139e
```

Representative output/region hashes:

| State | Output SHA-256 | Target-region SHA-256 | Outside-region SHA-256 |
| --- | --- | --- | --- |
| A | `39c404863eb56ea5e5593b530f42d4badc1c5e38e15f80e7c0bdc86f7f351b25` | `761571d91e8172c957d37b31474b994096107fb60b3f18aeef9a10d46ef48ec1` | `79dd86e5aa3b3ed654d9efe593ff5f9561696f54b9f77111d988dc0a5d6b4a22` |
| B | `d48c3cc7646a83b935df228047f545fee1bcd85d1a5249b254ada17eb6cffdca` | `8a6b190e2093af0408bd0941507935b613d03a9b7b09fd6d24757bf90cab63c5` | `7f42bfabef6545d52a49a0b75cafdb6ef5ffe0ade7e04846c851f85ac6f065a3` |
| C | `8443d0fc3ee7ad2031cdb10321d4f8cec8373f83444561129c5ae7ec817a3c27` | `d289036d2d29ce2a5c83862b6f2fb166acad012a553ca437467ab26329a15ce7` | `c940827e434d100b298ae5be6a319b509c33c8d095962d8f13cc9a7d4f7386c3` |
| D | `21a6f82287f1f78e4f52294a1e8db077e0c2cbc657c8309790d526ebbfb84f3b` | `1be1e203fc7c1b1bfe6b18ce685563a21c97c6d207dc4660af282790e593ef4c` | `b600a2b7fd2b34935befacd8e1e2b995b2441bae42250c446e62a814c5e0b20d` |

NONE, STALE, and INVALID each matched the current semantic-frame hash exactly.

## Aggregate real-Bitwig bitmap observation

Temporary aggregate-only instrumentation was derived from the exact source head and removed completely afterward.

Final observation identities:

```text
temporary patch SHA-256:       f3f0889e7f31176c0535499d4a1a3da28bb6c751fe60fd1273281dfd0ad7e8d1
temporary observer source:      64f1f77b5d5940c7d8a65be058f1f11e1ed335621f820e5de270e5d9ce934726
temporary Push2Display source:   da42ffbdb348c6ef97a05addf3faa78b206e2cf9c3473cc907df99034d877045
temporary artifact SHA-256:     c9a409ec87fb73f8ed3b19d70485ebb8737b919d6f84fc842a9cf781bbc08b53
temporary artifact bytes:       14,375,323
```

It waited 60 seconds for startup settling, discarded 100 warmup frames, then measured 1,000 frames. It encoded only to fixed in-memory byte arrays and emitted one aggregate summary; no raw frame or screenshot was retained.

The first run established every restoration metric but recorded no semantic change because UI selections were issued too quickly. A second run with one-second-separated track selections was decisive:

```text
target mismatches:                       985,088
outside mismatches:                      0
old-region restoration mismatches:       0
post-NONE full-frame mismatches:          0
STALE full-frame mismatches:              0
INVALID full-frame mismatches:            0
semantic updates while covered:          1
semantic-update mismatches:               0
```

Representative hashes:

```text
semantic frame:  be0488d4910eb3695fe7f860e64d05fccdd83f9620887f330187b26e872d6fe0
composed output: 75226c541881415cf06638496c8ab97fa2b5d2568e116f877ce0fb0fb38d962a
target region:   48cbca933df85241218b93dcd207e0247fec19a40f3fd387f9158cff61fa3c0b
outside region:  c49e3f28f867bd314d7e593eee6b2f8fb95a13ccbff95bbe82cbf0b6862999a0
```

## Commands and tools

Tools included exact Java 21 compilation/execution, `shasum -a 256`, deterministic byte-array comparison, `IBitmap.encode` only in temporary observation code, fixed region masks, bounded counters, Bitwig's exact executable, and spaced track-selection changes in the local UI.

## What this proves

- Visual movement, enlargement, overlap, shrink, replacement, absence, stale fallback, and invalid fallback preserve every pixel outside the current visual.
- Old visual regions restore from current semantics, not from an earlier snapshot.
- A semantic update under coverage is restored exactly.
- The same results hold in both the deterministic exact-class harness and aggregate observation of Bitwig's real bitmap.

## What this does not prove

- The temporary BGRA8888 harness representation is not a future wire format.
- No raw proprietary frame was retained.
- This is not an external producer, capture, IPC, or cross-platform proof.
