# Contributing to Pushwig

Thanks for helping build Pushwig.

The project is experimental but the core architecture is now real: a DrivenByMoss derivative owns Push control/display output, while optional helper processes can publish bounded visual frames. Contributions should make that system more useful, portable, testable, or understandable.

## Start here

Read:

1. [`README.md`](README.md)
2. [`docs/README.md`](docs/README.md)
3. [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md)
4. [`docs/DEVELOPMENT.md`](docs/DEVELOPMENT.md)
5. [`docs/TESTING.md`](docs/TESTING.md)

`AGENTS.md` and `CURRENT_SLICE.md` are maintainer/coding-agent control documents. You do not need them to evaluate the project or make an ordinary contribution unless your issue explicitly says otherwise.

## Where the code lives

- `capture/macos/**` — Pushwig's maintained macOS capture helper and Swift tests.
- [`kasselvania/DrivenByMoss`](https://github.com/kasselvania/DrivenByMoss) — the narrow controller-extension fork that owns semantic redraw, raster composition, frame ingress, and the sole Push display transport.
- `evidence/**` — retained experiment and real-hardware acceptance records, not production code.

## Issues and scope

Open or join an issue before substantial work.

Prefer **meaningful product-sized changes** over micro-slices. A good PR should deliver a user-visible capability, remove an important limitation, improve portability/reliability, or make the project materially easier to build and use.

Do not bundle unrelated cleanup with risky protocol, capture, hardware, or controller changes.

## Branches and worktrees

Follow [`docs/BRANCH_AND_WORKTREE_POLICY.md`](docs/BRANCH_AND_WORKTREE_POLICY.md).

The short version:

- branches are temporary review transport, not historical archives;
- use one branch for one PR role;
- research stays local unless there is a specific reason to push it;
- merged branches are deleted after merge;
- closed-unmerged branches are deleted unless explicitly quarantined;
- worktrees are temporary execution surfaces and must be clean before removal.

Do not create new `codex/*`, `status/*`, `docs/*`, or `bootstrap/*` branch families for ordinary work.

## Testing

Stable deterministic behavior belongs in committed tests whenever practical.

For the macOS helper:

```bash
cd capture/macos
xcrun swift test
```

See [`docs/TESTING.md`](docs/TESTING.md) for the distinction between:

- committed regression tests;
- temporary exploratory harnesses;
- retained real-hardware/experiment evidence.

A SHA for a temporary harness can be useful during research, but it is not a substitute for a repeatable repository test once the behavior becomes a stable product contract.

## Pull requests

A useful PR explains:

- what changes for a user or contributor;
- the issue it addresses;
- the branch role and base;
- the important ownership/failure implications;
- tests run;
- real Push/Bitwig checks, if the claim depends on hardware;
- any evidence retained beyond the committed tests;
- branch/worktree cleanup eligibility after merge.

Production code PRs should normally use a true merge commit when preserving the exact reviewed source head matters. Documentation/evidence-only PRs may be squash merged. Rebase merge is not used for governed project work.

## Real-device claims

If a change claims that something works on Push or inside Bitwig, make the observation reproducible enough to distinguish fact from assumption. Depending on the change, that can include:

- software and device versions;
- test commands and exit status;
- exact configuration;
- timing/counter summaries;
- concise manual acceptance notes;
- failure and rollback behavior.

Do not commit activation data, credentials, serial numbers, private network details, capability tokens, proprietary firmware/binaries, or proprietary UI frame captures used only as test evidence.

## Third-party code and licensing

Keep provenance clear when working with DrivenByMoss or other upstream projects:

- preserve copyright/license notices;
- document important upstream revisions;
- prefer small upstreamable patches where practical;
- do not copy third-party code into original-code areas without verifying license compatibility.

## Hardware work

Hardware experiments are optional project tracks and should be treated as a separate safety domain. Measure voltage/ground/source-sink behavior before connecting power, use current limiting where appropriate, and do not infer high-current rail behavior from connector position alone.

See [`docs/HARDWARE.md`](docs/HARDWARE.md) for scope and links to the detailed research dossier.
