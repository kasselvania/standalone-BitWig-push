# AGENTS.md — Maintainer and coding-agent rules

This file is for maintainers and coding agents executing governed repository work. It is **not** the public onboarding document. Human contributors should start with `README.md` and `CONTRIBUTING.md`.

## Authority

When instructions conflict, use this order:

1. the maintainer's current explicit instruction;
2. the owning issue / reviewed PR scope;
3. this file;
4. `CURRENT_SLICE.md` when an implementation slice is active;
5. the relevant durable design/protocol document.

Stop and surface real conflicts. Do not create additional governance layers merely to avoid making an engineering decision.

## Core invariants

- Bitwig remains the DAW/audio-engine authority.
- DrivenByMoss remains the semantic controller authority through the current architecture.
- Exactly one component owns the Push USB display endpoint in steady state.
- Visual capture is optional; musical control and audio never wait for it.
- The capture helper never owns Push MIDI, audio, bitmap memory, or USB transport.
- The external frame path is complete-frame, bounded, latest-frame oriented, and fails back to current semantic output.
- Historical composed pixels are never restoration authority.
- Wrong visual content is worse than semantic-only fallback.
- Platform-specific capture objects stay inside their platform helper/backend.
- Do not redistribute proprietary Bitwig/Ableton binaries, activation material, firmware, or committed proprietary UI frame fixtures.

## Work should be product-shaped

The V1 series deliberately used small experimental slices to settle dangerous ownership, memory, and cross-process questions. Those foundations are now established.

Do **not** create a new slice just to prove one obvious helper call or one implementation detail.

A new implementation unit should normally do at least one of the following:

- deliver a user-visible capability;
- remove a significant product limitation;
- make installation/operation materially easier;
- add a real portability target;
- integrate a substantial component;
- close a meaningful correctness/reliability gap.

Research can still be narrow when the uncertainty itself is the blocker.

## Tests and evidence

Use committed regression tests for stable deterministic contracts whenever practical.

Temporary harnesses are appropriate for exploratory research, native instrumentation, destructive fixture work, or one-off performance diagnosis. If the behavior becomes part of the maintained product contract, graduate the useful deterministic part into repository tests instead of keeping only a harness hash.

Real-hardware evidence belongs under `evidence/**` when it cannot be represented as an automated test. Evidence should be concise, reproducible, and honest about what was not tested.

See `docs/TESTING.md`.

## Branch and worktree lifecycle

Follow `docs/BRANCH_AND_WORKTREE_POLICY.md`.

Key rules:

- branches are temporary review transport;
- durable authority is merged history, docs, issues/PRs, and retained evidence;
- use role-oriented names such as `source/*`, `evidence/*`, `authority/*`, `research/*`, or a meaningful component prefix such as `capture/*` / `pushwig/*`;
- do not create new `codex/*`, `status/*`, `docs/*`, or `bootstrap/*` branch families;
- research stays local by default;
- merged branches are cleanup-eligible immediately;
- quarantines require an issue, exact SHA, owner, reason, and expiry;
- worktrees are not archives.

Before deleting a worktree, verify it is clean and contains no unpushed/unique work. Never use blind `git clean`, `reset --hard`, or bulk worktree deletion as a cleanup shortcut.

## PR and merge discipline

- One PR should have one primary product/maintenance claim.
- Production source PRs normally use true merge commits when preserving the exact reviewed source head is useful.
- Authority/documentation/evidence-only PRs may use squash merge.
- Rebase merge is not used for governed work.
- After merge, delete the remote feature branch when safe and report local cleanup eligibility.
- Do not preserve completed work by inventing archive branches.
- Keep fixture evidence proportional to the claim; do not recreate the V1 multi-file evidence pattern without a real need.

## Final report expectations

For implementation work, report:

- issue/PR;
- branch and base;
- final head/tree;
- changed paths;
- tests and real-fixture results that matter;
- important limitations;
- rollback/failure state when relevant;
- `git worktree list --porcelain` for worktrees the task created;
- clean/dirty status of those worktrees;
- branches/worktrees eligible for cleanup.

Do not turn the final report into a transcript of every command or a restatement of all project governance.

## Current project state

The project has accepted:

- current-semantic visual restoration;
- a validated opaque-BGRA raster sink in the DrivenByMoss fork;
- authenticated bounded external latest-frame ingress;
- a maintained macOS ScreenCaptureKit helper that displays real Bitwig pixels on a physical Push 3 Controller;
- a schema-v1 Bitwig-window-relative visual profile that survives ordinary move, supported resize, source loss, and window recreation;
- explicit helper-local cropping and scaling for single-window capture, proven by committed tests and a generated native crop fixture.

V3 is accepted under issue #45 and `docs/design/window-relative-visual-lens.md`.

There is currently **no active implementation slice**. Do not open the next issue or branch until the maintainer and technical lead have agreed on the next product design. The key unresolved question is utility: how Pushwig should select, present, and interact with device-aware visuals rather than merely following a correct but device-unaware window crop.
