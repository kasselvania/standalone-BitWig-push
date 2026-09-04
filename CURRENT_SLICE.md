# Current Work — V5A ordinary Bitwig external-ingress activation

## Status

**ACTIVE — GATE 0 FIXTURE RECOVERY, THEN GATE 1 READ-ONLY DECISION**

Owning issue and executable prompt: [#53 — V5A ordinary Bitwig external-ingress activation](https://github.com/kasselvania/standalone-BitWig-push/issues/53)

Durable design: [`docs/design/ordinary-launch-ingress-activation.md`](docs/design/ordinary-launch-ingress-activation.md)

Failed predecessor: [#50 — V5 portable frame-source bakeoff](https://github.com/kasselvania/standalone-BitWig-push/issues/50), preserved by draft PR #52 and the [failure review](evidence/v5-portable-frame-source-bakeoff/failure-review.md).

Blocked product goal: [#49 — V4 Sampler device-page foundation](https://github.com/kasselvania/standalone-BitWig-push/issues/49)

## Why this slice exists

The project proved the hard external-frame data path only after Bitwig had been started through a special JVM-property fixture:

```text
complete authenticated frame
    -> fixed latest-frame publication
    -> nonblocking DrivenByMoss composition
    -> one Push USB writer
```

The project did not prove how an ordinary, fully usable Bitwig session enables that receiver or exposes its private endpoint to a producer.

V5 attempted source selection while forbidding changes to that unfinished activation boundary. It therefore reached a green component suite with no product-valid receiver to connect to. V5A repairs that prerequisite before any more capture work.

## Product result

The user launches Bitwig normally. The accepted Pushwig DrivenByMoss derivative loads, activates exactly one existing V1D-2 receiver through a supported setting/lifecycle path, publishes a private session-scoped rendezvous, accepts one deterministic generated frame, restores current semantics on CLEAR/disconnect/staleness, and quits/restarts/rolls back cleanly.

Success must not depend on JVM option environment variables, direct executable invocation, private APIs, code injection, UI automation, a new capture backend, or a second frame/USB path.

## Current authorization

### Gate 0 — fixture recovery

Before code, restore the official DrivenByMoss artifact and remove the derivative/token state left by the stopped V5 session. Confirm ordinary display, controls, Push audio/headphones, no listener/generated pixels, and normal quit.

Do not manipulate the current Bitwig session until the maintainer confirms work is safe to save and quit.

### Gate 1 — read-only lifecycle decision

Map, without editing:

- `PushConfiguration` setting registration and availability;
- Push controller/display construction order;
- V1D-2 receiver construction and shutdown;
- the narrowest lawful activation/rendezvous owner;
- runtime-file permissions, atomic publication, stale-session behavior, cleanup, changed paths, and targeted tests.

Stop for technical-lead review. Passing this gate authorizes implementation; repository access alone does not.

## Later gates

- **Gate 2:** ordinary-launch deterministic HELLO/FRAME/CLEAR/disconnect proof with one rendezvous, token, loopback listener, and receiver thread.
- **Gate 3:** one bounded physical Push smoke test and one formal acceptance session covering display, controls, and audio.
- **Gate 4:** shutdown while idle/active, immediate restart with a new generation, capability/rendezvous cleanup, derivative removal, and byte-exact official restoration.

## Frozen boundaries

Preserve the existing V1D-2 protocol, receiver data validation, fixed latest-frame ownership, nonblocking display adoption, semantic fallback, raster sink, and sole `PushUsbDisplay.send` ownership.

Activation/configuration/rendezvous is intentionally open because it is the missing product boundary.

## Strict non-goals

No capture-source bakeoff, AVFoundation, ScreenCaptureKit, common C++ frame model, crop/scale work, Sampler UI, Linux, Steam Deck, managed compositor, remote desktop, encoding, public SDK, or broad DrivenByMoss cleanup.

## Delivery controls

- no implementation PR before Gate 2 passes;
- one DrivenByMoss implementation PR;
- one central closure/evidence PR only after physical acceptance and rollback, unless central production code is genuinely required;
- one concise evidence record;
- targeted changed-contract tests plus the affected V1D-2 regression suite;
- no PR/test/status chain and no repeated whole-project rebuild loop.

## Immediate stops

Stop if ordinary launch still requires environment injection/direct execution, the setting lifecycle demands a broad refactor, secure cleanup cannot be guaranteed, the change creates another frame plane/writer/queue/receiver, the production-path budget in issue #53 is exceeded, physical behavior conflicts with logs, controls/audio regress, or exact fixture recovery fails.

V5A does not select a visual source. It earns the ordinary product ingress contract that the next source slice must use.
