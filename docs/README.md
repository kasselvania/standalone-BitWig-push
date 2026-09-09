# Documentation

## Start here

1. [`../README.md`](../README.md)
2. [`ARCHITECTURE.md`](ARCHITECTURE.md)
3. [`../CONTRIBUTING.md`](../CONTRIBUTING.md)
4. [`DEVELOPMENT.md`](DEVELOPMENT.md)
5. [`TESTING.md`](TESTING.md)
6. [`ROADMAP.md`](ROADMAP.md)

A new contributor should not need maintainer control files or evidence hashes to understand Pushwig.

## Current work and accepted activation

[`../CURRENT_SLICE.md`](../CURRENT_SLICE.md) owns the current-work pointer. V5A is accepted. [V5B / issue #57](https://github.com/kasselvania/standalone-BitWig-push/issues/57) tests one actual Mac window-acquisition candidate; the [lead source decision](research/v5b-window-source-decision.md) records the inspected backend and limitations.

- [Completed issue #53 — V5A ordinary Bitwig external-ingress activation](https://github.com/kasselvania/standalone-BitWig-push/issues/53)
- [Accepted activation guide](design/ordinary-launch-ingress-activation.md)
- [Final physical acceptance and rollback](../evidence/v5a-ordinary-ingress-activation/README.md)

The recovery ladder is retired. The guide describes the implemented setting, startup, private rendezvous and lifecycle rather than prescribing another recovery exercise.

## Failed/superseded source slice

- [Issue #50 — failed V5 frame-source bakeoff](https://github.com/kasselvania/standalone-BitWig-push/issues/50)
- [Closed PR #52 — unmerged WIP archive](https://github.com/kasselvania/standalone-BitWig-push/pull/52)
- [`design/portable-frame-source-bakeoff.md`](design/portable-frame-source-bakeoff.md)
- [`../evidence/v5-portable-frame-source-bakeoff/failure-review.md`](../evidence/v5-portable-frame-source-bakeoff/failure-review.md)

No code from PR #52 is selected. Source work needs its own explicit selection; completing V5A does not reactivate the failed slice.

## Blocked device goal

- [Issue #49 — blocked Sampler device-page foundation](https://github.com/kasselvania/standalone-BitWig-push/issues/49)
- [`design/device-aware-presentation-layer.md`](design/device-aware-presentation-layer.md)
- [`design/native-device-behavior-matrix.md`](design/native-device-behavior-matrix.md)

Ordinary ingress activation is accepted. A product-valid visual source is still missing for the Sampler page.

## Durable references

- [`ARCHITECTURE.md`](ARCHITECTURE.md)
- [`PROTOCOLS.md`](PROTOCOLS.md)
- [`RUNTIME_STRATEGY.md`](RUNTIME_STRATEGY.md)
- [`PROJECT_TRACKS.md`](PROJECT_TRACKS.md)
- [`DEVELOPMENT.md`](DEVELOPMENT.md)
- [`TESTING.md`](TESTING.md)
- [`HARDWARE.md`](HARDWARE.md)
- [`BRANCH_AND_WORKTREE_POLICY.md`](BRANCH_AND_WORKTREE_POLICY.md)
- [`integrations/drivenbymoss.md`](integrations/drivenbymoss.md)

## Future runtime/appliance design

[`design/managed-visual-workspace.md`](design/managed-visual-workspace.md) describes a future canonical Bitwig workspace with independent Push and remote-desktop consumers. It is not current implementation authority.

## Research references

- [`VISUAL_PORTABILITY.md`](VISUAL_PORTABILITY.md)
- [`SEMANTIC_PIXEL_ANCHOR_RESOLVER.md`](SEMANTIC_PIXEL_ANCHOR_RESOLVER.md)
- [`VISUAL_RESEARCH_BASIS.md`](VISUAL_RESEARCH_BASIS.md)
- [`HARDWARE_DOSSIER.md`](HARDWARE_DOSSIER.md)
- [`DRIVENBYMOSS_DERIVATIVE_STRATEGY.md`](DRIVENBYMOSS_DERIVATIVE_STRATEGY.md)

Research documents are not automatically active implementation plans.

## Evidence

See [`../evidence/README.md`](../evidence/README.md). Evidence is for audit and reproduction, not normal onboarding.
