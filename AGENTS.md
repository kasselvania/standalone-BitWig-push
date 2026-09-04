# AGENTS.md — Maintainer and coding-agent rules

This file is for maintainers and coding agents. Human contributors should start with `README.md` and `CONTRIBUTING.md`.

## Authority

When instructions conflict:

1. current explicit maintainer instruction;
2. owning issue and reviewed gate decision;
3. this file;
4. `CURRENT_SLICE.md`;
5. relevant durable architecture/protocol document.

Stop on a real conflict. Do not invent a governance layer, interpretation, or extra PR to avoid an engineering decision.

## Core product invariants

- Bitwig remains DAW/audio authority.
- DrivenByMoss remains semantic/controller authority and sole Push USB display writer.
- Visual work never blocks musical control or audio.
- Wrong, stale, partial, or ambiguously sourced visual content is worse than current semantic fallback.
- Historical composed pixels are never restoration authority.
- Platform-specific source objects remain behind their backend.
- Existing good DrivenByMoss experiences remain intact unless a specific replacement is accepted.
- Do not redistribute proprietary Bitwig/Ableton binaries, activation material, firmware, or captured UI fixtures.

## Proven and unproven boundaries

V1D-2 proves the external-frame **data plane when activated**:

```text
authenticated complete message
    -> fixed latest-frame publication
    -> nonblocking display-thread adoption
    -> accepted raster writer
    -> one Push USB send
```

It does not prove a product-valid **activation and rendezvous plane**. The accepted fixture used startup JVM properties supplied by a special executable launch. Treating that fixture mechanism as an ordinary product startup path caused the failed V5 slice.

Freeze the proven invariants above. Do not freeze an unfinished activation mechanism merely because it lives beside proven code.

## Current V5A rule

V5A is **ordinary Bitwig external-ingress activation** under issue #53.

The first authorized work is fixture recovery and a read-only DrivenByMoss lifecycle decision. No capture-source implementation is authorized.

Do not:

- resume PR #52 or issue #50;
- cherry-pick its AVFoundation or `capture/common` work;
- add ScreenCaptureKit, AVFoundation, CoreGraphics, GStreamer, FFmpeg, OBS, WebRTC, Linux, Steam Deck, remote desktop, Sampler, or device-localization scope;
- activate through `JAVA_TOOL_OPTIONS`, `JDK_JAVA_OPTIONS`, `_JAVA_OPTIONS`, or direct `BitwigStudio` invocation;
- alter Push USB, audio, MIDI, raster-format, protocol-layout, or latest-frame-store ownership;
- begin implementation before the Gate 1 lifecycle decision is reviewed.

Do:

- recover and verify the official Mac fixture before code;
- map settings registration/observation, Push display construction, receiver startup, and shutdown in source;
- put product activation with the owner that can lawfully control receiver lifetime;
- use a private session-scoped capability and atomically published nonsecret rendezvous;
- prove ordinary Bitwig launch before any source work resumes;
- stop on ambiguity rather than accumulating speculative code.

See `docs/design/ordinary-launch-ingress-activation.md` and issue #53.

## Cross-component dependency rule

Before implementing a slice that crosses processes, repositories, devices, or operating-system services, write the real construction/runtime sequence and identify the first unproven dependency.

That dependency becomes the first acceptance gate. It may not be deferred until the end behind unit tests, benchmarks, abstractions, or physical-fixture churn.

A passing component suite does not establish a passing product path. Process presence, property readback, or logs do not substitute for the user-visible claim.

## Slice shape

A product slice must have:

- one user-visible or operational result;
- named owners and frozen invariants;
- a bounded production-path budget;
- explicit non-goals and stop conditions;
- a verification ladder ordered from cheap/deterministic to expensive/physical;
- one completion definition that cannot be satisfied by proxy evidence.

Do not combine broad ecosystem research, abstraction design, implementation, physical acceptance, and rollback into one unconstrained prompt.

## Tests and evidence

Add tests only for changed stable contracts. Reuse existing suites instead of cloning architecture into test-only models.

Verification order is:

1. fixture custody/recovery where live installation is involved;
2. targeted deterministic contract tests;
3. the real process-to-process vertical path;
4. one bounded physical smoke test and one formal acceptance session when required;
5. shutdown, restart, and exact rollback.

Run affected tests while iterating. Run the broader affected-module suite once the implementation is stable. Do not repeatedly rebuild the whole project for narrative evidence.

Keep one concise formal evidence document per completed or failed physical slice. Never commit tokens, proprietary frames, or huge raw logs.

## Branch/worktree lifecycle

Follow `docs/BRANCH_AND_WORKTREE_POLICY.md`.

- branches are temporary review transport;
- research stays local by default;
- worktrees are not archives;
- verify clean/unpushed state before deletion;
- no blind reset, clean, force quit, or bulk deletion.

## PR discipline

- Do not open an implementation PR before its deterministic vertical gate passes.
- Prefer one reviewed substantive commit; amend before review instead of building a repair-commit ladder.
- Do not create authority, evidence-only, status-closure, and cleanup PR chains for one slice.
- Cross-repository implementation may require one PR per repository, but each must carry real repository-owned work.
- A failed gate gets a concise issue report and stop. Open a WIP preservation PR only when the maintainer explicitly requests it.
- Final reports must distinguish tests, process proof, physical observation, and rollback. Never promote one category into another.
