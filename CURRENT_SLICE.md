# Current work

**ACTIVE — V5B: Mac window-source proof with ScreenCaptureLite**

Executable scope and acceptance: [issue #57](https://github.com/kasselvania/standalone-BitWig-push/issues/57).

Source-grounded lead decision: [candidate, actual backends and known risks](docs/research/v5b-window-source-decision.md).

## Intended result

Current pixels from an explicitly selected Bitwig window reach Push through the accepted ordinary-launch ingress while Bitwig remains normally usable. This is window acquisition, not a physical-monitor crop and not device localization.

ScreenCaptureLite at `0c5beb0e3c5e4f9e0fcc9203025a80ad5164e6a4` is selected **for this proof**, not adopted as a permanent product dependency. Its Mac window path uses deprecated CoreGraphics acquisition; build/runtime viability and desktop usability must be established before integration. The known deprecation and Linux/X11 limitations remain explicit even if the proof passes.

First exercise the minimal source locally with the official extension untouched. On success continue into the existing helper and one final Push acceptance; on failure record the concrete result in #57 and stop. These are steps inside one effort, not new authority cycles.

## Stable baseline

V5A is accepted: ordinary launch, persisted enablement, private rendezvous, generated frames, semantic fallback, shutdown/restart and exact official rollback.

- DrivenByMoss `pushwig/main`: `997158b0a4ddd932a0a985c8b74ffff1e631120f`
- Accepted source tree: `dbf3dc8d4e6d6b95a654088f85b8a183584063b7`
- [Activation guide](docs/design/ordinary-launch-ingress-activation.md)
- [V5A evidence](evidence/v5a-ordinary-ingress-activation/README.md)

No DrivenByMoss source change is part of V5B. The official installed extension is not the derivative and must not be assumed to expose ingress.

## Boundaries

macOS remains the live fixture. Linux is a source-audited continuation, not an implementation target. No ScreenCaptureKit substitution, AVFoundation monitor crop, failed-PR #52 reuse, new frame core, receiver, store, protocol, remote desktop, Sampler page or Steam Deck work.

V4/#49 remains blocked until a source is accepted. No source is accepted merely by activating this issue. The V5A recovery ladder stays retired; normal local iteration, proportionate tests and fixture custody apply.
