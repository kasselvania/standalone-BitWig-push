# Current Work — V5A ordinary Bitwig external-ingress activation

## Status

**ACTIVE — CHECKPOINT A BASELINE RECOVERY, THEN CHECKPOINT B DESIGN DECISION**

Owning issue and executable scope: [#53 — V5A ordinary Bitwig external-ingress activation](https://github.com/kasselvania/standalone-BitWig-push/issues/53)

Durable design: [`docs/design/ordinary-launch-ingress-activation.md`](docs/design/ordinary-launch-ingress-activation.md)

Failed predecessor: [#50 — failed/superseded V5 frame-source bakeoff](https://github.com/kasselvania/standalone-BitWig-push/issues/50), preserved only as historical failure evidence in closed, unmerged PR #52 and [`evidence/v5-portable-frame-source-bakeoff/failure-review.md`](evidence/v5-portable-frame-source-bakeoff/failure-review.md).

Blocked product goal: [#49 — V4 Sampler device-page foundation](https://github.com/kasselvania/standalone-BitWig-push/issues/49)

## Product vertical

V5A is accepted only when an ordinary operating-system launch of Bitwig activates exactly one existing V1D-2 receiver through the supported DrivenByMoss lifecycle, publishes a private current-session rendezvous, displays a deterministic generated frame on the physical Push, restores current semantics on CLEAR, disconnect, and staleness, and completes normal shutdown, immediate restart, and byte-exact official-artifact rollback on the reviewed heads.

It does not select a frame source. It establishes the ordinary product ingress contract that later source work must use.

## Why this slice exists

V1D-2 proved the external-frame data plane once activated:

```text
complete authenticated frame
    -> fixed latest-frame publication
    -> nonblocking DrivenByMoss composition
    -> one Push USB writer
```

It did not prove normal user-facing activation, producer rendezvous, current-session capability custody, or clean shutdown/restart. Failed V5 built source machinery before that prerequisite existed. V5A repairs the missing control plane without reopening the accepted data plane.

## Lean execution checkpoints

### Checkpoint A — restore and confirm the baseline

This is a safety and fixture-custody checkpoint, not a recurring architecture review.

Restore the exact official DrivenByMoss artifact, remove abandoned derivative/runtime state, launch Bitwig normally, and confirm ordinary Push display, controls, audio/headphones, and normal quit. Stop only if identity, cleanup, or observed baseline behavior is ambiguous or wrong. A clean pass proceeds directly to Checkpoint B.

### Checkpoint B — decide activation ownership

This is the one formal pre-implementation technical review.

Read the exact DrivenByMoss construction and shutdown path. Identify when `PushConfiguration` values are available, who constructs `Push2Display`, who owns receiver lifetime, and the narrow secure capability/rendezvous lifecycle. Return the proposed changed production areas and targeted tests. Do not implement before this decision is reviewed.

### Checkpoint C — implement and prove the local vertical

This is ordinary engineering work, not another authority cycle.

After Checkpoint B approval, use one local DrivenByMoss implementation branch/worktree. Local commits, amendments, discarded probes, targeted tests, and focused development verification are allowed. Prove ordinary launch, exactly one current receiver/rendezvous, generated producer authentication, FRAME, CLEAR, disconnect/staleness, failure cleanup, and restart locally.

Do not open a mergeable implementation PR until this deterministic/process vertical passes. Passing Checkpoint C authorizes publication for review; it is not final product acceptance.

### Checkpoint D — final physical acceptance and rollback

This is the final technical review and the only acceptance boundary.

On exact reviewed heads, run the complete vertical on physical Push, verify normal Bitwig use, controls, audio/headphones, generated pixels, authority-loss fallback, shutdown while idle and active, immediate restart with new session authority, derivative removal, and byte-exact official restoration. Shutdown/restart/rollback are part of this final checkpoint, not a separate authority gate.

## Physical-session classes

- **Diagnostic:** one narrow question, explicitly non-acceptance, counted and rolled back.
- **Development verification:** checks a specific correction after deterministic readiness, counted and non-final.
- **Final acceptance:** complete product vertical on exact reviewed heads; the only physical result that supports merge/acceptance.

Use the minimum safe sessions needed. A targeted rerun within the same accepted design does not require a new governance cycle. Scope or ownership expansion does.

## Frozen boundaries

Preserve the existing V1D-2 wire protocol, capability authentication, complete-message validation, fixed latest-frame store, nonblocking display-thread adoption, semantic fallback, raster sink, shutdown safety, and sole `PushUsbDisplay.send` ownership.

Activation/configuration/rendezvous is intentionally open because it is the missing product boundary.

## Strict non-goals

No frame-source bakeoff, AVFoundation, ScreenCaptureKit, `capture/common`, crop/scale work, Sampler presentation, Linux, Steam Deck, managed compositor, remote desktop, encoding, public adapter SDK, protocol redesign, second receiver, second latest-frame store, second raster sink, or second Push writer.

## Publication and evidence

- one local implementation branch is expected;
- no implementation PR until Checkpoint C passes;
- one ordinary DrivenByMoss implementation PR;
- central changes only when the central repository genuinely owns a generated producer, formal evidence, or final current-state update;
- one concise final evidence record;
- no authority/evidence/status/cleanup PR chain.

## Sunset

When V5A is accepted, retire the V5A recovery ladder, exact failed-session cleanup instructions, and V5A-specific publication restrictions from active guidance. Retain only the durable rules: map cross-component ownership before code, distinguish local WIP from published claims, exhaust deterministic proof before final physical acceptance, preserve live-fixture custody/rollback, and accept only the complete product vertical.
