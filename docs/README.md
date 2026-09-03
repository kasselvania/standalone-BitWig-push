# Documentation

This index separates public/contributor documentation from durable architecture, current product design, future research, historical slice dossiers, and retained evidence.

## New to Pushwig

Read these first:

1. [`../README.md`](../README.md) — what Pushwig is, what has been proven, and the current blocker.
2. [`ARCHITECTURE.md`](ARCHITECTURE.md) — current component ownership, proven downstream substrate, and unresolved visual-source operating mode.
3. [`../CONTRIBUTING.md`](../CONTRIBUTING.md) — how to contribute.
4. [`DEVELOPMENT.md`](DEVELOPMENT.md) — build and local development setup.
5. [`TESTING.md`](TESTING.md) — committed tests versus temporary harnesses and real-hardware evidence.
6. [`ROADMAP.md`](ROADMAP.md) — accepted capabilities and longer-term product direction.

A competent developer should not need `AGENTS.md`, `CURRENT_SLICE.md`, or evidence hashes to understand the project.

## Current status

There is no active implementation slice.

[V4 / issue #49](https://github.com/kasselvania/standalone-BitWig-push/issues/49) stopped before production implementation because the accepted macOS primary-window capture structure failed its required attached-desktop usability gate. The blocker evidence is retained at commit `52f6f41f4fc7285d652453a3530b9764e0295cc5`.

Read:

- [`../CURRENT_SLICE.md`](../CURRENT_SLICE.md) — concise blocked-state summary.
- [`ARCHITECTURE.md`](ARCHITECTURE.md) — distinction between the proven downstream visual substrate and unresolved product source.
- [`design/device-aware-presentation-layer.md`](design/device-aware-presentation-layer.md) — device-aware product vocabulary with source viability as prerequisite zero.

## Device and workflow catalog

- [`design/native-device-behavior-matrix.md`](design/native-device-behavior-matrix.md) — native-device × DrivenByMoss baseline, behavior families, screen/context decisions, and priorities.
- [`design/native-device-behavior-matrix.csv`](design/native-device-behavior-matrix.csv) — machine-sortable 151-device inventory.
- [`reference/manuals/README.md`](reference/manuals/README.md) — exact Bitwig/DrivenByMoss manual sources and local download workflow.
- [Issue #47](https://github.com/kasselvania/standalone-BitWig-push/issues/47) — ongoing device catalog and capability-audit work.

The catalog remains useful design work. It is not authorization to continue device-page implementation on the blocked source architecture.

## Current durable references

- [`ARCHITECTURE.md`](ARCHITECTURE.md) — system boundaries and source-mode blocker.
- [`PROTOCOLS.md`](PROTOCOLS.md) — raster sink and external frame protocol summary.
- [`DEVELOPMENT.md`](DEVELOPMENT.md) — build/run setup.
- [`TESTING.md`](TESTING.md) — testing model.
- [`ROADMAP.md`](ROADMAP.md) — longer-term product direction.
- [`HARDWARE.md`](HARDWARE.md) — concise appliance/internal-compute scope.
- [`BRANCH_AND_WORKTREE_POLICY.md`](BRANCH_AND_WORKTREE_POLICY.md) — repository hygiene/lifecycle.
- [`integrations/drivenbymoss.md`](integrations/drivenbymoss.md) — current DrivenByMoss integration guide.

## Accepted and current design references

- [`design/window-relative-visual-lens.md`](design/window-relative-visual-lens.md) — accepted V3 engineering design; not a supported attached-desktop product mode.
- [`design/device-aware-presentation-layer.md`](design/device-aware-presentation-layer.md) — current product vocabulary, paused at source viability.
- [`design/native-device-behavior-matrix.md`](design/native-device-behavior-matrix.md) — device/screen behavior catalog.

## Maintainer / automation control files

These are intentionally outside the normal contributor reading path:

- [`../AGENTS.md`](../AGENTS.md) — coding-agent/maintainer execution rules.
- [`../CURRENT_SLICE.md`](../CURRENT_SLICE.md) — compact current-work summary.

## Research references

- [`VISUAL_PORTABILITY.md`](VISUAL_PORTABILITY.md) — long-term adaptive visual-source problem.
- [`SEMANTIC_PIXEL_ANCHOR_RESOLVER.md`](SEMANTIC_PIXEL_ANCHOR_RESOLVER.md) — semantic-seeded anchor/localization hypothesis; not active while source mode is unresolved.
- [`RUNTIME_STRATEGY.md`](RUNTIME_STRATEGY.md) — historical/platform strategy.
- [`VISUAL_RESEARCH_BASIS.md`](VISUAL_RESEARCH_BASIS.md) — research references/provenance.
- [`HARDWARE_DOSSIER.md`](HARDWARE_DOSSIER.md) — detailed appliance/CM11EB hardware research.
- [`DRIVENBYMOSS_DERIVATIVE_STRATEGY.md`](DRIVENBYMOSS_DERIVATIVE_STRATEGY.md) — detailed fork/history notes.

A design or research document is not automatically an active implementation plan.

## Historical slice dossiers

These files document how earlier architecture questions were researched and accepted. They remain useful history, but are not current onboarding or separate constitutional layers:

- `V1B_SYNTHETIC_COMPOSITION.md`
- `V1C0_DYNAMIC_RASTER_COMPOSITION.md`
- `V1C_DYNAMIC_LOCAL_COMPOSITION.md`
- `V1D0_BULK_RASTER_COMPOSITION.md`
- `V1D1_LOCAL_RASTER_COMPOSITION.md`
- `V1D20_EXTERNAL_FRAME_INGRESS.md`
- `V1D2_EXTERNAL_FRAME_INGRESS.md`
- `V2_MACOS_DISPLAY_CROP_LENS.md`

If a historical dossier contains a rule that still matters, the durable version should live in `ARCHITECTURE.md`, `PROTOCOLS.md`, `TESTING.md`, or another current document.

## Evidence

See [`../evidence/README.md`](../evidence/README.md).

`evidence/**` contains exact experiment/fixture custody. Consult it when reproducing a specific experiment or investigating a regression, not as the default project introduction.
