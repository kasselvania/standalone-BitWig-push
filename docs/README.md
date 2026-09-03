# Documentation

This index separates public/contributor documentation from durable architecture, active product design, historical research, and retained evidence.

## New to Pushwig

Read these first:

1. [`../README.md`](../README.md) — what Pushwig is and what works today.
2. [`ARCHITECTURE.md`](ARCHITECTURE.md) — component/source ownership and current system shape.
3. [`../CONTRIBUTING.md`](../CONTRIBUTING.md) — how to contribute.
4. [`DEVELOPMENT.md`](DEVELOPMENT.md) — build and local development setup.
5. [`TESTING.md`](TESTING.md) — committed tests versus fixture evidence.
6. [`ROADMAP.md`](ROADMAP.md) — capability-oriented product direction.

## Active work

[V5 — Managed Bitwig workspace and PipeWire frame source](https://github.com/kasselvania/standalone-BitWig-push/issues/50) is active.

Read:

- [`design/managed-visual-workspace.md`](design/managed-visual-workspace.md) — canonical managed workspace, raw frame source, remote desktop, and portable source contract.
- [`RUNTIME_STRATEGY.md`](RUNTIME_STRATEGY.md) — attached versus managed runtimes and backend families.
- [`PROJECT_TRACKS.md`](PROJECT_TRACKS.md) — Track V software, Track A appliance, Track H internal hardware, and fixture roles.
- [`../CURRENT_SLICE.md`](../CURRENT_SLICE.md) — concise executable status.

The blocked Sampler page remains [issue #49](https://github.com/kasselvania/standalone-BitWig-push/issues/49). V5 does not silently waive its source-usability blocker.

## Device-aware product design

- [`design/device-aware-presentation-layer.md`](design/device-aware-presentation-layer.md) — context, semantic state, experience profile, resolver, camera, composer, and source-backend vocabulary.
- [`design/native-device-behavior-matrix.md`](design/native-device-behavior-matrix.md) — native-device × DrivenByMoss baseline and priorities.
- [`design/native-device-behavior-matrix.csv`](design/native-device-behavior-matrix.csv) — machine-sortable native-device inventory.
- [`reference/manuals/README.md`](reference/manuals/README.md) — pinned Bitwig/DrivenByMoss manual references.

These remain product/design references while V5 establishes a viable managed source.

## Current durable references

- [`ARCHITECTURE.md`](ARCHITECTURE.md)
- [`RUNTIME_STRATEGY.md`](RUNTIME_STRATEGY.md)
- [`PROJECT_TRACKS.md`](PROJECT_TRACKS.md)
- [`PROTOCOLS.md`](PROTOCOLS.md)
- [`DEVELOPMENT.md`](DEVELOPMENT.md)
- [`TESTING.md`](TESTING.md)
- [`ROADMAP.md`](ROADMAP.md)
- [`HARDWARE.md`](HARDWARE.md)
- [`BRANCH_AND_WORKTREE_POLICY.md`](BRANCH_AND_WORKTREE_POLICY.md)
- [`integrations/drivenbymoss.md`](integrations/drivenbymoss.md)

## Accepted and historical design documents

- [`design/window-relative-visual-lens.md`](design/window-relative-visual-lens.md) — accepted V3 engineering/source proof and its limitations.
- [`VISUAL_PORTABILITY.md`](VISUAL_PORTABILITY.md) — attached/managed visual portability and source strategy ladder.
- [`SEMANTIC_PIXEL_ANCHOR_RESOLVER.md`](SEMANTIC_PIXEL_ANCHOR_RESOLVER.md) — semantic-seeded visual localization hypothesis for later device work.
- [`MAC_FIRST_DEVELOPMENT.md`](MAC_FIRST_DEVELOPMENT.md) — historical Mac-first fixture decision; useful for understanding why macOS was an implementation order choice rather than product scope.
- [`HARDWARE_DOSSIER.md`](HARDWARE_DOSSIER.md) — detailed appliance/CM11EB hardware research.

Historical V1/V2 slice dossiers remain evidence/history, not onboarding or active authority.

## Maintainer / automation files

- [`../AGENTS.md`](../AGENTS.md) — maintainer/coding-agent execution rules.
- [`../CURRENT_SLICE.md`](../CURRENT_SLICE.md) — active work summary.

Human contributors should not need these files to understand Pushwig.

## Evidence

See [`../evidence/README.md`](../evidence/README.md).

`evidence/**` contains exact fixture/experiment custody. Consult it to reproduce a specific result or investigate a regression, not as the default project introduction.
