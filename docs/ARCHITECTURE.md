# Architecture

## Product thesis

Pushwig combines semantic control/state from Bitwig and DrivenByMoss with optional visual information when graphics improve a Push task. The controller remains useful when the visual source is absent, unsupported, stale, or broken.

## Four separate planes

The architecture has four planes that must not be collapsed into one success claim.

### 1. Semantic/control plane

```text
Bitwig state
    -> DrivenByMoss controller model
    -> pads / encoders / transport / ordinary Push semantics
```

Bitwig owns DAW/audio. DrivenByMoss owns Push control semantics.

### 2. Frame data plane

```text
authenticated complete producer message
    -> bounded V1D-2 receiver
    -> fixed latest-frame publication
    -> nonblocking display-thread adoption
    -> accepted opaque-BGRA raster write
    -> current semantic composition
    -> one PushUsbDisplay.send
```

This plane is proven on physical Push hardware **once activated**. It has one loopback receiver, no application frame FIFO, bounded storage, no source I/O on the display thread, and current-semantic fallback.

### 3. Activation/rendezvous plane

```text
ordinary Bitwig launch
    -> accepted DrivenByMoss derivative
    -> product enablement and receiver lifetime
    -> private session capability
    -> atomically published nonsecret rendezvous
    -> producer discovery
```

This plane is not yet proven. Historical V1D-2 evidence activated the receiver with startup JVM properties supplied through a special executable launch. That is valid fixture evidence, not an accepted end-user startup architecture.

The owner that creates/destroys the receiver must own the capability and rendezvous lifetime. A producer cannot be expected to connect before the ordinary Bitwig session has lawfully brought the receiver online.

### 4. Visual-source plane

```text
product-valid visual or generated source
    -> bounded crop / scale / opaque-BGRA production
    -> activation rendezvous
    -> V1D-2 data plane
```

The tested ScreenCaptureKit desktop-independent stream of the user's primary Bitwig window is not product-valid for ordinary attached use because macOS sharing UI obstructs normal window controls. The failed V5 slice did not select an alternative.

Therefore:

```text
proven frame data plane
    != proven ordinary activation
    != selected product frame source
```

## Current target: V5A

V5A repairs the activation/rendezvous plane without reopening the proven frame data plane or selecting a source.

Preferred ownership, subject to the required construction-lifecycle audit:

```text
persistent Pushwig enablement in the Push controller configuration
    -> extension/controller startup
    -> owner-only runtime directory
    -> random session capability file
    -> existing receiver bind
    -> atomic rendezvous publication
    -> generated producer proof
```

The rendezvous may contain protocol version, loopback port, capability-file path, session generation, and nonsecret ownership facts. It must not contain the capability value. Publication happens only after a successful bind; invalidation/removal begins before receiver authority ends.

## Device-aware presentation

After activation and source viability are proven, the product model remains:

```text
context router
semantic context
experience profile
visual resolver
semantic camera
presentation composer
source backend
```

The blocked Sampler page resumes only after both prerequisites exist. Existing track, mixer, session, transport, and performance screens remain ordinary DrivenByMoss by default.

## Attached and managed modes

### Attached

Use the user's ordinary Bitwig desktop. Activation and source mechanisms are eligible only when Bitwig remains visible, controllable, and cleanly recoverable.

### Managed

A future appliance may own a canonical Bitwig workspace and expose it independently to Pushwig and a remote full-desktop client. No compositor or remote stack is selected by V5A.

## Ownership invariants

- Bitwig owns DAW/audio.
- DrivenByMoss owns semantic Push behavior and final USB display transport.
- The DrivenByMoss/Push runtime owner controls receiver activation and session rendezvous lifetime.
- Producers own frame acquisition/generation and producer-local processing only.
- Capture/media backends never own MIDI, audio, controller state, or USB transport.
- Visual failures remove visual authority and return to current semantics.
- Platform-specific objects do not define portable semantic/device/presentation identity.
- A technically correct component does not establish a product path until ordinary launch, real interaction, shutdown, and rollback pass.

See [V5A activation design](design/ordinary-launch-ingress-activation.md), [protocols](PROTOCOLS.md), and [device-aware presentation](design/device-aware-presentation-layer.md).
