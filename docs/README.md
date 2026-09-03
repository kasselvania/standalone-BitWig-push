# Documentation

This index separates public/contributor documentation from durable architecture, current product design, future research, historical slice dossiers and retained evidence.

## New to Pushwig

Read these first:

1. [`../README.md`](../README.md) — what Pushwig is, what works today and what it is not.
2. [`ARCHITECTURE.md`](ARCHITECTURE.md) — current component ownership and failure boundaries.
3. [`../CONTRIBUTING.md`](../CONTRIBUTING.md) — how to contribute.
4. [`DEVELOPMENT.md`](DEVELOPMENT.md) — build and local development setup.
5. [`TESTING.md`](TESTING.md) — committed tests versus temporary harnesses and real-hardware evidence.
6. [`ROADMAP.md`](ROADMAP.md) — accepted capabilities and longer-term product direction.

A competent developer should not need `AGENTS.md`, `CURRENT_SLICE.md` or evidence hashes to understand the project.

## Active product work

[V4 — Sampler device-page foundation](https://github.com/kasselvania/standalone-BitWig-push/issues/49) is the active milestone.

V4 establishes the first intentional hybrid native-device page while preserving ordinary DrivenByMoss everywhere else.

Read:

- [`design/device-aware-presentation-layer.md`](design/device-aware-presentation-layer.md) — the shared operating vocabulary for context, semantics, device experiences, visual resolution, camera behavior, composition and capture. It is not a separate authority hierarchy or roadmap.
- [`design/native-device-behavior-matrix.md`](design/native-device-behavior-matrix.md) — native-device × DrivenByMoss baseline, behavior families, screen/context decisions and priorities.
- [`design/native-device-behavior-matrix.csv`](design/native-device-behavior-matrix.csv) — machine-sortable 151-device inventory.
- [`reference/manuals/README.md`](reference/manuals/README.md) — exact Bitwig/DrivenByMoss manual sources and local download workflow.
- [Issue #47](https://github.com/kasselvania/standalone-BitWig-push/issues/47) — ongoing device catalog and capability-audit work.

## Current durable references

- [`ARCHITECTURE.md`](ARCHITECTURE.md) — system boundaries, current V3 foundation and device-aware operating layer.
- [`PROTOCOLS.md`](PROTOCOLS.md) — raster sink and external frame protocol summary.
- [`DEVELOPMENT.md`](DEVELOPMENT.md) — build/run setup.
- [`TESTING.md`](TESTING.md) — testing model.
- [`ROADMAP.md`](ROADMAP.md) — longer-term product direction.
- [`HARDWARE.md`](HARDWARE.md) — concise appliance/internal-compute scope.
- [`BRANCH_AND_WORKTREE_POLICY.md`](BRANCH_AND_WORKTREE_POLICY.md) — repository hygiene/lifecycle.
- [`integrations/drivenbymoss.md`](integrations/drivenbymoss.md) — current DrivenByMoss integration guide.

## Accepted product designs

- [`design/window-relative-visual-lens.md`](design/window-relative-visual-lens.md) — accepted V3 window-relative capture design.
- [`design/device-aware-presentation-layer.md`](design/device-aware-presentation-layer.md) — current post-V3 product operating model.
- [`design/native-device-behavior-matrix.md`](design/native-device-behavior-matrix.md) — current device/screen behavior catalog.

## Maintainer / automation control files

These are intentionally outside the normal contributor reading path:

- [`../AGENTS.md`](../AGENTS.md) — coding-agent/maintainer execution rules.
- [`../CURRENT_SLICE.md`](../CURRENT_SLICE.md) — compact active-work summary.

## Design and research references

- [`VISUAL_PORTABILITY.md`](VISUAL_PORTABILITY.md) — long-term adaptive visual-source problem.
- [`SEMANTIC_PIXEL_ANCHOR_RESOLVER.md`](SEMANTIC_PIXEL_ANCHOR_RESOLVER.md) — semantic-seeded anchor/localization hypothesis; not yet the active implementation.
- [`RUNTIME_STRATEGY.md`](RUNTIME_STRATEGY.md) — historical/platform strategy; portions are superseded by V2/V3 and current architecture.
- [`VISUAL_RESEARCH_BASIS.md`](VISUAL_RESEARCH_BASIS.md) — research references/provenance.
- [`HARDWARE_DOSSIER.md`](HARDWARE_DOSSIER.md) — detailed appliance/CM11EB hardware research.
- [`DRIVENBYMOSS_DERIVATIVE_STRATEGY.md`](DRIVENBYMOSS_DERIVATIVE_STRATEGY.md) — detailed fork/history notes.

A design or research document is not automatically an active implementation plan.

## Historical slice dossiers

These files document how earlier architecture questions were researched and accepted. They remain useful history, but are **not** current onboarding or separate constitutional layers:

- `V1B_SYNTHETIC_COMPOSITION.md`
- `V1C0_DYNAMIC_RASTER_COMPOSITION.md`
- `V1C_DYNAMIC_LOCAL_COMPOSITION.md`
- `V1D0_BULK_RASTER_COMPOSITION.md`
- `V1D1_LOCAL_RASTER_COMPOSITION.md`
- `V1D20_EXTERNAL_FRAME_INGRESS.md`
- `V1D2_EXTERNAL_FRAME_INGRESS.md`
- `V2_MACOS_DISPLAY_CROP_LENS.md`

If a historical dossier contains a rule that still matters, the durable version should live in `ARCHITECTURE.md`, `PROTOCOLS.md`, `TESTING.md` or another current document rather than requiring contributors to reconstruct it from slice history.

## Evidence

See [`../evidence/README.md`](../evidence/README.md).

`evidence/**` contains exact experiment/fixture custody and is intentionally more detailed than the public documentation. Consult it when reproducing a specific accepted experiment or investigating a regression, not as the default project introduction.
