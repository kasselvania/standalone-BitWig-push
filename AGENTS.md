# AGENTS.md — Maintainer and coding-agent rules

This file is for maintainers and coding agents. Human contributors should start with `README.md` and `CONTRIBUTING.md`.

## Authority

When instructions conflict:

1. current explicit maintainer instruction;
2. owning issue / reviewed PR scope;
3. this file;
4. `CURRENT_SLICE.md`;
5. relevant durable design/protocol document.

Stop on real conflicts. Do not create new governance layers to avoid an engineering decision.

## Core invariants

- Bitwig remains DAW/audio authority.
- DrivenByMoss remains semantic/controller authority and sole Push USB display writer.
- Visual work never blocks musical control or audio.
- V1D-2 remains the complete bounded latest-frame sink unless a concrete blocker requires review.
- Historical composed pixels are never restoration authority.
- Wrong visual content is worse than semantic fallback.
- Platform-specific capture objects stay behind their backend.
- Existing good DrivenByMoss screens are preserved unless a specific better experience is designed.
- Do not redistribute proprietary Bitwig/Ableton binaries, activation material, firmware, or captured UI fixtures.

## Current V5 rule

V5 is a **Mac-first portable frame-source bakeoff** under issue #50.

Do not:

- move implementation to Linux or Steam Deck;
- select Weston/PipeWire merely because a managed appliance will eventually need Linux;
- treat a cross-platform framework as proof of a materially different macOS source;
- retest the rejected ScreenCaptureKit primary-window source as a new candidate;
- resume V4 Sampler work before source selection;
- add Windows scope.

Do:

- inspect actual source code for candidate macOS/Linux backends;
- include unconventional second-screen, game-streaming, remote-desktop, and direct-framebuffer projects in the audit;
- compare materially different source families on the Mac;
- require normal Bitwig controls, acceptable capture UI, clean pointer behavior, bounded raw frames, V1D-2/Push proof, and a real future Linux path;
- return a no-winner result rather than selecting the least-bad candidate.

The design vocabulary in `docs/design/portable-frame-source-bakeoff.md` supports issue #50; it is not separate execution authority.

## Product-shaped work

Do not create a slice for one obvious helper call. An implementation unit should deliver a user-visible capability, remove a major limitation, make operation materially easier, add a real portability target, integrate a substantial component, or close a meaningful reliability gap.

## Tests and evidence

Commit repeatable deterministic tests for stable contracts. Temporary harnesses are appropriate for exploratory/native instrumentation; graduate useful deterministic behavior into repository tests when it becomes maintained product behavior.

Keep real-hardware evidence concise and honest under `evidence/**`. Never commit proprietary frame captures.

## Branch/worktree lifecycle

Follow `docs/BRANCH_AND_WORKTREE_POLICY.md`.

- branches are temporary review transport;
- use role-oriented names;
- research stays local by default;
- worktrees are not archives;
- verify clean/unpushed state before deletion;
- no blind reset/clean/bulk deletion.

## PR expectations

V5 uses one central branch/PR:

```text
capture/v5-portable-frame-source-bakeoff
```

No separate authority/evidence PR. Keep candidate audit, common seam, probes/tests, selected implementation or no-winner decision, and concise evidence coherent in that PR.

Final reports should include basis/head/tree, changed paths, exact source backend findings, tests, Bitwig usability, performance, Push/control/audio result, future Linux path, limitations, rollback, and worktree cleanup eligibility.
