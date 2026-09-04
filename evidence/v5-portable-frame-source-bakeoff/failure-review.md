# V5 portable frame-source bakeoff — failure review

## Verdict

**V5 failed. No source substrate or portable frame architecture was selected. Draft PR #52 must not merge.**

This is a technical-lead/process failure record, not an implementation acceptance document.

## Exact preserved snapshot

```text
central basis/parent: af6032f0467fe6e223431db2a1c4a360eaa2df21
basis tree:          347cd427b0cec3e20fcfac4a9c9486730a791cb7
WIP head:            59ddea5856eb598530d22b3239dbf39d46bfd93e
WIP tree:            5bfb953df0f4906211734821a5f82d8769e06690
branch:               capture/v5-portable-frame-source-bakeoff
PR:                   #52, draft, unmerged
scope:                16 paths under capture/**
DrivenByMoss changes: none
```

Reported component checks at the snapshot were 18/18 portable-core tests and 38/38 macOS helper tests. Those results do not establish the missing vertical product path.

## Intended result

V5 was supposed to compare materially distinct Mac frame-source/media paths and either select one that preserved ordinary Bitwig use, reached the physical Push, and had a real future Linux path, or return an honest no-winner result.

## Actual implementation

The WIP branch added:

- a C++17/C-ABI raw-frame descriptor, metadata gates, crop/scale, and opaque-BGRA conversion;
- an opt-in AVFoundation backend using `AVCaptureScreenInput`;
- full-display acquisition followed by a fixed normalized crop and frontmost-Bitwig publication guard;
- generated quadrant, protocol-sink, and resource probes.

ScreenCaptureKit remained the default helper backend. No DrivenByMoss source changed.

## Product blocker encountered

The existing external receiver is not an independent always-running Pushwig service. It is constructed inside DrivenByMoss only when startup properties enable the external raster pipeline.

The stopped physical session found two different states:

```text
controlled direct executable launch + JVM properties
    -> expected activation inputs
    -> Bitwig did not become a reliably ordinary visible/usable session

ordinary visible Bitwig launch
    -> usable application session
    -> no external-raster startup properties
    -> no V1D-2 receiver/listener
```

The final helper never published the candidate source to Push. There was no proven state containing both an ordinary usable Bitwig session and an active V1D-2 receiver. The exact cause of the direct-launch/window behavior was not diagnosed and is not inferred here.

## Architectural root cause

The project conflated two boundaries:

- **proven:** V1D-2 authentication, complete-message validation, fixed latest-frame publication, nonblocking display adoption, raster composition, fallback, and one USB writer once active;
- **unproven:** ordinary Bitwig enablement, receiver construction, producer rendezvous, capability lifecycle, shutdown cleanup, and user-facing activation.

The slice authority froze all DrivenByMoss changes instead of freezing the proven data-plane invariants. It then demanded ordinary launch and physical acceptance through the unfinished control plane. That was contradictory.

## Implementation-shape problems

### Whole-display crop is not attached source identity

`AVCaptureScreenInput(displayID:)` acquires a physical monitor. A normalized crop plus a frontmost-app guard does not identify a Bitwig window, device, or logical surface. It remains vulnerable to movement, resize, reflow, unrelated-window contamination, and physical desktop geometry.

It may be useful as a diagnostic source or an explicitly dedicated/managed-display mode. It is not accepted as the attached product winner.

### Portability was extracted after Apple acquisition

The C++ layer begins after AVFoundation has already produced an Apple-specific display frame. It moves crop/scale/format work that the project had substantially proven. It does not solve portable acquisition.

A descriptor Boolean such as `linux_path_available` does not demonstrate a Linux backend. Descriptor/generation/latest metadata tests do not establish a production frame handoff when the real latest-frame owner remains V1D-2.

### Tests proved components, not the product claim

The green suites exercised pixel arithmetic, metadata gates, configuration, and helper-local behavior. They could pass while no Bitwig receiver existed. The missing construction/activation dependency should have been Gate 0/1, before candidate code.

## Technical-lead/process failure

The failed prompt combined:

- broad ecosystem/backend research;
- common abstraction design;
- candidate implementation;
- generated tests and performance probes;
- ordinary Bitwig testing;
- V1D-2 integration;
- physical Push acceptance;
- rollback.

It did not require a pre-code construction/ownership map or ordinary-launch generated-frame preflight. It made the easiest measurable work occur before the most important dependency.

The corrected rule is:

> Freeze proven invariants, not adjacent files. Trace process construction and ownership before implementation. Make the first unproven cross-component dependency the first acceptance gate.

## Retained value and nonselection

Potentially useful generated fixtures/probes may be reconsidered individually in future work. No file or layer from PR #52 is approved for cherry-pick at this time.

V5 did not select:

- AVFoundation display capture;
- ScreenCaptureKit as an attached primary-window source;
- the C++ `capture/common` frame model;
- FFmpeg, GStreamer, OBS, WebRTC, Sunshine, Weylus, or another framework;
- a Linux path.

## Fixture state at stop

At the PR #52 snapshot:

- the derivative remained the sole scanned DrivenByMoss artifact;
- an untouched official artifact backup was reported outside scan paths at SHA-256 `98dc3195ad8d911526e18b1005f09f69a1aedcb965b080565474104654345c5a`;
- Bitwig might still have been running from the controlled launch;
- a temporary private capability file remained;
- rollback and cleanup were explicitly not claimed.

V5A Gate 0 owns recovery. This document must not be amended later to imply that rollback had already occurred at the stop snapshot.

## Disposition

- preserve exact WIP history in closed draft PR #52;
- close issue #50 as failed/superseded rather than completed;
- do not merge or repair the WIP branch;
- execute V5A / issue #53 beginning with fixture recovery and a read-only DrivenByMoss lifecycle decision;
- permit source selection only after ordinary-launch ingress activation passes.
