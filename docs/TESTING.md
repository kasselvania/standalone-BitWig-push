# Testing

Pushwig uses deterministic tests, process-level integration, physical fixture acceptance, and retained evidence. These categories support one another but are not interchangeable.

## Verification ladder

Order verification from cheapest and most controlled to most expensive and physical.

### 0. Fixture custody and recovery

When a slice installs a DrivenByMoss derivative or creates private runtime state, begin and end with exact custody:

- save/quit boundaries confirmed by the maintainer;
- exact application/audio-engine/listener state;
- sole scanned extension and artifact hashes;
- capability/runtime-file cleanup;
- ordinary official-artifact launch and physical confirmation.

Do not mix recovery from a failed session with new implementation testing.

### 1. Targeted deterministic contracts

Commit repeatable tests for changed stable behavior. Examples include:

- configuration parsing and observation;
- capability/rendezvous permissions and atomic lifecycle;
- stale-session refusal and failure cleanup;
- protocol framing and complete-message refusal;
- crop/profile validation and source-state transitions;
- latest-frame behavior already owned by the existing data plane.

Do not create a parallel frame model, fake queue, or metadata-only stand-in merely to increase test count. Reuse the production owner and existing regression suite.

### 2. Real process-to-process vertical proof

Exercise the actual construction sequence and boundary under test. For V5A this means:

```text
ordinary Bitwig launch
    -> accepted derivative
    -> one receiver + current rendezvous
    -> generated producer HELLO / FRAME / CLEAR / disconnect
```

A process listing, property readback, listener, or log line is supporting evidence. None proves that Bitwig is ordinarily usable or that pixels reached Push.

### 3. Physical Push acceptance

Some claims require direct maintainer observation:

- coherent pixels on the physical Push;
- pads, pressure/MPE, encoders, transport, and representative modes;
- Push audio/headphones;
- ordinary Bitwig controls and window behavior;
- semantic restoration and absence of residue;
- normal quit without force or hidden error loops.

Use one bounded smoke session after deterministic proof and one formal acceptance session. Do not use repeated physical sessions as the primary debugging loop.

### 4. Shutdown, restart, and rollback

Prove the relevant idle/active/partial states, immediate restart, authority generation change, runtime-file cleanup, derivative removal, official-artifact restoration, and final ordinary behavior.

A feature is not accepted while the fixture remains dirty or rollback is merely planned.

## Exploratory harnesses

Temporary harnesses are appropriate for architecture research, destructive/error injection, native scheduling/memory observation, or candidate reconnaissance before product selection.

They do not become production architecture by accumulating tests. Retain a source hash and commands only when that aids audit; graduate stable changed contracts into repository tests.

## Efficient test policy

- Run the smallest affected tests while iterating.
- Run the broader affected-module suite once after the implementation is stable.
- Run unrelated repository-wide suites only when the dependency graph or release claim requires them.
- Reuse build outputs during one evidence session where lawful.
- Do not rebuild Bitwig/DrivenByMoss repeatedly to collect narrative checkpoints.
- A sandbox nonexecution is not a product PASS or FAIL; rerun only the affected command on the correct host.
- Add no queue, thread, abstraction, or test-only API solely to satisfy a benchmark or coverage number.

## Evidence budget

Keep one concise evidence document for a formal physical slice or a material failed slice. It should include:

- exact repository heads/trees and artifact hashes;
- changed-path and ownership summary;
- exact targeted tests and process proof;
- physical acceptance rows when required;
- shutdown/restart and rollback;
- honest limitations and failed/nonexecuted claims.

Do not duplicate source code, agent narration, proprietary UI captures, tokens, or large raw logs.

## Pull-request gates

An implementation PR should not open until the deterministic vertical gate passes. A PR must state separately:

- changed-contract tests;
- process-level proof;
- physical observations;
- performance data only when the claim is performance-sensitive;
- rollback/final fixture state;
- limitations and explicit nonclaims.

Green unit tests cannot waive a missing vertical or physical gate. Evidence should be proportional to changed risk, not to the desire to make the PR look substantial.

## Current commands

For the maintained macOS helper baseline:

```bash
cd capture/macos
xcrun swift test
```

Use commands defined by the owning issue for the active slice. V5A primarily changes DrivenByMoss activation/rendezvous and must reuse the affected V1D-2 suites rather than expanding capture tests.

See [`../evidence/README.md`](../evidence/README.md).
