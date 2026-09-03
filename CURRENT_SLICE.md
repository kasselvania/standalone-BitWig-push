# Current Work — V4 Sampler device-page foundation

## Status

**ACTIVE**

Owning issue: [#49 — V4: Sampler device-page foundation](https://github.com/kasselvania/standalone-BitWig-push/issues/49)

Operating model: [`docs/design/device-aware-presentation-layer.md`](docs/design/device-aware-presentation-layer.md)

Device catalog: [`docs/design/native-device-behavior-matrix.md`](docs/design/native-device-behavior-matrix.md)

Implementation branches begin from the current accepted `origin/main` containing this V4 activation.

## Goal

Deliver the first useful device-aware Pushwig screen.

```text
DrivenByMoss Device mode
        + selected supported native Sampler
        + current valid Sampler visual
        -> intentional hybrid device page
        -> current encoder semantics + tightly bounded native pixels
        -> physical Push
```

Track, mixer, session, transport, performance and unsupported-device screens remain ordinary DrivenByMoss.

## Product result

For one explicitly supported Bitwig Studio 6.1 Sampler fixture:

- the native Sampler visual is tightly framed, centered and bottom-aligned;
- adjacent Bitwig panels and unexplained empty space are excluded;
- eight names/values reflect the current DrivenByMoss parameter bindings;
- touching one encoder visibly emphasizes its semantic slot;
- turning, Shift fine adjustment and Delete+touch reset retain their current behavior;
- leaving Device mode, selecting another device/page, losing the visual, or leaving the supported layout returns immediately to the ordinary DrivenByMoss screen.

V4 is a complete first screen, not a universal device resolver.

## Source ownership

V4 spans two existing owners and therefore uses two coordinated source PRs:

### `kasselvania/DrivenByMoss`

- context eligibility and generation fencing;
- current Sampler/device/page/encoder semantic state;
- custom semantic page composition;
- touched-encoder emphasis;
- raster gating to the eligible context;
- exact standard-page fallback;
- final Push display ownership.

### `kasselvania/standalone-BitWig-push`

- one fixture-verified tight Sampler visual profile;
- bounded supported-layout validation;
- macOS helper tests and concise product evidence;
- contributor-facing run instructions affected by the new experience.

Do not create separate evidence or authority PRs.

## Acceptance

V4 succeeds when:

1. ordinary non-device and unsupported-device screens remain unchanged;
2. the supported Sampler Device page visibly activates and is more useful than the generic eight-bar page;
3. current names/values and touch emphasis agree with the actual encoder bindings;
4. the Sampler visual is tight and coherent with those semantics;
5. no previous device/page visual appears after a context change;
6. supported move works and unsupported resize/reflow fails closed rather than drifting;
7. the Push visual contains no ordinary mouse pointer/hover contamination;
8. the selected attached-mode capture does not make normal Bitwig window controls unusable;
9. controls, MPE, transport, audio and headphones remain normal;
10. deterministic routing, gating and renderer behavior are committed tests;
11. exact official DrivenByMoss rollback passes.

## Explicit non-goals

V4 does not implement:

- automatic Sampler landmark/anchor resolution;
- touch-driven camera zoom;
- multi-touch bounding-box framing;
- start/end/loop marker task views;
- sliced-Sampler task views;
- Browser redesign;
- Polymer or other device support;
- macros, modulators or arbitrary plug-ins;
- Linux capture;
- a public adapter SDK;
- an external raster protocol redesign.

These are subsequent product capabilities using the same operating model.

## Stable boundaries

- Bitwig remains the DAW and audio-engine authority.
- DrivenByMoss remains controller-semantic authority and sole Push USB display writer.
- The helper owns platform capture and helper-local pixel processing.
- Existing good DrivenByMoss screens are preserved by default.
- Wrong, stale, unsupported or ambiguous visual state falls back to current semantics.
- The device-aware operating model is shared design vocabulary, not another instruction hierarchy.
