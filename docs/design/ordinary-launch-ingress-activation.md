# Ordinary-launch external-ingress activation

**Accepted in V5A, September 9, 2026.** This document describes the implemented lifecycle, not a recovery procedure or active implementation order.

- [Source PR #6](https://github.com/kasselvania/DrivenByMoss/pull/6)
- [Completed issue #53](https://github.com/kasselvania/standalone-BitWig-push/issues/53)
- [Exact source, tests, final physical acceptance and rollback](../../evidence/v5a-ordinary-ingress-activation/README.md)

## Using the accepted integration

In the Push controller settings in Bitwig, select **Pushwig → External visual ingress (requires restart) → On**, then quit and relaunch Bitwig normally. Default is Off. V5A verified full application restart on the Mac/Push 3 fixture; changing the preference does not hot-switch a running receiver.

No `JAVA_TOOL_OPTIONS`, `JDK_JAVA_OPTIONS`, `_JAVA_OPTIONS`, direct executable invocation, or capture helper is needed to enable ingress. The official upstream extension does not expose this derivative-only feature.

A producer discovers `$HOME/.pushwig/runtime/external-raster-v1/current.json`, validates the private runtime and session metadata, separately reads the referenced capability file, and connects to IPv4 loopback port 45291 using unchanged V1D-2. Producers do not launch Bitwig, configure its controller, create the receiver, or write Push USB.

## Construction and activation

```text
ordinary Bitwig launch
    -> controller configuration initialized; persisted setting read once
    -> Push2Display constructed with no ingress authority
    -> complete controller setup initialization returns
    -> scheduled PushControllerSetup.startup() completes its existing work
    -> final startup hook: Push2Display.startExternalIngress()
    -> private rendezvous prepared
    -> existing V1D-2 receiver binds
    -> atomic current-manifest publication
    -> display adopts external pipeline
```

`Push2Display` remains activation, composition and shutdown owner. Before successful startup, an external request selects pass-through and keeps precedence over lower diagnostic modes. One lifecycle monitor serializes startup with shutdown; a separate frame lock publishes/uses the pipeline without performing filesystem, bind or join operations inside that frame lock.

Repeated startup never duplicates or retries activation. Shutdown-before-startup prevents late activation. Requested external ingress fixes current-semantic redraw before any external pixels can be applied. Startup failure stays semantic-only until a new display lifecycle.

## Runtime custody

```text
$HOME/.pushwig/runtime/external-raster-v1/
    owner.lock                      # retained dormant after shutdown
    current.json                    # nonsecret, atomic publication
    capability-<generation>.hex      # secret, exclusive current-session file
```

The directories are real, current-owner, 0700 directories; files are regular, current-owner, 0600 files. Symbolic links and unsafe state are refused rather than repaired. The lifetime file lock permits **one active ingress per user**, not one per controller. A second enabled instance fails semantic-only without touching the active owner's files.

Every activation generates a fresh nonsecret generation and 32 random capability bytes, encoded as 64 lowercase hexadecimal characters. The secret is created exclusively, never overwritten in place, kept out of manifests/arguments/environment/logs/evidence, and zeroed in memory where practical. Synthetic test values are not live credentials.

The bounded schema-v1 manifest contains only:

```text
schema_version
protocol_version
transport = ipv4-loopback
port
capability_file                 # validated relative basename
session_generation
owner_pid
owner_start_epoch_millis
```

The manifest is written to a private sibling temporary file, forced where supported, and renamed atomically only after bind succeeds. Atomic publication has no non-atomic fallback. Publication failure shuts down the receiver and removes this generation's files.

## Shutdown, failure and restart

```text
mark closing; prevent further activation
    -> invalidate current manifest
    -> begin existing receiver shutdown; close publication/socket authority
    -> bounded receiver join on the existing shutdown executor
    -> remove capability/temporary files; release owner lock
    -> finish existing display/USB teardown
```

Receiver termination independently revokes its rendezvous files after closing the store and sockets. The dormant lock file remains intentionally; it is not continuing authority. A new lifecycle creates a new generation and secret, so an old capability cannot authenticate to the new receiver.

Abrupt process death cannot guarantee immediate file deletion. The next owner validates known remnants while holding the lock and checks process PID/start identity. Live/ambiguous ownership or malformed/unsafe entries cause refusal, not speculative cleanup. Hostile same-user filesystem races and general power-loss recovery were not accepted by V5A.

## Preserved frame data plane

Activation supplies explicit configuration to the existing external pipeline. It does not replace:

- V1D-2 header, message types or capability comparison;
- bounded staging and complete-message validation;
- the fixed latest-frame store;
- nonblocking display-thread adoption and freshness;
- the opaque-BGRA raster sink;
- current-semantic restoration;
- the sole Push USB display writer or MIDI/audio ownership.

The accepted stale timeout is 1500 ms. CLEAR, disconnect, producer exit and stale input remove visual authority and return to current semantics.

## Verification and limits

The committed settings, rendezvous and lifecycle tests run through `scripts/test-pushwig-external-ingress-activation.sh` in the DrivenByMoss fork. That runner includes its own Java 21 package build; do not add duplicate clean/build passes merely to restate evidence. The display regression uses the real display/pipeline/receiver/store with host adapters and verifies deferred/idempotent startup, shutdown-first refusal, failure pass-through and redraw before external application.

Final physical acceptance verified normal launch, generated pixels, controls/MPE/modes/audio/headphones, authority-loss fallback, idle and active normal shutdown, fresh restart and exact official rollback. The [evidence record](../../evidence/v5a-ordinary-ingress-activation/README.md) separates those observations from deterministic and process checks.

Scope remains Mac/Push 3, restart-scoped enablement, one ingress per user and POSIX runtime custody. V5A selects no capture backend and proves neither Push 2 hardware nor endurance. The former recovery checkpoints and failed-session cleanup recipe are historical issue material, not permanent requirements for later work.
