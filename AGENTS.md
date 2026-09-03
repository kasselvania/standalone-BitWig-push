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

The device-aware presentation operating model in `docs/design/device-aware-presentation-layer.md` is shared design vocabulary. It is not a second authority hierarchy, roadmap, or substitute for an owning issue.

## Core invariants

- Bitwig remains the DAW/audio-engine authority.
- DrivenByMoss remains the semantic controller authority through the current architecture.
- Exactly one component owns the Push USB display endpoint in steady state.
- Visual acquisition is optional; musical control and audio never wait for it.
- A source/helper never owns Push MIDI, audio, semantic parameter bindings, bitmap memory, or USB transport.
- The external frame path is complete-frame, bounded, latest-frame oriented, and fails back to current semantic output.
- Historical composed pixels are never restoration authority.
- Wrong visual content is worse than semantic-only fallback.
- Platform-specific source objects stay inside their platform backend.
- Existing good DrivenByMoss screens are preserved unless a specific Pushwig experience is intentionally better for that context.
- Current encoder binding—not encoder number alone—is semantic control identity.
- A source is not product-valid merely because it supplies correct pixels quickly; it must also preserve acceptable use of the host application.
- Do not redistribute proprietary Bitwig/Ableton binaries, activation material, firmware, or committed proprietary UI frame fixtures.

## Work should be product-shaped

The V1 series used small experimental slices to settle dangerous ownership, memory, and cross-process questions. Those downstream foundations are established.

Do **not** create a new slice just to prove one obvious helper call or one implementation detail.

A new implementation unit should normally deliver a user-visible capability, remove a significant product limitation, improve installation/operation, add a real portability target, integrate a substantial component, or close a meaningful correctness gap.

Research can be narrow when the uncertainty itself is the blocker.

## Device-aware presentation

Organize supported experiences with these concepts:

```text
context router
semantic context
experience profile
visual resolver
semantic camera
presentation composer
source backend
```

Do not collapse them into one ad hoc crop profile.

However, **source viability is prerequisite zero**. Do not build device semantics and presentation on a source mode that makes the primary Bitwig session materially unusable.

- Context determines whether Pushwig participates at all.
- DrivenByMoss provides current semantic truth and controller bindings.
- The resolver proves the visual subject and its regions.
- The camera frames a verified subject; it does not establish identity.
- The composer combines semantics and visual information intentionally.
- A source backend may be attached capture, managed capture, direct/generated visual data, or a hybrid.

Unsupported devices, pages, layouts, mappings, or source modes stay on ordinary DrivenByMoss.

## Tests and evidence

Use committed regression tests for stable deterministic contracts whenever practical.

Temporary harnesses are appropriate for exploratory research, native instrumentation, destructive fixture work, or one-off performance diagnosis. If behavior becomes part of the maintained product contract, graduate the useful deterministic part into repository tests.

Real-hardware evidence belongs under `evidence/**` when it cannot be represented as an automated test. Evidence should be concise, reproducible, and honest about what was not tested.

See `docs/TESTING.md`.

## Branch and worktree lifecycle

Follow `docs/BRANCH_AND_WORKTREE_POLICY.md`.

Key rules:

- branches are temporary review transport;
- durable authority is merged history, docs, issues/PRs, and retained evidence;
- use role-oriented names such as `source/*`, `evidence/*`, `authority/*`, `research/*`, or meaningful component prefixes;
- do not create new `codex/*`, `status/*`, `docs/*`, or `bootstrap/*` branch families;
- research stays local by default;
- merged branches are cleanup-eligible immediately;
- quarantines require an issue, exact SHA, owner, reason, and expiry;
- worktrees are not archives.

Before deleting a worktree, verify it is clean and contains no unpushed/unique work. Never use blind `git clean`, `reset --hard`, or bulk worktree deletion.

## PR and merge discipline

- One PR should have one primary product/maintenance claim.
- Production source PRs normally use true merge commits when preserving the exact reviewed source head is useful.
- Authority/documentation/evidence-only PRs may use squash merge.
- Rebase merge is not used for governed work.
- After merge, delete the remote feature branch when safe and report local cleanup eligibility.
- Do not preserve completed work by inventing archive branches.
- Keep fixture evidence proportional to the claim.

## Final report expectations

For implementation work, report:

- issue/PR;
- branch and base;
- final head/tree;
- changed paths;
- tests and real-fixture results that matter;
- important limitations;
- rollback/failure state when relevant;
- worktrees created and their clean/dirty state;
- cleanup eligibility.

Do not turn the final report into a transcript of every command or restatement of all governance.

## Current project state

The project has accepted:

- current-semantic visual restoration;
- a validated opaque-BGRA raster sink in the DrivenByMoss fork;
- authenticated bounded external latest-frame ingress;
- a maintained macOS ScreenCaptureKit helper that proved real Bitwig pixels can reach a physical Push 3 Controller;
- a schema-v1 Bitwig-window-relative visual profile and explicit helper-local crop/scale path;
- committed tests and real-hardware evidence showing low-latency, bounded capture/delivery;
- a 151-device native Bitwig × DrivenByMoss behavior catalog and pinned manual references.

The current macOS primary-window capture path is **not accepted as an end-user attached-desktop source**. On the tested fixture, macOS places a sharing badge over Bitwig's normal window controls, preventing normal minimize/full-screen access while capture is active.

V4 stopped at preflight. No V4 production source was written and no DrivenByMoss source changed.

There is currently **no active implementation slice**. Do not resume V4, relax the desktop-usability gate, or add more device/crop logic until the maintainer and technical lead select a viable visual-source operating mode.
