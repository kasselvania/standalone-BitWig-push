# Branch and worktree policy

Branches are temporary execution and review transport. They are not the historical record of the project.

Durable project history lives in merged commits, PRs/issues, documentation, committed tests, retained evidence, and intentional tags when a tag is genuinely useful.

## Local WIP and the publication boundary

Local work-in-progress is normal engineering and is explicitly allowed:

- one local implementation branch/worktree for a product vertical;
- experimental commits;
- amend, reorder, squash, or discard before publication;
- local probes, generated fixtures, and temporary harnesses;
- deterministic local tests;
- research branches that never leave the host.

Local WIP is not a repository claim. It may be incomplete and may fail while the engineer learns, provided live-fixture safety and frozen ownership boundaries are respected.

A pushed branch is transport. A mergeable PR is the product-claim boundary. Do not open one until the owning issue's publication prerequisite passes. Push a WIP/archive branch or open a draft preservation PR only when another person needs the exact ref or the maintainer explicitly requests preservation.

## Durable branches

### Central repository

```text
main
```

### DrivenByMoss fork

```text
pushwig/main
pushwig/upstream-26.4.1
```

Fork/upstream mirror branches such as `master` or `API15` are managed separately from Pushwig feature branches.

## Branch roles and names

Prefer names that describe the product or component work:

```text
pushwig/<claim>
capture/<claim>
research/<issue>-<claim>
```

Do not create actor/history-category families such as:

```text
codex/*
status/*
bootstrap/*
archive/*
```

A separate `authority/*` or `evidence/*` branch is not a normal stage of every slice. Use one only when it owns genuinely independent durable work that cannot coherently travel with the product change.

## Lifecycle

### Open PR

Retain the branch while the PR is open.

### Merged PR

Delete the remote feature branch after the merge is visible and the reviewed head is recorded in the PR/history.

### Closed without merge

Delete within 24 hours unless the work is explicitly quarantined.

### Research

Research stays local by default. Push a research branch only when another person needs the exact ref or there is a clear review/custody reason.

A pushed research branch must have an owning issue and planned expiry.

### Quarantine

Quarantine is exceptional. Record:

- issue;
- branch and exact SHA;
- reason it cannot merge;
- unique material worth keeping;
- owner;
- expiry date;
- final disposition.

At expiry, either delete the branch or preserve the one useful commit as an annotated tag and then delete the branch. Do not create a permanent archive branch family.

## Worktrees

A worktree is an execution surface, not an archive.

- Give each worktree one role: implementation, research, base-build, or observation.
- Base-build/observation worktrees should normally be detached and local-only.
- Do not push a branch merely to preserve a worktree.
- Temporary harness/build/output material belongs outside tracked worktrees when practical.
- Before removal, verify clean tracked state, inspect untracked files, and confirm there are no unpushed commits or unique artifacts.
- Never use blind `git clean`, `reset --hard`, or bulk worktree deletion as a cleanup shortcut.

## Branch budget

Ordinary central steady state should be roughly:

```text
main
+ current product branch when the central repository owns changes
+ exceptional pushed research/quarantine only when justified
```

DrivenByMoss should normally have only one active Pushwig product branch in addition to its durable branches.

If a task believes it needs several pushed branches or PRs for one product vertical, explain why one local branch and one coherent publication are insufficient.

## Merge method

Use the method that preserves useful history without preserving branch clutter:

```text
production source PR          -> merge commit when exact reviewed head should remain a parent
standalone documentation PR   -> squash merge
rebase merge                  -> not used for governed project work
```

Documentation and evidence that belong to a product result should normally travel with that repository's coherent PR rather than creating a later chain.

## PR closeout

A final task report should include:

```text
branch and base
PR state
reviewed head/tree
worktrees created
git status for those worktrees
branches/worktrees now eligible for cleanup
```

After merge, verify deletion of the remote branch when repository settings permit automatic deletion. Local branch/worktree cleanup happens only after local clean-state verification.

## Read-only audit

Use:

```bash
scripts/branch-audit.sh
```

The script intentionally does not delete anything. Review its output before issuing exact branch/worktree removal commands.

## Emergency bypass

Direct integration to a durable branch should be exceptional. If repository tooling prevents the normal PR lifecycle and the owner explicitly authorizes a bypass, record the reason in the owning maintenance issue and keep the bypass to one auditable commit.
