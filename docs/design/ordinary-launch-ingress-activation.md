# Ordinary-launch external-ingress activation

## Status and authority

This is the durable technical design for V5A. The executable scope, gate order, change budget, and completion report are owned by [issue #53](https://github.com/kasselvania/standalone-BitWig-push/issues/53).

V5A exists because a proven data plane was mistaken for a complete product service.

## Problem

V1D-2 established:

```text
producer TCP message
    -> capability authentication
    -> complete bounded validation
    -> fixed latest-frame publication
    -> display-thread try-adopt
    -> opaque-BGRA raster composition
    -> one Push USB writer
```

The receiver is constructed inside the DrivenByMoss Push display path only when startup configuration enables it. Formal V1D-2 evidence delivered that configuration through JVM properties before launching Bitwig's executable.

That mechanism is useful for controlled fixture testing, but it leaves four product questions unanswered:

1. How does an ordinary user launch enable Pushwig?
2. Which owner creates and destroys the receiver?
3. How does an external producer discover the current endpoint and capability without exposing a secret?
4. How are crash, stale files, restart, and rollback handled?

No source implementation can complete a vertical Push path until these are answered.

## Product claim

The accepted result is:

```text
ordinary operating-system Bitwig launch
    -> fully visible and usable Bitwig session
    -> accepted DrivenByMoss derivative
    -> supported Pushwig enablement
    -> exactly one existing V1D-2 receiver
    -> private current-session rendezvous
    -> generated producer FRAME on physical Push
    -> CLEAR/disconnect/stale semantic fallback
    -> normal quit/restart and exact rollback
```

The result is false if it depends on direct executable invocation, JVM option environment variables, hidden manual terminal steps, or a dirty final fixture.

## Ownership

### Bitwig

Owns DAW state, audio engine, application lifecycle, and controller-extension hosting.

### DrivenByMoss Push runtime

Owns semantic/controller behavior, final Push USB display transport, construction of the external raster pipeline, and receiver shutdown. Because it owns receiver authority, it must own activation and current-session rendezvous lifetime.

### Producer

Owns generated/captured frames and producer-local processing. It discovers a current rendezvous, reads the separate private capability file, authenticates, publishes complete frames, and loses authority on CLEAR/disconnect/staleness/session replacement.

The producer does not start Bitwig, mutate controller configuration, own the receiver, or write Push USB.

## Required construction audit

Before implementation, trace exact source and runtime order for:

- where Push settings are registered and persisted;
- when their observed values are available;
- when Push controller surfaces and `Push2Display` are constructed;
- whether enablement can be supplied as construction state rather than polled per frame;
- receiver bind success/failure reporting;
- controller/display shutdown and restart behavior;
- how multiple controller instances or a disabled setting behave.

The preferred design is a durable Pushwig enable/disable setting feeding construction. If the existing setting lifecycle cannot lawfully do that without a broad refactor, stop. Do not smuggle activation through another global property.

## Session runtime representation

The exact platform path is selected in Gate 1. The logical representation is:

```text
Pushwig runtime root (owner-only)
    current.json           # nonsecret, atomically published
    capability-<generation> # secret, regular file, owner-only
```

### Capability

- 32 cryptographically random bytes represented in the existing accepted format;
- regular file, symbolic links rejected;
- owner-only access, target mode `0600` where POSIX permissions exist;
- created exclusively, never overwritten in place;
- value absent from manifest, command arguments, environment, logs, exceptions, tests, and evidence;
- zeroed in memory where practical and removed when authority ends.

### Rendezvous manifest

A versioned nonsecret schema may contain:

```text
schema_version
protocol_version
transport = ipv4-loopback
port
token_file
session_generation
owner_process_id or another nonsecret liveness hint
created_monotonic/diagnostic facts where meaningful
```

It must not contain captured data or the capability value.

### Publication order

```text
validate private runtime root
    -> remove/refuse stale unsafe entries
    -> create new capability exclusively
    -> start/bind existing V1D-2 receiver
    -> write manifest temp file
    -> flush where practical
    -> atomic rename to current manifest
```

If any step fails, publish no current rendezvous and leave ordinary DrivenByMoss semantics usable.

### Shutdown order

```text
mark activation closing
    -> invalidate/remove current manifest
    -> begin existing receiver shutdown
    -> close sockets / prevent publication
    -> await bounded receiver exit
    -> remove capability and temporary files
    -> continue existing display/USB shutdown
```

A producer holding old path data cannot gain authority in a later session because each session has a new capability and generation.

## State model

The activation owner should have a small explicit state model, for example:

```text
DISABLED
STARTING
ACTIVE
FAILED_SEMANTIC_ONLY
CLOSING
CLOSED
```

State transitions occur on setup/configuration/startup/shutdown owners, not on every display frame. Failure is bounded and leaves semantic operation intact.

Hot switching is not required. A setting may require controller/Bitwig restart if that is the narrow honest lifecycle. The UI must say so rather than pretending live reconfiguration exists.

## Preserved data plane

V5A should not redesign:

- V1D-2 wire header/message semantics;
- capability authentication comparison;
- complete bounded staging and refusal behavior;
- fixed latest-frame store;
- display-thread `tryLock`/adoption/freshness behavior;
- `IRasterWritableBitmap` sink;
- semantic redraw/restoration;
- `PushUsbDisplay` transport and sole-writer rule.

A small constructor/factory adjustment may pass explicit activation configuration instead of reading JVM properties. That is control-plane repair, provided the downstream owners remain unchanged.

## Failure behavior

At minimum, test:

- Pushwig disabled;
- invalid/unwritable runtime root;
- unsafe existing symlink/file/permissions;
- capability creation failure;
- receiver bind collision;
- manifest publication failure after bind;
- producer absent;
- wrong/stale capability;
- CLEAR, clean disconnect, forced producer exit, and stale timeout;
- normal quit while waiting in accept;
- normal quit while continuously receiving;
- immediate ordinary restart;
- stale prior-session manifest/capability remnants;
- official-artifact rollback.

Every failure must preserve ordinary semantics and control/audio. Startup failure must not silently select a lower diagnostic visual mode.

## Verification gates

### Gate 0 — recovery

Restore and physically verify the official Mac fixture before code.

### Gate 1 — lifecycle decision

Produce and review the exact construction map, runtime-file design, path budget, and tests before editing.

### Gate 2 — deterministic vertical proof

Use an ordinary Bitwig launch with all JVM option variables absent. Verify one current rendezvous/listener/receiver and run a generated producer through HELLO, FRAME, CLEAR, reconnect/restart, and negative lifecycle cases.

### Gate 3 — physical acceptance

Observe generated pixels, current-semantic restoration, ordinary Bitwig interaction, Push controls, and Push audio/headphones. Process evidence alone is insufficient.

### Gate 4 — shutdown/restart/rollback

Prove bounded cleanup, new-session authority, derivative removal, exact official restoration, and final ordinary operation.

## Efficiency controls

- Map architecture once before implementation.
- Change only the activation/rendezvous owner and tests for that contract.
- Reuse the existing protocol and V1D-2 regression suites.
- Build/test affected code while iterating; perform one final broader affected-module run.
- Use physical hardware only after deterministic proof; one smoke and one formal session.
- Retain one formal evidence document.
- Do not open an implementation PR before Gate 2 passes.

## Completion and successor

V5A is complete only after ordinary launch, generated physical-Push presentation, fallback, shutdown/restart, and exact rollback all pass on reviewed heads.

Completion does not select a capture source. It permits a later, separately reviewed source slice to target a real activation contract rather than a fixture-only listener.
