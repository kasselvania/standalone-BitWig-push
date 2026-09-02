# Documentation

This index separates public/contributor documentation from design research, historical slice dossiers, and retained evidence.

## New to Pushwig

Read these first:

1. [`../README.md`](../README.md) — what Pushwig is, what works today, and what it is not.
2. [`ARCHITECTURE.md`](ARCHITECTURE.md) — current component ownership and failure boundaries.
3. [`../CONTRIBUTING.md`](../CONTRIBUTING.md) — how to contribute.
4. [`DEVELOPMENT.md`](DEVELOPMENT.md) — build and local development setup.
5. [`TESTING.md`](TESTING.md) — committed tests versus temporary harnesses and real-hardware evidence.
6. [`ROADMAP.md`](ROADMAP.md) — product-shaped current and next milestones.

A competent developer should not need `AGENTS.md`, `CURRENT_SLICE.md`, or evidence hashes to understand the project.

## Active product design

- [`design/window-relative-visual-lens.md`](design/window-relative-visual-lens.md) — active V3 design: move from a fixed display crop to a Bitwig-window-relative visual profile that survives move, supported resize, and recreation.
- [Issue #45](https://github.com/kasselvania/standalone-BitWig-push/issues/45) — V3 product claim, acceptance, and implementation scope.

## Current durable references

- [`ARCHITECTURE.md`](ARCHITECTURE.md) — system boundaries and ownership.
- [`PROTOCOLS.md`](PROTOCOLS.md) — raster sink and external frame protocol summary.
- [`DEVELOPMENT.md`](DEVELOPMENT.md) — build/run setup.
- [`TESTING.md`](TESTING.md) — testing model.
- [`ROADMAP.md`](ROADMAP.md) — future product direction.
- [`HARDWARE.md`](HARDWARE.md) — concise appliance/internal-compute scope.
- [`BRANCH_AND_WORKTREE_POLICY.md`](BRANCH_AND_WORKTREE_POLICY.md) — repository hygiene/lifecycle.

## Maintainer / automation control files

These are intentionally outside the normal contributor reading path:

- [`../AGENTS.md`](../AGENTS.md) — coding-agent/maintainer execution rules.
- [`../CURRENT_SLICE.md`](../CURRENT_SLICE.md) — compact current-work summary.

## Design and research documents

These documents contain useful future design thinking. They are not all implemented behavior.

- [`VISUAL_PORTABILITY.md`](VISUAL_PORTABILITY.md) — long-term adaptive visual-source problem.
- [`SEMANTIC_PIXEL_ANCHOR_RESOLVER.md`](SEMANTIC_PIXEL_ANCHOR_RESOLVER.md) — unproven semantic-seeded anchor/localization hypothesis.
- [`RUNTIME_STRATEGY.md`](RUNTIME_STRATEGY.md) — historical/platform strategy; portions are superseded by V2 and current architecture.
- [`VISUAL_RESEARCH_BASIS.md`](VISUAL_RESEARCH_BASIS.md) — research references/provenance.
- [`HARDWARE_DOSSIER.md`](HARDWARE_DOSSIER.md) — detailed appliance/CM11EB hardware research.
- [`DRIVENBYMOSS_DERIVATIVE_STRATEGY.md`](DRIVENBYMOSS_DERIVATIVE_STRATEGY.md) — detailed fork/history notes; see the concise integration guide below for current contributor use.

The concise current DrivenByMoss integration guide is [`integrations/drivenbymoss.md`](integrations/drivenbymoss.md).

## Historical slice dossiers

The following files document how earlier architecture questions were researched and accepted. They remain useful history, but are **not** current onboarding or separate constitutional layers:

- `V1B_SYNTHETIC_COMPOSITION.md`
- `V1C0_DYNAMIC_RASTER_COMPOSITION.md`
- `V1C_DYNAMIC_LOCAL_COMPOSITION.md`
- `V1D0_BULK_RASTER_COMPOSITION.md`
- `V1D1_LOCAL_RASTER_COMPOSITION.md`
- `V1D20_EXTERNAL_FRAME_INGRESS.md`
- `V1D2_EXTERNAL_FRAME_INGRESS.md`
- `V2_MACOS_DISPLAY_CROP_LENS.md`

If a historical dossier contains a rule that still matters, the durable version of that rule should live in `ARCHITECTURE.md`, `PROTOCOLS.md`, `TESTING.md`, or another current document rather than requiring future contributors to reconstruct it from slice history.

## Evidence

See [`../evidence/README.md`](../evidence/README.md).

`evidence/**` contains exact experiment/fixture custody and is intentionally more detailed than the public documentation. It should be consulted when reproducing a specific accepted experiment or investigating a regression, not as the default project introduction.
