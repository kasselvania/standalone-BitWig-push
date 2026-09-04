# Evidence index

This directory retains detailed experiment, fixture, performance, rollback, and material failure records for Pushwig milestones.

It exists so a maintainer investigating a result can answer:

- which exact source/build was tested;
- what hardware/software fixture was used;
- what failure cases were exercised;
- what timing/allocation behavior was observed;
- what physical Push checks passed or did not occur;
- how the normal DrivenByMoss environment was restored, or what cleanup remained.

Evidence is **not** the public project narrative and is not required reading for a new contributor.

## Testing versus evidence

Stable deterministic product behavior should live in committed repository tests whenever practical.

Evidence is appropriate for:

- real Push controls/audio/display observations;
- macOS permission and application-launch behavior;
- temporary native instrumentation;
- one-off candidate research;
- environment-specific performance;
- derivative install/rollback custody;
- a failed slice whose exact limit changes architecture or process.

A large test count does not convert exploratory scaffolding into accepted architecture. See [`../docs/TESTING.md`](../docs/TESTING.md).

## Major evidence sets

- `s0-macos-reference-fixture/` — initial macOS/Bitwig/Push fixture and display-path reconnaissance.
- `v1a0-drivenbymoss-build-baseline/` — reproducible DrivenByMoss fork/build/install baseline.
- `v1a-identity-frame-pipeline/` — first identity frame seam.
- `v1b-static-synthetic-overlay/` — bounded project-owned pixels.
- `v1c0-dynamic-raster-composition/` — restoration-architecture decision research.
- `v1c-dynamic-local-composition/` — current-semantic redraw and dynamic lifecycle.
- `v1d0-bulk-raster-composition/` — direct writable raster decision research.
- `v1d1-local-raster-composition/` — production raster sink.
- `v1d20-external-frame-ingress/` — external ingress architecture selection.
- `v1d2-external-frame-ingress/` — production authenticated latest-frame data plane under controlled activation.
- `v2-macos-display-crop/` — maintained macOS helper and real Bitwig pixels on Push.
- `v5-portable-frame-source-bakeoff/failure-review.md` — failed source-bakeoff/activation-premise review; no implementation selected and rollback was pending at the stop snapshot.

Each directory or document explains its own scope, acceptance status, and limitations.

## Evidence hygiene

Do not commit:

- capability tokens or credentials;
- Bitwig activation/license data;
- serial numbers or private network details;
- full proprietary UI captures solely for proof;
- generated binaries that can be rebuilt from source;
- huge raw logs when a bounded aggregate/sanitized result is sufficient;
- agent narration that does not establish a product fact.

Prefer concise metadata, hashes, generated fixtures, commands, counters, direct acceptance rows, and explicit nonclaims.
