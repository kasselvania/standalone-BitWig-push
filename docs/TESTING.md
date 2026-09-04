# Testing

Pushwig uses deterministic tests, real process integration, physical fixture work, and retained evidence. These support one another but are not interchangeable.

## Local iteration is not a published claim

Engineers may use local branches/worktrees, experimental commits, temporary harnesses, generated fixtures, and targeted tests while learning or correcting an implementation. Such work may be amended, squashed, or discarded.

A local green result is not an accepted repository claim. The owning issue defines when an implementation is mature enough to publish as a mergeable PR.

## Verification sequence

Order work from cheapest and most controlled to most expensive and physical.

### 1. Fixture custody and baseline

When a slice installs a DrivenByMoss derivative or creates private runtime state, preserve exact custody:

- maintainer-confirmed save/quit boundary;
- exact application, audio-engine, and listener state;
- sole scanned extension and artifact hashes;
- capability/runtime-file cleanup;
- ordinary official-artifact launch and physical confirmation;
- exact final rollback.

Recovery from a failed session is not new implementation evidence. A baseline mismatch stops the work; a clean baseline does not need a recurring approval ceremony.

### 2. Targeted deterministic contracts

Commit repeatable tests for changed stable behavior. Examples include:

- configuration and initial observation;
- capability/rendezvous permissions and atomic lifecycle;
- stale-session refusal and failure cleanup;
- protocol framing and complete-message refusal;
- source-state and geometry contracts when those are actually changed.

Reuse the production owner and existing regression suites. Do not create a parallel frame model, fake queue, or metadata-only stand-in merely to increase test count.

### 3. Real process-to-process vertical

Exercise the actual construction sequence and boundary under test. For V5A:

```text
ordinary Bitwig launch
    -> accepted derivative
    -> exactly one receiver and current rendezvous
    -> generated producer HELLO / FRAME / CLEAR / disconnect
```

A process listing, property readback, listener, or log line is supporting evidence. None proves ordinary Bitwig usability or physical Push presentation.

This is normally an engineering checkpoint. It becomes a formal review boundary only when it reveals a material ownership or architecture change.

### 4. Physical fixture work

Every physical session is one of three classes.

#### Diagnostic

Answers one narrow question. It is explicitly non-acceptance, is counted, uses the same artifact-custody and rollback discipline, and cannot support a merged product claim.

#### Development verification

Checks a specific correction after deterministic readiness. It is counted and non-final. It must not silently broaden the product or become repeated random poking.

#### Final acceptance

Runs the complete product vertical on exact reviewed heads. It is the only physical class that supports acceptance and must include all user-visible behavior, authority-loss behavior, and relevant failure/recovery behavior.

Use the minimum safe sessions needed. Session counts are visibility and planning data, not permission tokens. A focused rerun for the same accepted design does not require a new governance cycle; scope or ownership expansion does.

### 5. Shutdown, restart, and rollback

For a live integration, these are part of final acceptance rather than a separate authority gate. Exercise the relevant idle/active states, immediate restart, authority-generation change, runtime-file cleanup, derivative removal, official-artifact restoration, and final ordinary behavior.

A feature is not accepted while the fixture remains dirty or rollback is merely planned.

## Exploratory harnesses

Temporary harnesses are appropriate for architecture research, destructive/error injection, native scheduling or memory observation, and candidate reconnaissance before product selection.

They do not become production architecture by accumulating tests. Retain a source hash and commands only when that aids audit; graduate stable changed contracts into repository tests.

## Efficient test policy

- Run the smallest affected tests while iterating.
- Run the broader affected-module suite once after the implementation is stable.
- Run unrelated repository-wide suites only when the dependency graph or release claim requires them.
- Reuse build outputs during one evidence session where lawful.
- Do not rebuild Bitwig/DrivenByMoss repeatedly to collect narrative checkpoints.
- A sandbox nonexecution is not a product PASS or FAIL; rerun only the affected command on the correct host.
- Add no queue, thread, abstraction, or test-only API solely to satisfy a benchmark or coverage number.
- Test volume follows changed risk and ownership, not a fixed numerical quota.

## Evidence

Keep one concise formal evidence document for a completed physical slice or material failed slice. Include:

- exact repository heads/trees and artifact hashes;
- changed-path and ownership summary;
- targeted tests and real process proof;
- the class and count of physical sessions;
- final acceptance rows when required;
- shutdown/restart and rollback;
- honest limitations and failed/nonexecuted claims.

Do not duplicate source code, agent narration, proprietary UI captures, capabilities, or large raw logs.

## Pull-request threshold

A mergeable implementation PR should not open until the deterministic/process product prerequisite named by the owning issue passes. The PR must separate:

- changed-contract tests;
- process-level proof;
- diagnostic/development physical observations;
- final physical acceptance, when complete;
- performance data only when the claim is performance-sensitive;
- rollback/final fixture state;
- limitations and explicit nonclaims.

Green unit tests cannot waive a missing product vertical. Evidence should be proportional to changed risk, not to the desire to make the PR look substantial.

## Current commands

Use commands defined by the owning issue for the active slice. V5A primarily changes DrivenByMoss activation/rendezvous and must reuse affected V1D-2 suites rather than expanding capture tests.

See [`../evidence/README.md`](../evidence/README.md).
