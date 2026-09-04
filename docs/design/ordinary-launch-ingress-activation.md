# Ordinary-launch external-ingress activation

## Status and authority

This is the durable technical design for V5A. The executable scope, current basis, acceptance sentence, and ownership-based stops are owned by [issue #53](https://github.com/kasselvania/standalone-BitWig-push/issues/53).

V5A exists because a proven frame data plane was mistaken for a complete product service.

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

The receiver is currently constructed inside the DrivenByMoss Push display path only when startup JVM properties enable it. Formal V1D-2 evidence supplied those properties before launching Bitwig's executable.

That fixture mechanism left four product questions unanswered:

1. How does an ordinary user launch enable Pushwig?
2. Which owner creates and destroys the receiver?
3. How does an external producer discover the current endpoint and capability without exposing a secret?
4. How are crash, stale files, restart, and rollback handled?

No source implementation can complete a product vertical until these questions are answered.

## Product vertical

```text
ordinary operating-system Bitwig launch
    -> fully visible and usable Bitwig session
    -> accepted DrivenByMoss derivative
    -> supported Pushwig enablement
    -> exactly one existing V1D-2 receiver
    -> private current-session rendezvous
    -> generated frame on physical Push
    -> CLEAR/disconnect/staleness restores current semantics
    -> normal shutdown and immediate restart
    -> exact official-artifact rollback
```

The result is false if it depends on direct executable invocation, JVM option environment variables, hidden terminal startup steps, proxy evidence, or a dirty final fixture.

## Ownership

### Bitwig

Owns DAW state, audio engine, application lifecycle, and controller-extension hosting.

### DrivenByMoss Push runtime

Owns semantic/controller behavior, final Push USB display transport, construction of the external raster pipeline, and receiver shutdown. Because it owns receiver authority, it must own activation and current-session rendezvous lifetime.

### Producer

Owns generated or captured frames and producer-local processing. It discovers a current rendezvous, reads the separate private capability file, authenticates, publishes complete frames, and loses authority on CLEAR, disconnect, staleness, or session replacement.

The producer does not start Bitwig, mutate controller configuration, own the receiver, or write Push USB.

## Required construction audit

Before implementation, trace exact source and runtime order for:

- where Push settings are registered and persisted;
- when their observed values are available;
- when Push controller surfaces and `Push2Display` are constructed;
- whether enablement can be supplied as construction state rather than polled per frame;
- receiver bind success/failure reporting;
- controller/display shutdown and restart behavior;
- how multiple controller instances or disabled configuration behave.

The preferred design is a durable Pushwig enable/disable setting feeding construction. If the existing setting lifecycle cannot lawfully do that without a material ownership refactor, stop for the one pre-implementation design review. Do not smuggle activation through another global property.

## Session runtime representation

The exact platform path is selected by the construction review. The logical representation is:

```text
Pushwig runtime root (owner-only)
    current.json             # nonsecret, atomically published
    capability-<generation> # secret, regular owner-only file
```

### Capability

- 32 cryptographically random bytes represented in the existing accepted format;
- regular file with symbolic links rejected;
- owner-only access, target mode `0600` where POSIX permissions exist;
- created exclusively and never overwritten in place;
- value absent from manifest, command arguments, environment, logs, exceptions, tests, and evidence;
- zeroed in memory where practical and removed when authority ends.

### Rendezvous manifest

A versioned nonsecret schema may contain:

```text
schema_version
protocol_version
transport = ipv4-loopback
port
capability_file
session_generation
nonsecret owner/liveness facts
```

It must not contain captured data or the capability value.

### Publication order

```text
validate private runtime root
    -> handle stale unsafe entries conservatively
    -> create fresh capability exclusively
    -> start/bind the existing V1D-2 receiver
    -> write manifest to a sibling temporary file
    -> flush where practical
    -> atomic rename to current manifest
```

If any step fails, publish no current rendezvous and leave ordinary DrivenByMoss semantics usable.

### Shutdown order

```text
mark activation closing
    -> invalidate/remove current manifest
    -> begin existing receiver shutdown
    -> close sockets and prevent publication
    -> await bounded receiver exit
    -> remove capability and temporary files
    -> continue existing display/USB shutdown
```

A producer holding stale path data cannot gain authority in a later session because each session has a new capability and generation.

## State model

The activation owner should have a small explicit lifecycle, for example:

```text
DISABLED
STARTING
ACTIVE
FAILED_SEMANTIC_ONLY
CLOSING
CLOSED
```

Transitions belong to setup, construction, and shutdown owners, not to every display frame. Startup failure must be bounded and leave ordinary semantic operation intact.

Hot switching is not required. A setting may honestly require controller or Bitwig restart. The user-facing setting must say so rather than pretending live reconfiguration exists.

## Preserved data plane

V5A must not redesign:

- V1D-2 wire header and message semantics;
- capability authentication comparison;
- complete bounded staging and refusal behavior;
- fixed latest-frame store;
- display-thread `tryLock`/adoption/freshness behavior;
- `IRasterWritableBitmap` sink;
- semantic redraw/restoration;
- `PushUsbDisplay` transport and sole-writer rule.

A small constructor or factory adjustment may pass explicit activation configuration instead of reading JVM properties. That is control-plane repair only while the downstream owners and behavior remain unchanged.

## Failure behavior

At minimum, cover:

- Pushwig disabled;
- invalid or unwritable runtime root;
- unsafe existing symlink/file/permissions;
- capability creation failure;
- receiver bind collision;
- manifest publication failure after bind;
- producer absent;
- wrong or stale capability;
- CLEAR, clean disconnect, forced producer exit, and stale timeout;
- normal quit while waiting in accept;
- normal quit while receiving;
- immediate ordinary restart;
- stale prior-session remnants;
- official-artifact rollback.

Every failure preserves ordinary semantics and control/audio. Startup failure must not silently select a diagnostic visual mode.

## Lean execution model

### Checkpoint A — baseline custody

Restore and confirm the official fixture. This is a safety checkpoint. A successful exact recovery does not require a separate approval; any mismatch stops the work.

### Checkpoint B — material design decision

Map construction and choose the activation/rendezvous owner, lifecycle, runtime representation, expected changed production areas, and targeted tests. This is the only formal review before implementation.

### Checkpoint C — local implementation and deterministic vertical

After Checkpoint B approval, implement on one local DrivenByMoss branch/worktree. Iterate locally, amend or discard work, run targeted tests, and prove the ordinary-launch producer-to-receiver vertical. This is ordinary engineering. It does not require another authority cycle and it must pass before a mergeable implementation PR opens.

### Checkpoint D — final physical acceptance and rollback

Run the complete product vertical on exact reviewed heads. Physical Push behavior, controls/audio, authority-loss fallback, shutdown, immediate restart, cleanup, and byte-exact official restoration form one final acceptance boundary and one final technical review.

## Local iteration and publication

Local experimental commits, generated producers, temporary probes, deterministic tests, and focused non-final fixture checks are allowed after the relevant safety/design boundary. They may be amended, squashed, or discarded.

They are not accepted claims. A mergeable PR is the publication boundary and opens only after the deterministic/process vertical works. A remote WIP archive exists only by explicit maintainer request.

## Physical verification classes

- **Diagnostic:** narrow question, explicitly non-acceptance, counted, same custody/rollback discipline.
- **Development verification:** validates a specific correction after deterministic readiness, counted and non-final.
- **Final acceptance:** complete product claim on exact heads; only this class supports acceptance.

Use the minimum safe work necessary rather than a token budget. An unexpected result may justify a narrow rerun within the same accepted design. A new owner, product mechanism, or scope requires review.

## Completion and sunset

V5A completes only when the exact product vertical passes and the official fixture is restored.

After completion, remove V5A's recovery-specific ladder, failed-session cleanup instructions, and temporary publication restrictions from active guidance. Preserve only the durable cross-component ownership rule, local-WIP/published-claim distinction, deterministic-before-final-physical sequence, and exact live-fixture rollback requirement.
