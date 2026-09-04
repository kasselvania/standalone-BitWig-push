# V5 portable frame-source bakeoff — failed and superseded

## Status

**FAILED / NOT ACTIVE / NO IMPLEMENTATION SELECTED**

Owning historical issue: [#50](https://github.com/kasselvania/standalone-BitWig-push/issues/50)

Unmerged preservation snapshot: [draft PR #52](https://github.com/kasselvania/standalone-BitWig-push/pull/52)

Detailed review: [`../../evidence/v5-portable-frame-source-bakeoff/failure-review.md`](../../evidence/v5-portable-frame-source-bakeoff/failure-review.md)

Current corrective slice: [V5A / issue #53](https://github.com/kasselvania/standalone-BitWig-push/issues/53)

This document is historical context, not execution authority.

## Intended question

V5 attempted to find a product-usable macOS frame-source/media path with a concrete future Linux path after the tested ScreenCaptureKit primary-Bitwig-window stream proved unacceptable for ordinary attached use.

The useful research premise was:

```text
framework name
    != actual macOS acquisition backend
    != source type / operating mode
```

GStreamer, FFmpeg, OBS, WebRTC, Sunshine, RustDesk, Weylus, game-streaming projects, and other systems must be decomposed into acquisition API, source identity, frame ownership, processing, encoding/transport, client presentation, and returned input. A wrapper around the same platform source is not a new source.

## Why the slice failed

V5 treated V1D-2 as a fully product-operable service. In fact:

- the frame receiver/store/composition **data plane** was proven once active;
- receiver activation depended on JVM properties read during DrivenByMoss construction;
- the accepted fixture supplied those properties through a special Bitwig executable launch;
- an ordinary visible Bitwig launch did not have the properties/listener;
- the V5 authority simultaneously prohibited DrivenByMoss changes.

The final physical path therefore had no proven state containing both an ordinary usable Bitwig session and an active V1D-2 receiver.

This missing prerequisite should have been the first gate. Instead it was discovered after candidate implementation and component tests.

## What PR #52 contains

The draft snapshot contains:

- an AVFoundation `AVCaptureScreenInput` whole-display experiment;
- a fixed normalized display crop guarded by Bitwig being frontmost;
- a C++ crop/scale/pixel-format layer labeled as portable;
- generated quadrant/protocol probes and tests.

None is selected.

The AVFoundation path captures a physical display, not a logical Bitwig surface. A frontmost guard does not turn monitor pixels into source identity. It may remain diagnostic evidence or later serve an explicitly dedicated/managed display mode; it is not an accepted attached-mode source.

The C++ layer begins after Apple-specific acquisition and mostly moves already-proven pixel transformation. Its descriptor/generation/latest-frame scaffolding is not the production V1D-2 publication owner, and a `linux_path_available` flag is not proof of a Linux implementation.

## Findings worth retaining

- The tested ScreenCaptureKit primary-window operating mode remains disqualified by ordinary Bitwig control obstruction.
- Whole-display fixed crops are not attached-mode source identity.
- Performance cannot outrank usability or correct ownership.
- Cross-platform media plumbing does not guarantee a materially different macOS source.
- Portable extraction should follow one working real backend and ownership map, not precede them.
- Generated fixtures and deterministic pixel/protocol probes may be reconsidered individually; no block should be cherry-picked wholesale.

## Conditions for future source work

Source selection may resume only after V5A proves ordinary receiver activation and rendezvous. The next source slice must:

1. evaluate one materially distinct source class rather than an ecosystem catalogue;
2. identify the actual acquisition API and logical source identity before implementation;
3. reject physical-display crop as an attached-mode winner unless a dedicated/managed display is explicitly the product mode;
4. prove generated-source correctness, then ordinary Bitwig interaction, then one physical Push pass;
5. extract only common code exercised by the accepted production owner;
6. use a bounded change/test/physical-session budget and stop on the first failed product gate.

V5 did not select AVFoundation, C++, FFmpeg, GStreamer, or any other substrate.
