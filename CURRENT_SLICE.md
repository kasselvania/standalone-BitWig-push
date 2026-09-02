# Current Work — V3 Adaptive Bitwig window-relative visual lens

## Status

**ACTIVE**

Owning issue: [#45 — V3: Adaptive Bitwig window-relative visual lens](https://github.com/kasselvania/standalone-BitWig-push/issues/45)

Durable design: [`docs/design/window-relative-visual-lens.md`](docs/design/window-relative-visual-lens.md)

Implementation basis:

```text
commit: 349634919236cb361d274903ce22559b10a7812c
tree:   a7a730cbf84eaecf6fe982aba10d12f8a7bf28ba
```

V2 is accepted and merged. The repository-entry cleanup is complete enough to resume product development; branch-ref/worktree housekeeping tracked by #41 must not widen or block V3.

## Goal

Remove V2's fixed physical-display coordinate from normal use.

```text
unique Bitwig main window
        -> explicit visual profile
        -> crop relative to current Bitwig window content
        -> aspect-preserving capture
        -> accepted external frame ingress
        -> live visual on Push
```

A working profile should survive moving, supported resizing, closing, and reopening the Bitwig main window without asking the user to recalculate desktop coordinates.

## Product shape

V3 is one coherent user-visible milestone, not a sequence of micro-slices.

The expected user path is approximately:

```text
PushwigCaptureHelper \
  --profile /path/to/profile.json \
  --port 45291 \
  --token-file /path/to/private-token
```

The profile describes the Bitwig window selector, normalized visual crop, Push destination, frame rate, and aspect policy. Port/token/session state remains runtime plumbing.

The existing V2 explicit-display mode should remain available as a diagnostic/reference path unless a concrete implementation conflict requires changing it.

## Implementation scope

Primary production work stays under `capture/macos/**` and may add:

- profile decoding/validation;
- bounded Bitwig main-window discovery;
- desktop-independent ScreenCaptureKit window capture;
- window-generation lifecycle;
- resize/recreation crop recomputation;
- concise window inventory/discovery support;
- committed deterministic regression tests;
- one example profile.

No DrivenByMoss source change is expected or authorized by default.

## PR shape

Use one temporary implementation branch:

```text
capture/v3-window-relative-lens
```

Open one ordinary PR:

```text
V3: add adaptive Bitwig window-relative visual lens
```

The PR may contain production source, committed tests, the example profile, necessary contributor docs, and concise V3 real-fixture evidence. Do **not** create a separate evidence branch/PR unless review uncovers a concrete reason to separate it.

## Acceptance

V3 is complete when one maintained profile on the accepted macOS fixture:

- selects exactly one intended Bitwig main window or abstains;
- displays useful live Bitwig pixels on the real Push;
- survives moving the Bitwig window;
- recomputes correctly after supported resize;
- falls back to current semantics when the window disappears or becomes ambiguous;
- reacquires after window recreation without old-generation pixels escaping;
- preserves aspect and destination bounds;
- keeps helper processing comfortably within visual cadence;
- preserves normal Push controls, audio, and headphone output;
- covers deterministic profile/selection/geometry/lifecycle logic with committed Swift tests.

## Explicit non-goals

V3 does not need to:

- recognize Sampler or arbitrary devices automatically;
- add semantic pixel anchors;
- solve general plug-in-window identity;
- add Linux capture;
- create a third-party visual-adapter SDK;
- change the external raster protocol or raster sink;
- automate mouse/keyboard interaction;
- change the one-writer Push display ownership model.

## Stable boundaries

- DrivenByMoss remains semantic/controller authority and sole Push display transport owner.
- The helper owns macOS discovery/capture only.
- Visual failure returns to current semantic output.
- Wrong or ambiguous source selection must abstain.
- Global desktop x/y is not visual-profile identity.
- Stable deterministic behavior should be committed tests; real fixture evidence should stay concise.
