# Evidence index

This directory retains detailed experiment, fixture, performance, and rollback records for accepted Pushwig milestones.

It exists so a maintainer investigating a regression can answer questions such as:

- which exact source/build was tested;
- what hardware/software fixture was used;
- what failure cases were exercised;
- what timing/allocation behavior was observed;
- what physical Push checks passed;
- how the normal DrivenByMoss environment was restored afterward.

Evidence is **not** the public project narrative and is not required reading for a new contributor.

## Testing versus evidence

Stable deterministic product behavior should live in committed repository tests whenever practical.

Evidence is appropriate for things that ordinary tests cannot fully capture, including:

- real Push controls/audio/display observations;
- macOS permission behavior;
- temporary native instrumentation;
- one-off candidate research;
- environment-specific timing/resource measurements;
- exact derivative install/rollback custody.

Temporary harness hashes are useful research custody, but they should not replace committed regression tests once a behavior becomes a stable maintained contract.

See [`../docs/TESTING.md`](../docs/TESTING.md).

## Accepted evidence sets

The repository currently retains evidence for these major stages:

- `s0-macos-reference-fixture/` — initial macOS/Bitwig/Push fixture and display-path reconnaissance.
- `v1a0-drivenbymoss-build-baseline/` — reproducible DrivenByMoss fork/build/install baseline.
- `v1a-identity-frame-pipeline/` — first identity frame seam.
- `v1b-static-synthetic-overlay/` — bounded project-owned pixels.
- `v1c0-dynamic-raster-composition/` — restoration-architecture decision research.
- `v1c-dynamic-local-composition/` — current-semantic redraw and dynamic lifecycle.
- `v1d0-bulk-raster-composition/` — direct writable raster decision research.
- `v1d1-local-raster-composition/` — production raster sink.
- `v1d20-external-frame-ingress/` — external ingress architecture selection.
- `v1d2-external-frame-ingress/` — production authenticated latest-frame ingress.
- `v2-macos-display-crop/` — maintained macOS ScreenCaptureKit helper and real Bitwig Sampler pixels on Push.

Each directory explains its own scope and limitations.

## Evidence hygiene

Do not commit:

- capability tokens or credentials;
- Bitwig activation/license data;
- serial numbers or private network details;
- full proprietary UI captures solely for proof;
- generated binaries that can be rebuilt from source;
- huge raw logs when an aggregate/sanitized result is sufficient.

Prefer concise metadata, hashes, generated fixtures, commands, counters, and manual acceptance tables.
