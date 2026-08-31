# Alternative candidate disposition

## Date, machine state, and authorities

- Evidence date: 2026-08-31 PDT.
- Machine state: accepted macOS 26.4.1 arm64 fixture; Candidate A completed offline and real-hardware gates before later candidates were reached.
- Central basis: `24431c70eb720235b9c7836d9b2842a798d81d54`, tree `bb72673d2b3ce01ed6525a6ab7f2096dde1ac7bf`.
- DrivenByMoss basis: `1ae0b74f383314d170a5960ca763bdf9c319e787`, tree `a81e5c4330b31f36845c25e98e322990d62f0c67`.
- Selected local Candidate A commit/tree: `3e8df95e9cc489e69da72b9acb82f2d06c90dd00` / `f448eeda923232346037074a75b71c485e56ebe8`.
- Harness source SHA-256: `4dc4ea733ba7b46e3dc9db542cfe0567e7c6059ab6d042260e9956535a4e382c`.

## Required ordered stopping rule

The execution contract required candidates in this order and required work to stop when one candidate satisfied every acceptance criterion strongly enough to authorize V1C:

1. retained semantic redraw;
2. pristine semantic plus reusable final bitmap;
3. generation-aware region restore;
4. narrow backend memory copy.

Candidate A produced zero preservation/restoration mismatches, green timing, bounded ownership, unchanged `PushUsbDisplay`, full real-fixture acceptance, and exact rollback. Continuing to implement B, C, or D would have violated the stop-on-decisive-winner rule and widened a research slice without a blocker.

## Candidate B — NOT REACHED

Candidate B was not implemented or built.

Source/API inspection established that Bitwig API 21 declares `Bitmap extends Image` and `GraphicsOutput.drawImage(Image, ...)`. It also established that the current project wrapper `GraphicsContextImpl.drawImage(IImage, ...)` casts only to `ImageImpl`; project `IBitmap` is not drawable through that wrapper.

Candidate B would therefore require:

- one second 960x160 bitmap with explicit lifetime;
- a new internal wrapper/blit capability;
- proof that host drawing introduces no scaling, filtering, color conversion, or unexpected allocation;
- a full-frame copy on every eligible output.

Those are solvable research questions, not current blockers. They are rejected for V1C because Candidate A achieved exact restoration without a second bitmap, wrapper change, or copy.

## Candidate C — NOT REACHED

Candidate C was not implemented or built.

A region snapshot is safe only when tied to explicit semantic-generation ownership. It must refresh after every semantic update and correctly handle old/new overlap before restoration. Candidate A eliminates this historical state entirely by redrawing current semantics, so Candidate C would introduce generation tracking, snapshot storage, and stale-snapshot failure modes without a demonstrated need.

It is rejected for V1C because it is more stateful and less direct than the selected exact current-semantic redraw.

## Candidate D — NOT REACHED

Candidate D was not implemented or built.

`BitmapImpl.encode` proves readable access to the Bitwig bitmap memory, and API 21 exposes `MemoryBlock.createByteBuffer()`. A write/copy backend would still need explicit writable semantics, pixel format, stride, bounds, lifetime, and host-neutral containment. It would also move restoration toward backend memory ownership even though Candidate A succeeds at the semantic layer.

It is rejected for V1C because no missing higher-level capability remains to justify raw memory-copy complexity.

## Commands and tools

Disposition used direct accepted-source inspection, Java 21 `javap` of the resolved API JAR, Candidate A's raster harness, exact base/head build and payload comparison, real-Bitwig aggregate measurement, and the real Push fixture. No B/C/D source worktree, patch, commit, artifact, or hardware run exists.

## What this proves

- Later candidates were omitted because of an explicit successful gate, not because they were forgotten or silently assumed impossible.
- Candidate A is the smallest selected ownership model among the ordered choices.
- No unnecessary second bitmap, snapshot generation, raw buffer contract, or transport change entered V1C-0.

## What this does not prove

- It does not prove B, C, or D could never work.
- It does not provide B/C/D performance or pixel numbers because the contract prohibited unnecessary continuation after A passed.
- B remains a bounded fallback research direction only if a future authority update demonstrates a Candidate A limitation.
