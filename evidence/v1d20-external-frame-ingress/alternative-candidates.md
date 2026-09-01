# Alternative-candidate disposition

## Date, state, and bases

- Date: 2026-09-01 PDT.
- Machine state: accepted macOS 26.4.1 arm64 fixture.
- Central basis/tree: `5597624bd50e5ef95ecd3af82ea1816ce4facd21` / `ec016bd3174345e32f1a6d47eb061820e7a1e9b9`.
- DrivenByMoss basis/tree: `663d719207ef58ec84b4d235c43211ec5da43605` / `c4e42825d069421a44b3241349de9a7c6453a3ad`.
- Selected Candidate A head/tree: `4f00972355fcf7b5f0ead0fef3365b81850be12f` / `7202267e51d0f2613cea93d186b132a996ec14ec`.

## Candidate B: Unix-domain socket

**Not reached.** Candidate A met every correctness, ownership, lifecycle, performance, fixture, and rollback gate after its bounded same-port restart correction. Under the explicit candidate order and stopping rule, implementing Candidate B would add work without answering an unresolved requirement.

A Unix-domain socket remains a plausible future transport alternative if a production authority decision rejects a loopback TCP endpoint or requires filesystem-mediated peer identity. That would introduce socket-path ownership, permissions, stale-file cleanup, and crash recovery that this selected design does not need.

## Candidate C: memory-mapped double buffer

**Not reached.** Candidate A already proves fixed arrays, complete publication, latest-frame supersession, nonblocking display acquisition, and zero application backlog without mapped-file lifetime or cross-process memory-ordering complexity.

Candidate C would require a separate exact proof for mapping permissions, header/payload atomicity, generation fencing, producer crash cleanup, memory ordering, and stale-file custody. No Candidate A blocker justified that expansion.

## Commands and tools

The disposition follows the mandated candidate order, full deterministic harness, live fixture, performance results, and exact rollback. No Candidate B/C worktree, branch, patch, artifact, or source PR was created.

## What this proves

- Research stopped at the first decisive winner rather than implementing alternatives for completeness.
- No untested alternative is being represented as equivalent evidence.

## What this does not prove

- It does not claim TCP is universally superior to Unix-domain sockets or mapped memory.
- It does not preclude a later authority decision from evaluating another transport for a new requirement.
