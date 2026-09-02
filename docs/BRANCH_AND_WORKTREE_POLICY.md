# Branch and worktree policy

Branches are temporary review transport. They are not the historical record of the project.

Durable project history lives in merged commits, PRs/issues, documentation, committed tests, retained evidence, and intentional tags when a tag is genuinely useful.

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

Prefer names that describe the work's role:

```text
source/<claim>
evidence/<claim>
authority/<claim>
research/<issue>-<claim>
```

Meaningful component prefixes are also fine:

```text
capture/<claim>
pushwig/<claim>
```

Do not create new actor/history-category families such as:

```text
codex/*
status/*
docs/*
bootstrap/*
```

Those prefixes do not define a lifecycle and should not be used as archives.

## Lifecycle

### Open PR

Retain the branch while the PR is open.

### Merged PR

Delete the remote feature/evidence/authority branch after the merge is visible and the reviewed head is recorded in the PR/history.

The branch name is not needed to preserve accepted work.

### Closed without merge

Delete within 24 hours unless the work is explicitly quarantined.

### Research

Research stays local by default. Push a research branch only when another person needs the exact ref or when there is a clear review/custody reason.

A pushed research branch must have an owning issue and a planned expiry.

### Quarantine

Quarantine is exceptional. Record:

- issue;
- branch and exact SHA;
- reason it cannot merge;
- unique material worth keeping;
- owner;
- expiry date;
- final disposition.

At expiry, either delete the branch or preserve the one useful commit as an annotated tag and then delete the branch. Do not create a permanent `archive/*` branch family.

## Worktrees

A worktree is an execution surface, not an archive.

- Give each worktree one role: source, evidence, research, base-build, or observation.
- Base-build/observation worktrees should normally be detached and local-only.
- Do not push a branch merely to preserve a worktree.
- Temporary harness/build/output material belongs outside tracked worktrees when practical.
- Before removal, verify clean tracked state, inspect untracked files, and confirm there are no unpushed commits or unique artifacts.
- Never use blind `git clean`, `reset --hard`, or bulk worktree deletion as a cleanup shortcut.

## Branch budget

Ordinary central steady state should be roughly:

```text
main
+ current source branch
+ paired evidence branch when needed
+ exceptional quarantine only when justified
```

DrivenByMoss should normally have only one active Pushwig feature branch in addition to its durable branches.

If a task believes it needs several pushed branches, stop and explain why local/detached worktrees are insufficient.

## Merge method

Use the method that preserves useful history without preserving branch clutter:

```text
production source PR          -> merge commit when exact reviewed head should remain a parent
documentation/authority PR    -> squash merge
evidence-only PR              -> squash merge
rebase merge                  -> not used for governed project work
```

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

After merge, verify deletion of the remote source branch when repository settings permit automatic deletion. Local branch/worktree cleanup happens only after local clean-state verification.

## Read-only audit

Use:

```bash
scripts/branch-audit.sh
```

The script intentionally does not delete anything. Review its output before issuing exact branch/worktree removal commands.

## Emergency bypass

Direct integration to a durable branch should be exceptional. If repository tooling prevents the normal PR lifecycle and the owner explicitly authorizes a bypass, record the reason in the owning maintenance issue and keep the bypass to one auditable commit.
