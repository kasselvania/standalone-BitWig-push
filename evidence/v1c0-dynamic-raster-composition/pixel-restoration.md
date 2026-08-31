# Pixel restoration evidence

## Date, machine state, and identities

- Evidence date: 2026-08-31 PDT.
- Machine state: accepted macOS 26.4.1 arm64 fixture; exact 960x160 Push frame; BGRA8888 observation layout; no frame or screenshot retained.
- Central basis: `24431c70eb720235b9c7836d9b2842a798d81d54`, tree `bb72673d2b3ce01ed6525a6ab7f2096dde1ac7bf`.
- DrivenByMoss basis: `1ae0b74f383314d170a5960ca763bdf9c319e787`, tree `a81e5c4330b31f36845c25e98e322990d62f0c67`.
- Candidate commit/tree: `3e8df95e9cc489e69da72b9acb82f2d06c90dd00` / `f448eeda923232346037074a75b71c485e56ebe8`.
- Clean candidate artifact SHA-256: `22b37222aa9242f822c4717168ecde0d66cab10488caaabec9fe481cffba4c72`.
- External harness source SHA-256: `4dc4ea733ba7b46e3dc9db542cfe0567e7c6059ab6d042260e9956535a4e382c`.
- Final aggregate-only observation diff SHA-256: `3ad3e472cfdce65c6af59e941e5b090a960acf3b7395c03b567427dfb1f3d1a4`.
- Temporary observation source SHA-256: `4d6a88192538c6ac9c998e53855a37ef84cd0e460256490800c5478d1a100c16`.
- Temporary observation artifact: 14,375,111 bytes, SHA-256 `d06c316588a839d221e0bb9fa026f32a3f1abb0b3ad1be8ef7dd174971ebb0e4`.

The temporary observation source was outside the candidate commit, was never pushed, was removed after use, and its worktree returned clean.

## Visual sequence and comparison regions

The deterministic sequence was:

```text
A at R1 [16,4,64,16]
B at R2 [304,32,64,16]
C at R3 [560,112,64,16]
D at R4 [880,72,64,16]
none
stale -> semantic-only
invalid -> semantic-only
```

Each visual was an opaque 64x16 outer rectangle with a 56x8 white inner rectangle. The four outer colors were red, orange, green, and blue.

For each output the comparison tracked:

- current semantic reference;
- final output;
- current visual region;
- prior visual region;
- current/next semantic generation where applicable;
- full-frame and masked SHA-256 values;
- pixel mismatch counts inside, outside, and under previous coverage.

## Deterministic external harness

The Java 21 harness used an exact 960x160, four-byte BGRA8888 raster bitmap and the real candidate `AbstractGraphicDisplay`/pipeline classes. It ran 1,000 complete cycles, or 7,000 A/B/C/D/none/stale/invalid transitions. At cycle 500 it changed the semantic generation while continuing the visual lifecycle.

Exact result:

| Metric | Count |
| --- | ---: |
| Current target-region mismatches | 4,096,000 |
| Outside-current-region mismatches | 0 |
| Old-region restoration mismatches | 0 |
| Post-none full-frame mismatches | 0 |
| Stale full-frame mismatches | 0 |
| Invalid full-frame mismatches | 0 |
| Semantic-update-under-overlay mismatches | 0 |

The positive target count proves that current visuals changed target pixels. Every required non-target/restoration count is zero.

Representative generation-2 hashes:

| State | Full output SHA-256 | Target SHA-256 | Outside SHA-256 |
| --- | --- | --- | --- |
| A / R1 | `03c3821f4bc8fa9df110c6e2f341f5cab0e929bbff51d82690f19f50689e2641` | `48cbca933df85241218b93dcd207e0247fec19a40f3fd387f9158cff61fa3c0b` | `352a9b99a7d37f8505734f37fa28012bbddf9a8bc3a19528262167fd6a5aa591` |
| B / R2 | `d6d25107aab89840301e58d09451c080b3b6d5f2bbea8056d194078f1ee4c8b3` | `53793af103f0b068b2d97c6c24daa5ab71c92bc9e07939f819d40cd1263f4520` | `d651394e0a429fe6cc73e0540349abc0d99a8ba32dd927d95c6b07a325fed522` |
| C / R3 | `cab31578eaacd4b2dc5d1eda032f68e4849400ce79dc8dea9b8199a98a62bbfb` | `9f4d7e60c0e6ad6c940616a5d24e26253e3198b2764e14051d0f6d2185e6fdca` | `a4d70ae6e54fdb172b4669271a745d82bb05a06bebc69283c5f40c578a58af84` |
| D / R4 | `1c58794dc0b40d98ee911518bc86cb7026f81ebc29f3e4235052b6c34b167e63` | `a5dd29d703257825fa4b52b1dfa75f02498f69bcbdd63b5a1fb280cca6149e04` | `d8536a04826a98cee83d19c820cc25eb1b43798977cde22ba5bc9ef791749a49` |

Generation-2 semantic reference SHA-256 was `42c8bb5aa2d5d87f77846a6a3abe7a4d91a40d1b2691d12fd8a84d9149dce8f6`. The full outputs for none, stale, and invalid were each exactly that same hash.

## Real-Bitwig aggregate observation

The temporary observation build called `IBitmap.encode` immediately before and after the dynamic pipeline. It copied only into fixed in-process arrays, calculated aggregate hashes/counts, and emitted one summary after 100 warmup plus 1,000 measured sends. It wrote no frame, screenshot, crop, or raw pixel file.

The first live run produced every required zero restoration count but observed no semantic change under a covered region. That was treated as insufficient rather than softened into a pass.

For the accepted rerun, two visible Bitwig tracks were alternated repeatedly across covered intervals. Exact accepted result:

| Metric | Result |
| --- | ---: |
| Samples | 1,000 |
| Target mismatches | 628,992 |
| Outside mismatches | 0 |
| Old-region restoration mismatches | 0 |
| Post-none full-frame mismatches | 0 |
| Stale full-frame mismatches | 0 |
| Invalid full-frame mismatches | 0 |
| Semantic updates while covered | 2 |
| Semantic-update restoration mismatches | 0 |

Representative live hashes:

```text
semantic: be0488d4910eb3695fe7f860e64d05fccdd83f9620887f330187b26e872d6fe0
output:   81aa58f35c78932409f1802b29baef5f7e864b8bc4d435398536237cc40b81c4
target:   53793af103f0b068b2d97c6c24daa5ab71c92bc9e07939f819d40cd1263f4520
outside:  2d986efdc8017369b3139eb7a5d317121a368844909d04b0f45ba4bf381b4c36
```

## Commands and tools

Tools included Java 21 compilation/execution of the external harness, the exact clean candidate artifact on its classpath, temporary `IBitmap.encode` observation, `MessageDigest` SHA-256, explicit pixel masks, fixed arrays, Maven, `shasum`, and local Bitwig track-selection actions. No proprietary image was persisted.

## What this proves

- Every final output is reconstructable from current semantics plus the current valid visual.
- Prior visual pixels never remain after movement, none, stale, or invalid states.
- A new semantic value that arrived while covered reappeared exactly after the visual moved.
- The selected mechanism does not require similarity thresholds, frame hashes as authority, or historical region snapshots.

## What this does not prove

- The representative hashes are evidence for this deterministic fixture state, not universal constants for all semantic screens.
- The aggregate observer used `encode` only for research; production V1C does not need before/after encoding.
- No external process, capture source, resize filter, or final V1D frame format was tested.
