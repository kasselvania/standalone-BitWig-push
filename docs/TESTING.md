# Testing

Pushwig uses three different kinds of verification. Keeping them separate makes the project easier to understand and reproduce.

## 1. Committed regression tests

Stable deterministic product behavior should live in the repository whenever practical.

For the macOS helper:

```bash
cd capture/macos
xcrun swift test
```

Current committed tests cover strict visual-profile parsing, window/display selection, nonzero-origin window geometry, resize and capture-generation behavior, aspect mapping, BGRA normalization, protocol layout/sequence behavior, and bounded authority transitions.

As the product grows, stable deterministic contracts should continue to graduate into committed tests instead of remaining only as one-off harness evidence.

Good candidates include:

- protocol framing and refusal behavior;
- crop/profile validation;
- window-relative geometry;
- source-state transitions;
- stale/clear/reconnect behavior that can be exercised without proprietary pixels;
- repeatable compatibility bugs.

## 2. Exploratory harnesses

Temporary harnesses remain useful for:

- architecture research;
- native-memory or scheduler observation;
- destructive/error injection that would be awkward in the normal test suite;
- one-off performance diagnosis;
- testing a candidate before deciding whether it belongs in production.

A temporary harness may be retained by source hash and commands in `evidence/**` when committing it would add more scaffolding than durable value.

Once the behavior becomes a stable product contract, prefer a committed regression test for the deterministic part.

## 3. Real-hardware / experiment evidence

Some important claims cannot be reduced to unit tests:

- live pixels on a physical Push;
- actual controls, pressure/MPE, audio and headphones;
- macOS Screen Recording permission lifecycle;
- performance on a real Bitwig session;
- exact rollback after installing a derivative controller extension.

Those results live under [`../evidence/`](../evidence/) with enough environment/configuration detail to understand what was observed.

Evidence is not a second implementation and should not duplicate every line of the source.

## Testing principles

- Test behavior and contracts, not incidental implementation trivia.
- Prefer generated/synthetic pixel fixtures to committed proprietary UI images.
- Separate source delivery cadence from project processing time.
- Report failure/nonexecution honestly; do not turn resource limits into a fake PASS.
- Keep real-time/control paths free of test instrumentation after measurement.
- Do not add queues/threads merely to improve a benchmark number without a product reason.
- Preserve failure/rollback behavior when the change touches live hardware or controller-extension installation.

## Pull-request expectations

A normal PR should state:

- committed tests run;
- any temporary harness used and why it remains temporary;
- any real Push/Bitwig checks required by the claim;
- meaningful performance data if the change is latency-sensitive;
- known limitations that remain outside the PR.

A small source change does not need a scientific paper. The amount of evidence should be proportional to the risk and novelty of the change.

## Evidence index

See [`../evidence/README.md`](../evidence/README.md) for the retained historical experiment sets.
