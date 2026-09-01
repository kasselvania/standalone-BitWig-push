# Alternative-candidate disposition

## Evidence identity

- Date: 2026-09-01 PDT.
- Machine state: accepted arm64 macOS + Bitwig Studio 6.1 + DrivenByMoss 26.4.1 + Push 3 fixture.
- Central basis: `a66e1e45ebb2cb72f8ea1cb12e96d1bc46d7c343`, tree `b83e9e9507dc2e26d551abed1f03c30a6b76a551`.
- DrivenByMoss basis: `852b520933eed87fbe496a04b5c18819a10b3564`, tree `d03a372e2efcf41b22cef46501e08efbfb0c0036`.
- Selected Candidate A identity: local research commit `61c659e19faad3944f610022fca5d57f09e7b442`, tree `6d06def69677918e871bb5a0c978be83aab29cb8`; harness SHA-256 `7be829d7e302b00226f6fabf005e2a423b91132d6eebdae980acbc57657b6ee7`; observation patch SHA-256 `2cba0fbffabeb6e7609f6c5ffbdb433e1e9bfa90d9f1e5414f84843a8c4b7e96`.

## Ordered stopping-rule result

Candidate A passed every required pixel, restoration, validation, abstraction, thread, allocation, performance, real-fixture, shutdown, and rollback gate. Evaluation therefore stopped exactly as required.

## Candidate B — reusable source bitmap plus blit

**NOT REACHED.**

API inspection did establish that Bitwig `Bitmap extends Image` and `GraphicsOutput.drawImage(Image,...)` exists, while the current project wrapper casts `IImage` to `ImageImpl`. Candidate B remains a bounded fallback if direct backing-memory access ceases to be available on a future host.

It was not prototyped because it would add a second bitmap, a wrapper change, source-bitmap size/lifetime policy, and new filtering/premultiplication/exact-blit proof without solving a remaining Candidate A gap.

This is not a claim that Candidate B is impossible or broken.

## Candidate C — encode-time composition above transport

**NOT REACHED.**

Candidate C would require an additional bounded output representation and copy/lifetime rules above `PushUsbDisplay`. Candidate A already writes exact pixels into the current semantic bitmap before the unchanged encode/send path, so encode-time composition would add ownership and copying complexity without a missing capability.

This is not a claim that Candidate C is impossible. It remains the last bounded fallback only if both direct write and reusable bitmap blit become unavailable.

## Commands and tools

Disposition is based on exact API 21 `javap`, accepted wrapper/source inspection, Candidate A source/bytecode/build comparison, external correctness and validation harnesses, post-warmup timing/allocation measurement, real Bitwig memory/coherence observation, all 34 physical fixture results, and exact official rollback.

## What this proves

The ordered research stopped at the first decisive winner and did not create unnecessary prototype surfaces.

## What this does not prove

Candidates B and C were not implemented or benchmarked. No relative performance or pixel-exactness claim is made for either.
