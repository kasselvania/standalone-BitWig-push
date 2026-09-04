# AGENTS.md — Maintainer and coding-agent rules

This file contains durable working rules. Human contributors should start with `README.md` and `CONTRIBUTING.md`.

## Authority

When instructions conflict:

1. current explicit maintainer instruction;
2. the owning issue and any reviewed material design decision recorded there;
3. this file;
4. `CURRENT_SLICE.md`;
5. durable architecture, protocol, testing, and branch-policy documents.

Stop on a real conflict. Do not invent another document, gate, branch, or PR to avoid making an engineering decision.

## Core product invariants

- Bitwig remains DAW/audio authority.
- DrivenByMoss remains semantic/controller authority and sole Push USB display writer.
- Visual work never blocks musical control or audio.
- Wrong, stale, partial, or ambiguously sourced visual content is worse than current semantic fallback.
- Historical composed pixels are never restoration authority.
- Platform-specific source objects remain behind their backend.
- Existing good DrivenByMoss experiences remain intact unless a specific replacement is accepted.
- Do not redistribute proprietary Bitwig/Ableton binaries, activation material, firmware, or captured UI fixtures.

## Current work

`CURRENT_SLICE.md` owns the short current-work pointer. The owning issue owns executable scope and acceptance. A durable design owns the technical model; it must not duplicate the whole issue.

V5A is active under issue #53. It repairs ordinary-launch activation and rendezvous for the existing V1D-2 receiver. Until V5A is accepted:

- do not resume failed V5 PR #52 or issue #50;
- do not cherry-pick its AVFoundation or `capture/common` work;
- do not select or implement another capture source;
- preserve the accepted V1D-2 protocol, receiver validation, fixed latest-frame store, nonblocking display adoption, semantic fallback, raster sink, and sole Push USB writer;
- treat activation, configuration, rendezvous, and their lifecycle as the open boundary.

See issue #53 and `docs/design/ordinary-launch-ingress-activation.md`.

## Cross-component decision rule

Before implementing work that crosses processes, repositories, devices, or operating-system services, write the actual construction/runtime sequence and identify the first unproved dependency.

A formal stop-and-review belongs only at:

- a safety, custody, or irreversible-state boundary;
- a material product-ownership or architecture decision;
- the final expensive fixture result that supports acceptance.

Everything else is an engineering checkpoint. Deterministic tests, local vertical proofs, ordinary corrections, and bounded reruns do not become separate authority cycles merely because they are named.

A passing component suite does not establish a passing product path. Process presence, property readback, and logs are supporting evidence, not substitutes for the user-visible claim.

Any emergency or recovery-only control must name the condition that removes it. Temporary recovery law must not silently become the default development model.

## Local iteration versus published claims

Disciplined local work is expected and allowed:

- one local implementation branch/worktree for the product vertical;
- experimental local commits;
- amend, squash, reorder, or discard before publication;
- targeted deterministic tests;
- bounded local probes and temporary harnesses;
- non-acceptance fixture diagnostics when the owning issue permits them.

Local WIP is not an accepted repository claim. It may be ugly, incomplete, or discarded while the engineer learns, provided frozen ownership and fixture-safety boundaries are respected.

Publication is the claim boundary:

- do not open a mergeable implementation PR until the owning issue's deterministic product prerequisite passes;
- a remote WIP/archive PR exists only when the maintainer explicitly requests preservation or remote review;
- never describe partial work as accepted, merge speculative production source, or use a PR chain as a substitute for one coherent product result.

See `docs/BRANCH_AND_WORKTREE_POLICY.md`.

## Physical verification

Use three explicit classes of physical work:

1. **Diagnostic** — answers one narrow question; explicitly non-acceptance.
2. **Development verification** — checks a specific correction after deterministic readiness; still non-final.
3. **Final acceptance** — runs the complete product vertical on exact reviewed heads and is the only class that can support acceptance.

Every physical session must preserve artifact custody and rollback, record what was actually exercised, and avoid silent scope expansion. Count sessions for visibility, not as tokens in a permission system. A bounded rerun for the same question does not require a new governance cycle; an ownership or scope change does.

## Tests and evidence

- Add deterministic tests only for changed stable contracts.
- Reuse existing production owners and regression suites instead of cloning architecture into test-only models.
- Run the smallest affected tests while iterating and the broader affected-module suite once the implementation is stable.
- Keep one concise formal evidence record for a completed or materially failed physical slice.
- Separate deterministic results, process proof, physical observation, and rollback in reports.
- Never commit capabilities, proprietary frames, activation data, or huge raw logs.

See `docs/TESTING.md`.

## Slice shape

A product slice must have:

- one user-visible or operational result;
- named owners and frozen invariants;
- explicit non-goals and ownership-based stop conditions;
- the smallest causal checkpoints needed to avoid building beyond an unproved prerequisite;
- one completion sentence that cannot be satisfied by proxy evidence;
- a sunset rule for temporary recovery controls.

Changed-path counts, test counts, and physical-session counts are planning signals, not substitutes for ownership analysis. Escalate when the work crosses a frozen boundary or materially expands the product, not merely because one more lawful file or rerun is necessary.

## Documentation ownership

- `CURRENT_SLICE.md` — current active-work pointer and lean checkpoint summary.
- Owning issue — executable scope, acceptance, stops, and current basis.
- `docs/ARCHITECTURE.md` — durable ownership and system boundaries.
- `docs/design/**` — durable technical design for a selected problem.
- `docs/ROADMAP.md` — product sequence and direction.
- `docs/TESTING.md` — durable verification taxonomy.
- `docs/BRANCH_AND_WORKTREE_POLICY.md` — local/remote branch and publication lifecycle.
- `evidence/**` — historical fixture facts and formal results.
- `README.md` and `docs/README.md` — onboarding and links, not duplicated execution authority.

Prefer links to copied current-state prose. A normal slice should update only the owning files whose facts actually changed.

## Branch/worktree lifecycle

Follow `docs/BRANCH_AND_WORKTREE_POLICY.md`.

- branches are temporary review transport;
- research stays local by default;
- worktrees are execution surfaces, not archives;
- verify clean/unpushed state before deletion;
- never use blind reset, clean, force quit, or bulk deletion.

## PR discipline

- Prefer one coherent implementation PR per repository that owns real changed production work.
- Prefer one reviewed substantive commit; amend before review rather than building a repair-commit ladder.
- Do not create authority, evidence-only, status-closure, and cleanup PR chains for one product vertical.
- A failed material boundary gets one concise report and a stop; it does not automatically get a preservation PR.
- Final reports must distinguish tests, process proof, physical observation, and rollback. Never promote one category into another.
